# Firebase Setup Guide for Design System Builder

This guide will help you connect Firebase to your Design System Builder project for Web, macOS, and Windows platforms.

## Prerequisites

1. **Firebase Account**: You need a Firebase account. If you don't have one, create it at [Firebase Console](https://console.firebase.google.com/)
2. **FlutterFire CLI**: Install the FlutterFire CLI tool
3. **Firebase Project**: Create a Firebase project named "design-system" (or use your existing project)

## Step 1: Install FlutterFire CLI

```bash
dart pub global activate flutterfire_cli
```

## Step 2: Login to Firebase

```bash
firebase login
```

## Step 3: Configure Firebase for Your Project

Navigate to your project directory and run:

```bash
flutterfire configure
```

This command will:

- Detect your Firebase projects
- Let you select the "design-system" project (or create a new one)
- Configure Firebase for Web, macOS, and Windows platforms
- Generate the `lib/firebase_options.dart` file with your actual Firebase credentials

### During Configuration:

1. **Select Firebase Project**: Choose "design-system" or create a new one
2. **Select Platforms**:
   - ✅ Web
   - ✅ macOS
   - ✅ Windows
   - ❌ iOS (skip)
   - ❌ Android (skip)

3. **For Web**: The CLI will automatically configure your web app
4. **For macOS**: You may need to provide bundle ID (default: `com.example.designSystem`)
5. **For Windows**: The CLI will configure Windows app

## Step 4: Enable Firebase Services

In the Firebase Console (https://console.firebase.google.com/), enable the following services:

### Authentication

1. Go to **Authentication** → **Get Started**
2. Enable **Email/Password** sign-in method
3. Optionally enable **Google** sign-in for better UX

### Firestore Database

1. Go to **Firestore Database** → **Create Database**
2. Start in **Test Mode** (for development)
3. Choose a location close to your users

### Storage

1. Go to **Storage** → **Get Started**
2. Start in **Test Mode** (for development)
3. Choose the same location as Firestore

## Step 5: Install Dependencies

After configuration, install the Firebase packages:

```bash
flutter pub get
```

## Step 6: Verify Setup

Run the app to verify Firebase is connected:

```bash
# For Web
flutter run -d chrome

# For macOS
flutter run -d macos

# For Windows
flutter run -d windows
```

## Manual Configuration (Alternative)

If you prefer to configure manually or the CLI doesn't work:

### Web Configuration

1. Go to Firebase Console → Project Settings → Your apps → Web app
2. Copy the Firebase configuration object
3. Update `lib/firebase_options.dart` with your actual values:

```dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'your-actual-api-key',
  appId: 'your-actual-app-id',
  messagingSenderId: 'your-sender-id',
  projectId: 'design-system',
  authDomain: 'design-system.firebaseapp.com',
  storageBucket: 'design-system.appspot.com',
);
```

### macOS Configuration

1. Go to Firebase Console → Project Settings → Your apps → macOS app
2. Download `GoogleService-Info.plist`
3. Place it in `macos/Runner/`
4. Update `lib/firebase_options.dart` with macOS values

### Windows Configuration

1. Go to Firebase Console → Project Settings → Your apps → Windows app
2. Download the configuration file
3. Update `lib/firebase_options.dart` with Windows values

## Security Rules

### Firestore Rules (for development)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### Storage Rules (for development)

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

⚠️ **Note**: These are development rules. Update them for production!

## What You Need to Provide

To complete the setup, you need:

1. **Firebase Project ID**: `design-system` (or your project name)
2. **Web API Key**: From Firebase Console → Project Settings → Web app
3. **App IDs**: For Web, macOS, and Windows platforms
4. **Messaging Sender ID**: From Firebase Console → Project Settings

## Troubleshooting

### Error: "Firebase not configured"

- Make sure you've run `flutterfire configure`
- Check that `lib/firebase_options.dart` exists and has correct values
- Verify Firebase project name matches

### Error: "Platform not supported"

- Make sure you selected the correct platforms during `flutterfire configure`
- For macOS/Windows, ensure you have the latest Flutter SDK

### Web: "Firebase SDK not found"

- Check that `web/index.html` includes Firebase SDK (already added)
- Verify Firebase configuration in Firebase Console

## Next Steps

After Firebase is configured:

1. ✅ Authentication will work for user login/signup
2. ✅ Firestore can store design system projects
3. ✅ Storage can store user files and assets
4. ✅ Real-time sync across devices

## Support

If you encounter issues:

1. Check Firebase Console for project status
2. Verify all services are enabled
3. Check FlutterFire documentation: https://firebase.flutter.dev/
