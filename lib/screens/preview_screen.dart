import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/design_system_provider.dart';
import '../models/design_system.dart' as models;

class PreviewScreen extends StatelessWidget {
  const PreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DesignSystemProvider>(context);
    final designSystem = provider.designSystem;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Design System Preview'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, 'Colors'),
            const SizedBox(height: 16),
            _buildColorPreview(context, designSystem),
            const SizedBox(height: 32),
            _buildSectionTitle(context, 'Typography'),
            const SizedBox(height: 16),
            _buildTypographyPreview(context, designSystem),
            const SizedBox(height: 32),
            _buildSectionTitle(context, 'Components'),
            const SizedBox(height: 16),
            _buildComponentsPreview(context, designSystem),
            const SizedBox(height: 32),
            _buildSectionTitle(context, 'Spacing'),
            const SizedBox(height: 16),
            _buildSpacingPreview(context, designSystem),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildColorPreview(BuildContext context, models.DesignSystem ds) {
    final colors = <String, dynamic>{};
    colors.addAll(ds.colors.primary);
    if (ds.colors.semantic.isNotEmpty) {
      colors.addAll(ds.colors.semantic);
    }

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: colors.entries.take(8).map((entry) {
        final colorValue = entry.value is Map
            ? (entry.value as Map)['value']?.toString() ?? '#000000'
            : entry.value.toString();
        return _buildColorSwatch(colorValue, entry.key);
      }).toList(),
    );
  }

  Widget _buildColorSwatch(String colorHex, String name) {
    Color? color = _parseColor(colorHex);
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color ?? Colors.grey,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          name,
          style: const TextStyle(fontSize: 12),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildTypographyPreview(BuildContext context, models.DesignSystem ds) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (ds.typography.textStyles.isNotEmpty)
          ...ds.typography.textStyles.entries.take(4).map((entry) {
            final style = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.key,
                    style: TextStyle(
                      fontFamily: style.fontFamily,
                      fontSize: _parseSize(style.fontSize),
                      fontWeight: FontWeight.values.firstWhere(
                        (w) => w.value == style.fontWeight,
                        orElse: () => FontWeight.normal,
                      ),
                      color: _parseColor(style.color ?? '#000000') ?? Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${style.fontFamily} • ${style.fontSize} • Weight ${style.fontWeight}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          })
        else
          Text(
            'The quick brown fox jumps over the lazy dog',
            style: TextStyle(
              fontFamily: ds.typography.fontFamily.primary,
              fontSize: 16,
            ),
          ),
      ],
    );
  }

  Widget _buildComponentsPreview(BuildContext context, models.DesignSystem ds) {
    return Column(
      children: [
        if (ds.components.buttons.isNotEmpty)
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: ds.components.buttons.entries.take(3).map((entry) {
              return ElevatedButton(
                onPressed: () {},
                child: Text(entry.key),
              );
            }).toList(),
          ),
        const SizedBox(height: 16),
        if (ds.components.cards.isNotEmpty)
          ...ds.components.cards.entries.take(2).map((entry) {
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text('${entry.key} Card'),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildSpacingPreview(BuildContext context, models.DesignSystem ds) {
    final spacingEntries = ds.spacing.values.entries.toList()
      ..sort((a, b) => _parseSize(a.value).compareTo(_parseSize(b.value)));

    return Column(
      children: spacingEntries.take(6).map((entry) {
        final size = _parseSize(entry.value);
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Container(
                width: size,
                height: 20,
                color: Colors.blue.withOpacity(0.3),
              ),
              const SizedBox(width: 12),
              Text(
                '${entry.key}: ${entry.value}',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Color? _parseColor(String colorString) {
    try {
      if (colorString.startsWith('#')) {
        return Color(int.parse(colorString.substring(1), radix: 16) + 0xFF000000);
      } else if (colorString.startsWith('rgb')) {
        // Simple RGB parsing
        return Colors.blue;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  double _parseSize(String size) {
    try {
      return double.parse(size.replaceAll('px', ''));
    } catch (e) {
      return 16.0;
    }
  }
}
