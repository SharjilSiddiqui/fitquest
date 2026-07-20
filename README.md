# 🏆 FitQuest

FitQuest is a gamified fitness RPG built with **Flutter** and **DartStream Cloud Services**.

Instead of simply tracking habits, FitQuest transforms healthy activities into RPG progression. Players create a hero, complete daily quests, earn XP and Gold, maintain streaks, unlock achievements, and persist their progress using DartStream Cloud Services.

FitQuest serves as a complete reference application demonstrating the official **DartStream Flutter SDK**, Firebase Authentication, Cloud Save, Feature Flags, Reactive Events, OAuth2 Client Credentials, CI/CD, and Firebase Hosting.

---

# ✨ Features

## 🛡 Hero Classes

Choose your hero class:

- Warrior
- Ranger
- Mage
- Monk

Hero selection is persisted using DartStream Cloud Save.

---

## ⚡ RPG Progression

Earn XP and Gold by completing real-world healthy activities.

| Activity       |  XP | Gold |
| -------------- | --: | ---: |
| 💧 Drink Water |  10 |    5 |
| 🏋 Workout     |  25 |   10 |
| 🚶 Walk        |  15 |    5 |
| 🧘 Meditate    |  20 |    5 |

### Level Formula

```dart
level = (xp ~/ 100) + 1;
```

Example:

|   XP | Level |
| ---: | ----: |
|    0 |     1 |
|  100 |     2 |
|  500 |     6 |
| 1000 |    11 |

---

## 📅 Daily Quests

Current quests include:

- Drink Water ×5
- Workout ×1
- Walk ×1
- Meditate ×1

Features:

- Persistent progress
- Daily reset
- XP rewards
- Cloud synchronization

---

## 🔥 Daily Streaks

Track consecutive active days.

Features:

- Automatic streak tracking
- Persistent streak storage
- Daily reward support
- Future streak bonuses

---

## 🏆 Achievement System

Achievements unlock automatically based on player progress.

Examples:

- First Drink
- First Workout
- Reach Level 5
- Earn 100 Gold
- 7 Day Streak
- Boss Slayer

---

## 👹 Boss Battles

Battle powerful enemies and earn rewards.

Possible rewards:

- XP
- Gold
- Equipment
- Achievement Progress

---

## 🎒 Inventory

Inventory supports:

- Consumables
- Equipment
- Future RPG items

Inventory is synchronized using DartStream Cloud Save.

---

# ☁ DartStream Integration

FitQuest demonstrates multiple DartStream services.

## 🔐 Authentication

Uses the official **dartstream_client** SDK together with Firebase Authentication.

Features:

- User Registration
- User Login
- Session Onboarding
- Session Persistence

---

## 🚩 Platform Service

Uses DartStream Platform APIs for:

- Feature Flags

Feature Flags actively influence application behaviour and gameplay.

---

## ☁ Experience Service

Uses DartStream Experience APIs for:

- Cloud Save
- Character Persistence
- Inventory
- Player Progress

Cloud Save stores:

- Hero Class
- XP
- Gold
- Daily Quests
- Streak
- Inventory
- Achievements
- Boss Progress

---

## ⚡ Reactive Service

Uses DartStream Reactive APIs for gameplay events.

Current events include:

- Character Created
- Gameplay Progression Events

---

# 🔐 OAuth2 Machine-to-Machine Demo

The repository includes a standalone OAuth2 CLI demonstrating the **Client Credentials Grant**.

Location:

```text
bin/oauth2_deepdive.dart
```

The CLI demonstrates:

- OAuth2 Client Credentials
- JWT Inspection
- OAuth2 Bearer Authentication
- Live Platform API Access
- Machine-to-Machine Authentication

The OAuth2 CLI is completely separate from the Flutter application and **is not deployed** to Firebase Hosting.

---

## Using the DartStream CLI

Install the official DartStream CLI:

```bash
dart pub global activate ds_dartstream 0.0.8
```

Log in with a CLI token generated from the DartStream dashboard:

```bash
dartstream login --token <your-cli-token> --api-url https://dev-api.dartstream.io
```

Validate the project manifest:

```bash
dartstream validate --strict
```

Show CLI help:

```bash
dartstream --help
```

The CLI validates the DartStream project manifest in `dartstream.yaml`.

---

# 📂 Project Structure

