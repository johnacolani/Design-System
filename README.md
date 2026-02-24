# Design System Builder

A comprehensive Flutter application for creating, managing, and exporting design systems for Flutter, Kotlin (Android), and Swift (iOS) projects. Think of it as Figma, but specifically designed for building complete design systems.

## 🎨 Features

### Core Functionality
- **Project Management**: Create and manage multiple design system projects
- **Design Tokens**: Comprehensive management of all design tokens
- **Multi-Platform Export**: Export to Flutter, Kotlin (Android), and Swift (iOS)
- **Design Library**: Browse and import from Material Design and Cupertino (iOS) design systems

### Design Token Management
- ✅ **Colors**: Primary, semantic, and custom color palettes
- ✅ **Typography**: Font families, weights, sizes, and text styles
- 🔄 **Spacing**: Spacing scale and values
- 🔄 **Border Radius**: Corner radius values
- 🔄 **Shadows**: Elevation and shadow definitions
- 🔄 **Effects**: Glass morphism, overlays, and visual effects
- 🔄 **Components**: Buttons, cards, inputs, navigation, avatars
- 🔄 **Grid**: Layout grid system with breakpoints
- 🔄 **Icons**: Icon size definitions
- 🔄 **Gradients**: Gradient definitions
- 🔄 **Roles**: Role-based theming

### Design Libraries
- ✅ **Material Design**: Browse and import Material components, colors, icons, and typography
- ✅ **Cupertino (iOS)**: Browse and import iOS system colors, icons, components, and typography

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.10.0 or higher)
- Dart SDK
- Android Studio / VS Code with Flutter extensions

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

3. Generate JSON serialization code:
```bash
flutter pub run build_runner build
```

4. Run the app:
```bash
flutter run
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
- [x] Onboarding flow with project creation
- [x] Color picker widget
- [x] Basic color management UI
- [x] Basic typography management UI
- [x] Main navigation/dashboard UI
- [x] Material Design library picker
- [x] Cupertino (iOS) design library picker

### 🔄 In Progress / Planned Features
- [ ] Full CRUD operations for all design tokens
- [ ] JSON export functionality
- [ ] Flutter code generator
- [ ] Kotlin (Android) code generator
- [ ] Swift (iOS) code generator
- [ ] Project save/load functionality
- [ ] File system integration
- [ ] Preview functionality
- [ ] Platform-specific UI adaptations

## 📦 Dependencies

- `provider`: State management
- `go_router`: Navigation and routing
- `flutter_colorpicker`: Color selection
- `path_provider`: File system access
- `file_picker`: File selection
- `json_annotation`: JSON serialization
- `intl`: Internationalization

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
