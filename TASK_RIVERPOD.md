# Task — Migrazione parziale a Riverpod

**Tipo:** refactor
**Priorità:** media
**Stima:** mezza giornata / 1 giornata
**Referenze:** `REVIEW.md` — sez. 5 (state globale via `findAncestorStateOfType`),
sez. 6 (`setState` ovunque), sez. 8 (`mounted` check dopo `await`).

---

## Obiettivo

Introdurre Riverpod come state management dell'app, partendo da **una
manciata di providers centralizzati** e migrando **3 screen** selezionate.
Non è una migrazione massiva: è il primo passo per dimostrare il pattern
ed eliminare il `findAncestorStateOfType` attuale + il carico DB sparso
nelle screen.

Tutto l'**auth flow resta com'è**: verrà migrato in un task successivo.

---

## Scope

### ✅ Dentro

- Aggiunta dipendenza `flutter_riverpod`.
- Nuovo file centralizzato `lib/providers/app_providers.dart` con
  **5 providers**.
- `ProviderScope` in `main.dart` + `FinQuizApp` che consuma il
  `themeModeProvider`.
- Migrazione di **3 screen** da `StatefulWidget` a `ConsumerWidget` /
  `ConsumerStatefulWidget`.

### ❌ Fuori (esplicitamente)

- Tutto `lib/screens/welcome/*` (login, register, reset password,
  security questions) — resta `StatefulWidget`.
- `lib/screens/quiz/quiz_screen.dart` — ha `Timer` + 3
  `AnimationController` + logica reviews; migrazione in un task a parte.
- `ResultScreen`, `StudyScreen` e sottoschermate, `AllCategoriesScreen`,
  `StudyTopicsListScreen` — non si toccano.
- Modelli (`lib/models/`) e `DatabaseHelper` — API invariata, non si
  tocca la firma dei metodi.
- No refactor parallelo (estrazione widget, `ThemeExtension<AppColors>`,
  immutabilità `UserModel`): sono task separati già tracciati in
  `REVIEW.md`.

---

## Dipendenze

In `pubspec.yaml` aggiungi:

```yaml
dependencies:
  flutter_riverpod: ^2.5.1
```

**Niente code-gen** in questa iterazione (no `riverpod_annotation` /
`build_runner`). Teniamo la sintassi manuale: meno moving parts, più
facile da leggere per chi legge la PR.

---

## File centralizzato dei providers

**Path:** `lib/providers/app_providers.dart`

### Regole del file

- **Unico file** che espone tutti i provider di questa iterazione —
  niente provider sparsi nelle feature.
- Ogni provider ha un commento `///` sopra che ne descrive contratto,
  dipendenze e scope (auto-dispose o global).
- Solo provider + eventuali `Notifier` minimi: **zero logica UI**.
- Import dei modelli via `../models/models.dart`, del DB via
  `../database/database_helper.dart`.

### Scheletro del file

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../database/database_helper.dart';
import '../models/models.dart';

// ─── Theme ──────────────────────────────────────────────────────────

/// Persisted ThemeMode. Reads `isDarkMode` from SharedPreferences on
/// first read; `toggle()` flips and persists.
class ThemeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    _load();
    return ThemeMode.dark; // default prima del load async
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDarkMode') ?? true;
    state = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> toggle() async {
    final next =
        state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    state = next;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', next == ThemeMode.dark);
  }
}

final themeModeProvider =
    NotifierProvider<ThemeNotifier, ThemeMode>(ThemeNotifier.new);

// ─── Current user ───────────────────────────────────────────────────

/// `userId` corrente, letto da SharedPreferences. `null` se non loggato.
final currentUserIdProvider = FutureProvider<int?>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getInt('userId');
});

/// `UserModel` corrente. `null` se non loggato.
/// Dipende da `currentUserIdProvider`.
final currentUserProvider = FutureProvider<UserModel?>((ref) async {
  final userId = await ref.watch(currentUserIdProvider.future);
  if (userId == null) return null;
  return DatabaseHelper.instance.getUser(userId);
});

// ─── Quiz results ───────────────────────────────────────────────────

/// Ultimi N risultati di un utente (default 3).
/// Family keyed sullo userId per permettere più utenti.
final recentResultsProvider =
    FutureProvider.family<List<QuizResult>, int>((ref, userId) async {
  return DatabaseHelper.instance.getRecentResults(userId, limit: 3);
});

