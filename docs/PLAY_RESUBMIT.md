# Play production resubmit (SMS policy)

Closed testing can pass while **production** still fails. That is expected.
Google reviewed production against a **different SMS use case** than this app.

## Why it was rejected

You declared:

> SMS-based financial transactions (e.g., 5 digit messages), and related
> activity including OTP account verification for financial transactions and
> fraud detection

This app does **not** do OTP, 5-digit short codes, or fraud detection.
It **ignores** OTP SMS. It reads **bank/card debit SMS** and turns them into
expenses (SMS-based **money management**).

Both rejection bullets (in-app experience + store listing) come from that mismatch.

## What this build already changed (1.0.1+3)

- Extra SMS/call permissions still stripped (`SEND_SMS`, call log, phone state).
- Onboarding disclosure states READ_SMS / RECEIVE_SMS, on-device only, no OTP.
- Denying SMS still opens the app (manual expenses).
- Empty dashboard: “No bank SMS found” + **Try a sample debit SMS** so a
  reviewer with no Pakistani bank SMS can still see a parsed expense.

## Play Console (must do by hand)

### 1. Sensitive app permissions (most important)

**Policy → App content → Sensitive app permissions** (SMS)

1. Open the declaration and **edit** it. Do **not** keep the 5-digit / OTP use case.
2. Core functionality: **SMS-based money management**
   (wording may be “Financial services / SMS-based money management”).
   **Do not** select OTP, 5-digit messages, account verification, or fraud detection.
3. Permissions in the app: **READ_SMS** and **RECEIVE_SMS** only.
4. Video: new unlisted YouTube link (script below).
5. Short explanation to paste:

```
Expense Tracker is SMS-based money management. It reads and receives bank and
card debit SMS on the device and creates local expense records. It does not send
SMS, does not read OTP or 5-digit verification codes, and does not upload SMS.
Users can skip SMS and enter expenses manually.
```

### 2. Store listing (must match the same use case)

**Short description** (80 chars max):

```
Track expenses from bank and wallet debit SMS. Data stays on your phone.
```

**Full description — start with this:**

```
Expense Tracker is SMS-based money management for Android.

It reads the debit SMS your bank or card already sends (for example “charged at
FOODPANDA for PKR-1,250”) and turns matching messages into expenses on this
phone. It does not send SMS and it does not use OTP or 5-digit verification codes.

You can also add expenses by hand. All cards, SMS parses, and transactions stay
in the app’s private storage. Nothing is uploaded to our servers.

Allow SMS to auto-track spends. If you skip SMS, the rest of the app still works.
```

### 3. Data safety

- SMS / messages: collected **for app functionality**, processed **on the device**.
- Not shared with third parties.
- Not uploaded to a developer server.

### 4. Privacy policy URL

Update the hosted page (`docs/privacy.html`) then use:

`https://zafari-ahmed.github.io/ExpenseTracker/privacy.html`

(or `/privacy` if that URL already works.)

The policy must say the app **reads SMS** for bank/card expense tracking.

### 5. Demo video (30–90 seconds, YouTube unlisted)

Show in this order:

1. App launch
2. SMS disclosure (“Allow SMS tracking”)
3. Android SMS permission granted
4. Dashboard empty state **or** a real bank debit SMS
5. Tap **Try a sample debit SMS** (or show a real inbox debit SMS)
6. The expense appearing (place + amount) on the dashboard

Say on camera or as on-screen text: “This app reads bank debit SMS to track
expenses. It does not read OTP.”

### 6. App access

No login. In **App content → App access**, say:

```
No account. After onboarding, allow SMS, then on the dashboard tap
“Try a sample debit SMS” if the device has no bank messages.
```

## Rebuild and send to production

```bash
flutter build appbundle --release
```

Upload `build/app/outputs/bundle/release/app-release.aab` to
**Production → Create new release** (version **1.0.1 (3)**).

Do **not** send another closed-testing-only release. Production is the review
that failed. Closed testing does not need to be repeated.

Release name: `1.0.1 (3)`

Release notes:

```
Policy update: clearer SMS money-management disclosure, continue without SMS,
and a sample debit SMS so reviewers can verify expense tracking without a bank inbox.
```
