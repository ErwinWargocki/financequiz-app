---
name: FinQuiz App Project State
description: Flutter finance quiz app — architecture, what's built, what's pending
type: project
---

Cross-platform Flutter finance learning app. Guide doc: `financequiz_app_development_guide.md` at project root.

**Current stack:** Flutter (Dart), SQLite (sqflite), SharedPreferences, Google Fonts, fl_chart, crypto (SHA-256 hashing)

**What's implemented (as of April 2026):**
- Full auth system: email/password register+login (SHA-256 hashed), Google login UI (placeholder — needs backend)
- Profile icon selection: 20 emoji icons chosen on first register (`ProfileIcons` in models.dart)
- 4-tab navigation: Home, Study, Test, Profile
- Study Topics page (`study_screen.dart`) — 8 topics with expandable lessons and "Take Quiz" CTA
- Study content data (`lib/data/study_topics.dart`) — Budgeting, Investing, Crypto, Savings, Taxes, Debt
- Quiz system with timer, 2-attempt mechanic, scoring, result screen, question review
- DB version 2 migration (added email, passwordHash, googleId, profileIconIndex columns)
- Expanded quiz questions: savings 8, taxes 8, debt 8, crypto 8, investing 10, budgeting 8
- Category names updated to match guide: "Personal Finance", "Bitcoin & Crypto", "Savings Strategies", "Debt Management"

**Pending (guide requirements not yet implemented):**
- Backend: Dart Frog REST API (`/backend` directory)
- Database: Neon (PostgreSQL) to replace/supplement SQLite
- Real Google OAuth (requires google-services.json, iOS plist, Firebase setup)
- `remember me` backend tokens (currently handled via SharedPreferences userId)
- `/frontend` + `/backend` project structure split
- Daily learning system (rotate daily topics, daily quiz tracking)

**Architecture notes:**
- All auth is currently local-only (SQLite). When backend is ready, replace `DatabaseHelper.getUserByEmail()` + password check with HTTP call to `POST /auth/login`
- `onboardingDone` SharedPreferences flag persists across sign-out so returning users skip slides
- `userId` in SharedPreferences = logged-in session token

**Why:** User wants to build a scalable finance learning app matching the dev guide. Backend (Dart Frog + Neon) is the next major milestone.
