# Session final report – Design System Builder

Summary of what was implemented and how key flows work.

---

## 1. How users can subscribe to a plan

**You were never asked to choose a plan because the app does not require it on first use.** Subscription is optional and available in these places:

| Where | How |
|-------|-----|
| **Pricing page** | **Home** → overflow menu (⋮) → **Pricing**. Shows Free, Pro ($19/mo), Team. **Upgrade to Pro** opens the Upgrade screen, then Stripe Checkout in the browser. |
| **“Upgrade to Pro” banner** | On **Home**, a purple banner appears for non‑Pro users. **Upgrade Now** was updated to open the **Upgrade** screen (Pro) and then Stripe Checkout (no longer a mock local upgrade). |
| **Gated features** | Tapping **Export**, **Theme builder advanced**, or **Version history** when on Free shows a lock/upgrade prompt; choosing upgrade opens the Upgrade flow and Stripe. |

**Flow:** App → **UpgradeScreen** → Firebase `createCheckoutSession` → **Stripe Checkout** (browser) → payment → Stripe webhook updates Firestore → **BillingProvider** updates → Pro/Team features unlock.

Details are in **`HOW_TO_SUBSCRIBE.md`**.

---

## 2. Export: Download package & Save (web fix)

- **Issue:** On **web**, **Download package** and **Save** (for non‑JSON exports) used `FilePicker` + `dart:io` `File`, which are not supported in the browser.
- **Change:**  
  - **Web:** Use **`downloadFile`** (text) and **`downloadBytes`** (zip) so the browser triggers a download.  
  - **Desktop/mobile:** Keep **FilePicker** + platform save helpers in **`export_file_platform_io.dart`**.  
  - **`export_screen.dart`** no longer imports `dart:io`; it branches on **`kIsWeb`** and uses the right path.
- **Result:** Download package and Save work on web; existing behavior preserved on Windows/macOS/Linux.

---

## 3. Design Library – where added items go

- **Material colors (full palettes):** Stored in the design system **Colors** (primary or blue/green/red/etc.). Visible in **Theme Builder → Colors**.
- **Material/Cupertino components:** Previously only showed a snackbar. **Now:** Adding e.g. “Buttons” or “Cards” **creates real component entries** in **Components** (buttons, cards, inputs, navigation, alerts). They appear in **Components** and **Preview**.
- **Material/Cupertino typography:** Previously only snackbar. **Now:** Adding a style **adds it to Typography** (e.g. `material_display_large`, `cupertino_large_title`). Visible in **Typography** and **Preview**.
- **Material/Cupertino icons:** Adding an icon can **add it to Project icons** (Design Library → Icons → “Add to project”). Project icons are listed in **Icons** and **Preview**.

---

## 4. Icons: project icons + preview

- **Icons** screen has a **“Project icons”** section: list which icons the product uses (e.g. nav, actions).
- **Add project icon** opens a searchable Material icon grid; user gives a label (e.g. “Tab — Home”). Entries are stored in **`designSystem.icons.projectIcons`**.
- **Preview** shows these under **Components & Assets → Project icons**.
- **Export/PDF** include project icon names and code points.
- **Design Library → Material Icons:** “Add to project” adds the icon to project icons (same data).

---

## 5. Multi‑platform (iOS / Android / Web)

- **Create project:** User chooses **“Which platform(s)?”**: iOS only, Android only, Web only, or **All (iOS + Android + Web)**.
- **Single platform:** One set of tokens; no selector.
- **All platforms:** One project, one save file, with **platform overrides** per platform. **Dashboard** shows a **platform selector** (iOS | Android | Web). All token screens (Colors, Typography, Components, etc.) show and edit the **selected platform’s** tokens; updates are stored in **`platformOverrides[platform]`**.
- **Model:** **`DesignSystem`** has **`targetPlatforms`** and **`platformOverrides: Map<String, PlatformOverride>`**. **`effectiveDesignSystem`** = base merged with override for **`currentPlatform`**. Save/load include `targetPlatforms` and `platformOverrides`.

---

## 6. Files touched (high level)

| Area | Files |
|------|--------|
| Export web fix | `export_screen.dart`, `export_file_platform*.dart`, `download_helper*.dart` |
| Design Library components | `design_library_components.dart`, `material_picker_screen.dart`, `cupertino_picker_screen.dart` |
| Design Library typography | `material_picker_screen.dart`, `cupertino_picker_screen.dart` |
| Project icons | `design_system.dart` (ProjectIconEntry, Icons.projectIcons), `icons_screen.dart`, `project_icon_picker_page.dart`, `material_icons_catalog.dart`, `preview_screen.dart`, `design_system_wrapper.dart`, export/PDF |
| Multi‑platform | `design_system.dart` (PlatformOverride, targetPlatforms), `design_system_wrapper.dart`, `design_system_provider.dart`, `create_new_project_screen.dart`, `dashboard_screen.dart` |
| Subscription | `home_screen.dart` (banner opens Upgrade screen), **`HOW_TO_SUBSCRIBE.md`** |

---

## 7. What you can do next

1. **Subscribe to a plan:** Use **Pricing** (menu → Pricing) or the Home **“Upgrade to Pro”** banner → complete checkout in Stripe.
2. **Make plan choice more visible (optional):** Add an onboarding step after sign-up or first project that routes to **PricingScreen** or **UpgradeScreen** so users are explicitly asked to choose a plan.
3. **Verify Stripe:** Ensure Firebase Cloud Function **`createCheckoutSession`** and Stripe webhook are set up so Firestore billing is updated and **BillingProvider** reflects the correct plan.

---

*Report generated for the Design System Builder session.*
