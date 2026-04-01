import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/stripe_config.dart';
import '../providers/user_provider.dart';
import '../providers/billing_provider.dart';

/// Maps [FirebaseFunctionsException] to text users understand (avoids bare "internal").
String _messageForPaymentError(Object error) {
  if (error is FirebaseFunctionsException) {
    final code = error.code;
    final msg = (error.message ?? '').trim();
    if (code == 'internal' || msg.toLowerCase() == 'internal') {
      return 'Payment could not start. This often means Stripe is not set up in Firebase '
          '(API key, price IDs) or the service was temporarily unavailable. '
          'Try again later or contact support if it keeps happening.';
    }
    if (msg.isNotEmpty) {
      return msg;
    }
    return 'Could not start checkout (code: $code). Please try again.';
  }
  return 'Could not reach the payment service. Check your connection and try again.';
}

/// Upgrade flow: select plan, then redirect to Stripe Checkout.
/// After payment, Stripe webhook updates Firestore; BillingProvider reflects it.
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

    try {
      final callable = FirebaseFunctions.instance.httpsCallable('createCheckoutSession');
      final result = await callable.call<Map<Object?, Object?>>({
        'plan': _plan,
        'successUrl': StripeConfig.successUrl,
        'cancelUrl': StripeConfig.cancelUrl,
      });

      final url = result.data['url'] as String?;
      if (url == null || url.isEmpty) {
        if (mounted) {
          setState(() {
            _loading = false;
            _message = 'No checkout URL returned. Try again.';
          });
        }
        return;
      }

      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (context.mounted) {
          setState(() => _loading = false);
          billingProvider.loadBilling(uid);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Complete payment in the browser. We\'ll update your plan when it\'s done.'),
            ),
          );
          Navigator.of(context).pop();
        }
      } else {
        if (mounted) {
          setState(() {
            _loading = false;
            _message = 'Could not open payment page.';
          });
        }
      }
    } on FirebaseFunctionsException catch (e, st) {
      debugPrint('createCheckoutSession: ${e.code} ${e.message} ${e.details}');
      debugPrint('$st');
      if (mounted) {
        setState(() {
          _loading = false;
          _message = _messageForPaymentError(e);
        });
      }
    } catch (e, st) {
      debugPrint('createCheckoutSession: $e');
      debugPrint('$st');
      if (mounted) {
        setState(() {
          _loading = false;
          _message = _messageForPaymentError(e);
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
              'You\'ll be taken to Stripe to pay securely. Your plan updates automatically after payment.',
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
                  color: theme.colorScheme.error,
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
                  : const Text('Continue to payment'),
            ),
          ],
        ),
      ),
    );
  }
}
