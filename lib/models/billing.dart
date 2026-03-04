import 'package:cloud_firestore/cloud_firestore.dart';

/// Subscription plan. Stored in Firestore as users/{uid}/billing.plan.
enum SubscriptionPlan {
  free,
  pro,
  team,
}

extension SubscriptionPlanExtension on SubscriptionPlan {
  String get displayName {
    switch (this) {
      case SubscriptionPlan.free:
        return 'Free';
      case SubscriptionPlan.pro:
        return 'Pro';
      case SubscriptionPlan.team:
        return 'Team';
    }
  }

  String get firestoreValue => name;
}

/// Subscription status. Stored as users/{uid}/billing.status.
enum SubscriptionStatus {
  active,
  trialing,
  canceled,
  pastDue,
}

extension SubscriptionStatusExtension on SubscriptionStatus {
  String get firestoreValue => name;
}

/// Billing snapshot from Firestore. Path: users/{uid}/billing.
/// Swap Stripe later by keeping this shape and writing from webhooks.
class BillingInfo {
  const BillingInfo({
    required this.plan,
    required this.status,
    this.currentPeriodEnd,
    this.stripeCustomerId,
    this.stripeSubscriptionId,
  });

  final SubscriptionPlan plan;
  final SubscriptionStatus status;
  final DateTime? currentPeriodEnd;
  final String? stripeCustomerId;
  final String? stripeSubscriptionId;

  bool get isActive =>
      status == SubscriptionStatus.active || status == SubscriptionStatus.trialing;

  static BillingInfo free() => BillingInfo(
        plan: SubscriptionPlan.free,
        status: SubscriptionStatus.active,
      );

  static BillingInfo fromFirestore(Map<String, dynamic>? data) {
    if (data == null) return free();
    final planStr = data['plan'] as String? ?? 'free';
    final statusStr = data['status'] as String? ?? 'active';
    return BillingInfo(
      plan: SubscriptionPlan.values.firstWhere(
        (p) => p.name == planStr,
        orElse: () => SubscriptionPlan.free,
      ),
      status: SubscriptionStatus.values.firstWhere(
        (s) => s.name == statusStr,
        orElse: () => SubscriptionStatus.active,
      ),
      currentPeriodEnd: data['currentPeriodEnd'] is Timestamp
          ? (data['currentPeriodEnd'] as Timestamp).toDate()
          : null,
      stripeCustomerId: data['stripeCustomerId'] as String?,
      stripeSubscriptionId: data['stripeSubscriptionId'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'plan': plan.firestoreValue,
        'status': status.firestoreValue,
        if (currentPeriodEnd != null) 'currentPeriodEnd': Timestamp.fromDate(currentPeriodEnd!),
        if (stripeCustomerId != null) 'stripeCustomerId': stripeCustomerId,
        if (stripeSubscriptionId != null) 'stripeSubscriptionId': stripeSubscriptionId,
      };
}
