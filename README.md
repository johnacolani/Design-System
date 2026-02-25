# Design System Builder

A comprehensive Flutter application for creating, managing, and exporting design systems for Flutter, Kotlin (Android), and Swift (iOS) projects. Think of it as Figma, but specifically designed for building complete design systems.

## 🎨 Features

### Core Functionality
- **Project Management**: Create and manage multiple design system projects
- **Design Tokens**: Comprehensive management of all design tokens
- **Multi-Platform Export**: Export to Flutter, Kotlin (Android), and Swift (iOS)
- **Design Library**: Browse and import from Material Design and Cupertino (iOS) design systems

### Design Token Management
- ✅ **Colors**: Primary, semantic, and custom color palettes with color picker, scales, and suggestions
- ✅ **Typography**: Font families, weights, sizes, and text styles
- ✅ **Spacing**: Spacing scale and values
- ✅ **Border Radius**: Corner radius values
- ✅ **Shadows**: Elevation and shadow definitions
- ✅ **Effects**: Glass morphism, overlays, and visual effects
- ✅ **Components**: Buttons, cards, inputs, navigation, avatars
- ✅ **Grid**: Layout grid system with breakpoints
- ✅ **Icons**: Icon size definitions
- ✅ **Gradients**: Gradient definitions
- ✅ **Roles**: Role-based theming

### Design Libraries
- ✅ **Material Design**: Browse and import Material components, colors (with full palette support), icons, and typography
- ✅ **Cupertino (iOS)**: Browse and import iOS system colors, icons, components, and typography

### User Features
- ✅ **Authentication**: Sign up with email/password, Google Sign-In, or continue as guest
- ✅ **User Profile**: View profile, membership status, and project statistics
- ✅ **Settings**: Account settings, app preferences, privacy, and support options
- ✅ **Project Preview**: Visual preview of created projects on home screen

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.10.0 or higher)
- Dart SDK
- Android Studio / VS Code with Flutter extensions
- Firebase account (for authentication and data storage)

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd design_system
```

2. Install dependencies:
```bash
flutter pub get
```

3. Configure Firebase (see `FIREBASE_SETUP.md` for detailed instructions):
```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase
flutterfire configure
```

4. Run the app:
```bash
# For web
flutter run -d chrome

# For macOS
flutter run -d macos

# For Windows
flutter run -d windows
```

### Supported Platforms
- ✅ Android
- ✅ iOS
- ✅ macOS
- ✅ Web
- ✅ Windows
- ✅ Linux

## 📁 Project Structure

```
lib/
├── models/              # Data models for design system
│   ├── design_system.dart
│   └── design_system_wrapper.dart
├── providers/           # State management
│   └── design_system_provider.dart
├── screens/             # UI screens
│   ├── onboarding_screen.dart
│   ├── dashboard_screen.dart
│   ├── colors_screen.dart
│   ├── typography_screen.dart
│   ├── design_library_screen.dart
│   ├── material_picker_screen.dart
│   └── cupertino_picker_screen.dart
└── main.dart            # App entry point
```

## 🎯 Usage

### Creating a New Design System

1. Launch the app
2. Enter your project name and description
3. Pick a primary color
4. Start adding design tokens from the dashboard

### Using Design Libraries

1. Click the "Design Library" button from the dashboard
2. Choose between Material Design or Cupertino (iOS)
3. Browse colors, icons, components, or typography
4. Click "Add" to import items into your design system
5. **Material Color Palettes**: Import complete color palettes (Blue, Green, Red, Orange, Purple, Teal, Grey) with all shades (50-900)

### Authentication Flow

1. **Sign Up**: Create an account with email/password or Google Sign-In
2. **After Signup**: You'll be redirected to the login screen with your credentials pre-filled
3. **Login**: Sign in to access your projects and profile
4. **Guest Mode**: Continue as guest to try the app without creating an account

### Managing Design Tokens

Navigate to specific sections from the dashboard:
- **Colors**: Manage color palettes and semantic colors
- **Typography**: Configure fonts, sizes, weights, and text styles
- **Spacing**: Define spacing scale
- **Components**: Configure button styles, cards, inputs, etc.

## 🔧 Development Status

### ✅ Completed Features
- [x] Project structure and dependencies
- [x] Data models for design system
- [x] State management with Provider
- [x] User authentication (Email, Google, Guest mode)
- [x] Firebase integration (Auth, Firestore, Storage)
- [x] Welcome screen with authentication options
- [x] Onboarding flow with project creation
- [x] Home screen with project preview (Figma-inspired design)
- [x] Responsive design for web, mobile, and desktop
- [x] Color picker with multiple color selection
- [x] Color management with scales and suggestions
- [x] Typography management (fonts, weights, sizes, styles)
- [x] Spacing management
- [x] Border radius management
- [x] Shadows management
- [x] Effects management
- [x] Components management
- [x] Grid configuration
- [x] Icons management
- [x] Gradients management
- [x] Roles management
- [x] Main navigation/dashboard UI
- [x] Material Design library picker with color palette import
- [x] Cupertino (iOS) design library picker
- [x] Project save/load functionality
- [x] JSON export functionality
- [x] Flutter code generator
- [x] Kotlin (Android) code generator
- [x] Swift (iOS) code generator
- [x] Preview functionality
- [x] User profile management
- [x] Project management (list, open, delete)
- [x] Settings screen with account and app preferences
- [x] Signup flow with automatic navigation to login
- [x] Material Design color palette import functionality

## 📦 Dependencies

- `provider`: State management
- `go_router`: Navigation and routing
- `flutter_colorpicker`: Color selection
- `path_provider`: File system access
- `file_picker`: File selection
- `json_annotation`: JSON serialization
- `intl`: Internationalization
- `firebase_core`: Firebase core functionality
- `firebase_auth`: User authentication
- `cloud_firestore`: Cloud database
- `firebase_storage`: File storage
- `google_sign_in`: Google Sign-In authentication

## 🛠️ Development

### Running Tests
```bash
flutter test
```

### Building for Production
```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release

# Web
flutter build web --release

# Windows
flutter build windows --release

# macOS
flutter build macos --release
```

## 📝 Design System JSON Format

The app generates design systems in a structured JSON format:

```json
{
  "designSystem": {
    "name": "Your Design System",
    "version": "1.0.0",
    "description": "Description",
    "created": "2025-02-24",
    "colors": { ... },
    "typography": { ... },
    "spacing": { ... },
    "borderRadius": { ... },
    "shadows": { ... },
    "effects": { ... },
    "components": { ... },
    "grid": { ... },
    "icons": { ... },
    "gradients": { ... },
    "roles": { ... }
  }
}
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is licensed under the MIT License.

## 🙏 Acknowledgments

- Material Design by Google
- Human Interface Guidelines by Apple
- Flutter team for the amazing framework

---

**Note**: This project is currently in active development. Some features may be incomplete or subject to change.
