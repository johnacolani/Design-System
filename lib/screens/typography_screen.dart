import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/design_system_provider.dart';

class TypographyScreen extends StatelessWidget {
  const TypographyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DesignSystemProvider>(context);
    final typography = provider.designSystem.typography;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Typography'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Add typography
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            context,
            'Font Family',
            [
              _buildInfoRow('Primary', typography.fontFamily.primary),
              _buildInfoRow('Fallback', typography.fontFamily.fallback),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            context,
            'Font Weights',
            typography.fontWeights.entries.map((entry) {
              return _buildInfoRow(
                entry.key,
                entry.value.toString(),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          _buildSection(
            context,
            'Font Sizes',
            typography.fontSizes.entries.map((entry) {
              final fontSize = entry.value;
              return _buildInfoRow(
                entry.key,
                '${fontSize.value} / ${fontSize.lineHeight}',
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          _buildSection(
            context,
            'Text Styles',
            typography.textStyles.entries.map((entry) {
              final style = entry.value;
              return ListTile(
                title: Text(entry.key),
                subtitle: Text(
                  '${style.fontSize} / ${style.fontWeight} / ${style.lineHeight}',
                ),
                trailing: Text(
                  'Sample',
                  style: TextStyle(
                    fontSize: _parseFontSize(style.fontSize),
                    fontWeight: FontWeight.values[style.fontWeight ~/ 100 - 1],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: TextStyle(color: Colors.grey[600], fontFamily: 'monospace'),
          ),
        ],
      ),
    );
  }

  double _parseFontSize(String fontSize) {
    try {
      return double.parse(fontSize.replaceAll('px', ''));
    } catch (e) {
      return 14.0;
    }
  }
}
