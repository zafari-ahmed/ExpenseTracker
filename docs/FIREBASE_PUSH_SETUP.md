# Firebase push notification setup (Android)

This app uses **local notifications** when SMS is read on your phone (no server required).  
Use Firebase Cloud Messaging (FCM) only if you later want notifications sent from a **backend server** (e.g. web dashboard, shared family account, admin alerts).

---

## Part A — What works today (no Firebase)

| Event | When it fires | Setting |
|--------|----------------|---------|
| Expense added | SMS parsed and saved | Settings → **Expense alerts** |
| Category threshold | Spend reaches alert % or exceeds limit | Settings → **Spending Limits** |
| Bill reminder | Within N days of card bill date | Settings → **Bill Reminders** |

Edit notification text in:

`lib/core/notifications/notification_messages.dart`

---

## Part B — Firebase setup (optional, for remote push)

### 1. Create a Firebase project

1. Open [Firebase Console](https://console.firebase.google.com/)
2. Click **Add project**
3. Name it (e.g. `expense-tracker`) → continue → create project

### 2. Register the Android app

1. In the project overview, click **Android** icon
2. **Android package name**: must match your app id  
   Current value: `com.example.expense_tracker`  
   (see `android/app/build.gradle.kts` → `applicationId`)
3. **App nickname**: optional (e.g. Expense Tracker)
4. **Debug signing SHA-1** (optional for now; required for some Google Sign-In flows):
   ```bash
   cd android
   ./gradlew signingReport
   ```
   Copy the SHA-1 under `debug` variant
5. Click **Register app**

### 3. Download `google-services.json`

1. Download **google-services.json**
2. Place it at:
   ```
   android/app/google-services.json
   ```

### 4. Add Firebase Gradle plugins

**`android/settings.gradle.kts`** (or root `build.gradle.kts` depending on Flutter version):

```kotlin
plugins {
    id("com.google.gms.google-services") version "4.4.2" apply false
}
```

**`android/app/build.gradle.kts`** — add at the top with other plugins:

```kotlin
plugins {
    id("com.google.gms.google-services")
}
```

**`android/build.gradle.kts`** — if using older Flutter template, add classpath in `buildscript` instead.

### 5. Add Flutter packages

In `pubspec.yaml`:

```yaml
dependencies:
  firebase_core: ^3.8.1
  firebase_messaging: ^15.1.6
```

Run:

```bash
flutter pub get
```

### 6. Initialize Firebase in the app

In `lib/main.dart` (before `runApp`):

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // Handle data payload if you add a backend later.
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  // ... existing notification + workmanager init
}
```

### 7. Request permission & get FCM token

After onboarding (Android 13+ also needs notification permission — already handled):

```dart
final messaging = FirebaseMessaging.instance;
await messaging.requestPermission();
final token = await messaging.getToken();
// Send `token` to your backend and store it per user/device.
```

### 8. Handle foreground messages

```dart
FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  final title = message.notification?.title ?? 'Expense Tracker';
  final body = message.notification?.body ?? '';
  // Show with your existing NotificationService or flutter_local_notifications.
});
```

### 9. Test from Firebase Console

1. Firebase Console → **Engage** → **Messaging**
2. **Create your first campaign** → **Firebase Notification messages**
3. Title + body → **Send test message**
4. Paste the FCM device token from step 7

### 10. Production checklist

- [ ] Change `applicationId` from `com.example.expense_tracker` to your own (e.g. `com.yourcompany.expense_tracker`)
- [ ] Add **release** signing SHA-1 / SHA-256 in Firebase project settings
- [ ] Use a backend to send targeted messages (never ship server keys in the app)
- [ ] Keep `google-services.json` out of public repos if the project is private production

---

## Part C — SMS expense alerts vs FCM

| Approach | Best for |
|----------|----------|
| **Local notifications** (current) | SMS read on device → instant alert, works offline |
| **FCM** | Server-triggered alerts, multi-device sync, marketing |

For “bank SMS arrived → expense saved → notify user”, **local notifications are correct** because parsing happens on the phone. FCM is useful when a **server** decides to push (e.g. weekly summary email-style push, family member added a expense).

---

## Troubleshooting

| Issue | Fix |
|--------|-----|
| No notifications on Android 13+ | Grant **Notifications** permission in system settings |
| No notifications when app is killed | Ensure SMS listener + background handler run; check battery optimization isn’t blocking the app |
| Bill reminders not firing | Open app once after install; Workmanager runs ~every 24h |
| Duplicate threshold alerts | Alerts are deduped per category per period (warning at alert %, once at exceed) |

---

## Files in this project

| File | Purpose |
|------|---------|
| `lib/core/notifications/notification_messages.dart` | **Edit all notification text here** |
| `lib/core/services/notification_service.dart` | Shows local notifications |
| `lib/core/services/notification_dispatcher.dart` | Expense + threshold logic |
| `lib/core/services/bill_reminder_service.dart` | Bill date reminders |
| `lib/core/services/background_tasks.dart` | Daily bill reminder task |