/// Statistiche aggregate dell'utente (totalScore, avgScore,
/// bestCategory, totalTime). Stessa shape di `DatabaseHelper.getUserStats`.
final userStatsProvider =
    FutureProvider.family<Map<String, dynamic>, int>((ref, userId) async {
  return DatabaseHelper.instance.getUserStats(userId);
});
```

> **Nota sul refresh:** dopo un quiz concluso, per aggiornare
> `recentResultsProvider` e `userStatsProvider` nella screen profile,
> usare `ref.invalidate(recentResultsProvider(userId))` e
> `ref.invalidate(userStatsProvider(userId))` quando serve (es. rientrando
> in `HomeScreen` dopo un quiz).

---

## Screen da migrare

Criterio: screen che oggi fanno `setState` dopo `await DatabaseHelper…`
e **non** hanno logica animata complessa.

### 1. `lib/screens/home/home_screen.dart`

**Da:** `StatefulWidget` con `_loadData`, `_user`, `_recentResults`,
`_weeklyTestCounts`, `_loading`.
**A:** `ConsumerWidget`.

Cosa rimuovere:
- `_HomeScreenState`, `initState`, `_loadData`.
- Campi `_user`, `_recentResults`, `_weeklyTestCounts`, `_loading`.
- Import di `DatabaseHelper` (non serve più).

Cosa usare:
```dart
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return userAsync.when(
      loading: () => const _Loading(),
      error: (e, _) => _Error(message: '$e'),
      data: (user) {
        if (user == null) return const _Loading(); // oppure redirect
        final recentAsync = ref.watch(recentResultsProvider(user.id!));
        return recentAsync.when(
          loading: () => const _Loading(),
          error: (e, _) => _Error(message: '$e'),
          data: (recent) => _HomeContent(user: user, recent: recent),
        );
      },
    );
  }
}
```

**Weekly chart (`_weeklyTestCounts`):** oggi viene calcolato da una
query dedicata (`getResultsForWeek`). Due scelte valide, motiva in PR:

- **a)** Deriva i 7 counts direttamente da `recentResultsProvider`
  ampliandone il limit (semplice ma sporca la semantica del provider).
- **b)** Crea un nuovo provider locale `weeklyResultsProvider` nel
  file `app_providers.dart`:

  ```dart
  final weeklyResultsProvider =
      FutureProvider.family<List<int>, int>((ref, userId) async {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final weekStart = DateTime(monday.year, monday.month, monday.day);
    final results = await DatabaseHelper.instance
        .getResultsForWeek(userId, weekStart);
    final counts = List<int>.filled(7, 0);
    for (final r in results) {
      counts[r.completedAt.weekday - 1]++;
    }
    return counts;
  });
  ```

  **Scelta consigliata:** `(b)`. Il provider resta puro, la UI non fa
  calendar-math.

### 2. `lib/screens/profile/profile_screen.dart`

**Da:** `StatefulWidget` con `_user`, `_results`, `_stats`, `_loading`.
**A:** `ConsumerWidget`.

Pattern identico alla Home:

```dart
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    return userAsync.when(
      loading: () => const _Loading(),
      error: (e, _) => _Error(message: '$e'),
      data: (user) {
        if (user == null) return const _Loading();
        final statsAsync = ref.watch(userStatsProvider(user.id!));
        // `_results` (history) servirà un provider a parte, opzionale:
        // lo fai in questo task se rientra, altrimenti lascialo via
        // FutureBuilder temporaneo — da risolvere in un task successivo.
        return statsAsync.when(
          loading: () => const _Loading(),
          error: (e, _) => _Error(message: '$e'),
          data: (stats) => _ProfileContent(user: user, stats: stats),
        );
      },
    );
  }
}
```

Per il toggle del tema in `profile_settings_sheet.dart`, aggiorna i call-site:

```dart
// prima
onPressed: () => FinQuizApp.toggleThemeMode(context),
isDarkMode: FinQuizApp.isDarkModeEnabled(context),

// dopo
onPressed: () => ref.read(themeModeProvider.notifier).toggle(),
isDarkMode: ref.watch(themeModeProvider) == ThemeMode.dark,
```

> `_ModeSwitcherTile` dovrà diventare `ConsumerWidget` o ricevere i
> callback già preparati dalla ProfileScreen.

### 3. `lib/screens/explore_screen.dart`

**Da:** `StatefulWidget` con `_searchController`, `_searchQuery`,
`_selectedDifficulty`, `_user`.
**A:** `ConsumerStatefulWidget` (conserva `TextEditingController` e
`dispose()`).

Sostituzioni:
- Elimina `_user` + `_loadUser` + `initState.loadUser`.
- Nel `build`: `final user = ref.watch(currentUserProvider).valueOrNull;`
- `_startQuiz`: `if (user == null) return;` come prima, ma `user` viene
  dal provider.
- **Tieni** `TextEditingController _searchController` + `dispose()`.

---

## Refactor `main.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const ProviderScope(child: FinQuizApp()));
}

