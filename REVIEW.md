# Code Review Frontend — FinanceQuiz App

**Scope:** solo frontend (widget, costruzione UI, gestione dello stato lato
screen, duplicazioni, theme, navigazione).
**Tono:** review per junior developer — per ogni problema trovi *perché*
è un problema e *come* si sistema.

---

## In due righe

L'app funziona, il theme è impostato bene, ma ci sono **tanti `_build*()`**,
**widget duplicati**, **colori hardcoded** e **dispose mancanti**. Niente di
drammatico: sono cose che, una volta che le vedi, smetti di scriverle per
sempre.

### Voti sintetici (solo frontend)

| Area                              |   Voto  | Nota in 1 riga                                                  |
| --------------------------------- | :-----: | --------------------------------------------------------------- |
| Costruzione dei widget            | **4/10** | Troppi metodi `_buildXxx()` invece di widget estratti           |
| Riusabilità componenti            | **4/10** | 5+ widget quasi identici copiati tra screen                     |
| Uso del theme                     | **5/10** | Ottima base, ma 42 `Color(0xFF…)` hardcoded la bucano           |
| Gestione stato lato screen        | **4/10** | Solo `setState`, logica e UI nello stesso `StatefulWidget`      |
| Lifecycle (dispose / mounted)     | **4/10** | 3 screen senza `dispose()`, `mounted` dimenticato dopo `await`  |
| Navigazione                       | **3/10** | `MaterialPageRoute` sparso ovunque, nessuna rotta nominata      |
| Organizzazione file / naming      | **5/10** | OK, ma `welcome_screen.dart` ha 7 `part` — si perde l'orientamento |

---

## 1. Anti-pattern: `Widget _buildXxx()` dentro la screen

**Dove:** `lib/screens/home/home_screen.dart:107-196`

```dart
SliverAppBar _buildAppBar() { ... }
Widget _buildAvatar({double size = 40}) { ... }
Widget _buildStatsRow() { ... }
Widget _buildSectionHeader(String title) => ...
Widget _buildRecentActivity() => ...
```

**Perché è un problema**

- Questi metodi non sono `const`, quindi Flutter **non può riusare** il
  widget anche se nulla è cambiato.
- Quando `_HomeScreenState` fa `setState`, tutto il ramo `_buildAppBar()`
  viene ricostruito anche se non c'entra niente.
- Non puoi spostarli né testarli: vivono dentro lo stato della screen.

**Come si fa**

Estrai ogni `_build*()` in una classe `StatelessWidget` dedicata:

```dart
class HomeAppBar extends StatelessWidget {
  final UserModel? user;
  const HomeAppBar({super.key, required this.user});

  @override
  Widget build(BuildContext context) { ... }
}
```

Passi i dati che servono via costruttore. La screen diventa:

```dart
slivers: [
  HomeAppBar(user: _user),
  SliverToBoxAdapter(child: StatsRow(user: _user)),
  ...
]
```

> Regola pratica: se un metodo ritorna `Widget`, **non è un metodo**,
> è un widget.

---

## 2. Widget duplicati

Sono *la stessa cosa* scritta due volte. Prima o poi una delle due
diverge e hai un bug di UI inspiegabile.

### 2.1 `_StatChip` ≈ `_StatCard`

- `lib/screens/home/home_stat_chip.dart:15-33`
- `lib/screens/result/result_stat_card.dart:61-78`

Stessa struttura (container con bordo colorato + icona + valore + label),
cambia solo il padding.

### 2.2 `_TestTimeCard` ≈ `_StudyTimeCard`

- `lib/screens/home/home_featured_card.dart:4-76` e `79-144`

~95% dello stesso codice. Differiscono per colore e testo.

### 2.3 Login form ≈ Register form

- `lib/screens/welcome/welcome_auth_forms.dart:36-100`
- `lib/screens/welcome/welcome_register_form.dart:29-150`

