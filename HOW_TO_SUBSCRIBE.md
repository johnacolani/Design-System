# How users can subscribe to a plan

The app does **not** force a plan choice during onboarding. Users can subscribe when they want to unlock Pro or Team features.

---

## Ways to choose or change a plan

### 1. **Pricing page (main path)**

- **From Home:** Open the **overflow menu** (⋮) in the top bar → **Pricing**.
- **When not logged in:** Use the **Pricing** button in the header.
- On the Pricing screen users see **Free**, **Pro** ($19/mo), and **Team** (Custom).  
  Tapping **Upgrade to Pro** opens the **Upgrade** screen → Stripe Checkout in the browser.

### 2. **“Upgrade to Pro” banner (Home)**

- On the **Home** screen, a purple “Upgrade to Pro” banner is shown for non‑Pro users.
- Tapping **Upgrade Now** opens the **Upgrade** screen (Pro plan) and then Stripe Checkout.

### 3. **Gated features**

- When a user tries a **Pro** or **Team** feature (e.g. **Export** code, **Theme builder advanced**, **Version history**), they see a lock badge or upgrade prompt.
- Choosing **Upgrade** opens the **Upgrade** screen (or Pricing) so they can pick a plan and pay via Stripe.

---

## What happens when they subscribe

1. User goes to **Pricing** or **Upgrade** and taps **Upgrade to Pro** (or similar).
2. App calls Firebase Cloud Function **`createCheckoutSession`** with plan and return URLs.
3. User is sent to **Stripe Checkout** in the browser to pay.
4. After payment, a **Stripe webhook** updates **Firestore** (`users/{uid}/billing/subscription`).
5. **BillingProvider** listens to that document; the app then shows Pro/Team features.

---

## Why it can feel like “never asked to choose a plan”

- There is **no required plan selection** on first launch or after sign-up.
- Plan choice is **optional** and available from:
  - **Pricing** (menu or header), and  
  - **Upgrade** (from banner or gated feature).
- If you want users to be **explicitly asked** to choose a plan, you can add a step in onboarding (e.g. after sign-up or after first project) that routes them to **PricingScreen** or **UpgradeScreen**.

---

## Summary

| Action                    | Where                         | Result                          |
|---------------------------|-------------------------------|---------------------------------|
| Open Pricing              | Menu → Pricing / Header       | See Free, Pro, Team; upgrade    |
| Upgrade from banner       | Home “Upgrade to Pro” → **Upgrade Now** | Upgrade screen → Stripe Checkout |
| Hit locked feature        | Export / Theme builder / etc. | Upgrade modal → Upgrade screen  |

Real subscription is always through **Stripe Checkout**; plan state is stored in **Firestore** and read by **BillingProvider**.
