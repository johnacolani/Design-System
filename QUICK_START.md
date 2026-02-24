# Quick Start Guide

## 🚀 Running the App

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Run on Web (Easiest)
```bash
flutter run -d chrome
```

### 3. Test Authentication
- Click "Get started" → Welcome Screen appears
- Try "Continue as Guest" → Goes to onboarding
- Try "Sign up with Email" → Create account
- Try "Sign in with Google" → Google Sign-In (requires Firebase setup)

### 4. Create a Project
- Fill in project name and description
- Pick a primary color
- Click "Create Design System"

### 5. Explore Features
- Navigate through design tokens from dashboard
- Add colors, typography, spacing, etc.
- Browse Material Design and Cupertino libraries
- Export your design system

## 📱 Testing Responsive Design

### In Chrome DevTools:
1. Press `F12` to open DevTools
2. Click device toolbar icon (or `Ctrl+Shift+M`)
3. Select different devices (iPhone, iPad, Desktop)
4. Test navigation and layout

### On Real Devices:
```bash
# List devices
flutter devices

# Run on device
flutter run -d <device-id>
```

## 🔍 What to Review

1. **Home Screen**: Logo, navigation, project preview
2. **Welcome Screen**: All three options work
3. **Authentication**: Email and Google sign-in
4. **Dashboard**: All design token screens accessible
5. **Color Picker**: Multiple color selection works
6. **Export**: Can export to different formats
7. **Responsive**: Works on mobile, tablet, desktop

## 🐛 Found an Issue?

Describe it clearly:
- **What**: What feature/button doesn't work
- **Where**: Which screen
- **Expected**: What should happen
- **Actual**: What actually happens

Example:
> "The color picker doesn't allow selecting multiple colors on the Colors screen. Expected: Select 5 colors at once. Actual: Only one color can be selected."

## ✅ Ready to Push?

See `GITHUB_PUSH.md` for step-by-step instructions.
