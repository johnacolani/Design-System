# Design System Builder — User Guide

This guide explains how to use the Design System Builder app to create, manage, and export design systems for Flutter, React, Swift, Kotlin, and Web.

---

## What is Design System Builder?

Design System Builder lets you:

- **Define design tokens** — colors, typography, spacing, radius, shadows, motion, and more
- **Build components** — buttons, cards, inputs, navigation, and other UI building blocks
- **Preview** your system in a playground (UI Lab)
- **Export** code to Flutter, React, Swift, Kotlin, or CSS
- **Download** a full design-system package (tokens, theme, components, docs)

---

## Getting started

### 1. Open the app

- **Web**: Open the app URL in your browser.
- **Desktop/Mobile**: Launch the installed app.

### 2. Sign in or continue as guest

- **Get started** or **Log in** — Sign in with email/password or Google to save projects and use Pro/Team features.
- **Pricing** — View plans (Free, Pro, Team) and feature comparison.
- **Guest** — You can explore without an account; sign in when you want to save or upgrade.

### 3. Create a project

- From the home screen, tap **Create New Project** (or **Get started** if you’re not signed in; you’ll be asked to sign in).
- Use the **onboarding wizard** to name your design system, set app type, audience, and pick a base color. The app will suggest colors and create an initial setup.
- Or open **My Projects**, pick an existing project, or create a new one from the projects list.

---

## Main workflow

### Dashboard

After opening a project, you’ll see the **dashboard** with:

- **Design Tokens** — Cards for Colors, Typography, Spacing, Border Radius, Shadows, Effects, Components, Grid, Icons, Gradients, Roles, Semantic Tokens, Motion Tokens
- **Preview** — Visual preview of your design system
- **Export** — Export to code (Pro) or view gated message
- **Documentation** — In-app docs (assets or Firestore)
- **Component Gallery** — Lazy-loaded components by category
- **Design Library** — Browse Material Design and Cupertino (iOS) and import components, colors, icons, typography
- **Version History** — Track versions (Team plan for full versioning)

Tap any card to open that section.

### Design tokens

- **Colors** — Manage primary, semantic, and custom palettes; use color picker, schemes, contrast checker.
- **Typography** — Set font families, weights, sizes, and text styles.
- **Spacing** — Define a spacing scale (e.g. xs, sm, md, lg).
- **Border radius** — Set corner radius values (none, sm, base, md, lg, xl, full).
- **Shadows** — Define elevation and shadow values.
- **Effects** — Glass morphism, overlays.
- **Components** — Add and edit buttons, cards, inputs, navigation, avatars, modals, tables, progress, alerts. Each component can have a **version** (e.g. v1, v2); use **New version** to bump.
- **Grid** — Columns, gutter, margin, breakpoints.
- **Icons** — Icon sizes.
- **Gradients** — Gradient definitions.
- **Roles** — Role-based theming (primary, accent, background per role).
- **Semantic tokens** — Map purpose-driven tokens to base tokens.
- **Motion tokens** — Duration and easing for animations.

### UI Lab (playground)

- Open **UI Lab** from the dashboard to preview components and tokens in a storybook-style playground.
- Experiment with buttons, cards, inputs, and other components without leaving the app.

### Export (Pro plan)

- Open **Export** from the dashboard.
- Choose format: **Tokens** (JSON), **JSON**, **Flutter**, **Kotlin**, **Swift**, **React**, **CSS**.
- **Generate Export**, then **Copy** or **Save** to file.
- **Download package** — Get a zip with `tokens/`, `theme/`, `components/`, `documentation/` for your design system.

If you’re on the **Free** plan, you’ll see a short explanation and an **Upgrade to Pro** option.

---

## Plans and upgrades

### Plans

- **Free** — Create design systems, use tokens and components, preview in UI Lab, one project (or as configured).
- **Pro** — Export code (Flutter, React, Swift, Kotlin, CSS), theme builder advanced, unlimited projects.
- **Team** — Everything in Pro plus team collaboration and version history.

### How to upgrade

- From **Pricing** (home or profile), choose **Upgrade to Pro** or **Contact Sales** for Team.
- Or tap a **Pro** or **Team** badge on a gated feature (e.g. Export, Theme builder advanced, Version history).
- On the **Upgrade** screen, select a plan and confirm. (Payment integration such as Stripe can be connected later; the app may use a mock upgrade for testing.)

### Gated features

- **Export code** — Shows a lock and “Pro” until you upgrade.
- **Theme builder advanced** — In Design Library, the “Theme builder advanced” card shows “Pro” until you upgrade.
- **Team collaboration & versioning** — Version History shows “Team” and limits adding versions until you’re on Team.

---

## Learn and explore

### Get started checklist

- From the home screen, open **Get started checklist** (under “Learn & explore”).
- Steps: Create tokens → Create first component → Preview in playground → Export code.
- Each step links to the right screen so you can complete the checklist in order.

### Tutorials

- Open **Tutorials** from the home “Learn & explore” section.
- Sample tutorials: Design tokens in 5 minutes, Building your first component, Export to Flutter and React.
- Tap a tutorial for its link (or placeholder).

### Demo projects

- Open **Demo projects** from the home “Learn & explore” section.
- Browse demos: Mobile UI kit, Admin dashboard, Landing page.
- Use them as references; open a demo to see its placeholder or link.

### Documentation

- From the dashboard, open **Documentation**.
- Read in-app docs (e.g. Getting started, Tokens guide). Content can come from bundled assets or from your team (e.g. Firestore) when configured.

---

## Projects and saving

- **My Projects** — From the top nav (when signed in), open **My Projects** to see saved projects and open or create one.
- **Save** — Use the save action in the dashboard (or as provided) to persist your design system. On web, projects may be stored in the browser or in Firebase depending on configuration.
- **Save to computer** — Use the dashboard option to export/save the project file to your device if supported.

---

## Profile and settings

- **Profile** — Tap your avatar or **Profile** to see your name, email, membership (Free/Pro/Team), and options to **Upgrade** or **Pricing**.
- **Settings** — From profile, open **Settings** for account and app preferences.

---

## Tips

- Complete the **Get started checklist** to learn the main flow.
- Use **Design Library** to pull in Material or Cupertino colors and components as a starting point.
- Use **New version** on components when you iterate so teams can track Button v1, v2, etc.
- On **Free**, you can build and preview everything; upgrade to **Pro** when you need export or advanced themes, and to **Team** when you need collaboration and versioning.

---

## Need help?

- Use **Documentation** and **Tutorials** in the app.
- Check the project’s **README** and docs in the repo for setup and developer information.
- For billing or plan questions, use **Contact Sales** from the Pricing page (or the contact method your team provides).
