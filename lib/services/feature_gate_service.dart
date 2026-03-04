import '../models/billing.dart';

/// Checks user plan and enables/disables features. Use in UI to show locked
/// state and Upgrade modal. Plan comes from BillingProvider (Firestore users/{uid}/billing).
class FeatureGateService {
  const FeatureGateService();

  /// Export code (Flutter, React, Swift, Kotlin, CSS, Tokens). Pro+ only.
  bool canExport(SubscriptionPlan plan) =>
      plan == SubscriptionPlan.pro || plan == SubscriptionPlan.team;

  /// Theme builder advanced (e.g. custom theme presets, advanced tokens). Pro+ only.
  bool canUseThemeBuilderAdvanced(SubscriptionPlan plan) =>
      plan == SubscriptionPlan.pro || plan == SubscriptionPlan.team;

  /// Team collaboration + versioning. Team only.
  bool canUseTeamFeatures(SubscriptionPlan plan) => plan == SubscriptionPlan.team;

  /// Minimum plan required for export. Use for upgrade CTA.
  SubscriptionPlan get requiredPlanForExport => SubscriptionPlan.pro;

  SubscriptionPlan get requiredPlanForThemeBuilderAdvanced => SubscriptionPlan.pro;
  SubscriptionPlan get requiredPlanForTeam => SubscriptionPlan.team;
}
