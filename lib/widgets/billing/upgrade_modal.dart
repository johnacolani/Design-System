import 'package:flutter/material.dart';

/// Modal shown when user hits a gated feature. Explains what's locked and CTA to upgrade.
class UpgradeModal extends StatelessWidget {
  const UpgradeModal({
    super.key,
    required this.featureName,
    required this.requiredPlan,
    this.description,
    required this.onUpgrade,
    this.onDismiss,
  });

  final String featureName;
  final String requiredPlan;
  final String? description;
  final VoidCallback onUpgrade;
  final VoidCallback? onDismiss;

  static Future<void> show(
    BuildContext context, {
    required String featureName,
    required String requiredPlan,
    String? description,
    required VoidCallback onUpgrade,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => UpgradeModal(
        featureName: featureName,
        requiredPlan: requiredPlan,
        description: description,
        onUpgrade: () {
          Navigator.of(ctx).pop();
          onUpgrade();
        },
        onDismiss: () => Navigator.of(ctx).pop(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.lock_outline, size: 32, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  featureName,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (onDismiss != null)
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: onDismiss,
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description ??
                '$featureName is available on the $requiredPlan plan. Upgrade to unlock.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: onUpgrade,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Upgrade'),
          ),
          if (onDismiss != null) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: onDismiss,
              child: const Text('Maybe later'),
            ),
          ],
        ],
      ),
    );
  }
}
