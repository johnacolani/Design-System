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

## 🎯 Usage Guide

### Getting Started

#### First Launch

1. **Launch the app** - Run `flutter run -d chrome` (or your preferred platform)
2. **Choose Authentication**:
   - **Sign Up**: Create an account with email/password or Google Sign-In
   - **Guest Mode**: Click "Continue as Guest" to try without an account
3. **Home Screen**: You'll see the home screen with promotional content and project previews

#### Creating Your First Project

1. **Click "Get Started"** (or "Create New Project" if logged in) on the home screen
2. **Onboarding Screen**:
   - Enter your **Project Name** (e.g., "My App Design System")
   - Add a **Description** (optional but recommended)
   - **Pick a Primary Color**:
     - Click the color circle or "Pick Color" button
     - Browse color palettes, select colors, and get suggestions
     - Tap colors to select multiple, then click "Add X" to confirm
   - Click **"Create Design System"**
3. **Dashboard**: You'll be taken to the Design Tokens dashboard

### Working with Design Tokens

The dashboard shows all available design token categories. Click any card to start editing:

#### 🎨 Colors

1. **Navigate**: Click "Colors" from the dashboard
2. **Categories**: Switch between Primary, Semantic, Blue, Green, Orange, Purple, Red, Grey
3. **Add Colors**:
   - Click the **"+"** button (top right)
   - Enter color name and description
   - Click **"Browse Color Palettes"** to use the advanced color picker:
     - Select from curated color palettes
     - Pick multiple colors at once
     - Get color suggestions and scales
     - Generate primary-to-dark and primary-to-light scales
   - Or tap the color preview to pick a color
   - Click **"Add"** to save
4. **Edit Colors**: Click any color card → Edit name/description/color → Save
5. **Delete Colors**: Click the three dots menu → Delete
6. **Back Navigation**: Use the back arrow to return to Design Tokens

#### ✍️ Typography

1. **Navigate**: Click "Typography" from the dashboard
2. **Tabs Available**:
   - **Font Family**: Edit primary and fallback fonts
     - Click the edit icon next to "Font Family"
     - Enter font names (e.g., "Roboto", "Inter", "system-ui")
     - Primary font is required
   - **Font Weights**: Add/edit font weight values (100-900)
   - **Font Sizes**: Define size values with line heights
   - **Text Styles**: Create reusable text styles combining font family, size, weight, color, etc.
3. **Add Items**: Use the "+" button in each tab
4. **Edit**: Click any item to edit
5. **Color in Text Styles**: Click the colorize icon next to the color field to use the color picker

#### 📏 Spacing

1. **Navigate**: Click "Spacing" from the dashboard
2. **View Scale**: See all spacing values in a visual scale
3. **Add Values**: Click "+" to add custom spacing values
4. **Edit**: Click any spacing value to modify

#### 🔲 Border Radius

1. **Navigate**: Click "Border Radius" from the dashboard
2. **Edit Values**: Click any radius value (None, Small, Base, Medium, Large, XL, Full) to edit
3. **Visual Preview**: See how each radius looks applied to shapes

#### 🌑 Shadows

1. **Navigate**: Click "Shadows" from the dashboard
2. **Add Shadow**: Click "+" → Enter name and shadow value (format: "offsetX offsetY blur color")
3. **Edit**: Click any shadow to modify

#### ✨ Effects

1. **Navigate**: Click "Effects" from the dashboard
2. **Configure**: Set up Glass Morphism and Dark Overlay effects

#### 🧩 Components

1. **Navigate**: Click "Components" from the dashboard
2. **Categories**: Manage Buttons, Cards, Inputs, Navigation, Avatars
3. **Add Components**: Click "+" in each category → Configure properties → Save
4. **Edit**: Click any component to modify

#### 📐 Grid

1. **Navigate**: Click "Grid" from the dashboard
2. **Configure**: Set columns, gutter, margin, and breakpoints

#### 🎯 Icons

1. **Navigate**: Click "Icons" from the dashboard
2. **Add Sizes**: Click "+" → Enter icon name and size → Save

#### 🌈 Gradients

1. **Navigate**: Click "Gradients" from the dashboard
2. **Add Gradient**: Click "+" → Configure type, direction, colors, and stops → Save

#### 👥 Roles

1. **Navigate**: Click "Roles" from the dashboard
2. **Add Role**: Click "+" → Set primary color, accent color, and background → Save

### Using Design Libraries

Import ready-made components from Material Design or iOS (Cupertino):

1. **Navigate**: Click "Design Library" from the dashboard
2. **Choose Library**:
   - **Material Design**: Google's Material Design system
   - **Cupertino**: Apple's iOS design system
3. **Browse Categories**:
   - **Colors**: Browse color palettes
     - **Material**: Import complete palettes (Blue, Green, Red, Orange, Purple, Grey) with all shades (50-900)
     - Click "Add" on any palette to import all shades
   - **Icons**: Browse icon libraries
   - **Components**: Browse pre-built components
   - **Typography**: Browse typography styles
4. **Import**: Click "Add" on any item to import into your design system

### Preview and Export

#### Preview Your Design System

1. **Navigate**: Click "Preview" from the dashboard
2. **View**: See all your design tokens in a visual preview
3. **Export as PDF**: Click the PDF icon (top right) to generate a PDF document
   - **Desktop**: Choose save location
   - **Mobile/Web**: Preview and share options

#### Export Your Design System

1. **Navigate**: Click "Export" from the dashboard
2. **Choose Format**:
   - **JSON**: Raw design system data
   - **Flutter**: Dart code for Flutter projects
   - **Kotlin**: Code for Android projects
   - **Swift**: Code for iOS projects
3. **Save**: Choose location and save the file

### Managing Projects

#### View All Projects

1. **From Home Screen**: Click your profile icon → "Projects"
2. **View List**: See all your created projects
3. **Open Project**: Click any project to open and continue editing
4. **Delete Project**: Use the delete option (if available)

#### Project Settings

1. **Profile**: Click profile icon → View your profile and statistics
2. **Settings**: Click settings icon → Configure account, app preferences, privacy

### Tips & Best Practices

- **Color Picker**: Use the advanced color picker (palette icon) for better color selection with scales and suggestions
- **Save Frequently**: Your changes are saved automatically, but you can manually save from the dashboard
- **Preview First**: Always preview your design system before exporting
- **Start Simple**: Begin with colors and typography, then add components
- **Use Design Libraries**: Import from Material/Cupertino to speed up your workflow
- **Consistent Naming**: Use consistent naming conventions (e.g., "primary", "secondary", "error", "success")
- **PDF Export**: Export as PDF for documentation and sharing with your team

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