Stessa struttura: `SafeArea` → `SingleChildScrollView` → `Column` →
badge icona → titolo → `TextField` × N → `ElevatedButton`.

**Come si fa**

Un widget generico parametrizzato per i pezzi che cambiano:

```dart
class StatDisplay extends StatelessWidget {
  final String label;
  final String value;
  final String icon;
  final Color color;
  final StatVariant variant; // .chip | .card

  const StatDisplay({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.variant = StatVariant.chip,
  });
  ...
}
```

Uguale per `FeaturedCard(title, subtitle, color, icon, onTap)`: un widget,
due istanze.

---

## 3. Theme usato bene… e poi bucato

**Lato positivo:** `lib/theme/app_theme.dart` è ben strutturato e viene
importato da `main.dart` e 9 screen. Ottimo punto di partenza.

**Lato negativo:** nonostante questo, ci sono **42 `Color(0xFF…)`
hardcoded** sparsi. Esempi:

- `lib/screens/home/home_featured_card.dart:10, 24, 39, 107`
- `lib/screens/study/study_topic_tile.dart:5-7` (verde, arancio, rosso
  inventati sul momento)
- `lib/screens/study/study_screen.dart:34-37`
- `lib/screens/loading/loading_screen.dart:34, 40, 42, 125`

**Perché è un problema**

- Se vuoi un nuovo tema (brand, dark fine-tune), devi fare caccia al
  tesoro su 42 righe.
- Il dark mode non sa cosa fare con colori letterali: restano uguali in
  entrambe le modalità.

**Come si fa**

Definisci i colori semantici come `ThemeExtension` e leggili dal
`context`:

```dart
// lib/theme/app_colors.dart
class AppColors extends ThemeExtension<AppColors> {
  final Color success;
  final Color warning;
  final Color danger;
  final Color info;
  const AppColors({
    required this.success,
    required this.warning,
    required this.danger,
    required this.info,
  });
  ...
}
```

Poi nelle screen:

```dart
final colors = Theme.of(context).extension<AppColors>()!;
Container(color: colors.success.withValues(alpha: 0.12), ...);
```

Niente più `Color(0xFF4ADE80)` scritti a mano.

---

## 4. Doppio `app_theme.dart` (dead code)

Finché non l'ho segnalato c'erano **due file**:

- `/app_theme.dart` (nella root del progetto, 170 righe)
- `/lib/theme/app_theme.dart` (207 righe, quello vero)

Il primo **non era importato da nessuno**. È codice morto che confonde
chi arriva nel progetto. Tieni solo `/lib/theme/app_theme.dart`.

---

## 5. `SizedBox` per spaziatura: 212 volte

**Esempi:** `const SizedBox(height: 8)`, `const SizedBox(height: 14)`,
`const SizedBox(width: 10)` ripetuti dappertutto con numeri leggermente
diversi tra loro.

**Perché è un problema**

- La spaziatura non è coerente tra screen (8 qui, 10 là, 12 altrove).
- Se domani il design system dice "gli spacing sono 4/8/16/24", devi
  toccare 200+ righe.

**Come si fa**

Una costante sola:

```dart
// lib/theme/app_spacing.dart
class AppSpacing {
  static const xs = SizedBox(height: 4);
  static const sm = SizedBox(height: 8);
  static const md = SizedBox(height: 16);
  static const lg = SizedBox(height: 24);
  // varianti orizzontali
  static const smH = SizedBox(width: 8);
}
```

Oppure il package `gap` (`const Gap(16)`).

---

## 6. Gestione stato: `setState` ovunque + file troppo densi

### `quiz_screen.dart:24-46` — 20 variabili di stato in una sola classe

Ci sono insieme: lista domande, indice, timer, `AnimationController`
(3!), risposta selezionata, tentativi, score, hint, reviews… È un mix di
**state UI** (animazioni, timer) e **state di dominio** (score, domande).