class FinQuizApp extends ConsumerWidget {
  const FinQuizApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp(
      title: 'FinQuiz',
      debugShowCheckedModeBanner: false,
      theme:     AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const LoadingScreen(),
    );
  }
}
```

**Cosa rimuovere da `main.dart`:**

- `_FinQuizAppState`, i metodi statici `isDarkModeEnabled` e
  `toggleThemeMode`.
- La lettura di `isDarkMode` da `SharedPreferences` dentro `main()`:
  se ne occupa `ThemeNotifier._load()`.
- La prop `isDarkMode` del costruttore di `FinQuizApp`.

**Attenzione:** ci sarà un flash sul primo frame con tema dark (default)
prima che `_load()` completi. Se è un problema accettabile, procedi
così. Alternativa: rendi `themeModeProvider` un `FutureProvider` e in
`FinQuizApp` mostra uno splash finché non arriva il valore. Per questa
iterazione la prima opzione va bene.

---

## Workflow operativo (stile Finanz)

### Branch

```bash
git checkout main
git pull --ff-only
git checkout -b refactor/riverpod-providers
```

### Commit (Conventional Commits, granularità consigliata)

```
chore: add flutter_riverpod dependency
feat(state): add centralized app_providers.dart
refactor(theme): migrate ThemeMode to themeModeProvider
refactor(home): migrate HomeScreen to ConsumerWidget
refactor(profile): migrate ProfileScreen to ConsumerWidget
refactor(explore): migrate ExploreScreen to ConsumerStatefulWidget
```

Commit atomici: ogni commit compila e passa `flutter analyze` da solo.

### Rebase su `main` prima della PR

```bash
git fetch origin
git rebase origin/main
# risolvi eventuali conflitti
git push --force-with-lease origin refactor/riverpod-providers
```

**No merge commit**: history lineare. Se hai lavorato più giorni e sono
arrivati commit su `main`, rifai il rebase prima di mettere la PR in
review.

### PR

- Titolo: `refactor: introduce Riverpod for theme + home/profile/explore state`
- Descrizione: link a questo file (`TASK_RIVERPOD.md`) + screenshot
  home/profile/explore prima/dopo (funzionalmente identiche).
- Checklist di DoD spuntata (sotto).

---

## Definition of Done

- [ ] `flutter pub get` scarica `flutter_riverpod ^2.5.1`.
- [ ] `flutter analyze` → zero nuovi errori/warning.
- [ ] `lib/providers/app_providers.dart` creato, contiene i 5 (o 6 con
      `weeklyResultsProvider`) provider elencati, con commenti `///`.
- [ ] `main.dart`: usa `ProviderScope` + `FinQuizApp` è `ConsumerWidget`.
      Rimossi `findAncestorStateOfType`, `isDarkModeEnabled`,
      `toggleThemeMode`, il costruttore `isDarkMode`.
- [ ] `HomeScreen`, `ProfileScreen`, `ExploreScreen` migrate: nessuna
      istanza di `DatabaseHelper.instance` rimane al loro interno, solo
      nei provider.
- [ ] Nessuna nuova `setState` nelle 3 screen migrate, **tranne** lo
      stato UI puro di `ExploreScreen` (search query, difficulty filter).
- [ ] Toggle tema dalla `ProfileScreen` funziona, persiste dopo kill &
      restart dell'app.
- [ ] `auth flow` non toccato: welcome/login/register/reset funzionano
      identici.
- [ ] Quiz + Result: nessun cambio comportamentale.
- [ ] Branch rebasato su `origin/main` (history lineare, no merge
      commits).
- [ ] PR ha link a `TASK_RIVERPOD.md` e checklist spuntata.

---

## Smoke test manuale

1. Login con account esistente.
2. Home: vedi hey-user + recent results + weekly chart.
3. Apri un quiz, completalo, torna in home: i totali si aggiornano
   (se non succede, hai dimenticato `ref.invalidate(recentResultsProvider(userId))`
   al ritorno dal quiz).
4. Apri Profile → Settings → cambia tema → chiudi l'app dal task
   manager → riapri: il tema deve essere quello scelto.
5. Apri Explore: user avatar caricato, search + filter funzionano.
6. Logout → torni a Welcome, nessuna regressione.

---

## Fuori scope (già accordato, non farli qui)

- Auth flow → task successivo.
- `QuizScreen` → task separato (ha animazioni + timer, richiede
  controller Riverpod più strutturato).
- Split `DatabaseHelper` in repository (`REVIEW.md`, sez. 11).
- `UserModel` immutable + `copyWith` (`REVIEW.md`, sez. 10).
- `ThemeExtension<AppColors>` (`REVIEW.md`, sez. 14).
- Estrazione `_buildXxx()` in widget separati (`REVIEW.md`, sez. 1).

---

## Default applicati

Se uno di questi default non va bene, modifica il ticket prima di
iniziare:

| Parametro      | Valore                                               |
| -------------- | ---------------------------------------------------- |
| File providers | `lib/providers/app_providers.dart` (singolo)         |
| Branch         | `refactor/riverpod-providers`                        |
| Commit style   | Conventional Commits                                 |
| Rebase policy  | `rebase on main`, `--force-with-lease`, no merge     |
| #providers     | 5 (6 se si aggiunge `weeklyResultsProvider`)         |
| #screen        | 3 (Home, Profile, Explore)                           |
| Package        | `flutter_riverpod ^2.5.1` — niente code-gen          |
