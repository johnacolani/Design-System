# Stripe Payments – Step-by-Step Guide (First Time)

This guide explains **what Stripe does**, **what you need to do**, and **what we will build** – in order, with no jargon.

---

## Part 1: What Happens When Someone Pays You

1. **User** clicks “Upgrade to Pro” (or Team) in your app.
2. **Your app** asks **your backend** (a small server): “Create a payment link for this user and this plan.”
3. **Your backend** talks to **Stripe** and gets a **checkout link** (Stripe’s payment page).
4. **Your app** opens that link in the browser. The user enters card details **on Stripe’s page** (you never see the card).
5. **User** pays. **Stripe** charges the card and then tells **your backend** “payment succeeded” (via a “webhook”).
6. **Your backend** updates **Firebase (Firestore)** so your app knows this user is now Pro or Team.
7. **Your app** already reads that data from Firestore, so the UI updates (e.g. “Pro” badge, unlocked features).

So: **You** need a small **backend** that creates the checkout link and listens to Stripe. The **app** only opens the link and reads from Firestore.

---

## Part 2: What You Already Have (Done)

| Item | What it is | Where it is |
|------|------------|-------------|
| **Stripe account** | Your Stripe dashboard (you log in at stripe.com) | You have this |
| **Publishable key** | A public key that says “payments go to this Stripe account” | In the app: `lib/config/stripe_config.dart` |
| **Pro Price ID** | Tells Stripe “charge the Pro plan price” | In the app config |
| **Team Price ID** | Tells Stripe “charge the Team plan price” | In the app config |
| **Secret key** | A secret key only your backend uses to talk to Stripe | You have it in Stripe Dashboard; we never put it in the app |

So: **Stripe side and app config are ready.** What’s left is: **backend** + **two URLs** + **app change** to open Stripe instead of the mock.

---

## Part 3: What You Need to Do (Your Tasks)

### Step A: Choose Your App’s Web Address

Your app is probably at something like:

- `https://my-flutter-apps-f87ea.web.app`  
  or  
- `https://your-project.web.app`

You need to decide the **exact** address (the one people use to open your app in the browser). We’ll use it for “Success” and “Cancel” URLs.

---

### Step B: Give Me Two URLs

When the user finishes paying (or cancels), Stripe sends them back to **your app**. We need two URLs:

1. **Success URL**  
   - When payment **succeeds**, the user is sent here.  
   - Example: `https://my-flutter-apps-f87ea.web.app/?payment=success`  
   - Use **your** real app address and add `?payment=success` (or any path you prefer).

2. **Cancel URL**  
   - When the user **cancels** or closes the payment page, they are sent here.  
   - Example: `https://my-flutter-apps-f87ea.web.app/?payment=cancel`  
   - Same base address, with `?payment=cancel` (or similar).

**What you do:** Send me these two URLs in a message, e.g.:

- Success: `https://my-flutter-apps-f87ea.web.app/?payment=success`  
- Cancel: `https://my-flutter-apps-f87ea.web.app/?payment=cancel`

(Replace with your real app URL if different.)

---

### Step C: Backend (Where the Secret Key Lives)

The **backend** is a small program that runs on a server (not inside your Flutter app). It will:

1. **Create checkout**  
   - Your app calls it and says: “This user (Firebase UID) wants Pro (or Team).”  
   - It uses your **Stripe secret key** to ask Stripe for a checkout link.  
   - It returns that link to the app. The app then opens the link in the browser.

2. **Handle webhooks**  
   - Stripe sends “payment succeeded” (or “subscription canceled”, etc.) to a **webhook URL** on your backend.  
   - The backend checks that the request really comes from Stripe, then updates **Firestore** (e.g. `users/{uid}/billing/subscription`) so your app shows Pro/Team.

**Where to run the backend:** The easiest for you is **Firebase Cloud Functions** (same project as your app, runs on Google’s servers). We can write two functions:

- One that **creates a Stripe Checkout Session** and returns the URL.
- One that **receives Stripe webhooks** and updates Firestore.

**What you need to do:**

1. **Keep your Secret Key safe**  
   - You already have it from Stripe (Developers → API keys → Secret key).  
   - We will **never** put it in the Flutter app or in GitHub.  
   - We will only put it in the **backend’s environment** (e.g. Firebase Functions config).

2. **When we add the Cloud Functions**, you will:  
   - Install Firebase CLI and log in (if not already).  
   - Run one or two commands to put the **Stripe secret key** and (later) the **webhook secret** into the function’s config.  
   - Deploy the functions. Then we’ll add the webhook URL in Stripe (Step D).

You don’t need to write code for this; I can give you the exact function code and the exact commands. You only need to run them and add the secrets.

---

### Step D: Webhook in Stripe (After Backend Is Deployed)

After the backend is deployed, it will have a **URL** for the webhook (e.g. `https://us-central1-YOUR_PROJECT.cloudfunctions.net/stripeWebhook`).

**What you do (in Stripe Dashboard):**

1. Go to **Developers** → **Webhooks**.
2. Click **Add endpoint**.
3. **Endpoint URL:** paste the webhook URL we give you.
4. **Events to send:** select at least:
   - `checkout.session.completed`
   - `customer.subscription.updated`
   - `customer.subscription.deleted`