### `welcome_screen.dart` — 314 righe + 7 `part` files

Il pattern `part of` sposta il codice in altri file ma **non lo separa
davvero**: tutte le variabili di `_WelcomeScreenState` sono accessibili
da tutti i part. Apri un editor e sembra un file da 1500 righe.

**Perché è un problema**

- Non puoi testare la logica senza montare il widget.
- Il file più lungo lo capisci bene solo tu che l'hai scritto.
- Basta un `setState` piazzato male e rebuilda metà screen.

**Come si fa (senza introdurre pacchetti)**

Separi lo "stato dei dati" in un `ChangeNotifier`:

```dart
class QuizController extends ChangeNotifier {
  List<QuizQuestion> questions = [];
  int currentIndex = 0;
  int score = 0;
  // logica pura: selectOption(), next(), finish()...
}
```

La screen si abbona con `ListenableBuilder`:

```dart
ListenableBuilder(
  listenable: _controller,
  builder: (_, __) => QuestionCard(question: _controller.current, ...),
);
```

Così:

- La logica è testabile senza `WidgetTester`.
- La screen torna a occuparsi solo di UI.
- `AnimationController` restano nello `StatefulWidget` (vivono col widget).

---

## 7. `dispose()` dimenticati → memory leak

Ogni `TextEditingController`, `AnimationController`, `Timer` o
`StreamSubscription` che crei **deve** essere chiuso in `dispose()`.
Se apri e chiudi la screen 20 volte senza `dispose`, lasci 20
controller vivi in memoria.

**Casi trovati:**

| File                                           | Cosa manca                                    |
| ---------------------------------------------- | --------------------------------------------- |
| `lib/screens/explore_screen.dart:17`           | `_searchController` mai disposto              |
| `lib/screens/home/home_screen.dart`            | nessun `dispose()` override                   |
| `lib/screens/profile/profile_screen.dart`      | nessun `dispose()` override                   |

**Come si fa**

```dart
@override
void dispose() {
  _searchController.dispose();
  super.dispose();
}
```

**Esempio fatto bene:** `lib/screens/welcome/welcome_screen.dart:167-184`
— 11 controller disposti uno per uno. Copia quel pattern.

---

## 8. `mounted` check dopo `await`

**Dove manca:**

- `lib/screens/home/home_screen.dart:_loadData()` — fa `await db.getUser(...)`
  e poi `setState(...)` senza check.
- `lib/screens/all_categories_screen.dart:35-39` — idem.
- `lib/screens/profile/profile_screen.dart:_loadData()` — idem.

**Perché è un problema**

Se l'utente naviga via mentre la query al DB sta finendo, lo
`setState` viene chiamato su un widget già smontato → Flutter lancia
un'eccezione in console (`setState called after dispose`).

**Come si fa**

```dart
Future<void> _loadData() async {
  final user = await db.getUser(userId);
  if (!mounted) return;   // ← sempre, dopo ogni await
  setState(() => _user = user);
}
```

**Esempio fatto bene:** `lib/screens/loading/loading_screen.dart:76-79`.

---

## 9. Navigazione sparsa

**Dove:** praticamente ovunque ci sia un bottone.

```dart
// home_screen.dart:82
Navigator.push(context, MaterialPageRoute(builder: (_) => const StudyScreen()))

// quiz_screen.dart:164
Navigator.pushReplacement(context, MaterialPageRoute(
  builder: (_) => ResultScreen(result: result, ...),
));

// profile_screen.dart:162
Navigator.pushAndRemoveUntil(context,
  MaterialPageRoute(builder: (_) => const WelcomeScreen()), (_) => false);
```

**Perché è un problema**

- Cambiare una rotta significa cercarla in 6+ file.
- Non c'è deep-linking (aprire l'app direttamente su una screen).
- Non puoi intercettare la navigazione (es. per analytics).

**Come si fa**

Versione minima, senza pacchetti, in `main.dart`:

