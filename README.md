# Design System Builder

A comprehensive Flutter application for creating, managing, and exporting design systems for Flutter, Kotlin (Android), and Swift (iOS) projects. Think of it as Figma, but specifically designed for building complete design systems.

## 🎨 Features

### Core Functionality
- **Project Management**: Create and manage multiple design system projects
- **Design Tokens**: Comprehensive management of all design tokens
- **Multi-Platform Export**: Export to Flutter, Kotlin (Android), and Swift (iOS)
- **Design Library**: Browse and import from Material Design and Cupertino (iOS) design systems

### Design Token Management
- ✅ **Colors**: 
  - Advanced color picker with 5 specialized tools (Palettes, Color Wheel, Schemes, Contrast Checker, Analysis)
  - Color scheme generator (monochromatic, analogous, complementary, triadic, split complementary, tetradic)
  - Automatic light/dark scale generation
  - WCAG contrast checker with accessibility scoring
  - Color psychology and cultural association analysis
  - Multiple color selection from palettes
  - Primary, semantic, and custom color palettes
- ✅ **Typography**: Font families, weights, sizes, and text styles
- ✅ **Spacing**: Spacing scale and values
- ✅ **Border Radius**: Corner radius values
- ✅ **Shadows**: Elevation and shadow definitions
- ✅ **Effects**: Glass morphism, overlays, and visual effects
- ✅ **Components**: Buttons, cards, inputs, navigation, avatars, modals, tables, progress indicators, alerts
  - Component states (default, hover, active, focus, disabled, loading)
- ✅ **Grid**: Layout grid system with breakpoints
- ✅ **Icons**: Icon size definitions
- ✅ **Gradients**: Gradient definitions
- ✅ **Roles**: Role-based theming
- ✅ **Semantic Tokens**: Purpose-driven tokens mapping to base tokens (color, typography, spacing, shadow, radius)
- ✅ **Motion Tokens**: Animation duration and easing functions
- ✅ **Version History**: Track changes and maintain changelog for your design system

### Design Libraries
- ✅ **Material Design**: Browse and import Material components, colors (with full palette support), icons, and typography
- ✅ **Cupertino (iOS)**: Browse and import iOS system colors, icons, components, and typography

### User Features
- ✅ **Authentication**: Sign up with email/password, Google Sign-In, or continue as guest
- ✅ **Guided Onboarding**: 5-step wizard for creating well-structured design systems
- ✅ **User Profile**: View profile, membership status, and project statistics
- ✅ **Settings**: Account settings, app preferences, privacy, and support options
- ✅ **Project Preview**: Visual preview of created projects on home screen
- ✅ **Auto-Save**: Projects automatically saved after creation
- ✅ **Multi-Platform Export**: JSON, Flutter (Dart), Kotlin (Android), Swift (iOS), and PDF

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

## 🎯 User instructions and usage guides

> **📖 [USER_INSTRUCTIONS.md](USER_INSTRUCTIONS.md)** — Single holistic guide: first launch, auth, creating projects, all token screens, design libraries, preview/export, projects, profile, and troubleshooting. Best starting point for using the app.

> **📖 [COMPLETE_USAGE_GUIDE.md](COMPLETE_USAGE_GUIDE.md)** — Extended step-by-step usage guide.

Both guides cover:
- Getting started and authentication
- Creating projects (5-step onboarding)
- All design token management screens
- Design libraries (Material Design & Cupertino)
- Preview and export functionality
- Project management
- Profile and settings
- Version history
- Tips, best practices, and troubleshooting

**Quick Start**: Below is a condensed guide. For comprehensive instructions, refer to [COMPLETE_USAGE_GUIDE.md](COMPLETE_USAGE_GUIDE.md).

---

## Quick Usage Guide

### Getting Started

#### First Launch

1. **Launch the app** - Run `flutter run -d chrome` (or your preferred platform)
2. **Choose Authentication**:
   - **Sign Up**: Create an account with email/password or Google Sign-In
   - **Guest Mode**: Click "Continue as Guest" to try without an account (projects saved locally)
   - **Sign In**: If you already have an account, sign in to access cloud-saved projects