5. Save. Stripe will show a **Signing secret** (starts with `whsec_...`).
6. Put that **signing secret** in your backend config (same place as the Stripe secret key). We’ll tell you the exact command.

That’s it. After that, Stripe will call your backend when someone pays or cancels, and your backend will update Firestore.

---

## Part 4: What We Will Build (App + Backend)

### In the app (Flutter)

- When the user taps “Upgrade” and picks Pro or Team, the app will:
  1. Call your **backend** (e.g. Firebase callable function) with: user id, plan (Pro/Team), Success URL, Cancel URL.
  2. Receive the **Stripe Checkout URL** from the backend.
  3. Open that URL in the browser (or in-app browser). The user pays on Stripe’s page.
  4. When they come back to your app (via Success or Cancel URL), we can show “Thank you” or “Payment canceled.”  
- We will **remove** the current “mock” upgrade that writes directly to Firestore. After this, only the **webhook** will write to Firestore when Stripe says “payment done.”

### On the backend (e.g. Cloud Functions)

- **Function 1 – Create Checkout**  
  - Input: user id, plan (Pro/Team), success URL, cancel URL.  
  - Uses Stripe SDK + **secret key** to create a Checkout Session with the right **Price ID** (Pro or Team).  
  - Returns the session’s URL to the app.

- **Function 2 – Webhook**  
  - Receives POST requests from Stripe.  
  - Verifies the request with the **webhook signing secret**.  
  - On `checkout.session.completed` (and optionally subscription updated/deleted), updates Firestore `users/{uid}/billing/subscription` (plan, status, period end, etc.).  
  - Your app already reads this document, so the UI will update automatically.

---

## Part 5: Order of Steps (Summary)

Do them in this order:

1. **You:** Send me the **Success URL** and **Cancel URL** (Step B).
2. **We:** Add the **backend** (Cloud Functions: create checkout + webhook) and tell you where to put the **secret key** and (later) **webhook secret**.
3. **You:** Deploy the functions and add the **Stripe secret key** (and webhook secret after Step 4) into the function config.
4. **We:** Add the **webhook URL** in Stripe (Step D) and give you the **Signing secret** to put in the backend.
5. **We:** Change the **UpgradeScreen** in the app to call the backend and open the Stripe Checkout URL.
6. **You:** Test with a Stripe test card (e.g. `4242 4242 4242 4242`) in **test mode**.

---

## Part 6: Quick Reference

| Who | What |
|-----|------|
| **You** | Send Success URL and Cancel URL. |
| **You** | Keep Secret Key and Webhook Secret only in backend config; never in the app or Git. |
| **You** | Deploy the backend and add secrets when we give you the commands. |
| **You** | In Stripe: add webhook endpoint and copy Signing secret into backend config. |
| **We** | Write the two Cloud Functions (create checkout + webhook). |
| **We** | Update the app to call the backend and open Stripe Checkout. |
| **Stripe** | Shows the payment page, charges the card, and notifies your backend. |
| **Firestore** | Stores who is Pro/Team; the app only reads from here. |

---

## What You Do Right Now

1. Decide your app’s full web address (e.g. `https://my-flutter-apps-f87ea.web.app`).
2. Send me **two URLs** in one message:
   - **Success:** `https://YOUR_APP_URL/?payment=success`
   - **Cancel:** `https://YOUR_APP_URL/?payment=cancel`

Once I have those, the next step is to add the backend (Cloud Functions) and the app changes, and give you the exact commands to set the secret key and deploy.

---

## Part 7: Deploy the backend (implemented)

Backend and app are implemented. To go live:

1. **Set secrets** (Firebase uses Google Secret Manager for these):
   - In [Google Cloud Console](https://console.cloud.google.com) → your project → **Security** → **Secret Manager**, create two secrets:
     - `STRIPE_SECRET_KEY` – value = your Stripe secret key (sk_test_... or sk_live_...).
     - `STRIPE_WEBHOOK_SECRET` – leave empty for now; add after Step 3.
   - Grant the default Cloud Functions service account access to these secrets (or use Firebase’s recommended approach: `firebase functions:secrets:set STRIPE_SECRET_KEY` etc. if available in your CLI).

2. **Deploy functions:**
   ```bash
   cd functions
   npm install
   firebase deploy --only functions
   ```
   Note the URL of **stripeWebhook** (e.g. `https://us-central1-YOUR_PROJECT.cloudfunctions.net/stripeWebhook`).

3. **Add webhook in Stripe:** Developers → Webhooks → Add endpoint. URL = the `stripeWebhook` URL. Events: `checkout.session.completed`, `customer.subscription.updated`, `customer.subscription.deleted`. Copy the **Signing secret** (whsec_...).

4. **Set webhook secret:** In Secret Manager, set `STRIPE_WEBHOOK_SECRET` to that signing secret (or create the secret if you skipped it). Redeploy the `stripeWebhook` function so it picks up the new secret: `firebase deploy --only functions:stripeWebhook`.

5. **Test:** In the app, sign in, open Upgrade, choose Pro, tap “Continue to payment”. Use Stripe test card `4242 4242 4242 4242`. After payment, you should be redirected to your app and Firestore `users/{uid}/billing/subscription` should show the plan.

See also **functions/README.md** for a short reference.
