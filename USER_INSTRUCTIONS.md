# Design System Builder — User Instructions

This guide explains how to use the Design System Builder app from first launch through creating projects, editing design tokens, and exporting your system. For developer setup (Flutter, Firebase), see [README.md](README.md) and [FIREBASE_SETUP.md](FIREBASE_SETUP.md).

---

## What This App Does

Design System Builder lets you **create, manage, and export** design systems for:

- **Flutter** (Dart)
- **Android** (Kotlin)
- **iOS** (Swift)

You define colors, typography, spacing, components, and more in one place, then export code or documentation (JSON, PDF) for your projects.

---

## Running the App

### Prerequisites

- **Flutter SDK** 3.10.0 or higher ([flutter.dev](https://flutter.dev))
- For **cloud sync and sign-in**: Firebase must be configured ([FIREBASE_SETUP.md](FIREBASE_SETUP.md))

### Install and run

```bash
# Get dependencies
flutter pub get

# Run on your platform (pick one)
flutter run -d chrome     # Web
flutter run -d macos       # macOS
flutter run -d windows     # Windows
flutter run -d android    # Android
flutter run -d ios        # iOS (mac only)
```

**First run**: The app opens on the **Home** screen (landing page). You can continue as a guest or sign in to sync projects.

---

## First-Time Flow

### 1. Home screen

- **Get Started** — Start creating a new project (or sign up first).
- **My Projects** — Open the list of your projects.
- **Profile** (avatar, top right) — Profile, Projects, Settings.
- **Continue as Guest** — Use the app without an account (projects saved only on this device).
- **Sign In / Sign Up** — Use email or Google (when Firebase is set up).

### 2. Sign up (new account)

1. Choose **Sign Up** (or Get Started → Sign Up).
2. Enter **name**, **email**, and **password** (at least 6 characters).
3. Tap **Sign Up**.
4. You are taken to the sign-in screen with your email filled in; enter your password and **Sign In**.

### 3. Sign in (existing account)

1. Choose **Sign In**.
2. Enter **email** and **password**, then **Sign In**.
3. Or use **Sign in with Google** if enabled.

### 4. Guest mode

- Choose **Continue as Guest**.
- Projects are stored **only on this device**; no cloud sync.
- You can create and edit projects and export them; sign in later to get cloud sync.

---

## Creating Your First Project (Onboarding)

Creating a project uses a **5-step onboarding** flow that sets name, app context, and an initial color palette.

### Step 1: Basic information

- **Project name** (required): e.g. “My App Design System”.
- **Description** (optional): short summary.
- Tap **Next**.

### Step 2: App information

- **App type**: Business, Creative, E-commerce, Health, Education, Social, Other.
- **Target audience**: Young, Middle-aged, Senior, All Ages.
- **Brand personality**: Professional, Creative, Energetic, Calm, Modern, Traditional.
- Tap **Next**.

### Step 3: Color scheme preference

Choose one:

- **Monochromatic** — One hue, different shades.
- **Analogous** — Neighboring hues.
- **Complementary** — Opposite hues.
- **Triadic** — Three evenly spaced hues.
- **Split complementary** — Base + two near its complement.
- **Tetradic** — Four hues in a rectangle.

Tap **Next**.

### Step 4: Base color

- Use the **color circle** or **hex field** (e.g. `#FF5733`), or a **preset** (Blue, Green, Purple, etc.).
- Tap **Generate Color Scheme** to build a palette from your choices.
- Tap **Next**.

### Step 5: Preview and create

- Review the **generated colors** and **project summary**.
- Tap a color to set it as **primary** (star).
- Tap **Create Design System** to finish.

You are taken to the **Dashboard** with your project loaded. Colors from onboarding are already in the design system.

---

## Dashboard Overview

The dashboard is the hub for editing your design system.

### Top bar

- **Home (house icon)** — Opens **My Projects** (list of all projects).
- **Project name** — Title of the current project.
- **Profile (avatar)** — Profile screen.
- **Save** — Save project (cloud if signed in, local if guest).
- **Design Library** — Import from Material Design or Cupertino (iOS).
- **Version History** — View and add version entries and changelog.

### Token cards

Tap a card to open that token editor:

| Card           | What you edit                                      |
|----------------|----------------------------------------------------|
| **Colors**     | Color palettes, schemes, contrast, scales           |
| **Typography** | Fonts, weights, sizes, text styles                 |
| **Spacing**    | Spacing scale and values                           |
| **Border Radius** | Corner radius values                           |
| **Shadows**    | Shadow / elevation definitions                     |
| **Effects**    | Glass morphism, overlays                           |
| **Components** | Buttons, cards, inputs, navigation, avatars, etc.  |
| **Grid**       | Columns, gutter, margin, breakpoints               |
| **Icons**      | Icon sizes                                         |
| **Gradients**  | Gradient definitions                               |
| **Roles**      | Role-based theming (e.g. primary, accent)          |
| **Semantic Tokens** | Purpose-based tokens (e.g. text-primary)   |
| **Motion Tokens**  | Duration and easing for animations            |
| **Preview**    | Visual preview and PDF export                      |
| **Export**     | Export to JSON, Flutter, Kotlin, Swift             |

Use the **back arrow** (top left) in any screen to return to the dashboard.

---

## Working with Design Tokens

### Colors

1. Dashboard → **Colors**.
2. Use the **tabs** (Primary, Semantic, Blue, Green, etc.) to switch categories.
3. **Add color**: tap **+**.
   - **Advanced (recommended)**: tap **Browse Color Palettes & Get Suggestions** for:
     - **Palettes** — Curated palettes; Material/iOS palettes.
     - **Color wheel** — HSL picker.
     - **Schemes** — Generate from a base color (mono, analogous, complementary, etc.).
     - **Contrast checker** — Foreground/background and WCAG info.
     - **Analysis** — Psychology, culture, harmony.
   - Or use the **simple color picker** or **hex input**.
4. Select one or more colors, then **Add** (or **Add X Colors**).
5. **Edit**: tap a color card. **Delete**: ⋮ menu on the card → Delete.

Generated colors get light/dark scale variations where applicable.

### Typography

1. Dashboard → **Typography**.
2. **Font family**: Set primary and fallback (e.g. Roboto, system-ui).
3. **Font weights**: Add values (e.g. 100–900).
4. **Font sizes**: Add sizes and line heights.
5. **Text styles**: Combine family, size, weight, color; use **+** to add, tap to edit.
6. Use the color icon next to a color field to open the color picker.

### Spacing

1. Dashboard → **Spacing**.
2. View the spacing scale; tap **+** to add values, tap a value to edit.

### Border radius

1. Dashboard → **Border Radius**.
2. Tap a value (None, Small, Base, Medium, Large, XL, Full) to edit; preview updates as you change values.

### Shadows

1. Dashboard → **Shadows**.
2. Tap **+**, enter name and shadow value (e.g. `offsetX offsetY blur color`), save. Tap a shadow to edit.

### Effects

1. Dashboard → **Effects**.
2. Configure **Glass morphism** and **Dark overlay** as needed.

### Components

1. Dashboard → **Components**.
2. Use **tabs** for: Buttons, Cards, Inputs, Navigation, Avatars, Modals, Tables, Progress, Alerts.
3. **Add**: tap **+** in a category → set name and properties (height, border radius, padding, font size, etc.) → choose **states** (default, hover, active, focus, disabled, loading) → Save.
4. **Edit**: tap a component. **Delete**: ⋮ on the component card.

### Grid

1. Dashboard → **Grid**.
2. Set columns, gutter, margin, and breakpoints.

### Icons

1. Dashboard → **Icons**.
2. Tap **+**, enter name and size, save.

### Gradients

1. Dashboard → **Gradients**.
2. Tap **+**, set type, direction, colors, and stops, save.

### Roles

1. Dashboard → **Roles**.
2. Tap **+**, set primary, accent, and background, save.

### Semantic tokens

1. Dashboard → **Semantic Tokens**.
2. Use **tabs**: Color, Typography, Spacing, Shadow, Radius.
3. Tap **+** → enter semantic name (e.g. `text-primary`), set **base token reference** (tap chips to fill), add description → Save.
4. Edit or delete via the expansion tile menu.

### Motion tokens

1. Dashboard → **Motion Tokens**.
2. **Duration**: Add timing (e.g. fast 150ms, medium 300ms).
3. **Easing**: Add curves (ease-in, ease-out, cubic-bezier, etc.); use presets or custom values.
4. Tap **+** to add; use edit/delete on each card.

### Version history

1. Dashboard → **Version History** (clock/history icon in the app bar).
2. View versions with date, description, and changes.
3. **Add version**: **+** → version number (e.g. 1.1.0), description, list of changes → Save.

---

## Design Libraries (Material & Cupertino)

Import ready-made colors, icons, components, and typography.

1. Dashboard → **Design Library** (or the Design Library card).
2. Choose **Material Design** or **Cupertino (iOS)**.

### Material Design

- **Colors**: Browse palettes (Blue, Green, Red, etc.); tap colors to **pick**, or **Add** a full palette to your system.
- **Icons**: Search and browse; import into your system.
- **Components**: Browse specs; import as needed.
- **Typography**: Browse styles; import.

### Cupertino (iOS)

- **Colors**: System and semantic colors; pick or import.
- **Icons**: SF Symbols; search and import.
- **Components**: iOS components; import.
- **Typography**: San Francisco specs; import.

**Tip**: In color picker mode, “Use This Color” sends the color back to the color form. In import mode, “Add” adds the palette/item to your design system.

---

## Preview and Export

### Preview

1. Dashboard → **Preview**.
2. Review your design tokens in the preview layout.
3. Tap the **PDF** icon to generate a PDF (save location depends on platform; on web, use the browser’s save/print dialog).

### Export

1. Dashboard → **Export**.
2. Choose format:
   - **JSON** — Full design system data (backup, version control).
   - **Flutter** — Dart code.
   - **Kotlin** — Android code.
   - **Swift** — iOS code.
3. Save or copy as offered by the app.

---

## Managing Projects

### Open another project

1. Dashboard → **Home** (house icon) → **My Projects**.
2. Tap a project card to open it (you leave the current project and load the selected one).

### Create a new project

- From **Home**: **Get Started** or **Create New Project** → onboarding (5 steps).
- From **My Projects**: use the create/new action if shown, or go back to Home and **Get Started**.

### Delete a project

1. **My Projects** → tap the **delete** icon on the project card.
2. Confirm. This cannot be undone.

### Saving

- **Save** in the dashboard bar writes the current project (cloud when signed in, local when guest).
- Projects are also saved automatically after creation and when you save explicitly.

---

## Profile and Settings

### Profile

1. Tap your **avatar** (top right) on the dashboard or home.
2. View **Profile**: name, email, avatar, membership (if any), and stats (e.g. projects, last active).
3. From here you can open **Settings**.

### Settings

- **Account**: Email, password, profile picture.
- **App preferences**: Theme, language, notifications (if implemented).
- **Privacy**: Data and visibility (if implemented).
- **Support**: Help, feedback, contact.
- **About**: Version, terms, privacy.
- **Sign out**: Sign out and return to the home screen.

---

## Tips and Troubleshooting

### Tips

- Use the **advanced color picker** (Palettes, Schemes, Contrast) for better accessibility and consistency.
- Use **semantic tokens** to map names like `text-primary` to base tokens for easier theming.
- Use **Version History** with semantic versions (e.g. 1.0.0, 1.1.0) and short change lists.
- Export **JSON** regularly for backups; use **PDF** for sharing with designers.
- **Design Library** speeds up setup: import Material or Cupertino palettes and adjust from there.

### Common issues

| Issue | What to try |
|-------|-------------|
| Colors not visible after onboarding | Open Dashboard → Colors and check the **Primary** (or relevant) tab. |
| PDF on web | Use the browser’s print or “Save as PDF” when the preview opens. |
| Google Sign-In fails | Ensure Firebase and Google Sign-In are set up ([FIREBASE_SETUP.md](FIREBASE_SETUP.md), [FIX_GOOGLE_SIGNIN_ERROR.md](FIX_GOOGLE_SIGNIN_ERROR.md)). |
| Projects not syncing | Sign in (not guest) and check your internet connection. |
| Color picker not opening | Use **Browse Color Palettes & Get Suggestions** from the add-color form; refresh if needed. |
| Design library import not showing | Confirm you tapped **Add** (or Import) on the palette/item, then check the relevant token screen (e.g. Colors). |

---

## Quick Reference

### Navigation

```
Home
├── Get Started → Onboarding (5 steps) → Dashboard
├── My Projects → Project list (open / delete)
├── Profile → Profile → Settings (Sign out, etc.)
├── Sign In / Sign Up / Continue as Guest
└── (when signed in) Same + cloud sync

Dashboard
├── Home icon → My Projects
├── Profile (avatar) → Profile
├── Save, Design Library, Version History
├── [Token cards] → Colors, Typography, … Preview, Export
└── Back arrow (from any token screen) → Dashboard
```

### Build commands (for reference)

```bash
flutter run -d chrome    # Web
flutter run -d macos     # macOS
flutter run -d windows   # Windows
flutter build web --release
flutter build macos --release
```

---

For development setup, dependencies, and project structure, see [README.md](README.md). For the long-form usage guide, see [COMPLETE_USAGE_GUIDE.md](COMPLETE_USAGE_GUIDE.md).
