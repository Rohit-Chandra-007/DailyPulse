# DailyPulse

A minimalist mood tracking app built with Flutter. Track your emotions, understand patterns, and maintain your mental well-being.

**Inspired by beautiful designs from Dribbble**

## Features

- 📝 Log moods with 6 emotion levels
- 📅 View history with date timeline
- 📊 Analyze patterns with insights
- 🔐 Secure Firebase authentication
- ☁️ Offline-first with cloud sync
- 🎨 Light & dark themes

## Setup

**Requirements:** Flutter SDK ≥3.9.2

```bash
# Clone repository
git clone https://github.com/yourusername/dailypulse.git
cd dailypulse

# Install dependencies
flutter pub get

# Generate Hive adapters
flutter pub run build_runner build

# Run app
flutter run
```

**Firebase Setup:**
1. Create Firebase project
2. Add `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
3. Enable Authentication & Firestore

## Screenshots

### Light Theme
<p float="left">
  <img src="screenshots/light/light_sign_in.png" width="200" />
  <img src="screenshots/light/light_home.png" width="200" />
  <img src="screenshots/light/light_histroy.png" width="200" />
  <img src="screenshots/light/light_insights.png" width="200" />
</p>

### Dark Theme
<p float="left">
  <img src="screenshots/dark/dark_sign_in.png" width="200" />
  <img src="screenshots/dark/dark_home.png" width="200" />
  <img src="screenshots/dark/dark_histroy.png" width="200" />
  <img src="screenshots/dark/dark_setting.png" width="200" />
</p>

## Architecture

```
lib/
├── core/
│   ├── app_theme/         # Theme configuration
│   ├── constant/          # App constants
│   ├── providers/         # State management
│   ├── routes/            # Navigation
│   ├── utils/             # Utilities
│   └── widgets/           # Reusable widgets
├── data/
│   ├── local/             # Hive storage
│   ├── models/            # Data models
│   ├── remote/            # Firestore
│   ├── repo/              # Repositories
│   └── services/          # Background sync
├── features/
│   ├── auth/              # Sign in/up
│   ├── history/           # Mood history
│   ├── home/              # Mood logging
│   ├── insights/          # Analytics
│   └── settings/          # App settings
├── app_scaffold.dart
└── main.dart
```

**State Management:** Provider for global state, setState for local UI state  
**Data Flow:** Local-first (Hive) → Background sync (Firestore)

## Emotion Logic

### Mood Scale (0-5)
| Level | Emoji | Label | Color |
|-------|-------|-------|-------|
| 0 | 😢 | Terrible | Pink |
| 1 | 😕 | Bad | Orange |
| 2 | 😐 | Okay | Yellow |
| 3 | 🙂 | Good | Green |
| 4 | 😄 | Great | Purple |
| 5 | 😡 | Angry | Red |

### Analytics Calculation

**Average Mood:**
```dart
avgMood = sum(all mood levels) / total entries
```

**Mood Distribution:**
```dart
percentage = (count of specific mood / total entries) × 100
```

**Time Filtering:**
- Week: Entries from last 7 days
- Month: Entries from last 30 days
- All: All recorded entries

### Design Choices

**Pastel Colors:** Calming, reduces visual stress  
**Emoji-First:** Universal, instant recognition  
**Minimalist UI:** Focus on emotions, not interface  
**Offline-First:** Always available, instant saves  
**Dark Mode:** Eye comfort, battery saving

**Inspired by:** Beautiful mood tracking designs from Dribbble

## Tech Stack

- **Framework:** Flutter 3.9.2+
- **State Management:** Provider
- **Local Database:** Hive
- **Backend:** Firebase (Auth + Firestore)
- **UI:** Material Design 3

## License

MIT License - feel free to use this project for learning or personal use.

---

**Built with Flutter** • Inspired by Dribbble designs
