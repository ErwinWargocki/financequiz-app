# 💰 FinQuiz — Financial Literacy App

FinQuiz is a clean, production-ready full-stack application designed to make financial education genuinely engaging through interactive quizzes. Built entirely within the Dart ecosystem, it leverages Flutter for a seamless cross-platform mobile experience and Dart Frog for a lightweight, performant backend.

Currently, the app is undergoing an exciting data-layer evolution. While it still utilizes local SQLite for legacy and temporary on-device storage, the primary source of truth is now a robust Neon (PostgreSQL-based) database connected via our custom Dart Frog APIs.

---

## 🧱 Tech stack
Frontend: Flutter (Dart)
Backend: Dart Frog (Dart)
Database: Neon (PostgreSQL)
Local storage (temporary): SQLite

---

## ✨ Features

Here is a quick look at the tech stack and features that make the app tick:

  ⚡ Full-Stack Dart: Share models and logic across both the frontend (Flutter) and backend (Dart Frog) for a unified developer experience.
  ☁️ Cloud Database: Powered by a PostgreSQL database hosted on Neon, allowing for scalable user data and real-time API integrations.
  🗃️ Local Storage: Utilizes SQLite for temporary local caching and legacy offline support (currently being refactored/reduced).
  📱 Cross-Platform: Works right out of the box natively on Android and iOS.
  🎨 Design: A dark, minimal interface heavily inspired by the clean aesthetics of an Instagram feed.
  🧠 6 Quiz Categories: Covers practical topics like Budgeting, Investing, Crypto, Savings, Taxes, and Debt.
  ⏱️ Timed Questions: Keeps users on their toes with 20 seconds per question, plus time-bonus scoring for quick thinkers.
  📊 Grade System: Grades performance visually from an S rank down to a D.
  🔥 Streaks & Achievements: Encourages daily habits by tracking user streaks and offering a fun, unlockable badge system.
  🔄 Onboarding: A smooth, 3-step welcome flow to get new users set up and their profiles synced with the backend without friction.

---

## 📁 Project Structure

```
finquiz/
├── lib/
│   ├── main.dart                   # Entry point
│   │ 
│   ├── theme/                      # Colors, typography, ThemeData
│   │                               
│   ├── models/                     # QuizQuestion, UserModel, QuizResult
│   │                               
│   ├── database/                   # Local DB (legacy / temporary)
│   │                               
│   ├── data/                       # Category definitions
│   │                               
│   ├── screens/                    # 
│   │ 
│   └── theme
│
├── app_theme.dart
├── backend/                        # Dart Frog API
├── pubspec.yaml
└── README.md
```

---

## 🔌 API & data flow

Typical flow when loading a quiz:
- Flutter calls an API 
- Dart Frog handles the request
- Backend queries Neon (PostgreSQL)
- Data is returned as JSON
- Flutter maps it into models and renders the UI

Same idea applies for:
- submitting results
- loading user stats
- tracking streaks

---

## 🚀 Setup Instructions

### Prerequisites

- Flutter SDK ≥ 3.0.0 installed
- VS Code with the **Flutter** and **Dart** extensions
- Dart Frog CLI
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
sqflite: ^2.3.0                       # Local SQLite database
path: ^1.8.3                          # File path utilities
shared_preferences: ^2.2.2            # Lightweight key-value storage
google_fonts: ^6.1.0                  # Space Grotesk + Inter + JetBrains Mono
fl_chart: ^0.66.0                     # Charts (ready for use)
animate_do: ^3.3.4                    # Animation utilities
cupertino_icons: ^1.0.6               # iOS-style icons
percent_indicator: ^4.2.3             # Progress indicators
flutter_staggered_animations: ^1.1.1  # List animations
```

---

## 🗄️ Database (PostgreSQL / Neon)

- Main tables:

  - users
   basic profile info
   total score
   streak tracking
  - questions
   category
   question + options
   correct answer
   explanation
  - results
   quiz results
   score + timing
   history

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

## 🗃️ Backend (Dart Frog)

The backend is responsible for:

serving quiz questions
handling user data
storing results
managing streak logic

Typical structure:

backend/
├── routes/
│   ├── questions/
│   ├── users/
│   └── results/
├── services/
├── models/
└── db/

---

## 🔮 Extending the App

Ideas for future development:
- Full removal of SQLite
- Multiplayer / competitive modes
- Cloud sync with Firebase
- Push notifications for streak reminders
- Multilingual support
- Sound effects and haptic patterns

---

## 👀 Final notes

This project started as a local-first Flutter app and is now evolving into a more complete, API-driven architecture.
It’s still simple enough to understand quickly, but structured in a way that can scale into a real product.