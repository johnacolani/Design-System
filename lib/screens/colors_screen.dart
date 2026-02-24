import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/design_system_provider.dart';

class ColorsScreen extends StatefulWidget {
  const ColorsScreen({super.key});

  @override
  State<ColorsScreen> createState() => _ColorsScreenState();
}

class _ColorsScreenState extends State<ColorsScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DesignSystemProvider>(context);
    final colors = provider.designSystem.colors;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Colors'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showAddColorDialog(context);
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildColorSection(
            context,
            'Primary Colors',
            colors.primary,
            Colors.deepPurple,
          ),
          const SizedBox(height: 24),
          _buildColorSection(
            context,
            'Semantic Colors',
            colors.semantic,
            Colors.blue,
          ),
          if (colors.blue != null) ...[
            const SizedBox(height: 24),
            _buildColorSection(
              context,
              'Blue Palette',
              colors.blue!,
              Colors.blue,
            ),
          ],
          if (colors.green != null) ...[
            const SizedBox(height: 24),
            _buildColorSection(
              context,
              'Green Palette',
              colors.green!,
              Colors.green,
            ),
          ],
          if (colors.red != null) ...[
            const SizedBox(height: 24),
            _buildColorSection(
              context,
              'Red Palette',
              colors.red!,
              Colors.red,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildColorSection(
    BuildContext context,
    String title,
    Map<String, dynamic> colorMap,
    Color accentColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 24,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (colorMap.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text(
                  'No colors yet. Tap + to add colors.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ),
            ),
          )
        else
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: colorMap.entries.map((entry) {
              return _buildColorCard(context, entry.key, entry.value);
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildColorCard(BuildContext context, String name, dynamic colorData) {
    Color color;
    String description = '';

    if (colorData is Map) {
      final value = colorData['value'] as String? ?? '#000000';
      color = _parseColor(value);
      description = colorData['description'] as String? ?? '';
    } else {
      color = Colors.grey;
    }

    return Card(
      child: InkWell(
        onTap: () {
          // TODO: Edit color
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                height: 80,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                name,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                _colorToHex(color),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                      fontFamily: 'monospace',
                    ),
              ),
              if (description.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _parseColor(String colorString) {
    try {
      if (colorString.startsWith('#')) {
        return Color(int.parse(colorString.substring(1), radix: 16) + 0xFF000000);
      } else if (colorString.startsWith('rgba')) {
        // Simple rgba parsing
        final matches = RegExp(r'rgba\((\d+),\s*(\d+),\s*(\d+),\s*([\d.]+)\)')
            .firstMatch(colorString);
        if (matches != null) {
          return Color.fromRGBO(
            int.parse(matches.group(1)!),
            int.parse(matches.group(2)!),
            int.parse(matches.group(3)!),
            double.parse(matches.group(4)!),
          );
        }
      }
    } catch (e) {
      // Invalid color
    }
    return Colors.grey;
  }

  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  void _showAddColorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Color'),
        content: const Text('Color picker dialog coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
