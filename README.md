# 💪 GymCoach

> Offline mobile app for gym coaches to manage their students, workout plans and strength progression.

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.10+-0175C2?logo=dart)
![SQLite](https://img.shields.io/badge/SQLite-Local-003B57?logo=sqlite)
![Platform](https://img.shields.io/badge/Platform-Android-3DDC84?logo=android)
![Status](https://img.shields.io/badge/Status-In%20development-yellow)

---

## 📋 Table of Contents

- [About](#-about)
- [Features](#-features)
- [Architecture](#-architecture)
- [Folder structure](#-folder-structure)
- [Database](#-database)
- [Tech stack and dependencies](#-tech-stack-and-dependencies)
- [Prerequisites](#-prerequisites)
- [Running the project](#-running-the-project)
- [Running the tests](#-running-the-tests)
- [Architecture decisions](#-architecture-decisions)
- [Roadmap](#-roadmap)
- [Principles applied](#-principles-applied)

---

## 📌 About

GymCoach was built to solve a real problem for gym coaches: managing students and workouts still happens in notebooks, spreadsheets and WhatsApp groups.

The app lets a coach register students, build personalised workout plans, track load progression for each exercise and keep everything in one place on their phone. It works 100% offline, with no dependency on internet access or external servers.

### Current version (MVP 1.0)
- Single user: the coach
- Fully offline
- Data stored locally with SQLite
- No login, no sync, no subscription plans

The architecture is designed to scale: when the product grows to support multiple coaches and student access, the data layer can be swapped for an API without touching the screens or business rules.

> **Note:** the codebase uses Portuguese domain names (`aluno` = student, `treino` = workout, `exercicio` = exercise, `historico_carga` = load history).

---

## ✅ Features

### MVP 1.0
- [x] Create, edit and list students
- [x] Student profile photo
- [x] Create workouts (any name: A, B, C or custom)
- [x] Add and reorder exercises within a workout
- [x] Record sets, reps, load and rest time
- [x] Load history per exercise
- [x] Dashboard with an overall summary
- [x] Archive inactive students
- [x] Archive old workouts

### Future (post-MVP)
- [ ] Student access to their own workouts
- [ ] Cloud sync
- [ ] Multiple coaches
- [ ] Notifications and reminders
- [ ] Export workouts to PDF

---

## 🏗 Architecture

The project follows **Clean Architecture**, with 3 layers per feature:

```
Presentation  →  Domain  →  Data
(Screens/State)  (Rules)    (Database/API)
```

### Dependency rule
Outer layers know about inner layers, never the other way round.
- `Presentation` depends on `Domain`
- `Data` depends on `Domain`
- `Domain` depends on nothing: it is pure Dart

This means replacing SQLite with an API in the future only requires a new implementation in `Data`, without touching any screen or business rule.

### Data flow
```
Screen → Provider (Riverpod) → UseCase → Repository (contract) → RepositoryImpl → DAO → SQLite
```

---

## 📁 Folder structure

```
lib/
├── main.dart                        # Entry point: only bootstraps the app
├── app/
│   ├── app.dart                     # MaterialApp + theme + ProviderScope
│   └── router.dart                  # All routes with GoRouter
│
├── core/                            # Utilities shared across the app
│   ├── constants/                   # Centralised strings, colours and dimensions
│   ├── database/
│   │   └── database_helper.dart     # SQLite connection singleton
│   ├── errors/
│   │   ├── exceptions.dart          # Data layer exceptions
│   │   └── failures.dart            # Domain layer failures
│   ├── theme/
│   │   └── app_theme.dart           # Global colours, fonts and styles
│   └── utils/
│       └── image_helper.dart        # Photo resizing and storage
│
├── shared/
│   └── widgets/                     # Widgets reused across features
│       ├── confirm_dialog.dart
│       ├── empty_state_widget.dart
│       ├── error_widget.dart
│       └── loading_widget.dart
│
└── features/
    ├── alunos/                      # Students
    │   ├── data/
    │   │   ├── datasources/         # SQL queries (DAOs)
    │   │   └── repositories/        # SQLite implementation of the contract
    │   ├── domain/
    │   │   ├── entities/            # Immutable models (Freezed)
    │   │   ├── repositories/        # Repository contract
    │   │   └── usecases/            # One class per use case
    │   └── presentation/
    │       ├── providers/           # State with Riverpod
    │       ├── screens/
    │       └── widgets/
    │
    ├── treinos/                     # Workouts, exercises and load history
    │   ├── data/
    │   ├── domain/
    │   └── presentation/
    │
    └── dashboard/                   # Overview screen
        └── presentation/

test/
└── features/
    └── treinos/
        └── data/                    # DAO tests with in-memory SQLite
```

---

## 🗄 Database

### Table: `alunos` (students)

| Column | Type | Required | Description |
|--------|------|----------|-------------|
| id | INTEGER PK | yes | Auto increment |
| nome | TEXT | yes | Full name |
| idade | INTEGER | no | Age |
| peso | REAL | no | Weight in kg |
| altura | REAL | no | Height in metres |
| data_nascimento | TEXT | no | Date of birth, ISO 8601 |
| telefone | TEXT | no | Phone number |
| objetivo | TEXT | no | Goal |
| observacoes | TEXT | no | Notes |
| foto_path | TEXT | no | Local photo path |
| data_inicio | TEXT | yes | Start date, ISO 8601 |
| ativo | INTEGER | yes | 1 = active, 0 = inactive |

### Table: `treinos` (workouts)

| Column | Type | Required | Description |
|--------|------|----------|-------------|
| id | INTEGER PK | yes | Auto increment |
| aluno_id | INTEGER FK | yes | References `alunos` |
| nome | TEXT | yes | e.g. "Workout A", "Chest" |
| objetivo | TEXT | no | Workout focus |
| ativo | INTEGER | yes | 1 = active, 0 = archived |
| data_criacao | TEXT | yes | Created at, ISO 8601 |

### Table: `treino_exercicios` (workout exercises)

| Column | Type | Required | Description |
|--------|------|----------|-------------|
| id | INTEGER PK | yes | Auto increment |
| treino_id | INTEGER FK | yes | References `treinos` |
| nome_exercicio | TEXT | yes | Exercise name |
| series | INTEGER | no | Sets |
| repeticoes | TEXT | no | Reps. TEXT because it can be "to failure" |
| carga | REAL | no | Load in kg |
| tempo_descanso | INTEGER | no | Rest time in seconds |
| observacao | TEXT | no | Notes |
| ordem | INTEGER | yes | Position, used for reordering |

### Table: `historico_carga` (load history)

| Column | Type | Required | Description |
|--------|------|----------|-------------|
| id | INTEGER PK | yes | Auto increment |
| exercicio_id | INTEGER FK | yes | References `treino_exercicios` |
| carga | REAL | yes | Recorded load |
| repeticoes | TEXT | no | Reps performed |
| data_registro | TEXT | yes | Recorded at, ISO 8601 |
| observacao | TEXT | no | Notes |

### Relationships
```
alunos ──< treinos ──< treino_exercicios ──< historico_carga
```
All with `ON DELETE CASCADE`: deleting a student removes all related data.

---

## 📦 Tech stack and dependencies

### Runtime
| Package | Version | Why |
|---------|---------|-----|
| flutter_riverpod | ^2.5.1 | State management and dependency injection |
| riverpod_annotation | ^2.3.4 | Code generation for providers |
| go_router | ^13.2.0 | Declarative, scalable navigation |
| sqflite | ^2.3.2 | Local SQLite database |
| path | ^1.9.0 | Locating the database file on the device |
| path_provider | ^2.1.0 | App documents directory (where photos are stored) |
| image_picker | ^1.1.2 | Pick a photo from the camera or gallery |
| flutter_image_compress | ^2.1.0 | Resize and compress student photos |
| freezed_annotation | ^2.4.1 | Immutable models with copyWith, == and toString |
| json_annotation | ^4.9.0 | Object serialisation/deserialisation |

### Dev (code generation and testing)
| Package | Version | Why |
|---------|---------|-----|
| build_runner | ^2.4.9 | Runs the code generators |
| freezed | ^2.5.2 | Generator for immutable models |
| riverpod_generator | ^2.4.0 | Generator for Riverpod providers |
| json_serializable | ^6.8.0 | Generator for JSON serialisation |
| sqflite_common_ffi | ^2.3.4 | In-memory database for DAO tests without an emulator |

---

## 🛠 Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) 3.10 or later
- [Android Studio](https://developer.android.com/studio) with an emulator set up (API 34+)
- [VS Code](https://code.visualstudio.com/) with the Flutter and Dart extensions
- Java JDK 17 or later

Check your setup:
```bash
flutter doctor
```
Every item should show ✅ before you run the project.

---

## 🚀 Running the project

**1. Clone the repository**
```bash
git clone https://github.com/Vitorfarani/gymcoach.git
cd gymcoach
```

**2. Install dependencies**
```bash
flutter pub get
```

**3. Generate code**
```bash
dart run build_runner build --delete-conflicting-outputs
```

**4. Start the emulator and run the app**
```bash
flutter run --no-enable-impeller
```

> `--no-enable-impeller` disables the Impeller renderer, which is too heavy for emulators. On a physical device you can run without this flag.

---

## 🧪 Running the tests

Run all tests:
```bash
flutter test
```

Run the tests for a specific feature:
```bash
flutter test test/features/treinos/
```

Run with coverage:
```bash
flutter test --coverage
```

---

## 🧠 Architecture decisions

### Why Clean Architecture?
The app starts offline with SQLite but is designed to scale. With Clean Architecture, switching the data source (SQLite → API) only requires a new implementation in `data/repositories/`, without touching any screen or business rule.

### Why Riverpod?
It is the most robust state management approach in Flutter. It handles dependency injection, caching, reactivity and testability without extra libraries.

### Why GoRouter?
Declarative navigation that scales well. When the app grows to need deep links, authentication and protected routes, GoRouter supports all of it without refactoring.

### Why SQLite and not Hive/Isar?
GymCoach has real relationships between entities (student → workouts → exercises → history). SQLite with relational queries is the most solid choice for this data model.

### Why Freezed for models?
Immutable models eliminate a whole class of bugs. With Freezed you never modify an object by accident; you always create a copy with `copyWith`. The generated `==` and `toString` also make testing and debugging easier.

---

## 🗺 Roadmap

### Version 1.0 — MVP (current)
- Full student and workout management
- Load progression history
- Works 100% offline

### Version 2.0 — Multi-user
- Cloud backend (REST API)
- Per-coach authentication
- Offline-first sync

### Version 3.0 — Students in the app
- Students can access their own workouts
- Mark exercises as done
- View their own progress

---

## 📐 Principles applied

| Principle | How it is applied |
|-----------|-------------------|
| **SOLID** | Each file has a single responsibility. Abstract contracts allow implementations to be swapped. |
| **DRY** | Strings in `app_strings`, colours in `app_theme`, SQL in the DAOs. |
| **KISS** | The simplest solution that solves the problem. No over-engineering. |
| **YAGNI** | The architecture supports growth, but the code only implements what the MVP needs. |
| **Clean Code** | Descriptive names, small functions, comments explain the why. |
| **TDD** | The data access layer is developed test-first against an in-memory SQLite database. |

---

## 👨‍💻 Author

Built by **Vitor Farani Barbosa**

[![LinkedIn](https://img.shields.io/badge/LinkedIn-blue?logo=linkedin)](https://www.linkedin.com/in/vitor-farani/)
[![GitHub](https://img.shields.io/badge/GitHub-black?logo=github)](https://github.com/Vitorfarani)
