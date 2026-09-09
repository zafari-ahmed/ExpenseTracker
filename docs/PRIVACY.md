# Privacy Policy — Expense Tracker

Last updated: 8 September 2026

Expense Tracker is a personal finance app that can read bank and card SMS on your Android device to create expense records. This policy describes what the app accesses and how that data is handled.

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
- Optional app lock PIN (stored as a one-way hash, not the PIN itself)
- SMS ignore-list phrases

This storage is protected by Android’s app sandbox. The current version does **not** add a separate encryption password on top of that sandbox.

## SMS access

If you grant SMS permission, the app reads incoming and recent inbox messages to detect card/bank expenses. It uses sender IDs and parsing rules you configure.

- SMS is processed on the device.
- Matching messages may be stored locally as transactions (including the original message body, so you can review or fix a parse).
- The app does not send SMS, and it does not upload SMS or transaction data to our servers.
- You can skip SMS permission and enter expenses manually.
- You can revoke SMS access at any time in Android Settings. New automatic imports will stop; existing local records remain until you delete them.

## Notifications

If you grant notification permission, the app can show local alerts for saved expenses, category limits, and upcoming bill dates. These notifications are created on the device.

## Photos and camera

A profile photo is optional. Choosing an image uses the system photo picker. Taking a photo uses the camera only if you tap that option and allow camera access. Photos stay on the device.

## Data sharing

We do not sell, rent, or share your SMS, transactions, or profile data with advertisers or third-party analytics services. The app has no cloud sync.

Android itself may include the app in device backups unless you turn backups off at the system level. A future Play Store build may disable auto-backup of app data.

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
