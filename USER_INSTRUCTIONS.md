# Design System Builder – User Instructions

Complete guide to using the app. Sections that are not yet available are marked **Coming soon**.

---

## What is Design System Builder?

Design System Builder helps you create and manage a design system (colors, typography, spacing, components, and more) and export it as code for **Flutter**, **Kotlin**, **Swift**, **React**, **CSS**, or **JSON**. You can preview your system and download a PDF or a full package.

---

## Getting Started

### 1. Open the app

- **Web:** Open the app in your browser (e.g. `my-flutter-apps-f87ea.web.app` or your deployed URL).
- **Desktop/Mobile:** Run the installed app.

### 2. Sign in (optional)

- You can use the app as a **guest** (no account).
- For saving projects in the cloud and using Pro/Team features, tap **Sign in** and sign in with **Google** (or the auth method you have set up).

### 3. Create or open a project

- **New project:** Tap **Create New Project**. Enter a name, choose a save location (on desktop/mobile), then tap **Create & Continue**. You’ll go through onboarding and then to the dashboard.
- **Existing project:** On the home screen you’ll see **My Projects**. Tap a project to open it and go to the dashboard.
- **Web:** New projects are saved in the browser (no folder picker). Use **Save to computer** from the dashboard to download the `.ds.json` file.

---

## Dashboard Overview

After opening a project, you see the **Dashboard** with shortcuts to:

| Section | What you can do |
|--------|-------------------|
| **Colors** | Define color palettes (primary, semantic, blue, green, etc.), pick colors, and manage roles. |
| **Typography** | Set font family, weights, sizes, and text styles. |
| **Spacing** | Define a spacing scale and values. |
| **Border Radius** | Set radius tokens (none, sm, base, md, lg, xl, full). |
| **Shadows** | Define shadow tokens. |
| **Effects** | Add glass morphism and dark overlay effects. |
| **Components** | Define buttons, cards, inputs, navigation, avatars, modals, tables, progress, alerts. |
| **UI Lab** | Preview components and tokens in a playground. |
| **Grid** | Configure grid columns and gutter. |
| **Icons** | Set icon sizes. |
| **Gradients** | Define gradient tokens. |
| **Roles** | Map roles (e.g. admin, viewer) to colors. |
| **Semantic Tokens** | Map semantic names to base tokens (color, typography, spacing, shadow, border radius). |
| **Motion Tokens** | Set duration and easing. |
| **Version History** | Add and view version entries (Team plan). |
| **Export** | Export as JSON, Tokens, Flutter, Kotlin, Swift, React, or CSS. |
| **Preview** | View a full preview of the design system and export as PDF. |
| **Design Library** | Browse Material and Cupertino design systems. |
| **Docs** | Read documentation. |

Use each tile to open the corresponding screen and edit your design system.

---

## Saving Your Work

- **Auto-save (web):** Projects are saved in the browser. Use **Save to computer** (dashboard app bar) to download the project as a `.ds.json` file.
- **Desktop/Mobile:** You can save to a chosen folder when creating a project, and use **Save to computer** to save a copy to another location.
- **Export:** Use the **Export** screen to save the project as JSON or to generate code (Flutter, Kotlin, Swift, React, CSS) or a download package. On **web**, “Save file” and “Download package” may not work in all browsers; **Coming soon** – see [Coming soon](#coming-soon) below.

---

## Preview & PDF

- Open **Preview** from the dashboard to see a full overview of your design system (colors, typography, spacing, components, etc.).
- Tap the **PDF** icon in the Preview app bar to generate and download a PDF. On web this may take a few seconds; the page should stay responsive.
- If a section has no data yet, you’ll see a placeholder; add data in the relevant dashboard section (e.g. Colors, Typography).

---

## Export

- Open **Export** from the dashboard.
- Choose format: **Tokens**, **JSON**, **Flutter**, **Kotlin**, **Swift**, **React**, or **CSS**.
- Tap **Generate Export** to see the code, then use **Save to file** to save it (on desktop/mobile). On **web**, saving exported code and the zip package is **Coming soon**.
- **Download package** creates a zip with tokens, theme, components, and documentation. On web this is **Coming soon**.

---

## Settings & Profile

Open **Settings** (from profile or menu) to manage:

- **Profile** – View and manage profile information.
- **Email** – **Coming soon.** Change email (will require re-authentication).
- **Password** – **Coming soon.** Change or reset password.
- **Notifications** – **Coming soon.** Toggle is visible but preference is not yet saved.
- **Theme** – **Coming soon.** Light/dark/system switching.
- **Language** – **Coming soon.** Language selection.
- **Privacy Policy** – **Coming soon.** Link to privacy policy.
- **Terms of Service** – **Coming soon.** Link to terms.
- **Delete Account** – **Coming soon.** Permanently delete account and data.
- **Help Center** – **Coming soon.** Help and support link.
- **Send Feedback** – **Coming soon.** Send feedback to the team.
- **About** – Available. Shows app name, version, and short description.

---

## Upgrade & Billing

- **Upgrade** screen lets you choose a plan (e.g. Pro, Team).  
- **Coming soon:** Real payment (Stripe) integration. The current flow is a **mock upgrade for testing**; no real charge. When ready, real subscriptions and webhooks will be used.

---

## Tutorials

- The **Tutorials** screen lists guides (e.g. “Design tokens in 5 minutes”, “Building your first component”, “Export to Flutter and React”).  
- **Coming soon:** Tapping a tutorial will open a real link or in-app content; currently it shows a placeholder message.

---

## Demo Gallery

- **Demo projects** (e.g. Mobile UI kit, Admin dashboard, Landing page) are shown on the Demo Gallery screen.  
- **Coming soon:** Tapping a demo will load that design system into your project or open a read-only preview; currently it shows a placeholder message.

---

## Figma Token Sync

- On the Export screen, **Figma Token Sync** is advertised as a future feature (import/export tokens, sync with Figma).  
- **Coming soon:** Full Figma plugin and sync flow.

---

## Platform Notes

| Feature | Web | Desktop / Mobile |
|--------|-----|-------------------|
| Create project | Yes (saved in browser) | Yes (can choose folder) |
| Save to computer | Yes (downloads `.ds.json`) | Yes (file picker) |
| Export PDF | Yes (may take a few seconds) | Yes |
| Save exported code (e.g. .dart) | **Coming soon** | Yes |
| Download package (zip) | **Coming soon** | Yes |
| Open project from folder | No (use My Projects) | Yes (where supported) |

---

## Coming Soon

These sections need more work. You may see “coming soon” messages or placeholders in the app until they are implemented:

1. **Settings:** Email change, password change, notifications, theme, language, privacy policy, terms, help center, feedback, delete account.
2. **Export (web):** Save exported code file and download package (zip) in the browser.
3. **Billing:** Real Stripe (or other) payment and subscription management.
4. **Tutorials:** Real tutorial links or in-app content.
5. **Demo Gallery:** Loading demo design systems when you tap a demo.
6. **Figma Token Sync:** Figma plugin and token sync.

When a feature is ready, the in-app message will be removed or updated and this list will be revised.

---

## Tips

- Start with **Colors** and **Typography**, then add **Spacing** and **Components**.
- Use **UI Lab** to try components before exporting.
- Use **Preview** to check the full system and export a PDF for sharing.
- On web, use **Save to computer** from the dashboard regularly if you want a backup of your project file.
- Pro/Team features (e.g. export code, advanced theme, version history) require an upgraded plan once real billing is available.

---

*For developers: see `TODO.md` for the implementation checklist. Mark items done with `[x]` as you implement them.*
