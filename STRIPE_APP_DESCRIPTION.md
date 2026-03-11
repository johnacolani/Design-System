# Stripe – App & Product Descriptions

Use these when setting up your products in the [Stripe Dashboard](https://dashboard.stripe.com/products) or for your Stripe business profile.

---

## Short description (for product name / tagline)

**Design System Builder** – Create, manage, and export design systems for Flutter, Kotlin, and Swift.

---

## Full app description (for Stripe product or website)

**Design System Builder** is a web and desktop application that helps product teams and developers create, manage, and export design systems in one place.

**What it does:**
- **Design tokens** – Define colors, typography, spacing, border radius, shadows, effects, and motion tokens.
- **Components** – Buttons, cards, inputs, navigation, avatars, modals, tables, and more with states and variants.
- **Multi-platform export** – Export to Flutter (Dart), Kotlin (Android), Swift (iOS), React, and CSS so your design system works across apps and platforms.
- **Preview & PDF** – Visual preview of the full system and export as a PDF for documentation or handoff.
- **Design libraries** – Browse and import from Material Design and Cupertino (iOS) for inspiration or as a starting point.

**Plans:**
- **Free** – Core token and component editing, project save, and basic export.
- **Pro** – Full code export (Flutter, Kotlin, Swift, React, CSS), advanced theme builder, and PDF export.
- **Team** – Everything in Pro plus team collaboration and version history.

Ideal for design leads, developers, and small teams who want a single source of truth for their design system and ready-to-use code for multiple platforms.

---

## One-line (for Stripe Dashboard or payment page)

Design System Builder – Create and export design systems for Flutter, Kotlin, Swift, and React from one place.

---

## Security reminder

- **Publishable key** (`pk_test_...`) – Safe to use in the Flutter app (e.g. in config or environment).
- **Secret key** (`sk_test_...`) – Must **only** be used on your backend (e.g. Cloud Functions). Never put it in the app, in git, or in public files. If it was ever exposed, rotate it in Stripe Dashboard → Developers → API keys.
