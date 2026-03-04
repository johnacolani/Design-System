import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../providers/billing_provider.dart';
import '../services/feature_gate_service.dart';
import '../utils/screen_body_padding.dart';
import '../widgets/billing/locked_badge.dart';
import '../widgets/billing/upgrade_modal.dart';
import 'material_picker_screen.dart';
import 'cupertino_picker_screen.dart';
import 'upgrade_screen.dart';

class DesignLibraryScreen extends StatelessWidget {
  const DesignLibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Design Library'),
      ),
      body: ScreenBodyPadding(
        verticalPadding: 24,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
          Text(
            'Choose Design System',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Browse components, colors, icons, and typography from popular design systems',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 32),
          _buildDesignSystemCard(
            context,
            title: 'Material Design',
            description: 'Google\'s Material Design 3 components, colors, icons, and typography',
            icon: Icons.auto_awesome,
            color: Colors.blue,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const MaterialPickerScreen()),
              );
            },
          ),
          const SizedBox(height: 16),
          _buildDesignSystemCard(
            context,
            title: 'Cupertino (iOS)',
            description: 'Apple\'s Human Interface Guidelines components, colors, icons, and typography',
            icon: CupertinoIcons.device_phone_portrait,
            color: Colors.grey,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CupertinoPickerScreen()),
              );
            },
          ),
          const SizedBox(height: 16),
          _buildThemeBuilderAdvancedCard(context),
        ],
        ),
      ),
    );
  }

  Widget _buildThemeBuilderAdvancedCard(BuildContext context) {
    final billingProvider = Provider.of<BillingProvider>(context);
    final gate = const FeatureGateService();
    final canUse = gate.canUseThemeBuilderAdvanced(billingProvider.plan);

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: canUse
            ? null
            : () {
                UpgradeModal.show(
                  context,
                  featureName: 'Theme builder advanced',
                  requiredPlan: 'Pro',
                  description: 'Custom theme presets and advanced tokens are available on the Pro plan.',
                  onUpgrade: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const UpgradeScreen(selectedPlan: 'pro')),
                    );
                  },
                );
              },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.palette, size: 40, color: Colors.purple),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Theme builder advanced',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        if (!canUse) ...[
                          const SizedBox(width: 8),
                          LockedBadge(requiredPlan: 'Pro'),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Custom theme presets, advanced tokens, and export-ready themes',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesignSystemCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 40, color: color),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}