```text
.
├── bin/
│   ├── intellitoggle_deepdive.dart
│   └── oauth2_deepdive.dart
│
├── lib/
│   ├── config/
│   ├── models/
│   ├── screens/
│   ├── services/
│   ├── state/
│   ├── widgets/
│   └── main.dart
│
├── test/
│   ├── cloud_save_service_test.dart
│   └── event_service_test.dart
│
├── web/
│
├── .github/
│   └── workflows/
│       └── flutter.yml
│
├── firebase.json
├── .firebaserc
└── pubspec.yaml
```

---

# 🛠 Tech Stack

## Frontend

- Flutter
- Dart
- Material Design 3

## Backend

- DartStream Cloud Services

## Authentication

- Firebase Authentication
- dartstream_client SDK

## Cloud Services

- Platform
- Experience
- Reactive

## Hosting

- Firebase Hosting

---

# 🚀 Getting Started

## Install Dependencies

```bash
flutter pub get
```

---

## Run Locally

```bash
flutter run \
  -d chrome \
  --dart-define=FIREBASE_API_KEY=YOUR_FIREBASE_API_KEY
```

---

## Build Web

```bash
flutter build web \
  --release \
  --dart-define=FIREBASE_API_KEY=YOUR_FIREBASE_API_KEY
```

---

## OAuth2 CLI

Run the OAuth2 Deep Dive:

```bash
dart run \
  -DOAUTH2_CLIENT_ID=YOUR_CLIENT_ID \
  -DOAUTH2_CLIENT_SECRET=YOUR_CLIENT_SECRET \
  -DAPI_BILLING=https://dev-apibilling.dartstream.io \
  bin/oauth2_deepdive.dart
```

Run the IntelliToggle Deep Dive:

```bash
dart run \
  -DINTELLITOGGLE_TOKEN_URL=https://dev-api.intellitoggle.com/api/v1/oauth/token \
  -DINTELLITOGGLE_API_URL=https://dev-api.intellitoggle.com \
  -DINTELLITOGGLE_CLIENT_ID=YOUR_CLIENT_ID \
  -DINTELLITOGGLE_CLIENT_SECRET=YOUR_CLIENT_SECRET \
  -DINTELLITOGGLE_TENANT_ID=YOUR_TENANT_ID \
  -DINTELLITOGGLE_PROJECT_ID=YOUR_PROJECT_ID \
  -DINTELLITOGGLE_ENVIRONMENT=development \
  bin/intellitoggle_deepdive.dart
```

The Flutter web app does not perform IntelliToggle OAuth. Live IntelliToggle
evaluation is demonstrated through the CLI so client credentials are never
bundled into the browser build.

---

# 🧪 Testing

Run unit tests:

```bash
flutter test
```

Run static analysis:

```bash
flutter analyze
```

Verify a production web build:

```bash
flutter build web \
  --dart-define=FIREBASE_API_KEY=dummy
```

---

# ⚙ Continuous Integration

GitHub Actions automatically runs:

- flutter pub get
- flutter analyze
- flutter test
- flutter build web

on every push and pull request.

---

# 🌍 Deployment

Build:

```bash
flutter build web \
  --release \
  --dart-define=FIREBASE_API_KEY=YOUR_FIREBASE_API_KEY
```

Deploy to Firebase Hosting:

```bash
firebase deploy --only hosting:fitquest
```

---

# 🔒 Security

- Firebase API Keys are supplied using `--dart-define`.
- OAuth2 Client Secrets are **never** embedded into the Flutter application.
- OAuth2 Client Secrets are only used by the standalone CLI.
- No secrets should be committed to Git.

---

# 📚 What This Sample Demonstrates

- ✅ Flutter + DartStream SDK
- ✅ Firebase Authentication
- ✅ Feature Flags
- ✅ Cloud Save
- ✅ Reactive Event Tracking
- ✅ OAuth2 Client Credentials
- ✅ Firebase Hosting
- ✅ GitHub Actions CI
- ✅ Unit Testing with MockClient

---

# 👨‍💻 Author

**Sharjil Siddiqui**

FitQuest is a production-quality reference application demonstrating modern Flutter development with the DartStream SDK. It showcases authentication, cloud persistence, feature flags, reactive events, OAuth2 machine-to-machine authentication, CI/CD, automated testing, and Firebase Hosting through a complete RPG-inspired fitness application.
