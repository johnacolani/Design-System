import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/billing.dart';
import '../providers/user_provider.dart';
import '../providers/billing_provider.dart';
import '../widgets/billing/plan_card.dart';

/// Upgrade flow: select plan and confirm. Placeholder for Stripe; writes mock
/// subscription to Firestore users/{uid}/billing/subscription for now.
class UpgradeScreen extends StatefulWidget {
  const UpgradeScreen({super.key, this.selectedPlan = 'pro'});

  final String selectedPlan;

  @override
  State<UpgradeScreen> createState() => _UpgradeScreenState();
}

class _UpgradeScreenState extends State<UpgradeScreen> {
  String _plan = 'pro';
  bool _loading = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    _plan = widget.selectedPlan;
  }

  Future<void> _confirmUpgrade(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final billingProvider = Provider.of<BillingProvider>(context, listen: false);
    final uid = userProvider.currentUser?.id;

    if (uid == null || uid.startsWith('guest_')) {
      setState(() {
        _message = 'Please sign in to upgrade.';
      });
      return;
    }

    setState(() {
      _loading = true;
      _message = null;
    });

    // Placeholder: in production, redirect to Stripe Checkout and let webhooks
    // write to Firestore. Here we write mock billing directly.
    await Future.delayed(const Duration(milliseconds: 800));

    final plan = _plan == 'team'
        ? SubscriptionPlan.team
        : _plan == 'pro'
            ? SubscriptionPlan.pro
            : SubscriptionPlan.free;
    final end = DateTime.now().add(const Duration(days: 30));

    final info = BillingInfo(
      plan: plan,
      status: SubscriptionStatus.active,
      currentPeriodEnd: end,
      stripeCustomerId: null,
      stripeSubscriptionId: null,
    );

    try {
      await billingProvider.setBilling(uid, info);
      if (context.mounted) {
        setState(() {
          _loading = false;
          _message = 'You\'re now on ${plan.displayName}.';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Welcome to ${plan.displayName}!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _message = 'Something went wrong. Try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userProvider = Provider.of<UserProvider>(context);
    final isLoggedIn = userProvider.isLoggedIn;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Upgrade'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Choose your plan',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Stripe integration coming soon. This is a mock upgrade for testing.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            ...['pro', 'team'].map((plan) {
              final isSelected = _plan == plan;
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(plan == 'pro' ? 'Pro — \$19/month' : 'Team — Contact sales'),
                  subtitle: Text(
                    plan == 'pro'
                        ? 'Export code, theme builder advanced'
                        : 'Everything in Pro + team collaboration',
                  ),
                  trailing: Radio<String>(
                    value: plan,
                    groupValue: _plan,
                    onChanged: (v) => setState(() => _plan = v ?? 'pro'),
                  ),
                  selected: isSelected,
                  onTap: () => setState(() => _plan = plan),
                ),
              );
            }),
            if (!isLoggedIn)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  'Sign in to upgrade.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
            if (_message != null) ...[
              const SizedBox(height: 16),
              Text(
                _message!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: _message!.startsWith('You') ? Colors.green : theme.colorScheme.error,
                ),
              ),
            ],
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _loading || !isLoggedIn
                  ? null
                  : () => _confirmUpgrade(context),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Confirm upgrade'),
            ),
          ],
        ),
      ),
    );
  }
}
