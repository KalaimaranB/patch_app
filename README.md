# Patch App

A Flutter application for Patch Medical — enabling patients and healthcare providers to manage medical patch devices, track dosage history, and monitor device status.

## Tech Stack

- **Framework**: Flutter (Dart)
- **Backend**: Supabase
- **State Management**: Riverpod
- **Routing**: GoRouter
- **Charts**: fl_chart

---

## Development Setup

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (stable channel)
- Android Studio or Xcode (for emulators/simulators)
- A `google-services.json` file in `android/app/` (get from Firebase Console)

### Run Locally

```bash
flutter pub get
flutter run
```

---

## CI/CD & Distribution

This project uses **GitHub Actions** + **Firebase App Distribution** to automatically build and distribute the Android app to testers on every push to `master`.

### How It Works

1. You push code to the `master` branch
2. GitHub Actions automatically builds a release APK
3. The APK is uploaded to Firebase App Distribution
4. Testers receive a notification and can install the new version with one tap

---

## 📱 Tester Onboarding Guide

### For Android Testers

Follow these steps to get set up as a tester. You only need to do this **once**.

#### Step 1: Accept the Invite

You'll receive an email invitation from Firebase App Distribution. **Tap the link** in the email to accept.

#### Step 2: Install the Firebase App Tester App

1. On your Android device, open the invitation link from the email
2. You'll be prompted to install the **Firebase App Tester** app — install it
3. Alternatively, download it directly: [Firebase App Tester on Google Play](https://play.google.com/store/apps/details?id=com.google.firebase.appdistribution)

#### Step 3: Enable "Install from Unknown Sources"

Since the app isn't on the Play Store, your phone needs permission to install it:

1. Go to **Settings → Apps → Special app access → Install unknown apps**  
   *(path may vary by phone manufacturer)*
2. Find **Firebase App Tester** in the list
3. Toggle **"Allow from this source"** to ON

> **Samsung devices**: Settings → Biometrics and Security → Install Unknown Apps  
> **Pixel/Stock Android**: Settings → Apps → Special Access → Install Unknown Apps

#### Step 4: Get Updates

Every time a new build is available:
1. You'll receive a **push notification** (if notifications are enabled for Firebase App Tester)
2. Open the Firebase App Tester app
3. Tap **"Download"** next to the latest release
4. The new version installs over the old one — your data is preserved

That's it! No need to uninstall/reinstall. Just tap the notification when a new build is ready.

---

### For iOS Testers

> ⚠️ **iOS distribution is currently manual.** We don't yet have an Apple Developer Program membership, which is required for remote iOS distribution (TestFlight/Ad Hoc).

**Current process**: Contact the developer to install the latest build via USB + Xcode.

---

## 🔐 GitHub Secrets (For Maintainers)

The following secrets must be configured in the **GitHub repo → Settings → Secrets and variables → Actions**:

| Secret Name | Description | How to Get It |
|---|---|---|
| `FIREBASE_APP_ID` | Android app's Firebase App ID | Firebase Console → Project Settings → Your Apps → App ID (e.g. `1:1234567890:android:abc123`) |
| `FIREBASE_SERVICE_ACCOUNT` | Firebase service account JSON (entire file content) | Firebase Console → Project Settings → Service accounts → Generate new private key → paste the entire JSON |
| `GOOGLE_SERVICES_JSON` | Base64-encoded `google-services.json` | Run: `base64 -i android/app/google-services.json` and paste the output |

### How to Base64 Encode google-services.json

On macOS/Linux, run this in the project root:

```bash
base64 -i android/app/google-services.json
```

Copy the entire output and paste it as the `GOOGLE_SERVICES_JSON` secret value.

---

## 🧪 Firebase App Distribution Setup (For Maintainers)

### Creating a Tester Group

1. Go to [Firebase Console](https://console.firebase.google.com) → your project
2. Navigate to **App Distribution** (in the left sidebar under "Release & Monitor")
3. Click **Testers & Groups**
4. Create a group called **`testers`** (this matches the workflow configuration)
5. Add tester email addresses to the group

### Inviting Testers

1. In the **Testers & Groups** tab, add emails of your testers
2. They'll receive an invitation email with setup instructions
3. Each tester follows the onboarding steps above

---

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── router/
│   └── app_router.dart       # GoRouter configuration
├── providers/                # Riverpod providers
├── screens/                  # App screens
│   ├── login_screen.dart
│   ├── register_screen.dart
│   ├── main_shell.dart       # Bottom navigation shell
│   ├── dashboard_screen.dart
│   ├── devices_screen.dart
│   ├── dosage_history_screen.dart
│   ├── settings_screen.dart
│   └── help_screen.dart
├── theme/
│   └── app_theme.dart        # Theme configuration
├── utils/
│   └── responsive_layout.dart
└── widgets/                  # Reusable widgets
    ├── animated_list_item.dart
    ├── pressable_card.dart
    └── shimmer_widget.dart
```

---

## License

Proprietary — Patch Medical © 2025
