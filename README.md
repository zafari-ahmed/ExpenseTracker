# ExpenseTracker

A Flutter expense tracking app that captures spending from bank SMS messages, organizes transactions by category and card, and surfaces analytics on a clean fintech-style dashboard.

## Features

- SMS-based expense detection (Android)
- Multi-card / account tracking
- Dashboard with balances, trends, and category breakdown
- Transaction list with filters
- Analytics charts
- Profile settings (name, photo, preferences)
- Local persistence with Isar

## Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.x recommended)
- Dart SDK `>=3.9.0 <4.0.0` (bundled with Flutter)
- Android Studio / Xcode for platform builds
- On Android: SMS permission for auto-detection

Check your toolchain:

```bash
flutter --version
dart --version
```

## Getting started

### 1. Clone the repository

```bash
git clone git@github.com:zafari-ahmed/ExpenseTracker.git
cd ExpenseTracker
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Generate Isar code (if needed)

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 4. Run the app

```bash
flutter run
```

Or pick a device/emulator first:

```bash
flutter devices
flutter run -d <device_id>
```

## Project structure

```
lib/
  app.dart                 # App bootstrap
  main.dart
  core/                    # Theme, routing, services, database
  features/                # Feature-first modules
    dashboard/
    transactions/
    analytics/
    cards/
    settings/
    onboarding/
assets/                    # Icons, illustrations, images
packages/                  # Local dependency patches (e.g. Isar)
```

## Key dependencies

| Package | Purpose |
|---------|---------|
| `flutter_riverpod` | State management |
| `go_router` | Navigation |
| `isar` | Local database |
| `another_telephony` | SMS access |
| `fl_chart` | Charts |
| `permission_handler` | Runtime permissions |
| `image_picker` | Profile photo |

See `pubspec.yaml` for the full list and versions.

## Notes

- **Android application id:** `com.theexpensetracker.app`. Changing this later installs a *new* app and leaves the old local database behind — export a backup first.
- **Android SMS:** Grant SMS permission, set correct bank Sender IDs on cards, then use **Sync SMS now** in Settings if needed.
- **Backup:** Settings → Export backup before uninstalling, changing signing keys, or changing the package name. Installing an update *over* the same app does not wipe data.
- **Privacy policy URL:** set `AppInfo.privacyPolicyUrl` in `lib/core/constants/app_info.dart`.
- **Release signing:** copy `android/key.properties.example` to `android/key.properties` only when you are ready for a Play Store upload key. Until then, release builds keep the debug key so they can update the current phone install.
- **`pubspec.lock`** is committed so everyone resolves the same dependency versions (standard for Flutter apps).
- Design export cache under `.stitch/` is gitignored.

## License

This project is private / unpublished (`publish_to: "none"`). Add a license file if you plan to open-source it.
