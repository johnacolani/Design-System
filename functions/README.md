# Stripe Cloud Functions

- **createCheckoutSession** (callable): Creates a Stripe Checkout Session and returns the URL. Requires auth.
- **stripeWebhook** (HTTP): Receives Stripe webhooks and updates Firestore `users/{uid}/billing/subscription`.

## Secrets (required)

Set these in Firebase / Google Cloud Secret Manager (see main project STRIPE_STEP_BY_STEP.md):

1. **STRIPE_SECRET_KEY** – Stripe secret key (sk_test_... or sk_live_...)
2. **STRIPE_WEBHOOK_SECRET** – Webhook signing secret (whsec_...) from Stripe Dashboard → Developers → Webhooks

## Deploy

```bash
cd functions
npm install
firebase deploy --only functions
```

After deploy, add the **stripeWebhook** function URL in Stripe Dashboard → Developers → Webhooks → Add endpoint. Use the URL for the `stripeWebhook` function (e.g. `https://REGION-PROJECT.cloudfunctions.net/stripeWebhook`).

## Optional config

- **STRIPE_PRICE_ID_PRO** / **STRIPE_PRICE_ID_TEAM** – Override default price IDs (e.g. via Firebase config or env).
