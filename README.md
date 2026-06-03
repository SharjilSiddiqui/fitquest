# 🏆 FitQuest

FitQuest is a gamified fitness RPG built with Flutter and DartStream Cloud Services.

Instead of simply tracking habits, FitQuest transforms healthy activities into an RPG experience where players create a hero, complete daily quests, earn XP and Gold, maintain streaks, unlock achievements, and level up through real-world actions.

---

## ✨ Features

### 🛡 Hero Classes

Choose your character:

- Warrior
- Ranger
- Monk
- Mage

---

### ⚔ RPG Progression

Earn XP by completing healthy habits.

| Activity       | XP Reward |
| -------------- | --------- |
| 💧 Drink Water | +10 XP    |
| 🏋 Workout     | +25 XP    |
| 🚶 Walk        | +15 XP    |
| 🧘 Meditate    | +20 XP    |

### 💰 Gold System

Earn gold alongside XP.

| Activity       | Gold Reward |
| -------------- | ----------- |
| 💧 Drink Water | +5 Gold     |
| 🏋 Workout     | +10 Gold    |
| 🚶 Walk        | +5 Gold     |
| 🧘 Meditate    | +5 Gold     |

Gold is planned to be used for:

- Equipment
- Hero Upgrades
- Shops
- Inventory Items

---

### 📅 Daily Quests

Complete daily quests to earn bonus rewards:

- 💧 Drink Water ×5
- 🏋 Workout ×1
- 🚶 Walk ×1
- 🧘 Meditate ×1

Features:

- Quest progress persists between sessions
- Cloud-saved player progress
- Automatic daily reset
- Bonus XP rewards

---

### 🔥 Streak System

FitQuest tracks consecutive active days.

Features:

- Daily streak tracking
- Automatic streak updates
- Streak resets after inactivity
- Future streak rewards

Example:

```text
🔥 Streak: 7 Days
```

---

### 🏅 Level System

Current level formula:

```dart
Level = (XP ~/ 100) + 1;
```

Examples:

| XP  | Level |
| --- | ----- |
| 0   | 1     |
| 100 | 2     |
| 200 | 3     |
| 500 | 6     |

---

### 🏆 Achievement System

Achievements currently planned and partially implemented:

- 💧 First Drink
- 🏋 First Workout
- 🔥 7 Day Streak
- ⭐ Reach Level 5
- 💰 Earn 100 Gold

---

## ☁ DartStream Integration

FitQuest uses DartStream Cloud Services for authentication and cloud persistence.

### Authentication

Used for:

- User Registration
- User Login
- Session Management

### Cloud Save

Used for:

- Saving Player Progress
- Loading Player Data
- Quest Persistence
- XP Tracking
- Gold Tracking
- Streak Tracking

Example:

```dart
await cloudSave.savePlayer(
  userId: session.userId!,
  tenantId: session.tenantId!,
  player: player,
);
```

### Example Saved Player Snapshot

```json
{
  "heroClass": "warrior",
  "xp": 400,
  "gold": 25,
  "waterCount": 6,
  "workoutCount": 4,
  "walkCount": 3,
  "meditationCount": 1,
  "streak": 5,
  "waterQuestProgress": 3,
  "workoutQuestProgress": 1,
  "walkQuestProgress": 1,
  "meditateQuestProgress": 0
}
```

---

## 🏗 Project Structure

```text
lib/
│
├── api/
│   ├── dartstream.dart
│   └── firebase_auth.dart
│
├── models/
│   ├── player_data.dart
│   └── daily_quest.dart
│
├── screens/
│   ├── login_screen.dart
│   ├── register_screen.dart
│   ├── character_setup_screen.dart
│   └── home_screen.dart
│
├── services/
│   ├── cloud_save_service.dart
│   ├── xp_service.dart
│   ├── level_service.dart
│   └── achievement_service.dart
│
├── state/
│   └── session.dart
│
├── widgets/
│   └── fitquest_dashboard.dart
│
└── main.dart
```

---

## 📱 Dashboard

### 🏠 Home

Displays:

- Hero Summary
- XP Progress
- Gold
- Current Level
- Streak Information

### 📋 Quests

Displays:

- Daily Quests
- Quest Progress
- Activity Actions

### 🛡 Hero

Displays:

- Hero Profile
- Character Statistics
- Hero Attributes

### 🏆 Achievements

Displays:

- Unlocked Achievements
- Achievement Progress
- Future Rewards

---

## 🛠 Tech Stack

### Frontend

- Flutter
- Dart
- Material Design 3

### Backend

- DartStream Cloud Services

### Authentication

- Firebase Authentication REST API
- DartStream Authentication

### Persistence

- DartStream Cloud Save
- Snapshot Storage

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK
- Android Studio
- VS Code (optional)
- Android Emulator or Physical Device

### Install Dependencies

```bash
flutter pub get
```

### Environment Configuration

Create a `.env` file:

```env
AUTH_HOST=your_auth_host
API_HOST=your_api_host
FIREBASE_API_KEY=your_firebase_api_key
```

### Run the App

```bash
flutter run
```

### Run on Chrome

```bash
flutter run -d chrome
```

### Run on Android Emulator

```bash
flutter emulators --launch Pixel_9_API_36
flutter run
```

---

## 🗺 Roadmap

### Phase 1 ✅

- Hero Classes
- XP System
- Gold System
- Daily Quests
- Streak Tracking
- Cloud Save

### Phase 2 🚧

- Achievement System
- Daily Rewards
- Hero Attributes
- Improved UI/Animations

### Phase 3

- Inventory System
- Equipment System
- Hero Customization
- Item Rewards

### Phase 4

- Boss Battles
- Dungeons
- PvP Challenges
- Guild System

### Phase 5

- Leaderboards
- Friends System
- Seasonal Events
- Multiplayer Challenges

---

## 👨‍💻 Author

Built with Flutter and DartStream as a learning project demonstrating:

- Mobile Development
- Cloud Persistence
- Gamification
- RPG Progression Systems
- DartStream Cloud APIs

FitQuest combines fitness tracking and RPG mechanics into a single mobile experience that encourages healthy habits through gameplay.
