# Design System Builder – TODO List

Mark items as done by changing `- [ ]` to `- [x]`.

**User-facing instructions:** See `USER_INSTRUCTIONS.md` for the full user guide and **Coming soon** sections.

---

## 1. Settings Screen (`lib/screens/settings_screen.dart`)

- [ ] **Email change** – Implement Firebase `updateEmail` with re-authentication flow (replace "coming soon" SnackBar).
- [ ] **Password change** – Implement Firebase password reset (e.g. `sendPasswordResetEmail`) or in-app change with re-auth.
- [ ] **Notifications** – Persist notification preference (e.g. SharedPreferences or Firestore) and wire the Switch `onChanged`.
- [ ] **Theme** – Implement light/dark/system theme switching; persist choice and apply via `ThemeMode` in `MaterialApp`.
- [ ] **Language** – Implement locale selection; persist and set `MaterialApp.locale` (and/or `localizationsDelegates`).
- [ ] **Privacy Policy** – Add URL and open in browser (e.g. `url_launcher`) or in-app WebView.
- [ ] **Terms of Service** – Same as Privacy Policy (URL + open in browser or in-app).
- [ ] **Help Center** – Add help URL or in-app help content and open/link to it.
- [ ] **Send Feedback** – Implement feedback (e.g. mailto, form, or backend endpoint).
- [ ] **Delete Account** – Implement Firebase `deleteUser`, clean up Firestore/Storage user data, then sign out (replace "coming soon" in dialog).

---

## 2. Export Screen – Web Support (`lib/screens/export_screen.dart`)

- [ ] **Save code export on web** – When `kIsWeb`, avoid `FilePicker.saveFile` and `File()`; use download helper to trigger browser download of exported code (e.g. `.dart`, `.json`, `.kt`, `.swift`, `.ts`, `.css`).
- [ ] **Download package on web** – When `kIsWeb`, for "Download package" use download helper with zip bytes from `PackageGeneratorService.buildPackage(ds)` (e.g. blob download with filename `*.zip`).

---

## 3. Billing & Upgrade (`lib/screens/upgrade_screen.dart`, `lib/providers/billing_provider.dart`)

- [x] **Stripe (or payment) integration** – Replace mock upgrade with real checkout (e.g. Stripe Checkout session or Payment Element). Implemented: Cloud Functions `createCheckoutSession` + app opens Stripe Checkout URL.
- [x] **Webhook handler** – Backend/webhook that receives Stripe events and writes to Firestore `users/{uid}/billing` (subscription created/updated/canceled). Implemented: `stripeWebhook` in `functions/index.js`.
- [x] **Stop mock billing from app** – In production, billing doc should be updated only by webhooks, not by app after "confirm upgrade". App now only calls backend and opens URL; webhook writes to Firestore.

---

## 4. Tutorials (`lib/screens/tutorials_screen.dart`)

- [ ] **Tutorial links** – Replace "link placeholder" with real URLs (e.g. docs, YouTube) using `url_launcher`, or add in-app tutorial content (e.g. markdown from `DocsService`).

---

## 5. Demo Gallery (`lib/screens/demo_gallery_screen.dart`)

- [ ] **Load demo projects** – Define demo design system JSON (e.g. Mobile UI kit, Admin dashboard, Landing page); on card tap load into `DesignSystemProvider` and navigate to dashboard or read-only preview.

---

## 6. Figma Token Sync (`lib/screens/export_screen.dart`)

- [ ] **Figma integration** – Implement Figma plugin/sync (import/export tokens, sync flow) or remove/relabel the "Figma Token Sync (coming soon)" section until ready.

---

## 7. Create New Project – Web (optional)

- [ ] **Optional: Save to computer on web** – On Create New Project (web), consider offering "Save to computer" (download `.ds.json`) using the same download helper as dashboard for consistency.

---

## 8. Preview Screen (optional)

- [ ] **Optional: Empty state copy** – Improve placeholder text (e.g. "Add colors in Colors screen") for empty sections in preview.

---

## 9. Auth & User

- [ ] **Google Sign-In client ID** – Ensure production `clientId` is set where needed (see commented line in `lib/providers/user_provider.dart` if applicable).
- [ ] **Re-auth flows** – Use re-authentication where required (e.g. before email change, password change, delete account) for sensitive actions.

---

## 10. General / Maintenance

- [ ] **Replace deprecated APIs** – Replace `Color.withOpacity` with `.withValues()` where linter reports deprecation (e.g. in `preview_screen.dart` and elsewhere).
- [ ] **Remove or fix unused code** – Address analyzer warnings (e.g. unused `_generatePdfSync`, `_generatePdf`, `subHeaderStyle`, `_colorEntries` in `preview_screen.dart` if no longer needed).
- [ ] **Use `BuildContext` safely** – Fix `use_build_context_synchronously` in async gaps (e.g. check `mounted` before using `context` after `await` in `preview_screen.dart`).

---

*Last updated: add date when you edit. Mark items done with `[x]` as you implement them.*