3. **Home Screen**: You'll see the home screen with promotional content and project previews

#### Creating Your First Project - Complete Onboarding Flow

The onboarding process guides you through 5 steps to create a well-structured design system:

**Step 1: Basic Information**
- Enter your **Project Name** (e.g., "My App Design System")
- Add a **Description** (optional but recommended)
- Click **"Next"** to proceed

**Step 2: App Information**
- **App Type**: Select from Business, Creative, E-commerce, Health, Education, Social, or Other
- **Target Audience**: Choose Young, Middle-aged, Senior, or All Ages
- **Brand Personality**: Select Professional, Creative, Energetic, Calm, Modern, or Traditional
- Click **"Next"** to continue

**Step 3: Color Scheme Preference**
- Choose your preferred color scheme type:
  - **Monochromatic**: Shades of a single color
  - **Analogous**: Colors next to each other on the color wheel
  - **Complementary**: Opposite colors for contrast
  - **Triadic**: Three evenly spaced colors
  - **Split Complementary**: Base color plus two adjacent to its complement
  - **Tetradic**: Four colors forming a rectangle
- Click **"Next"** to proceed

**Step 4: Base Color Selection**
- The app recommends a base color based on your app type and brand personality
- **Select Base Color**:
  - Use the **visual color picker** (tap the color circle)
  - Enter **hex color value** directly (e.g., #FF5733)
  - Choose from **quick preset colors** (Blue, Green, Purple, Orange, Red, Pink)
  - Click **"Generate Color Scheme"** to create your palette
- Click **"Next"** to see preview

**Step 5: Preview & Finalize**
- **Review Generated Colors**: See all colors generated from your scheme
- **Select Primary Color**: Tap any color to mark it as your primary color (star icon)
- **Review Project Summary**: Check all your selections
- Click **"Create Design System"** to finish
- **Success**: You'll be automatically taken to the Dashboard with all colors saved!

> **Note**: All generated colors are automatically saved to your design system with light/dark scale variations.

### Working with Design Tokens

The dashboard shows all available design token categories. Click any card to start editing:

#### 🎨 Colors - Complete Guide

**Navigation**: Click "Colors" from the dashboard

**Color Categories**: 
- Switch between tabs: Primary, Semantic, Blue, Green, Orange, Purple, Red, Grey
- Categories appear as you add colors to them

**Adding Colors - Three Methods**:

**Method 1: Advanced Color Picker (Recommended)**
1. Click the **"+"** button (top right)
2. Enter color name and description
3. Click **"Browse Color Palettes & Get Suggestions"**
4. You'll see the **Advanced Color Picker** with 5 tabs:

   **Tab 1: Palettes**
   - Browse curated color palettes
   - Tap colors to select multiple
   - Click **"Material Design"** or **"iOS"** to browse system palettes
   - In Material/iOS pickers: Tap colors to select, then click **"Use This Color"**
   - Selected colors return with scales and suggestions

   **Tab 2: Color Wheel**
   - Interactive HSL color wheel
   - Drag to select hue, saturation, and lightness
   - Real-time color preview
   - Perfect for precise color selection

   **Tab 3: Color Schemes**
   - Pick a base color (opens color picker)
   - Generate color schemes:
     - **Monochromatic**: Shades of one color
     - **Analogous**: Adjacent colors
     - **Complementary**: Opposite colors
     - **Triadic**: Three evenly spaced colors
     - **Split Complementary**: Base + two adjacent to complement
     - **Tetradic**: Four colors in rectangle
   - All generated colors include light/dark scales

   **Tab 4: Contrast Checker**
   - Select foreground and background colors
   - See live text preview
   - Get detailed contrast information:
     - Contrast ratio (WCAG AA/AAA compliance)
     - Accessibility score
     - Readability status
   - Get suggestions for better contrast if needed

   **Tab 5: Color Analysis**
   - **Color Psychology**: Meanings and emotional impact
   - **Cultural Associations**: Warnings for different regions
   - **Demographic Preferences**: Age/gender-based recommendations
   - **Harmony Analysis**: How well colors work together

5. After selecting colors, click **"Add X Colors"** to save them all

**Method 2: Simple Color Picker**
1. Click the **"+"** button
2. Enter color name and description
3. Tap the **color preview box** to open color picker
4. Select a color
5. Click **"Add"** to save

**Method 3: Direct Hex Input**
1. Click the **"+"** button
2. Enter color name and description
3. Use the hex input field in the color picker
4. Click **"Add"** to save

**Editing Colors**:
- Click any color card
- Edit name, description, or color
- Changes save automatically

**Deleting Colors**:
- Click the **three dots menu** (⋮) on any color card
- Select **"Delete"**
- Confirm deletion

**Color Scales**:
- All colors automatically get light/dark scale variations
- Scales are generated when you add colors via the advanced picker
- View scales by expanding color cards (if available)

**Back Navigation**: Click the back arrow (top left) to return to Dashboard

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
2. **Categories**: Manage 9 component types:
   - **Buttons**: Primary, secondary, outlined, text buttons
   - **Cards**: Container cards with various styles
   - **Inputs**: Text fields, forms, inputs
   - **Navigation**: Navigation bars, menus
   - **Avatars**: User avatars and profile images
   - **Modals**: Dialog boxes and modal windows
   - **Tables**: Data tables and grids
   - **Progress**: Progress bars and indicators
   - **Alerts**: Notification alerts and banners
3. **Component States**: Each component can have multiple states:
   - **Default**: Normal state
   - **Hover**: Mouse hover state
   - **Active**: Active/pressed state
   - **Focus**: Keyboard focus state
   - **Disabled**: Disabled state
   - **Loading**: Loading state
   - Buttons and inputs have default states pre-selected
4. **Add Components**: Click "+" in each category → Configure properties (height, borderRadius, padding, fontSize, fontWeight) → Select states → Save
5. **Edit**: Click any component to modify properties and states
6. **Delete**: Use the three dots menu (⋮) to delete components

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

#### 🏷️ Semantic Tokens

1. **Navigate**: Click "Semantic Tokens" from the dashboard
2. **Purpose**: Map purpose-driven names to base tokens (e.g., `text-primary` → `colors.primary.primary`)
3. **Categories**: Manage tokens for:
   - **Color**: Semantic color tokens (text-primary, surface-elevated, etc.)
   - **Typography**: Semantic typography tokens
   - **Spacing**: Semantic spacing tokens
   - **Shadow**: Semantic shadow tokens
   - **Radius**: Semantic border radius tokens
4. **Add Token**: Click "+" → Enter semantic name, base token reference, and description → Save
5. **Base Token Reference**: Click available base tokens (shown as chips) to auto-fill the reference
6. **Edit/Delete**: Use the expansion tile menu to edit or delete tokens

#### 🎬 Motion Tokens

1. **Navigate**: Click "Motion Tokens" from the dashboard
2. **Purpose**: Define animation timing and easing functions for consistent motion design
3. **Categories**:
   - **Duration**: Animation timing (e.g., fast: 150ms, medium: 300ms, slow: 500ms)
   - **Easing**: Animation curves (e.g., ease-in, ease-out, cubic-bezier functions)
4. **Add Token**: Click "+" → Enter token name and value → Save
5. **Presets**: Easing tab includes preset functions (ease-in, ease-out, ease-in-out, linear, cubic-bezier)
6. **Edit/Delete**: Click edit or delete icons on any token card

#### 📜 Version History

1. **Navigate**: Click the history icon (📜) from the dashboard app bar
2. **Purpose**: Track changes and maintain a changelog for your design system
3. **View History**: See all versions with dates, descriptions, and change lists
4. **Current Version**: The current version is highlighted with a "Current" badge
5. **Add Version**: Click "+" → Enter version number, description, and list of changes → Save
6. **Version Format**: Use semantic versioning (major.minor.patch, e.g., 1.1.0)
7. **Changes**: Add multiple change items describing what was updated in this version

### Using Design Libraries

Import ready-made components from Material Design or iOS (Cupertino):

**Navigation**: Click "Design Library" from the dashboard (or the blue card at the top)

**Choose Library**:
- **Material Design**: Google's Material Design 3 system
- **Cupertino (iOS)**: Apple's iOS Human Interface Guidelines

**Material Design Library** (4 tabs):

**Tab 1: Colors**
- Browse Material color palettes:
  - Blue, Green, Red, Orange, Purple, Teal, Indigo, Grey
- Each palette includes all shades (50, 100, 200...900)
- **Two Modes**:
  - **Color Picker Mode**: Tap colors to select, then click "Use This Color" (when picking for your design system)
  - **Import Mode**: Click "Add" on any palette to import all shades into your design system
- Imported palettes are added to appropriate color categories

**Tab 2: Icons**
- Browse Material Design icons
- Search by name
- Click icons to view details
- Import icons to your design system

**Tab 3: Components**
- Browse Material components:
  - Buttons, Cards, Text Fields, Navigation, etc.
- View component specifications
- Import components to your design system

**Tab 4: Typography**
- Browse Material typography styles
- View font families, sizes, weights
- Import typography to your design system

**Cupertino (iOS) Library** (4 tabs):

**Tab 1: Colors**
- Browse iOS system colors:
  - System colors (Blue, Green, Red, Orange, etc.)
  - Semantic colors (Label, Background, Separator, etc.)
- **Two Modes**: Same as Material (Color Picker or Import)
- Imported colors added to appropriate categories

**Tab 2: Icons**
- Browse SF Symbols (iOS icon system)
- Search by name
- Import icons to your design system

**Tab 3: Components**
- Browse iOS components:
  - Buttons, Lists, Navigation, etc.
- View component specifications
- Import components to your design system

**Tab 4: Typography**
- Browse iOS typography styles
- View San Francisco font specifications
- Import typography to your design system

**Tips**:
- When in "Color Picker Mode", selected colors return to the previous screen with scales
- When importing palettes, all shades are added automatically
- Imported items appear in your design system immediately

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

**From Dashboard**:
- Click the **folder icon** (top right) → "My Projects"

**From Home Screen**:
- Click your **profile icon** (top right) → "Projects"

**Project List Features**:
- **View All Projects**: See all your saved projects
- **Project Cards**: Each shows:
  - Project name
  - Description
  - Creation date
  - Last modified (if available)
- **Open Project**: Click any project card to load and continue editing
- **Delete Project**: 
  - Click the delete icon on a project card
  - Confirm deletion
  - ⚠️ This action cannot be undone

**Creating New Projects**:
- **From Home**: Click "Create New Project" or "Get Started"
- **From Dashboard**: Click home icon → "Create New Project"
- Projects are automatically saved after creation

#### Project Settings & Profile

**Access Profile**:
- Click your **profile icon** (top right) from any screen
- Or navigate: Home → Profile icon → "Profile"

**Profile Features**:
- **User Information**: Name, email, profile picture
- **Membership Status**: Free, Pro, Enterprise (if applicable)
- **Statistics**:
  - Projects created
  - Design tokens added
  - Last active date
- **Account Actions**: Edit profile, change password, etc.

**Access Settings**:
- Click **settings icon** (if available) or navigate: Profile → Settings

**Settings Categories**:
- **Account Settings**: Email, password, profile picture
- **App Preferences**: Theme, language, notifications
- **Privacy**: Data sharing, visibility settings
- **Support**: Help, feedback, contact
- **About**: App version, terms, privacy policy

#### Saving & Loading Projects

**Auto-Save**:
- Projects are automatically saved after creation
- Changes are saved in memory (session-based)
- Manual save available from dashboard (if implemented)

**Manual Save**:
- Projects save to local storage automatically
- **Logged-in users**: Projects sync to cloud (Firebase)
- **Guest users**: Projects saved locally only

**Loading Projects**:
- Projects load automatically when you open them
- Recent projects may appear on home screen
- Access all projects from "My Projects" screen

**Project File Format**:
- Projects saved as `.ds.json` files
- Location: App documents directory
- Can be exported/imported manually

### Tips & Best Practices

**Color Selection**:
- ✅ Use the **advanced color picker** for professional results with scales and suggestions
- ✅ Use **color schemes** (triadic, complementary) for harmonious palettes
- ✅ Check **contrast ratios** for accessibility (WCAG AA/AAA compliance)
- ✅ Consider **color psychology** and cultural associations for your target audience
- ✅ Use **color wheel** for precise HSL adjustments

**Design System Structure**:
- ✅ **Start Simple**: Begin with colors and typography, then add components
- ✅ **Consistent Naming**: Use clear, consistent names (e.g., "primary", "secondary", "error", "success")
- ✅ **Organize by Category**: Use appropriate color categories (Primary, Semantic, etc.)
- ✅ **Document Everything**: Add descriptions to colors, typography, and components

**Workflow Optimization**:
- ✅ **Use Design Libraries**: Import from Material/Cupertino to speed up your workflow
- ✅ **Preview First**: Always preview your design system before exporting
- ✅ **Export Regularly**: Export JSON for backups and version control
- ✅ **PDF Documentation**: Export as PDF for team sharing and documentation

**Onboarding**:
- ✅ **Complete All Steps**: The 5-step onboarding helps create a well-structured system
- ✅ **Choose Appropriate Scheme**: Select color scheme type that matches your brand
- ✅ **Review Generated Colors**: All generated colors are saved automatically

**Project Management**:
- ✅ **Save Frequently**: Projects auto-save, but be aware of session limits
- ✅ **Backup Projects**: Export JSON regularly for backups
- ✅ **Use Cloud Sync**: Sign in to sync projects across devices (if available)
- ✅ **Organize Projects**: Use descriptive names and descriptions

**Advanced Features**:
- ✅ **Color Scales**: All colors get automatic light/dark variations
- ✅ **Harmony Analysis**: Use color analysis tab to check harmony scores
- ✅ **Contrast Checker**: Always verify text readability with contrast checker
- ✅ **Multiple Colors**: Select multiple colors at once from palettes
- ✅ **Component States**: Define hover, active, focus, disabled, and loading states for components
- ✅ **Semantic Tokens**: Create purpose-driven tokens that map to base tokens for better maintainability
- ✅ **Motion Tokens**: Define consistent animation timing and easing functions
- ✅ **Version History**: Track all changes with version numbers and changelogs

**Export Best Practices**:
- ✅ **Platform-Specific**: Export Flutter/Kotlin/Swift code when starting new projects
- ✅ **Documentation**: Export PDF for design documentation
- ✅ **Version Control**: Export JSON and commit to git for version tracking
- ✅ **Team Sharing**: Share PDF exports with designers and developers

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
- [x] Semantic tokens system
- [x] Motion tokens (duration and easing)
- [x] Version history and changelog
- [x] Component states (hover, active, focus, disabled, loading)
- [x] Expanded component library (modals, tables, progress, alerts)
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

## 📖 Quick Reference Guide

### Navigation Map

```
Home Screen
├── Create New Project → Onboarding (5 steps) → Dashboard
├── Sign In / Sign Up → Welcome Screen → Home
├── Profile → Profile Screen
│   ├── Projects → Projects Screen
│   └── Settings → Settings Screen
└── Continue as Guest → Home (local storage only)

Dashboard (Design Tokens)
├── Colors → Colors Screen
│   └── Advanced Color Picker (5 tabs)
│       ├── Palettes → Material/Cupertino Libraries
│       ├── Color Wheel
│       ├── Schemes
│       ├── Contrast Checker
│       └── Analysis
├── Typography → Typography Screen
├── Spacing → Spacing Screen
├── Border Radius → Border Radius Screen
├── Shadows → Shadows Screen
├── Effects → Effects Screen
├── Components → Components Screen
├── Grid → Grid Screen
├── Icons → Icons Screen
├── Gradients → Gradients Screen
├── Roles → Roles Screen
├── Semantic Tokens → Semantic Tokens Screen
├── Motion Tokens → Motion Tokens Screen
├── Version History → Version History Screen (via app bar icon)
├── Design Library → Design Library Screen
│   ├── Material Design (4 tabs)
│   └── Cupertino (4 tabs)
├── Preview → Preview Screen → PDF Export
└── Export → Export Screen

Top Navigation (Dashboard)
├── Home Icon → Home Screen
└── Folder Icon → Projects Screen
```

### Keyboard Shortcuts (Web/Desktop)

- `Esc`: Close dialogs/modals
- `Enter`: Confirm actions in forms
- `Tab`: Navigate between form fields
- `Backspace`: Go back (when applicable)

### Common Tasks Quick Guide

**Add a Component with States**:
1. Dashboard → Components
2. Select component category tab (e.g., Buttons)
3. Click "+" button
4. Enter component name and properties
5. Select component states (default, hover, active, focus, disabled, loading)
6. Save

**Add a Color**:
1. Dashboard → Colors
2. Select category tab
3. Click "+" button
4. Choose method (Advanced Picker recommended)
5. Select colors → Add

**Generate Color Scheme**:
1. Colors → "+" → Browse Color Palettes
2. Go to "Schemes" tab
3. Pick base color
4. Select scheme type
5. Generated colors appear → Add all

**Check Color Contrast**:
1. Colors → "+" → Browse Color Palettes
2. Go to "Contrast" tab
3. Select foreground and background colors
4. Review contrast ratio and WCAG compliance

**Import Material Colors**:
1. Dashboard → Design Library
2. Material Design → Colors tab
3. Click "Add" on any palette
4. All shades (50-900) imported automatically

**Export Design System**:
1. Dashboard → Export
2. Select format (JSON/Flutter/Kotlin/Swift)
3. Save or copy code

**Create PDF Documentation**:
1. Dashboard → Preview
2. Click PDF icon (top right)
3. Save or share PDF

**Add Version History**:
1. Dashboard → Click history icon (📜) in app bar
2. Click "+" button
3. Enter version number (e.g., 1.1.0)
4. Add description (optional)
5. Add change items (e.g., "Added new color palette", "Updated typography scale")
6. Save

**Create Semantic Token**:
1. Dashboard → Semantic Tokens
2. Select category tab (Color, Typography, Spacing, Shadow, Radius)
3. Click "+" button
4. Enter semantic name (e.g., "text-primary")
5. Click a base token chip to auto-fill reference (e.g., "colors.primary.primary")
6. Add description
7. Save

## 🔧 Troubleshooting

### Common Issues

**Problem**: Colors not saving after onboarding
- **Solution**: Colors are automatically saved. Check Dashboard → Colors to verify.

**Problem**: Can't see generated colors
- **Solution**: Generated colors are saved to Primary category. Check Primary tab in Colors screen.

**Problem**: PDF export not working on web
- **Solution**: PDF opens in browser preview. Use browser's print/save dialog.

**Problem**: Google Sign-In not working
- **Solution**: See `FIX_GOOGLE_SIGNIN_ERROR.md` for detailed troubleshooting. Ensure client ID is configured in `web/index.html`.

**Problem**: Projects not syncing
- **Solution**: 
  - Ensure you're signed in (not guest mode)
  - Check internet connection
  - Projects sync to Firebase when logged in

**Problem**: Color picker not showing
- **Solution**: 
  - Ensure you clicked "Browse Color Palettes" button
  - Check browser console for errors (web)
  - Try refreshing the screen

**Problem**: Can't navigate back
- **Solution**: Use the back arrow (top left) or browser back button (web)

**Problem**: Design library colors not importing
- **Solution**: 
  - Ensure you're in "Import Mode" (not Color Picker Mode)
  - Click "Add" button on palette, not individual colors
  - Check Colors screen after import

### Getting Help

- **Documentation**: Check this README and other `.md` files in the project
- **Issues**: Report bugs or request features via GitHub Issues
- **Support**: Contact support through Settings → Support

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
    "roles": { ... },
    "semanticTokens": { ... },
    "motionTokens": { ... },
    "lastModified": "2025-02-24T10:30:00",
    "versionHistory": [
      {
        "version": "1.0.0",
        "date": "2025-02-24T10:00:00",
        "changes": ["Initial project creation"],
        "description": "Initial release"
      }
    ]
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
