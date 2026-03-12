# What We Need to Implement Stripe Payments (and Where to Find It)

Use this checklist. For each item, get the value from Stripe and either share it here or store it in the right place (e.g. backend env for secret keys).

---

## 1. Publishable key (for the Flutter app)

**What it’s for:** Used in the app to identify your Stripe account. Safe to ship in the app.

**Where to find it:**
1. Log in to [Stripe Dashboard](https://dashboard.stripe.com)
2. Click **Developers** (top right)
3. Click **API keys**
4. Under **Standard keys**, copy the **Publishable key** (starts with `pk_test_` in test mode or `pk_live_` in live mode)

**You can share:** The publishable key (e.g. paste it here so we can wire it into the app).

---

## 2. Secret key (for the backend only – never in the app)

**What it’s for:** Used only on your server/Cloud Function to create Checkout sessions and verify webhooks. Must never be in the Flutter app or in git.

**Where to find it:**
1. **Developers** → **API keys**
2. Under **Standard keys**, click **Reveal** next to **Secret key**
3. Copy the key (starts with `sk_test_` or `sk_live_`)

**You should:** Keep it in backend environment variables (e.g. Firebase Functions config). Do **not** paste it in chat or commit it. If you’re not building the backend yet, you can store it somewhere safe and we’ll use it when we set up the backend.

---

## 3. Products and Price IDs (for Pro and Team plans)

**What it’s for:** The backend uses these to create a Checkout session for “Pro” or “Team” when the user clicks upgrade.

**Where to find / create them:**
1. In Stripe Dashboard go to **Product catalog** → **Products**
2. Click **+ Add product**
3. For **Pro** (example):
   - Name: e.g. `Pro`
   - Description: (optional, or use the app description from STRIPE_APP_DESCRIPTION.md)
   - Pricing: **Standard pricing** → **Recurring** → Monthly (or your interval) → set price (e.g. $19)
   - Save and copy the **Price ID** (e.g. `price_1ABC...` – you see it in the product’s list of prices)
4. Repeat for **Team** (or create a “Contact sales” product and get its Price ID if you use that flow)

**You can share:** The two **Price IDs** (e.g. `price_xxxx` for Pro and `price_yyyy` for Team) so we can wire them into the backend and/or app.

---

## 4. Webhook signing secret (for the backend)

**What it’s for:** The backend uses this to verify that webhook events really come from Stripe (security).

**Where to find it (after you have a backend URL):**
1. **Developers** → **Webhooks**
2. Click **Add endpoint**
3. **Endpoint URL:** your backend URL (e.g. `https://us-central1-YOUR_PROJECT.cloudfunctions.net/stripeWebhook`)
4. **Events to send:** select at least:
   - `checkout.session.completed`
   - `customer.subscription.updated`
   - `customer.subscription.deleted`
5. **Add endpoint**
6. On the new endpoint, click **Reveal** under **Signing secret** and copy it (starts with `whsec_`)

**You should:** Put this only in your backend config (e.g. Firebase config). Do not put it in the app or in git.

**Note:** You can add the endpoint later when the backend is deployed. We need this before going live so the app’s billing stays in sync with Stripe.

---

## 5. Success and cancel URLs (your app URLs)

**What it’s for:** After payment, Stripe redirects the user back to your app. We need the exact URLs.

**Where to get them:**
- Your app’s base URL (e.g. `https://my-flutter-apps-f87ea.web.app` or your custom domain)
- **Success URL:** e.g. `https://my-flutter-apps-f87ea.web.app/?payment=success`  
  (We can use query params so the app shows “Thank you” or refreshes billing.)
- **Cancel URL:** e.g. `https://my-flutter-apps-f87ea.web.app/?payment=cancel`

**You can share:** The two URLs you want (success and cancel) so we use them when creating Checkout sessions.

---

## Summary – what to give so we can implement

| # | What we need              | Where in Stripe (or app)        | Safe to paste here? |
|---|---------------------------|----------------------------------|----------------------|
| 1 | Publishable key           | Developers → API keys            | Yes                  |
| 2 | Secret key                | Developers → API keys            | No – backend only    |
| 3 | Pro Price ID              | Product catalog → Products → Pro price | Yes          |
| 4 | Team Price ID             | Product catalog → Products → Team price | Yes          |
| 5 | Webhook signing secret    | Developers → Webhooks (after endpoint is added) | No – backend only |
| 6 | Success URL               | Your app URL + e.g. `?payment=success` | Yes            |
| 7 | Cancel URL                | Your app URL + e.g. `?payment=cancel`  | Yes            |

**To implement payment we need at least:**
- **From you now:** Publishable key, Pro Price ID, Team Price ID (if you use it), Success URL, Cancel URL.
- **Backend (you or we build):** Secret key and webhook signing secret stored only in the backend; backend creates Checkout sessions and handles webhooks.

Once you have the **Publishable key**, **Price IDs**, and **Success/Cancel URLs**, share those and we can wire the app to open Stripe Checkout. The backend (e.g. one Cloud Function to create a session + one for the webhook) can be set up next, using the secret key and webhook secret in its config.
