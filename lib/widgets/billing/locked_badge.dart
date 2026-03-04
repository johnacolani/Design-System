import 'package:flutter/material.dart';

/// Small badge for gated features: "Pro" or "Team" with lock icon. Tappable to show Upgrade modal.
class LockedBadge extends StatelessWidget {
  const LockedBadge({
    super.key,
    required this.requiredPlan,
    this.size = LockedBadgeSize.small,
    this.onTap,
  });

  final String requiredPlan;
  final LockedBadgeSize size;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSmall = size == LockedBadgeSize.small;

    final child = Material(
      color: theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(isSmall ? 12 : 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(isSmall ? 12 : 16),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isSmall ? 8 : 12,
            vertical: isSmall ? 4 : 6,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.lock_outline,
                size: isSmall ? 14 : 18,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              SizedBox(width: isSmall ? 4 : 6),
              Text(
                requiredPlan,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: isSmall ? 11 : 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return child;
  }
}

enum LockedBadgeSize { small, medium }
