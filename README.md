# 🕌 Quran App

A complete mobile audio application for listening to Quranic recitations, built with **Flutter** and **Firebase**, featuring biometric security.

> Developed by **CHABANE Rym** & **HAMZA Nacera Nour** — ING3 Sécurité · USTHB · 2025–2026

---

## ✨ Features

### 🔐 Biometric Authentication
- Fingerprint verification required on first launch using `local_auth`
- Audio feedback on successful authentication via `audioplayers`
- Redirects to system settings if no fingerprint is configured (`android_intent_plus`)
- Biometric verification also required to delete a favorite (double security)

### 🔑 Firebase Authentication
- Email + password login with "Forgot Password" support
- Registration with required fields: first name, last name, date of birth
- Age verification — user must be at least 13 years old (`isAtLeast13()`)
- Password reset via Firebase email
- Centralized `AuthService` for account creation, login, and logout

### 🎵 Audio Player & Playlist
- Reciters and surahs fetched from the Quran.com API via `quran.yousefheiba.com`
- Real-time search and dynamic filtering of reciters and surahs
- Playback controls: Play · Pause · Next · Previous · Repeat
- Background playback via `flutter_background_service` + persistent notification
- Persistent mini-player bar at the bottom of the screen during playback

### ❤️ Favorites & Security
- Add to favorites via heart button on the player
- Favorites synced online via Firestore, accessible across devices
- Dedicated favorites page with direct playback
- Secure deletion: `removeFavoriteById()` triggers a new biometric check
- Loop mode for continuous replay of a surah

### 📊 Statistics
- Personalized welcome message with full username from Firebase
- Total listening time displayed in hours and minutes
- Monthly histogram (minutes per day) using `fl_chart`
- Top most-listened surahs ranking
- Editable monthly goal (default: 20h) stored locally with `SharedPreferences`

---

## 🏗️ Architecture

```
lib/
├── models/       # Data structures (Surah, Reciter, Favorite...)
├── pages/        # app_theme, biometric, favorites, login, main,
│                 # player, reciters_list, reset_password,
│                 # signup, stats, surah_list
├── widgets/      # mini_player.dart
└── services/     # api, audio_player, auth, biometric,
                  # favorites, notification, stats, user
```

---

## 📦 Packages Used

| Category | Package | Usage |
|---|---|---|
| Security | `local_auth` | Biometric fingerprint authentication |
| Security | `android_intent_plus` | Redirect to system settings |
| Firebase | `firebase_auth` | User account management |
| Firebase | `cloud_firestore` | Favorites & online statistics |
| Audio | `just_audio` | Advanced audio playback (state, duration, loop) |
| Audio | `flutter_background_service` | Background playback |
| Audio | `flutter_local_notifications` | Persistent notification during playback |
| Audio | `audioplayers` | Biometric success sound |
| UI | `fl_chart` | Daily listening histogram |
| Data | `shared_preferences` | Local monthly goal storage |
| Network | `http` | External Quran API calls |

---

## 🚀 Getting Started

```bash
# Clone the repository
git clone https://github.com/rymchabane/Quran-App.git
cd Quran-App

# Install dependencies
flutter pub get

# Run the app
flutter run
```

> **Note:** Requires Android device or emulator with a configured fingerprint for biometric features.

---

## 🔧 Requirements

- Flutter SDK
- Android device/emulator (API 23+)
- Firebase project configured (`google-services.json` in `android/app/`)
