# Privacy Policy — Expense Tracker

Last updated: 7 October 2026

Expense Tracker is a personal finance app for **SMS-based money management**. It can read bank and card debit SMS on your Android device to create expense records. This policy describes what the app accesses and how that data is handled.

## Who we are

Expense Tracker is a local-only Android application. It does not create an online account and it does not operate a backend server for your spending data.

## Data stored on your device

The app stores the following on your phone, in the app’s private storage:

- Profile name and optional profile photo
- Cards / accounts you add (bank name, card nickname, last four digits, SMS sender IDs, bill date)
- SMS parsing rules and sample messages you save
- Transactions created from SMS or entered manually (amount, merchant/place, category, date, original SMS body)
- Categories, keywords, and spending limits
- Notification and display preferences
- SMS ignore-list phrases

This storage is protected by Android’s app sandbox. The current version does **not** add a separate encryption password on top of that sandbox.

## SMS access

If you grant SMS permission, the app uses **READ_SMS** and **RECEIVE_SMS** to read inbox and incoming messages and detect **bank and card debit / expense** SMS. Matching messages are saved locally as transactions.

- SMS is processed on the device only.
- The app does **not** send SMS.
- The app does **not** use SMS for OTP, 5-digit verification codes, account login, or fraud detection. Those messages are ignored.
- The app does not upload SMS or transaction data to our servers.
- You can skip SMS permission and enter expenses manually. The rest of the app still works.
- You can revoke SMS access at any time in Android Settings. New automatic imports will stop; existing local records remain until you delete them.

## Notifications

If you grant notification permission, the app can show local alerts for saved expenses, category limits, and upcoming bill dates. These notifications are created on the device.

## Photos and camera

A profile photo is optional. Choosing an image uses the system photo picker. Taking a photo uses the camera only if you tap that option and allow camera access. Photos stay on the device.

## Data sharing

We do not sell, rent, or share your SMS, transactions, or profile data with advertisers or third-party analytics services. The app has no cloud sync.

Android itself may include the app in device backups unless you turn backups off at the system level. This Play Store build disables auto-backup of app data (`allowBackup=false`).

## Your controls

In Settings you can:

- Export a backup file of your local data
- Import a backup file (this replaces data on that installation)
- Delete local data from the app
- Uninstall the app (this removes local data unless Android offers to keep it)

## Children

The app is not directed at children under 13.

## Changes

We may update this policy when the app’s data practices change. The updated date at the top will change.

## Contact

If you have questions about this policy, contact the developer through the Google Play store listing for Expense Tracker.
