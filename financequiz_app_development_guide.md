# Finance Learning App – Architecture & Development Guide

## 1. Overview
This document defines the structure, architecture, and development guidelines for a cross-platform finance learning application built using Flutter and Dart. The application must be clean, scalable, and maintainable, and must support both Android and iOS platforms.

The project is already in development, so this document also serves as a revision and standardization guide for improving the current codebase.

---

## 2. Core Technologies

- **Frontend:** Flutter (Dart)
- **Backend:** Dart Frog (Dart)
- **Database:** Neon (PostgreSQL-based)
- **Local Storage (temporary/legacy):** SQLite (to be refactored/reduced)

---

## 3. Project Structure

The project must be clearly divided into two main directories:

```
/project-root
  /frontend
  /backend
```

### 3.1 Frontend (Flutter)
Responsible for UI, user interaction, state management, and API communication.

### 3.2 Backend (Dart Frog)
Responsible for authentication, data persistence, business logic, and API endpoints.

---

## 4. Architecture Principles

- Clean and modular structure
- Separation of concerns
- Reusable components
- Readable and intuitive code
- Consistent naming conventions

---

## 5. Frontend Requirements

### 5.1 General
The frontend must be built entirely in Flutter and optimized for both Android and iOS platforms. It must communicate with the backend via REST APIs.

### 5.2 Pages Structure
The application must include 4 main pages:

#### 1. Home Page
The home page must behave similarly to a social dashboard (inspired by Instagram), displaying user progress, daily activity, and learning/test summaries.

**Functionality Description (≥20 words):**
This page aggregates user learning progress, daily activity, completed tests, and goals into a dynamic and visually engaging dashboard that encourages continuous engagement and tracks improvements over time.

#### 2. Study Topics Page
This page contains categorized financial topics with daily updates and three difficulty levels.

- Beginner
- Intermediate
- Advanced

Topics include:
- Bitcoin
- Personal Finance
- Investing
- Savings Strategies

**Functionality Description (≥20 words):**
This section delivers structured financial education content organized by difficulty level, updated daily, allowing users to progressively improve knowledge through curated explanations and practical examples.

#### 3. Test Page
This page provides quizzes based on studied topics.

**Functionality Description (≥20 words):**
The test system dynamically generates quizzes based on the user’s daily learning activity, ensuring personalized evaluation and reinforcing knowledge through targeted questions and performance tracking.

#### 4. Profile Page
A personal dashboard with statistics and settings.

**Functionality Description (≥20 words):**
This dashboard displays user achievements, completed lessons, quiz results, and progress metrics, while also allowing profile customization, theme switching, and account management features.

---

## 6. Authentication System

### 6.1 Login & Registration
Users must be able to:
- Register using email
- Login using email
- Login using Google

### 6.2 Persistent Login
The app must include a “remember me” option that stores login credentials securely in the backend and enables automatic login.

**Functionality Description (≥20 words):**
The authentication system securely manages user credentials, supports multiple login methods, and ensures persistent sessions by storing tokens and user preferences for seamless future access.

### 6.3 Profile Icon Selection
During the first login, users must select a profile icon from 20 random images.

---

## 7. Backend Requirements

### 7.1 Framework
Use Dart Frog to implement REST APIs.

### 7.2 Responsibilities
- User authentication
- Data storage
- Quiz management
- Progress tracking
- Profile data handling

### 7.3 Database Migration

- Replace or reduce SQLite usage
- Use Neon (PostgreSQL)

**Functionality Description (≥20 words):**
The backend must handle all persistent data operations, including user data, authentication tokens, learning progress, and quiz results, ensuring consistency, scalability, and secure storage.

---

## 8. Data Models

### 8.1 User
- id
- email
- password (hashed)
- googleId (optional)
- profileIcon
- preferences (theme, etc.)

### 8.2 Progress
- userId
- completedTopics
- quizScores
- dailyActivity

### 8.3 Topics
- id
- title
- category
- difficulty
- content
- updatedAt

### 8.4 Quiz
- id
- topicId
- questions
- answers
- correctAnswers

---

## 9. API Design

### Example Endpoints

- `POST /auth/register`
- `POST /auth/login`
- `POST /auth/google`
- `GET /topics`
- `GET /topics/:id`
- `GET /quiz/daily`
- `POST /quiz/submit`
- `GET /user/profile`
- `PUT /user/profile`

---

## 10. UI/UX Guidelines

- Simple and intuitive navigation
- Clean layout
- Responsive design
- Dark/Light mode toggle

---

## 11. Theme System

Users must be able to switch between:
- Light mode
- Dark mode

---

## 12. Daily Learning System

- Daily updated topics
- Daily quizzes
- Progress tracking

**Functionality Description (≥20 words):**
The daily learning system ensures continuous engagement by delivering fresh content and quizzes every day, encouraging habit formation and consistent improvement in financial knowledge.

---

## 13. Code Guidelines

- Keep functions small and focused
- Use meaningful variable names
- Avoid unnecessary complexity
- Document important logic sections clearly

---

## 14. Integration Requirements

- Frontend and backend MUST be connected via HTTP APIs
- Use JSON for communication
- Handle errors properly

---

## 15. Final Notes

This document must be used as a base for:
- Code refactoring
- Feature implementation
- Collaboration between LLM tools (Claude, Cursor)

The goal is to maintain a scalable, clean, and high-quality codebase while delivering a modern and engaging finance learning application.

