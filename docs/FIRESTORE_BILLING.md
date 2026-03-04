# Firestore data model — Billing

## Path

`users/{uid}/billing/subscription`

One document per user. Create the `billing` subcollection under `users/{uid}` and use document id `subscription`.

## Document fields

| Field | Type | Description |
|-------|------|-------------|
| `plan` | string | `free` \| `pro` \| `team` |
| `status` | string | `active` \| `trialing` \| `canceled` \| `pastDue` |
| `currentPeriodEnd` | Timestamp | End of current billing period (optional) |
| `stripeCustomerId` | string | Set when Stripe is connected (optional) |
| `stripeSubscriptionId` | string | Set when Stripe is connected (optional) |

## Example (mock)

```json
{
  "plan": "pro",
  "status": "active",
  "currentPeriodEnd": "2025-04-02T00:00:00.000Z"
}
```

## Stripe later

- Keep this document shape. Stripe webhooks (e.g. `customer.subscription.updated`) should write `plan`, `status`, `currentPeriodEnd`, and Stripe IDs to this document.
- `BillingProvider.setBilling()` is used for the mock flow only. In production, only read from Firestore; writes come from your backend or Cloud Functions.

## Security rules (suggestion)

- Users can read their own `users/{uid}/billing/**`.
- Users must not write directly; only backend/Cloud Functions write billing docs.
