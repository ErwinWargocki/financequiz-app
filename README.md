# 💰 FinQuiz — Financial Literacy App

A clean, production-ready Flutter app for financial education through interactive quizzes.
Works on **Android** and **iOS** with a local SQLite database.

---

## ✨ Features

| Feature | Details |
|---|---|
| 🎨 Design | Dark minimal UI inspired by Instagram's clean feed |
| 🗃️ Local DB | SQLite via `sqflite` — no backend required |
| 📱 Cross-platform | Android & iOS |
| 🧠 6 Quiz Categories | Budgeting, Investing, Crypto, Savings, Taxes, Debt |
| ⏱️ Timed Questions | 20s per question with time-bonus scoring |
| 📊 Grade System | S / A / B / C / D grading with visual breakdowns |
| 🔥 Streaks | Daily streak tracking per user |
| 🏆 Achievements | Unlockable badge system |
| 👤 User Profiles | Local profile with persistent stats |
| 🔄 Onboarding | 3-step welcome flow |

---

## 📁 Project Structure

```
finquiz/
├── lib/
│   ├── main.dart                   # Entry point
│   ├── theme/
│   │   └── app_theme.dart          # Colors, typography, ThemeData
│   ├── models/
│   │   └── models.dart             # QuizQuestion, UserModel, QuizResult
│   ├── database/
│   │   └── database_helper.dart    # SQLite CRUD + seed data
│   ├── data/
│   │   └── quiz_categories.dart    # Category definitions
│   └── screens/
│       ├── welcome_screen.dart     # Onboarding + profile setup
│       ├── main_shell.dart         # Bottom nav shell
│       ├── home_screen.dart        # Instagram-style home feed
│       ├── explore_screen.dart     # Search & filter categories
│       ├── quiz_screen.dart        # Active quiz with timer
│       ├── result_screen.dart      # Animated results + grade
│       └── profile_screen.dart     # Stats, history, achievements
├── pubspec.yaml
└── README.md
```

---

## 🚀 Setup Instructions

### Prerequisites

- Flutter SDK ≥ 3.0.0 installed
- VS Code with the **Flutter** and **Dart** extensions
- Android Studio (for Android emulator) or Xcode (for iOS simulator)

### Step 1 — Create the Flutter project

```bash
flutter create finquiz
cd finquiz
```

### Step 2 — Replace the generated files

Copy all provided source files into your project, maintaining the folder structure shown above.

### Step 3 — Create asset folders

```bash
mkdir -p assets/images assets/animations
```

Add a placeholder file to each folder (Flutter requires at least one file per declared asset folder):
```bash
touch assets/images/.keep assets/animations/.keep
```

### Step 4 — Install dependencies

```bash
flutter pub get
```

### Step 5 — Run the app

```bash
# Android
flutter run

# iOS (macOS only)
flutter run -d ios

# Specific device
flutter devices          # List connected devices
flutter run -d <device>  # Run on specific device
```

---

## 📦 Dependencies

```yaml
sqflite: ^2.3.0           # Local SQLite database
path: ^1.8.3              # File path utilities
shared_preferences: ^2.2.2 # Lightweight key-value storage
google_fonts: ^6.1.0      # Space Grotesk + Inter + JetBrains Mono
fl_chart: ^0.66.0         # Charts (ready for use)
animate_do: ^3.3.4        # Animation utilities
cupertino_icons: ^1.0.6   # iOS-style icons
percent_indicator: ^4.2.3  # Progress indicators
flutter_staggered_animations: ^1.1.1 # List animations
```

---

## 🗃️ Database Schema

### `users`
| Column | Type | Description |
|---|---|---|
| id | INTEGER PK | Auto-increment |
| name | TEXT | Display name |
| username | TEXT UNIQUE | @username |
| avatarInitial | TEXT | First letter of name |
| totalScore | INTEGER | Cumulative score |
| quizzesCompleted | INTEGER | Quiz count |
| currentStreak | INTEGER | Active streak |
| longestStreak | INTEGER | Best streak |
| createdAt | TEXT | ISO8601 timestamp |

### `questions`
| Column | Type | Description |
|---|---|---|
| id | INTEGER PK | Auto-increment |
| category | TEXT | budgeting/investing/crypto/savings/taxes/debt |
| question | TEXT | Question text |
| option0–3 | TEXT | Answer options |
| correctIndex | INTEGER | 0–3 |
| explanation | TEXT | Explanation shown after answering |
| difficulty | TEXT | easy/medium/hard |

### `results`
| Column | Type | Description |
|---|---|---|
| id | INTEGER PK | Auto-increment |
| userId | INTEGER FK | References users.id |
| category | TEXT | Quiz category |
| score | INTEGER | Points earned |
| totalQuestions | INTEGER | Question count |
| correctAnswers | INTEGER | Correct count |
| timeTakenSeconds | INTEGER | Time used |
| completedAt | TEXT | ISO8601 timestamp |

---

## 🎨 Design System

### Colors (Dark Theme)
```dart
primary:       #0A0A0A  // Background
accent:        #00E5A0  // Green (main CTA)
accentBlue:    #4C6EF5  // Blue accent
accentWarm:    #FFB800  // Amber accent
danger:        #FF4757  // Red/error
surface:       #141414  // Nav bar
cardBg:        #1A1A1A  // Card backgrounds
```

### Typography
- **Display/Headers**: Space Grotesk (bold, geometric)
- **Body**: Inter (readable, neutral)
- **Monospace/Numbers**: JetBrains Mono

---

## 🔧 Adding More Questions

In `database_helper.dart`, add entries to `_getInitialQuestions()`:

```dart
QuizQuestion(
  category: 'investing',  // Must match a category id
  question: 'Your question here?',
  options: ['Option A', 'Option B', 'Option C', 'Option D'],
  correctIndex: 1,        // 0-indexed
  explanation: 'Why this answer is correct...',
  difficulty: 'medium',   // easy | medium | hard
),
```

> Note: After adding questions, delete and reinstall the app to trigger a fresh DB seed,
> or implement a migration by incrementing the database version.

---

## 📱 Screenshots Overview

| Screen | Description |
|---|---|
| Welcome | 3-step onboarding + profile creation |
| Home | Instagram-style feed with stats, featured card, category grid |
| Explore | Searchable + filterable category list |
| Quiz | Timed questions with animated feedback + explanations |
| Results | Animated grade reveal, breakdown, score summary |
| Profile | Stats grid, achievements, full quiz history |

---

## 🔮 Extending the App

Ideas for future development:
- 📅 Daily challenge (one new quiz per day)
- 🌐 Cloud sync with Firebase
- 📣 Push notifications for streak reminders
- 📈 Charts showing score progression over time
- 🎭 Multiple themes (light mode, high contrast)
- 🌍 Multilingual support
- 🔊 Sound effects and haptic patterns