```dart
MaterialApp(
  routes: {
    '/welcome': (_) => const WelcomeScreen(),
    '/home':    (_) => const MainShell(),
    '/study':   (_) => const StudyScreen(),
    ...
  },
);
```

E nelle screen:

```dart
Navigator.pushNamed(context, '/study');
```

Quando l'app cresce, passi a `go_router` che dà anche deep-link e
redirect basati su stato di login.

---

## 10. Piccolo problema di OOP che tocca la UI: `UserModel` mutabile

**Dove:** `lib/models/models.dart:99-103`

```dart
int profileIconIndex;
int totalScore;
int quizzesCompleted;
int currentStreak;
int longestStreak;
```

Sono campi **senza `final`**: qualsiasi widget può mutare un `UserModel`
già costruito. E infatti:

```dart
// lib/screens/quiz/quiz_screen.dart:159-160
user..totalScore += _score..quizzesCompleted += 1..currentStreak += 1;
if (user.currentStreak > user.longestStreak) user.longestStreak = user.currentStreak;
await db.updateUser(user);
```

**Perché è un problema lato frontend**

- Il widget sta modificando un oggetto "di dominio" in-place. Se quel
  `user` è condiviso altrove, quell'altrove vede il cambiamento a
  sorpresa.
- Non puoi usare `==` per capire se l'utente è cambiato (serve per
  `AnimatedSwitcher`, `didUpdateWidget`, ecc.).

**Come si fa**

Campi tutti `final` + `copyWith`:

```dart
final updated = user.copyWith(
  totalScore: user.totalScore + _score,
  quizzesCompleted: user.quizzesCompleted + 1,
  currentStreak: user.currentStreak + 1,
);
await db.updateUser(updated);
```

Così ogni aggiornamento è una *nuova* istanza — esplicito, predicibile,
testabile.

---

## Checklist priorità

Ordine consigliato se vuoi sistemare le cose a piccoli passi:

- [ ] **Quick win (1h):** aggiungi `dispose()` mancanti (Sez. 7) e
      `if (!mounted) return;` dopo gli `await` (Sez. 8).
- [ ] **Quick win (30 min):** cancella `/app_theme.dart` nella root
      (Sez. 4).
- [ ] **Mezza giornata:** estrai 3-4 `_buildXxx()` della home come
      `StatelessWidget` (Sez. 1).
- [ ] **Mezza giornata:** unifica `_StatChip` / `_StatCard` e
      `_TestTimeCard` / `_StudyTimeCard` (Sez. 2).
- [ ] **Mezza giornata:** `AppColors` via `ThemeExtension` + sostituisci
      i `Color(0xFF…)` categoria per categoria (Sez. 3).
- [ ] **Mezza giornata:** `UserModel` con campi `final` + `copyWith`
      (Sez. 10).
- [ ] **Giornata:** rotte nominate in `main.dart` (Sez. 9).
- [ ] **Quando ti senti pronto:** `QuizController` separato dal
      `QuizScreen` (Sez. 6).

---

## Cose che stanno già andando bene

Non è tutto da buttare, anzi.

- **Theme impostato bene** (`lib/theme/app_theme.dart`): naming
  semantico, dark + light, text styles riusabili.
- **Dispose corretto in `welcome_screen.dart:167-184`** — è l'esempio
  giusto da copiare altrove.
- **`mounted` check corretto in `loading_screen.dart:76-79`** — stesso
  discorso.
- **Molti widget già estratti come classi** (es. `_CategoryGridTile`,
  `_ExploreCategoryTile`): dove è stato fatto, è fatto bene. Serve solo
  estenderlo ovunque.
- **File organizzati per feature** (`home/`, `quiz/`, `welcome/`): è la
  struttura giusta.

Il codice non è disordinato, è **acerbo**. La base è buona: i problemi
sono tutti "una volta che li vedi non li scrivi più".
