import 'package:flutter/material.dart';

/// One row in a feature comparison table: feature name + values per plan (check / dash / lock).
class FeatureRow extends StatelessWidget {
  const FeatureRow({
    super.key,
    required this.label,
    required this.freeValue,
    required this.proValue,
    required this.teamValue,
  });

  final String label;
  final FeatureCellValue freeValue;
  final FeatureCellValue proValue;
  final FeatureCellValue teamValue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.sizeOf(context).width < 600;

    if (isMobile) {
      return Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _cell(theme, 'Free', freeValue),
                  _cell(theme, 'Pro', proValue),
                  _cell(theme, 'Team', teamValue),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(1),
        2: FlexColumnWidth(1),
        3: FlexColumnWidth(1),
      },
      children: [
        TableRow(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            _tableCell(theme, freeValue),
            _tableCell(theme, proValue),
            _tableCell(theme, teamValue),
          ],
        ),
      ],
    );
  }

  Widget _cell(ThemeData theme, String planLabel, FeatureCellValue value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(planLabel, style: theme.textTheme.labelSmall),
        const SizedBox(height: 4),
        _iconFor(theme, value),
      ],
    );
  }

  Widget _tableCell(ThemeData theme, FeatureCellValue value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Center(child: _iconFor(theme, value)),
    );
  }

  Widget _iconFor(ThemeData theme, FeatureCellValue value) {
    switch (value) {
      case FeatureCellValue.yes:
        return Icon(Icons.check_circle, color: theme.colorScheme.primary, size: 24);
      case FeatureCellValue.no:
        return Icon(Icons.remove, color: theme.colorScheme.outline, size: 24);
      case FeatureCellValue.locked:
        return Icon(Icons.lock_outline, color: theme.colorScheme.outline, size: 24);
    }
  }
}

enum FeatureCellValue { yes, no, locked }
