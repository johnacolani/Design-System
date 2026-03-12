/// Stripe configuration. Publishable key is safe to use in the app.
/// Secret key must only be used on your backend (never here).
class StripeConfig {
  StripeConfig._();

  /// Stripe publishable key (test mode).
  /// For production, replace with your pk_live_... key or load from env.
  static const String publishableKey = 'pk_test_51PjS0TFQ76r4i2fngolFbQCteKf7AYlcZyVz2lyfGOmwtLhe22dVVBtb2lC9vOXeHZEo4VapBQBzqFdBStY4fuyl00hOyxKt6D';

  /// Set to true when using live keys and real payments.
  static const bool useLiveKey = false;

  /// Stripe Price IDs (from Product catalog → product → Pricing).
  /// Used by the backend to create Checkout sessions for each plan.
  static const String priceIdPro = 'price_1TAAF6FQ76r4i2fnsseTD6rS';
  static const String priceIdTeam = 'price_1TAAOoFQ76r4i2fnHHBni0l1';

  /// App base URL for redirects after Stripe Checkout.
  static const String appBaseUrl = 'https://my-flutter-apps-f87ea.web.app';

  /// Where Stripe sends the user after successful payment.
  static const String successUrl = 'https://my-flutter-apps-f87ea.web.app/?payment=success';

  /// Where Stripe sends the user if they cancel the payment.
  static const String cancelUrl = 'https://my-flutter-apps-f87ea.web.app/?payment=cancel';
}
