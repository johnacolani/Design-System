/**
 * Cloud Functions for Stripe: create Checkout Session (callable) and webhook (HTTP).
 *
 * Required secrets (set in Firebase / Google Cloud):
 *   STRIPE_SECRET_KEY       - Stripe secret key (sk_test_... or sk_live_...)
 *   STRIPE_WEBHOOK_SECRET   - Webhook signing secret (whsec_...)
 *
 * Optional config (or set in code): STRIPE_PRICE_ID_PRO, STRIPE_PRICE_ID_TEAM
 * If not set, defaults match lib/config/stripe_config.dart.
 */

const functions = require("firebase-functions");
const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { onRequest } = require("firebase-functions/v2/https");
const { defineString, defineSecret } = require("firebase-functions/params");
const admin = require("firebase-admin");
const Stripe = require("stripe");
const express = require("express");

const stripeSecretKey = defineSecret("STRIPE_SECRET_KEY");
const stripeWebhookSecret = defineSecret("STRIPE_WEBHOOK_SECRET");
const priceIdPro = defineString("STRIPE_PRICE_ID_PRO", {
  default: "price_1TAAF6FQ76r4i2fnsseTD6rS",
});
const priceIdTeam = defineString("STRIPE_PRICE_ID_TEAM", {
  default: "price_1TAAOoFQ76r4i2fnHHBni0l1",
});

if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

/**
 * Callable: createCheckoutSession
 * Body: { plan: 'pro' | 'team', successUrl?: string, cancelUrl?: string }
 * Returns: { url: string } (Stripe Checkout URL)
 */
exports.createCheckoutSession = onCall(
  {
    secrets: [stripeSecretKey],
  },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Sign in to upgrade.");
    }
    const uid = request.auth.uid;
    if (String(uid).startsWith("guest_")) {
      throw new HttpsError("invalid-argument", "Guest users cannot upgrade.");
    }

    const plan = request.data?.plan;
    if (plan !== "pro" && plan !== "team") {
      throw new HttpsError("invalid-argument", "plan must be 'pro' or 'team'.");
    }

    const successUrl =
      request.data?.successUrl ||
      "https://my-flutter-apps-f87ea.web.app/?payment=success";
    const cancelUrl =
      request.data?.cancelUrl ||
      "https://my-flutter-apps-f87ea.web.app/?payment=cancel";

    const stripe = new Stripe(stripeSecretKey.value(), { apiVersion: "2024-11-20.acacia" });
    const priceId = plan === "team" ? priceIdTeam.value() : priceIdPro.value();

    const session = await stripe.checkout.sessions.create({
      mode: "subscription",
      line_items: [{ price: priceId, quantity: 1 }],
      success_url: successUrl,
      cancel_url: cancelUrl,
      client_reference_id: uid,
      subscription_data: {
        metadata: { plan, firebase_uid: uid },
      },
    });

    return { url: session.url };
  }
);

/**
 * HTTP: Stripe webhook. Verify signature and on checkout.session.completed
 * update Firestore users/{uid}/billing/subscription.
 */
const webhookApp = express();
webhookApp.post(
  "/",
  express.raw({ type: "application/json" }),
  async (req, res) => {
    const sig = req.headers["stripe-signature"];
    if (!sig) {
      res.status(400).send("Missing stripe-signature");
      return;
    }
    let event;
    try {
      const payload = req.body;
      const payloadString = Buffer.isBuffer(payload) ? payload.toString("utf8") : payload;
      event = Stripe.webhooks.constructEvent(
        payloadString,
        sig,
        stripeWebhookSecret.value()
      );
    } catch (err) {
      console.warn("Webhook signature verification failed:", err.message);
      res.status(400).send(`Webhook Error: ${err.message}`);
      return;
    }

    if (event.type === "checkout.session.completed") {
      const session = event.data.object;
      const uid = session.client_reference_id || session.subscription_data?.metadata?.firebase_uid;
      if (!uid) {
        console.warn("checkout.session.completed: no client_reference_id");
        res.status(200).send("ok");
        return;
      }
      const plan =
        session.subscription_data?.metadata?.plan ||
        session.metadata?.plan ||
        "pro";
      const subscriptionId = session.subscription;
      const customerId = session.customer;

      const stripe = new Stripe(stripeSecretKey.value(), { apiVersion: "2024-11-20.acacia" });
      let currentPeriodEnd = null;
      if (subscriptionId) {
        try {
          const sub = await stripe.subscriptions.retrieve(subscriptionId);
          currentPeriodEnd = sub.current_period_end
            ? new Date(sub.current_period_end * 1000)
            : null;
        } catch (e) {
          console.warn("Could not retrieve subscription:", e.message);
        }
      }

      const subscriptionRef = db.doc(`users/${uid}/billing/subscription`);
      await subscriptionRef.set({
        plan: plan,
        status: "active",
        currentPeriodEnd: currentPeriodEnd
          ? admin.firestore.Timestamp.fromDate(currentPeriodEnd)
          : null,
        stripeCustomerId: customerId || null,
        stripeSubscriptionId: subscriptionId || null,
      });
    } else if (
      event.type === "customer.subscription.updated" ||
      event.type === "customer.subscription.deleted"
    ) {
      const subscription = event.data.object;
      const subscriptionId = subscription.id;
      const snapshot = await db
        .collectionGroup("billing")
        .where("stripeSubscriptionId", "==", subscriptionId)
        .limit(1)
        .get();
      if (!snapshot.empty) {
        const doc = snapshot.docs[0];
        const status =
          subscription.status === "active" || subscription.status === "trialing"
            ? "active"
            : subscription.status === "past_due"
              ? "pastDue"
              : "canceled";
        const currentPeriodEnd = subscription.current_period_end
          ? admin.firestore.Timestamp.fromDate(
              new Date(subscription.current_period_end * 1000)
            )
          : null;
        await doc.ref.update({
          status,
          currentPeriodEnd,
        });
      }
    }

    res.status(200).send("ok");
  }
);

exports.stripeWebhook = onRequest(
  {
    secrets: [stripeWebhookSecret, stripeSecretKey],
  },
  webhookApp
);
