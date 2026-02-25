# Complete Usage Guide - Design System Builder

## Table of Contents
1. [Getting Started](#getting-started)
2. [Authentication](#authentication)
3. [Creating Your First Project](#creating-your-first-project)
4. [Dashboard Overview](#dashboard-overview)
5. [Design Token Management](#design-token-management)
6. [Design Libraries](#design-libraries)
7. [Preview and Export](#preview-and-export)
8. [Project Management](#project-management)
9. [Profile and Settings](#profile-and-settings)
10. [Tips and Best Practices](#tips-and-best-practices)

---

## Getting Started

### Launching the App

1. **Run the application**:
   ```bash
   # For web
   flutter run -d chrome
   
   # For macOS
   flutter run -d macos
   
   # For Windows
   flutter run -d windows
   
   # For mobile (Android/iOS)
   flutter run
   ```

2. **First Screen**: The app opens on the **Home Screen** (landing page)

### Understanding the Home Screen

The Home Screen is your starting point and shows:
- **Top Navigation Bar**: Logo, "Get Started" button, profile icon
- **Hero Section**: Project previews (if you have projects)
- **Tagline**: Brief description of the app
- **Action Buttons**: 
  - "Get Started" - Create a new project
  - "My Projects" - View existing projects
  - Profile icon - Access your profile

---

## Authentication

### Sign Up (New Users)

1. **From Home Screen**: Click **"Get Started"** or **"Sign Up"**
2. **Fill in the form**:
   - **Name**: Your full name
   - **Email**: Your email address
   - **Password**: At least 6 characters
3. **Click "Sign Up"**
4. **After signup**: You'll be automatically redirected to the **Login Screen** with your email pre-filled
5. **Sign in**: Enter your password and click "Sign In"
6. **Success**: You'll be taken to the **Home Screen** as a logged-in user

### Sign In (Existing Users)

1. **From Home Screen**: Click **"Sign In"**
2. **Enter credentials**:
   - **Email**: Your registered email
   - **Password**: Your password
3. **Click "Sign In"**
4. **Alternative**: Click **"Sign in with Google"** for Google authentication
5. **Success**: You'll be taken to the **Home Screen**

### Guest Mode

1. **From Home Screen**: Click **"Continue as Guest"**
2. **Note**: 
   - Projects are saved **locally only** (on your device)
   - No cloud sync available
   - Projects won't be accessible on other devices
3. **Warning**: When creating a project as a guest, you'll see an informational message

### Sign Out

1. **Click your profile icon** (top right)
2. **Navigate**: Profile → Settings → Sign Out
3. **Confirm**: You'll be signed out and returned to Home Screen

---

## Creating Your First Project

### Starting the Onboarding Process

1. **From Home Screen**: Click **"Get Started"** or **"Create New Project"**
2. **Alternative**: Dashboard → Click home icon → "Create New Project"
3. **You'll enter**: The **Onboarding Screen** (5-step wizard)

### Step 1: Basic Information

**What to enter**:
- **Project Name** (Required): e.g., "My App Design System", "Company Brand System"
- **Description** (Optional): Brief description of your project

**Actions**:
- Click **"Next"** to proceed

**Tips**:
- Use descriptive names that help you identify projects later
- Descriptions help team members understand the project's purpose

### Step 2: App Information

**Select options**:

1. **App Type**: Choose one
   - Business
   - Creative
   - E-commerce
   - Health
   - Education
   - Social
   - Other

2. **Target Audience**: Choose one
   - Young
   - Middle-aged
   - Senior
   - All Ages

3. **Brand Personality**: Choose one
   - Professional
   - Creative
   - Energetic
   - Calm
   - Modern
   - Traditional

**Actions**:
- Click **"Next"** to continue

**Note**: These selections help the app recommend appropriate colors and styles

### Step 3: Color Scheme Preference

**Choose a color scheme type**:

- **Monochromatic**: Shades of a single color (e.g., light blue to dark blue)
- **Analogous**: Colors next to each other on the color wheel (e.g., blue, green, teal)
- **Complementary**: Opposite colors for contrast (e.g., blue and orange)
- **Triadic**: Three evenly spaced colors (e.g., red, yellow, blue)
- **Split Complementary**: Base color plus two adjacent to its complement
- **Tetradic**: Four colors forming a rectangle

**Actions**:
- Select one scheme type
- Click **"Next"** to proceed

**Tips**:
- Monochromatic: Best for minimal, focused designs
- Complementary: Great for high contrast and attention-grabbing designs
- Triadic: Balanced and vibrant color palettes

### Step 4: Base Color Selection

**The app recommends a base color** based on your app type and brand personality

**Ways to select a color**:

1. **Visual Color Picker**:
   - Tap the **large color circle** (color preview)
   - A color picker dialog opens
   - Select your color visually
   - Click **"OK"**

2. **Hex Input**:
   - Enter hex color value directly (e.g., `#FF5733`, `FF5733`)
   - The color preview updates automatically
   - Supports 3-digit (`#F73`) and 6-digit (`#FF5733`) formats

3. **Quick Presets**:
   - Click preset buttons: Blue, Green, Purple, Orange, Red, Pink
   - Color updates immediately

**Actions**:
- After selecting color, click **"Generate Color Scheme"**
- This creates your color palette based on the scheme type from Step 3
- Click **"Next"** to see preview

**Tips**:
- The recommended color is based on color psychology and your selections
- You can override it with any color you prefer

### Step 5: Preview & Finalize

**What you'll see**:

1. **Generated Colors**: All colors from your color scheme
   - Each color displayed as a card
   - Shows hex value
   - Shows color preview

2. **Select Primary Color**:
   - Tap any color card to mark it as primary (star icon appears)
   - The primary color is used as your main brand color

3. **Project Summary**:
   - Review all your selections:
     - Project name and description
     - App type, audience, brand personality
     - Color scheme type
     - Selected colors

**Actions**:
- Review everything
- Click **"Create Design System"** to finish
- **Success**: You'll be automatically taken to the **Dashboard** with all colors saved!

**Important Notes**:
- ✅ All generated colors are **automatically saved** to your design system
- ✅ Colors include **light/dark scale variations** automatically
- ✅ Colors are added to the **Primary** color category
- ✅ Project is **auto-saved** after creation

---

## Dashboard Overview

### Accessing the Dashboard

**Ways to reach Dashboard**:
1. After completing onboarding
2. From Home Screen → Open an existing project
3. From Projects Screen → Click any project card

### Dashboard Layout

**Top App Bar**:
- **Home Icon** (left): Return to Home Screen
- **Project Name**: Shows current project name (or "Design System" if unnamed)
- **Profile Avatar** (right): Access your profile
- **Save Icon**: Manually save project (projects auto-save, but this ensures immediate save)
- **History Icon**: Access version history
- **Design Library Icon**: Browse Material Design and Cupertino libraries
- **Projects Icon**: View all your projects

**Main Content**:
- **Design Library Card** (top): Quick access to Material Design and Cupertino libraries
- **Project Description** (if provided): Shows your project description
- **Design Tokens Grid**: All available design token categories

### Design Token Categories

The dashboard shows cards for each design token type:

1. **🎨 Colors** - Manage color palettes
2. **✍️ Typography** - Font families, weights, sizes, styles
3. **📏 Spacing** - Spacing scale and values
4. **🔲 Border Radius** - Corner radius values
5. **🌑 Shadows** - Elevation and shadow definitions
6. **✨ Effects** - Glass morphism, overlays
7. **🧩 Components** - Buttons, cards, inputs, navigation, avatars, modals, tables, progress, alerts
8. **📐 Grid** - Layout grid system
9. **🎯 Icons** - Icon size definitions
10. **🌈 Gradients** - Gradient definitions
11. **👥 Roles** - Role-based theming
12. **🏷️ Semantic Tokens** - Purpose-driven tokens
13. **🎬 Motion Tokens** - Animation duration and easing
14. **👁️ Preview** - Visual preview of design system
15. **💾 Export** - Export to JSON, Flutter, Kotlin, Swift

**Navigation**: Click any card to open that token category's screen

---

## Design Token Management

### 🎨 Colors

#### Accessing Colors Screen

**Path**: Dashboard → Click **"Colors"** card

#### Understanding the Colors Screen

**Top App Bar**:
- **Back Arrow**: Return to Dashboard
- **Title**: "Colors"
- **Add Button (+)**: Add new colors

**Tabs**:
- **Primary**: Primary brand colors
- **Semantic**: Semantic colors (success, error, warning, info)
- **Blue, Green, Orange, Purple, Red, Grey**: Color category palettes
- **Note**: Tabs appear as you add colors to them

**Color Cards**:
- Each color shows:
  - Color preview (large rectangle)
  - Color name
  - Hex value
  - Description (if provided)
  - Three dots menu (⋮) for actions

#### Adding Colors - Method 1: Advanced Color Picker (Recommended)

**Steps**:

1. **Click the "+" button** (top right)
2. **Enter details**:
   - **Color Name**: e.g., "primary", "accent", "error"
   - **Description** (optional): e.g., "Main brand color"
3. **Click "Browse Color Palettes & Get Suggestions"**
4. **Advanced Color Picker opens** with 5 tabs:

   **Tab 1: Palettes**
   - Browse curated color palettes
   - **Tap colors** to select multiple (selected colors show checkmark)
   - **Click "Material Design"** or **"iOS"** to browse system palettes
   - In Material/iOS pickers:
     - Browse color palettes (Blue, Green, Red, etc.)
     - **Tap colors** to select
     - **Click "Use This Color"** to return with selected color
   - Selected colors return with scales and suggestions
   - **Click "Add X Colors"** to save all selected colors

   **Tab 2: Color Wheel**
   - Interactive HSL color wheel
   - **Drag** to select hue (outer ring)
   - **Drag** to adjust saturation and lightness (inner area)
   - Real-time color preview
   - Perfect for precise color selection
   - **Click "Add Color"** when satisfied

   **Tab 3: Color Schemes**
   - **Pick Base Color**: Click color picker to select base color
   - **Generate Schemes**: Choose scheme type:
     - Monochromatic
     - Analogous
     - Complementary
     - Triadic
     - Split Complementary
     - Tetradic
   - Generated colors appear with light/dark scales
   - **Click "Add X Colors"** to save all generated colors

   **Tab 4: Contrast Checker**
   - **Select Foreground Color**: Click foreground color picker
   - **Select Background Color**: Click background color picker
   - **See Live Preview**: Text preview shows how colors look together
   - **Get Information**:
     - Contrast ratio (WCAG AA/AAA compliance)
     - Accessibility score
     - Readability status (Pass/Fail)
   - **Get Suggestions**: If contrast is low, suggestions appear
   - **Click "Add Color"** to save foreground color

   **Tab 5: Color Analysis**
   - **Color Psychology**: Meanings and emotional impact
   - **Cultural Associations**: Warnings for different regions
   - **Demographic Preferences**: Age/gender-based recommendations
   - **Harmony Analysis**: How well colors work together
   - **Click "Add Color"** to save

5. **After selecting colors**: Click **"Add X Colors"** (where X is number of selected colors)
6. **Success**: Colors are saved to the appropriate category

#### Adding Colors - Method 2: Simple Color Picker

**Steps**:

1. **Click the "+" button**
2. **Enter color name and description**
3. **Tap the color preview box** (opens simple color picker)
4. **Select a color** visually
5. **Click "Add"** to save

#### Adding Colors - Method 3: Direct Hex Input

**Steps**:

1. **Click the "+" button**
2. **Enter color name and description**
3. **In the color picker dialog**: Use the hex input field
4. **Enter hex value**: e.g., `#FF5733` or `FF5733`
5. **Click "Add"** to save

#### Editing Colors

**Steps**:

1. **Click any color card**
2. **Edit dialog opens** with:
   - Color name (editable)
   - Description (editable)
   - Color picker (change color)
3. **Make changes**
4. **Click "Update"** to save

#### Deleting Colors

**Steps**:

1. **Click the three dots menu (⋮)** on any color card
2. **Select "Delete"**
3. **Confirm deletion**
4. **Color is removed**

#### Color Categories

**Understanding categories**:
- **Primary**: Main brand colors
- **Semantic**: Purpose-driven colors (success, error, warning, info)
- **Named Categories** (Blue, Green, etc.): Organize colors by hue

**Tips**:
- Use Primary for your main brand colors
- Use Semantic for UI feedback colors
- Use named categories to organize color palettes

#### Color Scales

**Automatic Generation**:
- Colors added via Advanced Color Picker automatically get light/dark scale variations
- Scales are generated with 10 steps (light to dark)
- Scale colors are named: `colorName_light1`, `colorName_light2`, etc.

**Viewing Scales**:
- Scale variations appear in the same category as the base color
- They're automatically named and organized

---

### ✍️ Typography

#### Accessing Typography Screen

**Path**: Dashboard → Click **"Typography"** card

#### Understanding the Typography Screen

**Tabs**:
1. **Font Family**: Primary and fallback fonts
2. **Font Weights**: Weight values (100-900)
3. **Font Sizes**: Size values with line heights
4. **Text Styles**: Reusable text style combinations

#### Managing Font Families

**Steps**:

1. **Go to "Font Family" tab**
2. **Click edit icon** next to "Font Family"
3. **Enter fonts**:
   - **Primary Font** (Required): e.g., "Roboto", "Inter", "Poppins"
   - **Fallback Fonts** (Optional): e.g., "system-ui", "sans-serif"
4. **Click "Save"**

**Tips**:
- Use web-safe fonts or ensure fonts are loaded in your project
- Fallback fonts provide alternatives if primary font fails to load

#### Managing Font Weights

**Steps**:

1. **Go to "Font Weights" tab**
2. **Click "+" button**
3. **Enter**:
   - **Weight Name**: e.g., "light", "regular", "bold"
   - **Value**: 100-900 (e.g., 300, 400, 700)
   - **Description** (optional)
4. **Click "Add"**

**Common Weights**:
- 100: Thin
- 300: Light
- 400: Regular/Normal
- 500: Medium
- 700: Bold
- 900: Black

#### Managing Font Sizes

**Steps**:

1. **Go to "Font Sizes" tab**
2. **Click "+" button**
3. **Enter**:
   - **Size Name**: e.g., "xs", "sm", "base", "lg", "xl"
   - **Size Value**: e.g., "12px", "14px", "16px"
   - **Line Height**: e.g., "16px", "20px", "24px"
   - **Description** (optional)
4. **Click "Add"**

**Tips**:
- Use consistent naming (xs, sm, md, lg, xl)
- Line height should be 1.2-1.5x font size for readability

#### Managing Text Styles

**Steps**:

1. **Go to "Text Styles" tab**
2. **Click "+" button**
3. **Enter**:
   - **Style Name**: e.g., "heading1", "body", "caption"
   - **Font Family**: Select from your defined fonts
   - **Font Size**: Select from your defined sizes
   - **Font Weight**: Select from your defined weights
   - **Line Height**: Enter value
   - **Color** (optional): Click colorize icon to use color picker
   - **Text Decoration** (optional): underline, overline, line-through
4. **Click "Add"**

**Editing Text Styles**:
- Click any text style card to edit
- Make changes and click "Update"

**Deleting Text Styles**:
- Click three dots menu (⋮) → Delete

---

### 📏 Spacing

#### Accessing Spacing Screen

**Path**: Dashboard → Click **"Spacing"** card

#### Understanding the Spacing Screen

**Visual Scale**: Shows all spacing values in a visual scale
**Add Button (+)**: Add new spacing values

#### Adding Spacing Values

**Steps**:

1. **Click "+" button**
2. **Enter**:
   - **Key**: e.g., "1", "2", "3", "4" (spacing scale number)
   - **Value**: e.g., "4px", "8px", "16px", "24px"
3. **Click "Add"**

**Tips**:
- Use consistent scale (e.g., 4px, 8px, 12px, 16px, 24px, 32px)
- Common scales: 4px base (4, 8, 12, 16, 24, 32, 48, 64)
- Values are automatically added to the scale

#### Editing Spacing Values

**Steps**:

1. **Click any spacing value** in the scale
2. **Edit dialog opens**
3. **Modify key or value**
4. **Click "Update"**

#### Deleting Spacing Values

**Steps**:

1. **Click spacing value**
2. **In edit dialog**: Click delete button
3. **Confirm deletion**

---

### 🔲 Border Radius

#### Accessing Border Radius Screen

**Path**: Dashboard → Click **"Border Radius"** card

#### Understanding the Border Radius Screen

**Predefined Values**:
- None (0px)
- Small (4px)
- Base (8px)
- Medium (12px)
- Large (16px)
- XL (24px)
- Full (999px or 50%)

**Visual Preview**: Each value shows how it looks applied to shapes

#### Editing Border Radius Values

**Steps**:

1. **Click any radius value** (None, Small, Base, etc.)
2. **Edit dialog opens**
3. **Enter new value**: e.g., "8px", "12px", "50%"
4. **Click "Update"**

**Tips**:
- Use consistent values across your design system
- Common values: 4px, 8px, 12px, 16px, 24px
- Full radius (50% or 999px) creates circles/pills

---

### 🌑 Shadows

#### Accessing Shadows Screen

**Path**: Dashboard → Click **"Shadows"** card

#### Understanding the Shadows Screen

**Shadow Cards**: Each shadow shows:
- Shadow name
- Shadow value (visual preview)
- Description (if provided)

#### Adding Shadows

**Steps**:

1. **Click "+" button**
2. **Enter**:
   - **Shadow Name**: e.g., "sm", "md", "lg", "xl"
   - **Shadow Value**: Format: `offsetX offsetY blur color`
     - Example: `0 2px 4px rgba(0,0,0,0.1)`
     - Example: `0 4px 8px rgba(0,0,0,0.15)`
   - **Description** (optional)
3. **Click "Add"**

**Shadow Value Format**:
- `offsetX offsetY blur color`
- `offsetX offsetY blur spread color` (with spread)
- Use rgba() for color with opacity

**Common Shadows**:
- Small: `0 1px 2px rgba(0,0,0,0.05)`
- Medium: `0 4px 6px rgba(0,0,0,0.1)`
- Large: `0 10px 15px rgba(0,0,0,0.1)`

#### Editing Shadows

**Steps**:

1. **Click any shadow card**
2. **Edit dialog opens**
3. **Modify name, value, or description**
4. **Click "Update"**

#### Deleting Shadows

**Steps**:

1. **Click shadow card**
2. **In edit dialog**: Click delete button
3. **Confirm deletion**

---

### ✨ Effects

#### Accessing Effects Screen

**Path**: Dashboard → Click **"Effects"** card

#### Understanding the Effects Screen

**Available Effects**:
- **Glass Morphism**: Frosted glass effect
- **Dark Overlay**: Dark overlay for modals/overlays

#### Configuring Effects

**Steps**:

1. **Click on an effect** (Glass Morphism or Dark Overlay)
2. **Configure properties**:
   - **Glass Morphism**: Background blur, opacity, border
   - **Dark Overlay**: Opacity, color
3. **Click "Save"**

**Tips**:
- Glass morphism is popular in modern UI design
- Dark overlays help focus attention on modals

---

### 🧩 Components

#### Accessing Components Screen

**Path**: Dashboard → Click **"Components"** card

#### Understanding the Components Screen

**Tabs** (9 component types):
1. **Buttons**: Primary, secondary, outlined, text buttons
2. **Cards**: Container cards with various styles
3. **Inputs**: Text fields, forms, inputs
4. **Navigation**: Navigation bars, menus
5. **Avatars**: User avatars and profile images
6. **Modals**: Dialog boxes and modal windows
7. **Tables**: Data tables and grids
8. **Progress**: Progress bars and indicators
9. **Alerts**: Notification alerts and banners

**Component Cards**: Each shows:
- Component name
- Properties (height, borderRadius, padding, fontSize, fontWeight)
- States (if defined)
- Three dots menu (⋮) for actions

#### Adding Components

**Steps**:

1. **Select a category tab** (e.g., Buttons)
2. **Click "+" button**
3. **Enter component details**:
   - **Component Name**: e.g., "primary", "secondary", "outlined"
   - **Height**: e.g., "40px", "48px"
   - **Border Radius**: e.g., "8px", "12px"
   - **Padding**: e.g., "12px 24px"
   - **Font Size**: e.g., "14px", "16px"
   - **Font Weight**: e.g., 400, 500, 700
4. **Select Component States**:
   - **Default**: Normal state (always included)
   - **Hover**: Mouse hover state
   - **Active**: Active/pressed state
   - **Focus**: Keyboard focus state
   - **Disabled**: Disabled state
   - **Loading**: Loading state
   - **Note**: Buttons and inputs have default states pre-selected
5. **Click "Add"**

**Component States Explained**:
- **Default**: Base appearance
- **Hover**: When mouse hovers over component
- **Active**: When component is pressed/clicked
- **Focus**: When component has keyboard focus
- **Disabled**: When component is disabled
- **Loading**: When component shows loading state

#### Editing Components

**Steps**:

1. **Click any component card**
2. **Edit dialog opens** (same as add dialog)
3. **Modify properties or states**
4. **Click "Update"**

#### Deleting Components

**Steps**:

1. **Click three dots menu (⋮)** on component card
2. **Select "Delete"**
3. **Confirm deletion**

**Tips**:
- Define states for interactive components (buttons, inputs)
- Use consistent naming (primary, secondary, tertiary)
- Document component usage in descriptions

---

### 📐 Grid

#### Accessing Grid Screen

**Path**: Dashboard → Click **"Grid"** card

#### Understanding the Grid Screen

**Grid Configuration**:
- **Columns**: Number of columns (e.g., 12, 16)
- **Gutter**: Space between columns (e.g., "16px", "24px")
- **Margin**: Outer margin (e.g., "16px", "24px")
- **Breakpoints**: Responsive breakpoints

#### Configuring Grid

**Steps**:

1. **Edit grid properties**:
   - **Columns**: Enter number (e.g., 12)
   - **Gutter**: Enter value (e.g., "16px")
   - **Margin**: Enter value (e.g., "16px")
2. **Add Breakpoints**:
   - Click "+" to add breakpoint
   - Enter breakpoint name (e.g., "mobile", "tablet", "desktop")
   - Enter min-width (e.g., "768px", "1024px")
3. **Click "Save"**

**Common Grid Systems**:
- **12-column**: Most common (Bootstrap-style)
- **16-column**: More granular control
- **Gutter**: Usually 16px or 24px
- **Margin**: Usually matches gutter

---

### 🎯 Icons

#### Accessing Icons Screen

**Path**: Dashboard → Click **"Icons"** card

#### Understanding the Icons Screen

**Icon Size Cards**: Each shows:
- Icon name
- Size value
- Description (if provided)

#### Adding Icon Sizes

**Steps**:

1. **Click "+" button**
2. **Enter**:
   - **Icon Name**: e.g., "sm", "md", "lg", "xl"
   - **Size**: e.g., "16px", "24px", "32px", "48px"
   - **Description** (optional)
3. **Click "Add"**

**Common Icon Sizes**:
- Small: 16px
- Medium: 24px
- Large: 32px
- Extra Large: 48px

#### Editing Icon Sizes

**Steps**:

1. **Click any icon size card**
2. **Edit dialog opens**
3. **Modify name, size, or description**
4. **Click "Update"**

#### Deleting Icon Sizes

**Steps**:

1. **Click icon size card**
2. **In edit dialog**: Click delete button
3. **Confirm deletion**

---

### 🌈 Gradients

#### Accessing Gradients Screen

**Path**: Dashboard → Click **"Gradients"** card

#### Understanding the Gradients Screen

**Gradient Cards**: Each shows:
- Gradient name
- Visual preview
- Gradient type and direction
- Description (if provided)

#### Adding Gradients

**Steps**:

1. **Click "+" button**
2. **Enter gradient details**:
   - **Gradient Name**: e.g., "primary-gradient", "sunset"
   - **Type**: Linear or Radial
   - **Direction** (for linear): e.g., "to right", "to bottom", "45deg"
   - **Colors**: Add color stops
     - Click "+" to add color
     - Select color from picker
     - Set position (0-100%)
   - **Description** (optional)
3. **Click "Add"**

**Gradient Types**:
- **Linear**: Gradient in a straight line
- **Radial**: Gradient from center outward

**Common Directions**:
- `to right`: Left to right
- `to bottom`: Top to bottom
- `45deg`: Diagonal
- `to bottom right`: Corner gradient

#### Editing Gradients

**Steps**:

1. **Click any gradient card**
2. **Edit dialog opens**
3. **Modify properties**
4. **Click "Update"**

#### Deleting Gradients

**Steps**:

1. **Click gradient card**
2. **In edit dialog**: Click delete button
3. **Confirm deletion**

---

### 👥 Roles

#### Accessing Roles Screen

**Path**: Dashboard → Click **"Roles"** card

#### Understanding the Roles Screen

**Role Cards**: Each shows:
- Role name
- Primary color preview
- Accent color preview
- Background color preview
- Description (if provided)

#### Adding Roles

**Steps**:

1. **Click "+" button**
2. **Enter role details**:
   - **Role Name**: e.g., "admin", "user", "guest"
   - **Primary Color**: Click color picker to select
   - **Accent Color**: Click color picker to select
   - **Background Color**: Click color picker to select
   - **Description** (optional)
3. **Click "Add"**

**Role-Based Theming**:
- Different user roles can have different color schemes
- Useful for multi-tenant applications
- Example: Admin (blue), User (green), Guest (grey)

#### Editing Roles

**Steps**:

1. **Click any role card**
2. **Edit dialog opens**
3. **Modify colors or description**
4. **Click "Update"**

#### Deleting Roles

**Steps**:

1. **Click role card**
2. **In edit dialog**: Click delete button
3. **Confirm deletion**

---

### 🏷️ Semantic Tokens

#### Accessing Semantic Tokens Screen

**Path**: Dashboard → Click **"Semantic Tokens"** card

#### Understanding Semantic Tokens

**Purpose**: Map purpose-driven names to base tokens
- Example: `text-primary` → `colors.primary.primary`
- Example: `surface-elevated` → `colors.grey.100`

**Benefits**:
- Easier to maintain (change base token, semantic token updates)
- Better abstraction (designers think in terms of purpose)
- Consistent naming across projects

#### Understanding the Semantic Tokens Screen

**Tabs** (5 categories):
1. **Color**: Semantic color tokens
2. **Typography**: Semantic typography tokens
3. **Spacing**: Semantic spacing tokens
4. **Shadow**: Semantic shadow tokens
5. **Radius**: Semantic border radius tokens

**Token Cards**: Each shows:
- Semantic name (e.g., "text-primary")
- Base token reference (e.g., "colors.primary.primary")
- Description
- Category icon

#### Adding Semantic Tokens

**Steps**:

1. **Select a category tab** (e.g., Color)
2. **Click "+" button**
3. **Enter token details**:
   - **Semantic Name**: e.g., "text-primary", "surface-elevated", "border-subtle"
   - **Base Token Reference**: 
     - Click an **available base token chip** to auto-fill
     - Or type manually: e.g., "colors.primary.primary", "spacing.4"
   - **Description**: Explain the token's purpose
4. **Click "Add"**

**Available Base Tokens**:
- The app shows chips with available base tokens
- Click a chip to auto-fill the reference field
- Examples: `colors.primary.primary`, `spacing.4`, `typography.fontSizes.base`

**Naming Conventions**:
- Use kebab-case: `text-primary`, `surface-elevated`
- Be descriptive: `button-primary-background`, `input-border-color`
- Group by purpose: `text-*`, `surface-*`, `border-*`

#### Editing Semantic Tokens

**Steps**:

1. **Click any token card** (expansion tile)
2. **Token expands** to show details
3. **Click edit icon**
4. **Modify name, reference, or description**
5. **Click "Update"**

#### Deleting Semantic Tokens

**Steps**:

1. **Click token card** to expand
2. **Click delete icon**
3. **Confirm deletion**

**Tips**:
- Create semantic tokens for commonly used combinations
- Document the purpose clearly in descriptions
- Use consistent naming patterns

---

### 🎬 Motion Tokens

#### Accessing Motion Tokens Screen

**Path**: Dashboard → Click **"Motion Tokens"** card

#### Understanding Motion Tokens

**Purpose**: Define animation timing and easing functions for consistent motion design

**Categories**:
1. **Duration**: Animation timing (e.g., fast: 150ms, slow: 500ms)
2. **Easing**: Animation curves (e.g., ease-in, cubic-bezier)

#### Understanding the Motion Tokens Screen

**Top App Bar**:
- **Back Arrow**: Return to Dashboard
- **Title**: "Motion Tokens"
- **Category Chips**: Switch between Duration and Easing
- **Add Button (+)**: Add new tokens

**Token Cards**: Each shows:
- Token name
- Value (with monospace font)
- Category icon
- Edit and delete buttons

#### Adding Duration Tokens

**Steps**:

1. **Select "Duration" chip** (if not already selected)
2. **Click "+" button**
3. **Enter**:
   - **Token Name**: e.g., "fast", "medium", "slow", "instant"
   - **Value**: Duration in milliseconds, e.g., "150ms", "300ms", "500ms"
4. **Click "Add"**

**Common Duration Values**:
- Instant: 0ms
- Fast: 150ms
- Medium: 300ms
- Slow: 500ms
- Very Slow: 1000ms

#### Adding Easing Tokens

**Steps**:

1. **Select "Easing" chip**
2. **Click "+" button**
3. **Enter**:
   - **Token Name**: e.g., "ease-in", "ease-out", "bounce"
   - **Value**: Easing function, e.g.:
     - `ease-in`
     - `ease-out`
     - `ease-in-out`
     - `linear`
     - `cubic-bezier(0.4, 0, 1, 1)`
4. **Or click a preset chip** to auto-fill:
   - `ease-in`
   - `ease-out`
   - `ease-in-out`
   - `linear`
   - `cubic-bezier(0.4, 0, 1, 1)`
   - `cubic-bezier(0, 0, 0.2, 1)`
5. **Click "Add"**

**Common Easing Functions**:
- `ease-in`: Slow start, fast end
- `ease-out`: Fast start, slow end
- `ease-in-out`: Slow start and end
- `linear`: Constant speed
- `cubic-bezier()`: Custom curves

#### Editing Motion Tokens

**Steps**:

1. **Click edit icon** on any token card
2. **Edit dialog opens**
3. **Modify name or value**
4. **Click "Update"**

#### Deleting Motion Tokens

**Steps**:

1. **Click delete icon** on token card
2. **Confirm deletion dialog**
3. **Click "Delete"**

**Tips**:
- Use consistent duration values across your system
- Document easing functions in descriptions
- Test animations to ensure they feel natural

---

## Design Libraries

### Accessing Design Libraries

**Ways to access**:
1. Dashboard → Click **"Design Library"** card (top)
2. Dashboard → Click **design library icon** in app bar

### Understanding Design Libraries

**Two Libraries Available**:
1. **Material Design**: Google's Material Design 3 system
2. **Cupertino (iOS)**: Apple's iOS Human Interface Guidelines

**Purpose**: Browse and import ready-made components, colors, icons, and typography

### Material Design Library

#### Accessing Material Design

**Path**: Design Library Screen → Click **"Material Design"** card

#### Understanding Material Design Library

**Tabs** (4 tabs):
1. **Colors**: Material color palettes
2. **Icons**: Material Design icons
3. **Components**: Material components
4. **Typography**: Material typography

#### Material Colors Tab

**What you'll see**:
- Color palettes: Blue, Green, Red, Orange, Purple, Teal, Indigo, Grey
- Each palette shows all shades (50, 100, 200...900)

**Two Modes**:

**Mode 1: Color Picker Mode** (Default)
- **Purpose**: Select colors for your design system
- **How to use**:
  1. Browse palettes
  2. **Tap colors** to select (selected colors show checkmark)
  3. **Click "Use This Color"** button
  4. Selected colors return to previous screen with scales
  5. Colors are ready to add to your design system

**Mode 2: Import Mode**
- **Purpose**: Import entire palettes
- **How to use**:
  1. Browse palettes
  2. **Click "Add" button** on any palette card
  3. All shades (50-900) are imported automatically
  4. Colors appear in appropriate categories in your Colors screen

**Tips**:
- Use Color Picker Mode when selecting specific colors
- Use Import Mode when you want entire Material palettes

#### Material Icons Tab

**What you'll see**:
- Grid of Material Design icons
- Search bar to find icons by name

**Using Icons**:
1. **Browse icons** or **search** by name
2. **Click an icon** to view details
3. **Import**: Click "Import" to add to your design system

#### Material Components Tab

**What you'll see**:
- List of Material components:
  - Buttons, Cards, Text Fields, Navigation, etc.

**Using Components**:
1. **Browse components**
2. **Click a component** to view specifications
3. **Import**: Click "Import" to add to your design system

#### Material Typography Tab

**What you'll see**:
- Material typography styles
- Font families, sizes, weights

**Using Typography**:
1. **Browse typography styles**
2. **Click a style** to view details
3. **Import**: Click "Import" to add to your design system

### Cupertino (iOS) Library

#### Accessing Cupertino Library

**Path**: Design Library Screen → Click **"Cupertino (iOS)"** card

#### Understanding Cupertino Library

**Tabs** (4 tabs):
1. **Colors**: iOS system colors
2. **Icons**: SF Symbols (iOS icon system)
3. **Components**: iOS components
4. **Typography**: iOS typography (San Francisco font)

#### Cupertino Colors Tab

**What you'll see**:
- **System Colors**: Blue, Green, Red, Orange, Yellow, Pink, Purple, Teal, Indigo
- **Semantic Colors**: Label, Background, Separator, etc.

**Two Modes**: Same as Material (Color Picker or Import)

**Using Colors**:
- **Color Picker Mode**: Tap colors → "Use This Color"
- **Import Mode**: Click "Add" on palette → All colors imported

#### Cupertino Icons Tab

**What you'll see**:
- SF Symbols (iOS icon system)
- Search bar to find icons

**Using Icons**:
1. **Browse or search** SF Symbols
2. **Click icon** to view details
3. **Import**: Add to your design system

#### Cupertino Components Tab

**What you'll see**:
- iOS components: Buttons, Lists, Navigation, etc.

**Using Components**:
1. **Browse components**
2. **View specifications**
3. **Import**: Add to your design system

#### Cupertino Typography Tab

**What you'll see**:
- iOS typography styles
- San Francisco font specifications

**Using Typography**:
1. **Browse typography**
2. **View details**
3. **Import**: Add to your design system

### Design Library Tips

**Best Practices**:
- ✅ Use Color Picker Mode for specific color selection
- ✅ Use Import Mode for complete palettes
- ✅ Imported items appear immediately in your design system
- ✅ Review imported items in their respective screens
- ✅ Customize imported items to match your brand

---

## Preview and Export

### 👁️ Preview

#### Accessing Preview Screen

**Path**: Dashboard → Click **"Preview"** card

#### Understanding Preview Screen

**What you'll see**:
- Visual preview of your entire design system
- All design tokens displayed visually
- Colors, typography, spacing, components, etc.

#### Exporting as PDF

**Steps**:

1. **In Preview Screen**: Click **PDF icon** (top right)
2. **PDF Generation**:
   - App generates a PDF document
   - Contains all your design tokens
   - Formatted for documentation
3. **Save/Share**:
   - **Desktop**: Choose save location
   - **Mobile/Web**: Preview and share options
   - **Web**: Opens in browser, use browser's print/save dialog

**PDF Contents**:
- Project information (name, description, version)
- All colors with hex values
- Typography styles
- Spacing scale
- Components
- And more...

**Tips**:
- Export PDF for team documentation
- Share PDF with stakeholders
- Use PDF for design handoffs

---

### 💾 Export

#### Accessing Export Screen

**Path**: Dashboard → Click **"Export"** card

#### Understanding Export Screen

**Export Formats**:
1. **JSON**: Raw design system data
2. **Flutter**: Dart code for Flutter projects
3. **Kotlin**: Code for Android projects
4. **Swift**: Code for iOS projects

#### Exporting to JSON

**Steps**:

1. **Select "JSON" format** (default)
2. **Click "Generate Export"**
3. **Code appears** in the code viewer
4. **Copy or Save**:
   - **Copy**: Click "Copy" button to copy to clipboard
   - **Save**: Click "Save" button to save as file
     - Desktop: Choose save location
     - Web: Downloads folder

**Use Cases**:
- Version control (commit to git)
- Backups
- Importing into other tools
- API integration

#### Exporting to Flutter (Dart)

**Steps**:

1. **Select "Flutter" format**
2. **Click "Generate Export"**
3. **Dart code appears**
4. **Copy or Save** the code
5. **Use in Flutter project**:
   - Copy code to your Flutter project
   - Import and use design tokens

**Use Cases**:
- Flutter mobile apps
- Flutter web apps
- Flutter desktop apps

#### Exporting to Kotlin (Android)

**Steps**:

1. **Select "Kotlin" format**
2. **Click "Generate Export"**
3. **Kotlin code appears**
4. **Copy or Save** the code
5. **Use in Android project**:
   - Copy code to your Android project
   - Use design tokens in your app

**Use Cases**:
- Native Android apps
- Android libraries

#### Exporting to Swift (iOS)

**Steps**:

1. **Select "Swift" format**
2. **Click "Generate Export"**
3. **Swift code appears**
4. **Copy or Save** the code
5. **Use in iOS project**:
   - Copy code to your iOS project
   - Use design tokens in your app

**Use Cases**:
- Native iOS apps
- iOS libraries

### Export Tips

**Best Practices**:
- ✅ Export JSON regularly for backups
- ✅ Export platform-specific code when starting new projects
- ✅ Version control your JSON exports
- ✅ Share exports with your development team
- ✅ Use exports for design-to-code handoffs

---

## Project Management

### 📁 Viewing All Projects

#### Accessing Projects Screen

**Ways to access**:
1. **Dashboard**: Click **folder icon** (top right) → "My Projects"
2. **Home Screen**: Click **"My Projects"** button
3. **Profile**: Click profile icon → "Projects"

#### Understanding Projects Screen

**What you'll see**:
- **List of all projects**: All your saved projects
- **Project Cards**: Each shows:
  - Project name
  - Description
  - Creation date
  - Last modified (if available)
  - Delete icon

**Top App Bar**:
- **Title**: "My Projects"
- **Refresh Icon**: Reload projects list
- **Add Icon (+)**: Create new project

### Opening a Project

**Steps**:

1. **Go to Projects Screen**
2. **Click any project card**
3. **Project loads** and you're taken to **Dashboard**
4. **Start editing** your design system

### Creating a New Project

**Ways to create**:
1. **Projects Screen**: Click **"+" button** (top right)
2. **Home Screen**: Click **"Get Started"** or **"Create New Project"**
3. **Dashboard**: Click home icon → "Create New Project"

**Process**:
- You'll go through the **5-step onboarding** process
- Project is **auto-saved** after creation

### Deleting a Project

**Steps**:

1. **Go to Projects Screen**
2. **Click delete icon** (trash) on project card
3. **Confirm deletion dialog**
4. **Click "Delete"**
5. **⚠️ Warning**: This action cannot be undone!

**Note**: Deleted projects are permanently removed

### Project Auto-Save

**How it works**:
- Projects are **automatically saved** after creation
- Changes are saved in memory (session-based)
- **Manual save**: Click save icon in Dashboard app bar

**Cloud Sync**:
- **Logged-in users**: Projects sync to Firebase (cloud)
- **Guest users**: Projects saved locally only

### Loading Projects

**Automatic Loading**:
- Projects load automatically when you open them
- Recent projects may appear on Home Screen

**Manual Loading**:
- Go to Projects Screen
- Click any project card

---

## Profile and Settings

### 👤 Profile

#### Accessing Profile

**Ways to access**:
1. **Dashboard**: Click **profile avatar** (top right)
2. **Home Screen**: Click **profile icon** (top right)
3. **Settings**: Profile section

#### Understanding Profile Screen

**What you'll see**:
- **Profile Header**:
  - Profile picture (or initial)
  - Name
  - Email
  - Membership status (if applicable)
- **Statistics**:
  - Projects created
  - Design tokens added
  - Last active date
- **Account Actions**:
  - Edit profile
  - View projects
  - Access settings

#### Editing Profile

**Steps**:

1. **Go to Profile Screen**
2. **Click "Edit Profile"** button
3. **Modify**:
   - Name
   - Profile picture (if supported)
4. **Click "Save"**

### ⚙️ Settings

#### Accessing Settings

**Ways to access**:
1. **Profile Screen**: Click **settings icon** (top right)
2. **Profile Screen**: Click "Settings" option

#### Understanding Settings Screen

**Sections**:

1. **Account**:
   - **Profile**: Manage profile information
   - **Email**: View/change email (if supported)
   - **Password**: Change password (if supported)

2. **App Settings**:
   - **Notifications**: Manage notification preferences
   - **Theme**: Light/Dark mode (if supported)
   - **Language**: App language (if supported)

3. **Privacy**:
   - **Data Sharing**: Control data sharing preferences
   - **Visibility**: Control profile visibility

4. **Support**:
   - **Help**: Access help documentation
   - **Feedback**: Send feedback
   - **Contact**: Contact support

5. **About**:
   - **App Version**: Current version
   - **Terms of Service**: View terms
   - **Privacy Policy**: View privacy policy

#### Changing Settings

**Steps**:

1. **Go to Settings Screen**
2. **Navigate to desired section**
3. **Modify settings**:
   - Toggle switches
   - Click options to change
4. **Changes save automatically** (or click "Save" if required)

### Signing Out

**Steps**:

1. **Go to Settings Screen**
2. **Scroll to bottom**
3. **Click "Sign Out"**
4. **Confirm**: You'll be signed out
5. **Return to Home Screen**

---

## Version History

### 📜 Accessing Version History

**Path**: Dashboard → Click **history icon** (📜) in app bar

### Understanding Version History

**What you'll see**:
- **List of all versions**: Chronological list (newest first)
- **Version Cards**: Each shows:
  - Version number (e.g., "v1.0.0")
  - Date and time
  - "Current" badge (for current version)
  - Expandable details

**Expanded View**:
- **Description**: Version description (if provided)
- **Changes**: List of changes in this version
- Each change item shows with bullet point

### Adding a New Version

**Steps**:

1. **Go to Version History Screen**
2. **Click "+" button** (top right)
3. **Enter version details**:
   - **Version**: Use semantic versioning (e.g., "1.1.0", "2.0.0")
     - Format: `major.minor.patch`
     - Example: `1.0.0`, `1.1.0`, `2.0.0`
   - **Description** (optional): Brief description of this version
   - **Changes**: Add change items
     - Type change in text field
     - Press Enter or click "Add Change" button
     - Change appears as a chip
     - Add multiple changes
     - Remove changes by clicking X on chip
4. **Click "Add Version"**
5. **Success**: Version is added and becomes current version

**Version Format**:
- **Major** (1.0.0): Breaking changes
- **Minor** (0.1.0): New features, backward compatible
- **Patch** (0.0.1): Bug fixes, backward compatible

**Example Changes**:
- "Added new color palette"
- "Updated typography scale"
- "Fixed contrast issues"
- "Added component states"

### Viewing Version Details

**Steps**:

1. **Click any version card** to expand
2. **See details**:
   - Description
   - List of changes
3. **Click again** to collapse

### Version History Tips

**Best Practices**:
- ✅ Use semantic versioning consistently
- ✅ Document all significant changes
- ✅ Add version after major updates
- ✅ Keep changelog clear and concise
- ✅ Review version history regularly

---

## Tips and Best Practices

### Color Selection

**Best Practices**:
- ✅ Use the **Advanced Color Picker** for professional results
- ✅ Use **color schemes** (triadic, complementary) for harmonious palettes
- ✅ Check **contrast ratios** for accessibility (WCAG AA/AAA compliance)
- ✅ Consider **color psychology** and cultural associations
- ✅ Use **color wheel** for precise HSL adjustments
- ✅ Generate **light/dark scales** automatically via Advanced Picker

### Design System Structure

**Best Practices**:
- ✅ **Start Simple**: Begin with colors and typography, then add components
- ✅ **Consistent Naming**: Use clear, consistent names (e.g., "primary", "secondary", "error")
- ✅ **Organize by Category**: Use appropriate color categories (Primary, Semantic, etc.)
- ✅ **Document Everything**: Add descriptions to colors, typography, and components
- ✅ **Use Semantic Tokens**: Create semantic tokens for commonly used combinations

### Workflow Optimization

**Best Practices**:
- ✅ **Use Design Libraries**: Import from Material/Cupertino to speed up workflow
- ✅ **Preview First**: Always preview your design system before exporting
- ✅ **Export Regularly**: Export JSON for backups and version control
- ✅ **PDF Documentation**: Export as PDF for team sharing
- ✅ **Version Control**: Use version history to track changes

### Onboarding

**Best Practices**:
- ✅ **Complete All Steps**: The 5-step onboarding helps create a well-structured system
- ✅ **Choose Appropriate Scheme**: Select color scheme type that matches your brand
- ✅ **Review Generated Colors**: All generated colors are saved automatically
- ✅ **Select Primary Color**: Mark your main brand color in Step 5

### Project Management

**Best Practices**:
- ✅ **Save Frequently**: Projects auto-save, but use manual save for important changes
- ✅ **Backup Projects**: Export JSON regularly for backups
- ✅ **Use Cloud Sync**: Sign in to sync projects across devices
- ✅ **Organize Projects**: Use descriptive names and descriptions
- ✅ **Version History**: Add versions after major updates

### Component Design

**Best Practices**:
- ✅ **Define States**: Add states (hover, active, focus, disabled) for interactive components
- ✅ **Consistent Naming**: Use consistent component names (primary, secondary, tertiary)
- ✅ **Document Usage**: Add descriptions explaining when to use each component
- ✅ **Test States**: Ensure all states are visually distinct

### Semantic Tokens

**Best Practices**:
- ✅ **Create Semantic Tokens**: Map purpose-driven names to base tokens
- ✅ **Consistent Naming**: Use kebab-case and descriptive names
- ✅ **Document Purpose**: Clearly explain what each semantic token is for
- ✅ **Group by Purpose**: Use prefixes (text-*, surface-*, border-*)

### Motion Design

**Best Practices**:
- ✅ **Consistent Timing**: Use consistent duration values across your system
- ✅ **Natural Easing**: Choose easing functions that feel natural
- ✅ **Document Easing**: Explain when to use each easing function
- ✅ **Test Animations**: Ensure animations enhance, not distract

### Export Best Practices

**Best Practices**:
- ✅ **Platform-Specific**: Export Flutter/Kotlin/Swift code when starting new projects
- ✅ **Documentation**: Export PDF for design documentation
- ✅ **Version Control**: Export JSON and commit to git
- ✅ **Team Sharing**: Share PDF exports with designers and developers
- ✅ **Regular Backups**: Export JSON regularly

---

## Troubleshooting

### Common Issues

#### Colors Not Saving After Onboarding

**Problem**: Colors don't appear after completing onboarding

**Solution**:
- Colors are automatically saved to the **Primary** category
- Check Dashboard → Colors → Primary tab
- If colors don't appear, try refreshing or restarting the app

#### Can't See Generated Colors

**Problem**: Generated colors from onboarding don't appear

**Solution**:
- Generated colors are saved to **Primary** category
- Check Colors screen → Primary tab
- Colors include scale variations (light/dark)

#### PDF Export Not Working on Web

**Problem**: PDF doesn't download on web

**Solution**:
- PDF opens in browser preview on web
- Use browser's **Print** dialog (Ctrl+P / Cmd+P)
- Choose "Save as PDF" in print dialog
- Or use browser's download option

#### Google Sign-In Not Working

**Problem**: Google Sign-In fails

**Solution**:
- Ensure Google client ID is configured in `web/index.html`
- Check Firebase configuration
- See `FIREBASE_SETUP.md` for detailed instructions
- Ensure OAuth consent screen is configured in Google Cloud Console

#### Projects Not Syncing

**Problem**: Projects don't appear on other devices

**Solution**:
- Ensure you're **signed in** (not guest mode)
- Check internet connection
- Projects sync to Firebase when logged in
- Guest mode projects are local only

#### Color Picker Not Showing

**Problem**: Advanced Color Picker doesn't open

**Solution**:
- Ensure you clicked **"Browse Color Palettes & Get Suggestions"** button
- Check browser console for errors (web)
- Try refreshing the screen
- Ensure you're on the correct step in the add color dialog

#### Can't Navigate Back

**Problem**: Back button doesn't work

**Solution**:
- Use the **back arrow** (top left) in app bar
- Use browser back button (web)
- Use device back button (mobile)

#### Design Library Colors Not Importing

**Problem**: Colors from Material/Cupertino don't appear

**Solution**:
- Ensure you're in **"Import Mode"** (not Color Picker Mode)
- Click **"Add"** button on palette, not individual colors
- Check Colors screen after import
- Imported colors appear in appropriate categories

#### Component States Not Saving

**Problem**: Component states don't persist

**Solution**:
- Ensure you selected states before clicking "Add"
- Check Components screen → appropriate category tab
- States appear as chips on component cards
- Edit component to add/modify states

#### Version History Not Showing

**Problem**: Version history is empty

**Solution**:
- Version history starts with version 1.0.0 after project creation
- Add new versions manually via Version History screen
- Check that you're viewing the correct project

### Getting Help

**Resources**:
- **Documentation**: Check this guide and README.md
- **Issues**: Report bugs via GitHub Issues (if applicable)
- **Support**: Contact support through Settings → Support
- **Firebase Setup**: See `FIREBASE_SETUP.md` for Firebase configuration

---

## Quick Reference

### Navigation Map

```
Home Screen
├── Get Started → Onboarding (5 steps) → Dashboard
├── My Projects → Projects Screen
├── Sign In → Auth Screen → Home Screen
├── Sign Up → Auth Screen → Login → Home Screen
└── Continue as Guest → Home Screen (local storage)

Dashboard
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
├── Components → Components Screen (9 tabs)
├── Grid → Grid Screen
├── Icons → Icons Screen
├── Gradients → Gradients Screen
├── Roles → Roles Screen
├── Semantic Tokens → Semantic Tokens Screen (5 tabs)
├── Motion Tokens → Motion Tokens Screen (2 tabs)
├── Version History → Version History Screen (via app bar icon)
├── Design Library → Design Library Screen
│   ├── Material Design (4 tabs)
│   └── Cupertino (4 tabs)
├── Preview → Preview Screen → PDF Export
└── Export → Export Screen (4 formats)

Top Navigation (Dashboard)
├── Home Icon → Home Screen
├── Profile Avatar → Profile Screen
│   └── Settings → Settings Screen
├── Save Icon → Manual Save
├── History Icon → Version History
├── Design Library Icon → Design Library Screen
└── Projects Icon → Projects Screen
```

### Keyboard Shortcuts (Web/Desktop)

- `Esc`: Close dialogs/modals
- `Enter`: Confirm actions in forms
- `Tab`: Navigate between form fields
- `Backspace`: Go back (when applicable)
- `Ctrl+S` / `Cmd+S`: Save (if implemented)

### Common Tasks Quick Guide

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

**Add Component with States**:
1. Dashboard → Components
2. Select component category tab (e.g., Buttons)
3. Click "+" button
4. Enter component name and properties
5. Select component states (default, hover, active, focus, disabled, loading)
6. Save

**Create Semantic Token**:
1. Dashboard → Semantic Tokens
2. Select category tab (Color, Typography, Spacing, Shadow, Radius)
3. Click "+" button
4. Enter semantic name (e.g., "text-primary")
5. Click a base token chip to auto-fill reference (e.g., "colors.primary.primary")
6. Add description
7. Save

**Add Motion Token**:
1. Dashboard → Motion Tokens
2. Select category (Duration or Easing)
3. Click "+" button
4. Enter token name and value
5. Save

**Add Version History**:
1. Dashboard → Click history icon (📜) in app bar
2. Click "+" button
3. Enter version number (e.g., 1.1.0)
4. Add description (optional)
5. Add change items (e.g., "Added new color palette", "Updated typography scale")
6. Save

**Export Design System**:
1. Dashboard → Export
2. Select format (JSON/Flutter/Kotlin/Swift)
3. Click "Generate Export"
4. Copy or save code

**Create PDF Documentation**:
1. Dashboard → Preview
2. Click PDF icon (top right)
3. Save or share PDF

---

## Conclusion

This guide covers all aspects of using the Design System Builder app. From creating your first project to managing complex design systems, exporting code, and collaborating with your team.

**Key Takeaways**:
- ✅ Use the **5-step onboarding** to create well-structured design systems
- ✅ Leverage the **Advanced Color Picker** for professional color selection
- ✅ Use **Design Libraries** to speed up your workflow
- ✅ Create **Semantic Tokens** for better maintainability
- ✅ Track changes with **Version History**
- ✅ Export regularly for **backups and version control**
- ✅ Use **component states** for interactive components
- ✅ **Preview** before exporting
- ✅ **Document** everything with descriptions

**Happy Designing! 🎨**
