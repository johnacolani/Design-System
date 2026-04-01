import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/user_provider.dart';
import '../providers/billing_provider.dart';
import '../widgets/billing/plan_card.dart';
import '../widgets/billing/feature_row.dart';
import 'upgrade_screen.dart';
import 'auth_screen.dart';

const _kContactSalesEmail = 'johnacolani@gmail.com';

/// Pricing + Plans page (in-app and marketing). Free, Pro, Team with feature table and CTAs.
class PricingScreen extends StatelessWidget {
  const PricingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.sizeOf(context).width < 600;
    final userProvider = Provider.of<UserProvider>(context);
    final billingProvider = Provider.of<BillingProvider>(context);
    final isLoggedIn = userProvider.isLoggedIn;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pricing'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 16 : 48,
          vertical: 24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Simple pricing for every team',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Start free. Upgrade when you need export, advanced themes, or team features.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            // Plan cards
            isMobile
                ? Column(
                    children: [
                      PlanCard(
                        name: 'Free',
                        price: '\$0',
                        pricePeriod: '/month',
                        description: 'Get started with tokens and components.',
                        features: const [
                          'Unlimited design systems',
                          'Tokens & components',
                          'Preview & UI Lab',
                          '1 project',
                        ],
                        ctaLabel: 'Start Free',
                        ctaStyle: PlanCardCtaStyle.secondary,
                        onCtaPressed: () => _openDashboardOrAuth(context, userProvider),
                      ),
                      const SizedBox(height: 16),
                      PlanCard(
                        name: 'Pro',
                        price: '\$19',
                        pricePeriod: '/month',
                        description: 'Export code and advanced theme builder.',
                        highlighted: true,
                        features: const [
                          'Everything in Free',
                          'Export to Flutter, React, Swift, Kotlin, CSS',
                          'Theme builder advanced',
                          'Unlimited projects',
                        ],
                        ctaLabel: 'Upgrade to Pro',
                        onCtaPressed: () => _navigateUpgrade(context, 'pro'),
                      ),
                      const SizedBox(height: 16),
                      PlanCard(
                        name: 'Team',
                        price: 'Custom',
                        pricePeriod: '',
                        description: 'Collaboration and versioning for teams.',
                        features: const [
                          'Everything in Pro',
                          'Team collaboration',
                          'Version history & branching',
                          'Priority support',
                        ],
                        ctaLabel: 'Contact Sales',
                        ctaStyle: PlanCardCtaStyle.secondary,
                        onCtaPressed: () => _contactSales(context),
                      ),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: PlanCard(
                          name: 'Free',
                          price: '\$0',
                          pricePeriod: '/month',
                          description: 'Get started with tokens and components.',
                          features: const [
                            'Unlimited design systems',
                            'Tokens & components',
                            'Preview & UI Lab',
                            '1 project',
                          ],
                          ctaLabel: 'Start Free',
                          ctaStyle: PlanCardCtaStyle.secondary,
                          onCtaPressed: () => _openDashboardOrAuth(context, userProvider),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: PlanCard(
                          name: 'Pro',
                          price: '\$19',
                          pricePeriod: '/month',
                          description: 'Export code and advanced theme builder.',
                          highlighted: true,
                          features: const [
                            'Everything in Free',
                            'Export to Flutter, React, Swift, Kotlin, CSS',
                            'Theme builder advanced',
                            'Unlimited projects',
                          ],
                          ctaLabel: 'Upgrade to Pro',
                          onCtaPressed: () => _navigateUpgrade(context, 'pro'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: PlanCard(
                          name: 'Team',
                          price: 'Custom',
                          pricePeriod: '',
                          description: 'Collaboration and versioning for teams.',
                          features: const [
                            'Everything in Pro',
                            'Team collaboration',
                            'Version history & branching',
                            'Priority support',
                          ],
                          ctaLabel: 'Contact Sales',
                          ctaStyle: PlanCardCtaStyle.secondary,
                          onCtaPressed: () => _contactSales(context),
                        ),
                      ),
                    ],
                  ),
            const SizedBox(height: 48),
            Text(
              'Feature comparison',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            FeatureRow(
              label: 'Export code (Flutter, React, Swift, etc.)',
              freeValue: FeatureCellValue.locked,
              proValue: FeatureCellValue.yes,
              teamValue: FeatureCellValue.yes,
            ),
            FeatureRow(
              label: 'Theme builder advanced',
              freeValue: FeatureCellValue.locked,
              proValue: FeatureCellValue.yes,
              teamValue: FeatureCellValue.yes,
            ),
            FeatureRow(
              label: 'Team collaboration & versioning',
              freeValue: FeatureCellValue.no,
              proValue: FeatureCellValue.no,
              teamValue: FeatureCellValue.yes,
            ),
            FeatureRow(
              label: 'Unlimited projects',
              freeValue: FeatureCellValue.no,
              proValue: FeatureCellValue.yes,
              teamValue: FeatureCellValue.yes,
            ),
          ],
        ),
      ),
    );
  }

  void _openDashboardOrAuth(BuildContext context, UserProvider userProvider) {
    if (userProvider.isLoggedIn) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      // If you use a named home, pushReplacement to dashboard/projects
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const AuthScreen()),
      );
    }
  }

  void _navigateUpgrade(BuildContext context, String plan) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => UpgradeScreen(selectedPlan: plan),
      ),
    );
  }

  Future<void> _contactSales(BuildContext context) async {
    final subject = Uri.encodeComponent('Design System Builder — Team plan');
    final uri = Uri.parse('mailto:$_kContactSalesEmail?subject=$subject');
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Email us at $_kContactSalesEmail'),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open email app. Contact: $_kContactSalesEmail'),
            duration: const Duration(seconds: 5),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }
}
