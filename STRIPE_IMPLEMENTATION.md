# Stripe Payment Implementation – What You Need

To add real Stripe payments to the Design System Builder, here’s what is required from you and what will be implemented in the app.

---

## What You Need to Provide

### 1. **Stripe account**
- Sign up at [stripe.com](https://stripe.com) and complete account setup.
- Get your **API keys** from the [Stripe Dashboard](https://dashboard.stripe.com/apikeys):
  - **Publishable key** (e.g. `pk_test_...` or `pk_live_...`) – safe to use in the Flutter app.
  - **Secret key** (e.g. `sk_test_...` or `sk_live_...`) – must **only** be used on a backend, never in the app.

### 2. **Products and prices in Stripe**
- In [Stripe Dashboard → Products](https://dashboard.stripe.com/products), create:
  - **Pro plan** – e.g. recurring monthly price (e.g. $19/month).
  - **Team plan** – e.g. recurring monthly or “Contact sales” (custom price).
- Copy each **Price ID** (e.g. `price_xxxxx`) – the backend will use these when creating Checkout sessions.

### 3. **Backend (server or serverless)**
Stripe requires a **backend** to:
- Create a **Stripe Customer** (optional but recommended; link to your user ID).
- Create a **Checkout Session** (or Payment Link) with the chosen price and success/cancel URLs.
- Expose a simple API that the Flutter app calls to get the Checkout URL (or Payment Link URL).
- Handle **Stripe webhooks** and, when a subscription is paid/renewed/canceled, update **Firestore** `users/{uid}/billing/subscription` (same document shape your app already uses).

You can use:
- **Firebase Cloud Functions** (Node.js) – fits well with your existing Firebase/Firestore setup, or
- Any other backend (Node, Python, etc.) that can call Stripe and write to Firestore.

**What the backend must do:**
- **Endpoint 1 (e.g. `createCheckoutSession`):**  
  Input: `userId` (Firebase UID), `planId` (e.g. `pro` or `team`), `successUrl`, `cancelUrl`.  
  Output: `{ "url": "https://checkout.stripe.com/..." }` (or `sessionId` if you use Stripe.js).
- **Webhook endpoint:**  
  Receive `checkout.session.completed`, `customer.subscription.updated`, `customer.subscription.deleted`, and optionally `invoice.paid`.  
  For each event, update Firestore `users/{uid}/billing/subscription` with:
  - `plan` (e.g. `pro` / `team` / `free`),
  - `status` (e.g. `active` / `canceled`),
  - `currentPeriodEnd`,
  - `stripeCustomerId`,
  - `stripeSubscriptionId`.

Your app already reads this document via `BillingProvider` and `BillingInfo`, so no change to the document shape is required.

### 4. **Webhook signing secret**
- In [Stripe Dashboard → Webhooks](https://dashboard.stripe.com/webhooks), add an endpoint pointing to your backend (e.g. `https://your-cloud-function-url/.../stripeWebhook`).
- Select events: `checkout.session.completed`, `customer.subscription.updated`, `customer.subscription.deleted` (and optionally `invoice.paid`).
- Copy the **Webhook signing secret** (e.g. `whsec_...`) and store it in your backend environment (e.g. Firebase config or env vars). The backend will use this to verify that events really come from Stripe.

### 5. **URLs for success and cancel**
- **Success URL:** e.g. `https://your-app-domain.web.app/upgrade?success=true` (or a dedicated “thank you” page).
- **Cancel URL:** e.g. `https://your-app-domain.web.app/upgrade?canceled=true`.

Your Flutter web app can detect these query params and show a message or close a popup.

---

## What Will Be Implemented in the App

Once the above is in place, the app side will:

1. **Call your backend** (e.g. Firebase callable function or REST endpoint) with:
   - `userId` (current Firebase UID),
   - `plan` (`pro` or `team`),
   - `successUrl` and `cancelUrl` (e.g. current site + query params).
2. **Open the URL** returned by the backend (Stripe Checkout or Payment Link) in:
   - **Web:** same tab or new window; then detect success/cancel via URL or a simple “return” page.
   - **Mobile/desktop:** open in-app browser (e.g. `url_launcher` or WebView) and, after redirect back, close and refresh billing.
3. **Stop writing billing directly** from the app after “Confirm upgrade” – the app will only open Stripe; **webhooks** will be the single source of truth for writing to Firestore.
4. **Keep using** `BillingProvider` and `watchBilling(userId)` so the UI updates when the webhook updates Firestore (no app change needed for that part).

---

## Summary Checklist

| Item | Who | Notes |
|------|-----|--------|
| Stripe account + API keys | You | Publishable key for app; secret only on backend |
| Products & prices in Stripe | You | Pro + Team; get Price IDs |
| Backend (e.g. Cloud Functions) | You (or we implement) | Create Checkout Session; handle webhooks; update Firestore |
| Webhook endpoint + signing secret | You | Configure in Stripe Dashboard; store secret in backend |
| Success/cancel URLs | You | Your app domain + query params |
| App: call backend + open Stripe URL | Implementation | Replace mock in `UpgradeScreen`; no direct billing write |

---

## Next Step

Once you have:
- **Publishable key** (for the app),
- **Backend URL** (or Firebase function name) that creates a Checkout Session and returns the URL,
- **Price IDs** for Pro and Team (if the backend needs them from the client),

the Flutter app can be updated to call that backend and open Stripe Checkout instead of the mock upgrade. If you want, the next step can be a concrete code change plan (e.g. new `StripeService` + changes in `UpgradeScreen` and where you pass the publishable key).
