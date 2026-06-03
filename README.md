# 🏆 FitQuest

FitQuest is a gamified fitness RPG built with Flutter and DartStream Cloud Services.

Instead of simply tracking habits, FitQuest transforms healthy activities into RPG progression. Players create a hero, complete daily quests, earn XP and Gold, maintain streaks, unlock achievements, collect items, equip gear, battle bosses, and level up through real-world healthy habits.

---

## ✨ Features

### 🛡 Hero Classes

Choose your hero class:

- Warrior
- Ranger
- Mage
- Monk

Hero selection is persisted using DartStream Cloud Save.

---

### ⚡ RPG Progression System

Earn XP by completing fitness activities.

| Activity       | XP Reward |
| -------------- | --------- |
| 💧 Drink Water | +10 XP    |
| 🏋 Workout     | +25 XP    |
| 🚶 Walk        | +15 XP    |
| 🧘 Meditate    | +20 XP    |

#### Level Formula

```dart
Level = (XP ~/ 100) + 1;
```

| XP   | Level |
| ---- | ----- |
| 0    | 1     |
| 100  | 2     |
| 500  | 6     |
| 1000 | 11    |

---

### 💰 Gold System

Earn gold alongside XP.

| Activity       | Gold Reward |
| -------------- | ----------- |
| 💧 Drink Water | +5 Gold     |
| 🏋 Workout     | +10 Gold    |
| 🚶 Walk        | +5 Gold     |
| 🧘 Meditate    | +5 Gold     |

Gold can be used for:

- Shop purchases
- Equipment
- Inventory items
- Future hero upgrades

---

### 📅 Daily Quests

Current quests:

- Drink Water ×5
- Workout ×1
- Walk ×1
- Meditate ×1

Features:

- Persistent progress
- Automatic daily reset
- Bonus XP rewards
- Cloud-saved state

---

### 🔥 Streak System

Track consecutive active days.

Features:

- Daily streak tracking
- Automatic streak increment
- Streak reset after inactivity
- Future streak rewards

Example:

```text
🔥 Streak: 14 Days
```

---

### 🏆 Achievement System

Achievements unlock automatically based on player progress.

Examples:

- First Drink
- First Workout
- Reach Level 5
- Earn 100 Gold
- 7 Day Streak
- Boss Slayer

---

### 🎁 Daily Rewards

Players can claim daily rewards.

Reward examples:

- Gold
- XP
- Potions
- Equipment

---

### 🎒 Inventory System

Supported item types:

#### Consumables

- Small XP Potion
- Large XP Potion
- Gold Boost

#### Equipment

- Weapons
- Armor
- Accessories

Features:

- Inventory persistence
- Item usage
- Equipment management
- Cloud synchronization

---

### ⚔ Equipment System

Equipment slots:

- Weapon
- Armor
- Accessory

Example:

```text
Weapon: Iron Sword
Armor: Steel Armor
Accessory: Magic Ring
```

---

### 🛒 Shop System

Players can spend gold on:

- XP Potions
- Weapons
- Armor
- Accessories

---

### 👹 Boss Battle System

Example bosses:

- Forest Troll
- Goblin King
- Shadow Beast

Possible rewards:

```text
+200 XP
+100 Gold
Rare Equipment
```

---

## ☁ DartStream Integration

FitQuest uses DartStream Cloud Services for authentication and cloud persistence.

### Authentication

Used for:

- User Registration
- User Login
- Session Management
- Account Persistence

Files:

```text
lib/api/firebase_auth.dart
lib/state/session.dart
```

### Cloud Save

Used for:

- Hero Class
- XP
- Gold
- Streak
- Daily Quests
- Daily Rewards
- Inventory
- Equipment
- Achievements
- Boss Progress

Files:

```text
lib/services/cloud_save_service.dart
lib/api/dartstream.dart
```

---

## 🌐 API Endpoints Used

### Authentication

#### Register User

```http
POST {AUTH_HOST}/register
```

#### Login User

```http
POST {AUTH_HOST}/login
```

#### Refresh Session

```http
POST {AUTH_HOST}/refresh
```

### Cloud Save

#### Save Snapshot

```http
POST {API_HOST}/snapshot
```

#### Load Snapshot

```http
GET {API_HOST}/snapshot
```

#### Update Snapshot

```http
PUT {API_HOST}/snapshot
```

---

## 📂 Project Structure

```text
lib/

├── api/
│   ├── dartstream.dart
│   └── firebase_auth.dart
│
├── models/
│   ├── player_data.dart
│   ├── daily_quest.dart
│   └── hero_class.dart
│
├── screens/
│   ├── login_screen.dart
│   ├── register_screen.dart
│   ├── character_setup_screen.dart
│   ├── home_screen.dart
│   ├── inventory_screen.dart
│   └── profile_screen.dart
│
├── services/
│   ├── cloud_save_service.dart
│   ├── xp_service.dart
│   ├── level_service.dart
│   ├── achievement_service.dart
│   └── battle_service.dart
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

## 🛠 Tech Stack

### Frontend

- Flutter
- Dart
- Material Design 3

### Backend

- DartStream Cloud Services

### Authentication

- Firebase Authentication REST API
- DartStream Authentication Layer

### Persistence

- DartStream Cloud Save
- Snapshot Storage

---

## 🚀 Getting Started

### Install Dependencies

```bash
flutter pub get
```

### Environment Variables

Create a `.env` file:

```env
AUTH_HOST=
API_HOST=
FIREBASE_API_KEY=
```

### Run Application

```bash
flutter run
```

### Run On Chrome

```bash
flutter run -d chrome
```

### Run On Android Emulator

```bash
flutter emulators --launch Pixel_9_API_36
flutter run
```

---

## 🗺 Roadmap

### Completed

- Hero Classes
- XP System
- Gold System
- Daily Quests
- Streak Tracking
- Cloud Save
- Achievement System
- Inventory
- Equipment
- Shop
- Boss Battles

### Future Enhancements

- Avatar Customization
- PvP Battles
- Guild System
- Global Leaderboards
- Seasonal Events
- Multiplayer Challenges
- AI Fitness Recommendations

---

## 👨‍💻 Author

Built with Flutter and DartStream Cloud Services as a learning project focused on:

- Mobile Development
- Cloud Persistence
- Gamification
- RPG Mechanics
- Fitness Tracking
- DartStream APIs

FitQuest demonstrates how healthy habits can be transformed into an engaging RPG progression experience.
