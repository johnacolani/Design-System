import 'package:flutter/material.dart';

/// One plan in the pricing table. Responsive: stacks on mobile, row on desktop.
class PlanCard extends StatelessWidget {
  const PlanCard({
    super.key,
    required this.name,
    required this.price,
    this.pricePeriod = '/month',
    required this.description,
    required this.features,
    required this.ctaLabel,
    required this.onCtaPressed,
    this.highlighted = false,
    this.ctaStyle = PlanCardCtaStyle.primary,
  });

  final String name;
  final String price;
  final String pricePeriod;
  final String description;
  final List<String> features;
  final String ctaLabel;
  final VoidCallback onCtaPressed;
  final bool highlighted;
  final PlanCardCtaStyle ctaStyle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.sizeOf(context).width < 600;

    return Card(
      elevation: highlighted ? 8 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: highlighted
            ? BorderSide(color: theme.colorScheme.primary, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 20 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (highlighted)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Most popular',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            Text(
              name,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  price,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  pricePeriod,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            ...features.map((f) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 20,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          f,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                )),
            const Spacer(),
            const SizedBox(height: 16),
            switch (ctaStyle) {
              PlanCardCtaStyle.primary => FilledButton(
                  onPressed: onCtaPressed,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(ctaLabel),
                ),
              PlanCardCtaStyle.secondary => OutlinedButton(
                  onPressed: onCtaPressed,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(ctaLabel),
                ),
              PlanCardCtaStyle.text => TextButton(
                  onPressed: onCtaPressed,
                  child: Text(ctaLabel),
                ),
            },
          ],
        ),
      ),
    );
  }
}

enum PlanCardCtaStyle { primary, secondary, text }
