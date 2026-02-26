import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/design_system_provider.dart';
import '../models/design_system.dart' as models;
import '../utils/screen_body_padding.dart';

class SpacingScreen extends StatefulWidget {
  const SpacingScreen({super.key});

  @override
  State<SpacingScreen> createState() => _SpacingScreenState();
}

class _SpacingScreenState extends State<SpacingScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DesignSystemProvider>(context);
    final spacing = provider.designSystem.spacing;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Spacing'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showAddSpacingDialog(context);
            },
          ),
        ],
      ),
      body: ScreenBodyPadding(
        verticalPadding: 0,
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: [
          Text(
            'Spacing Scale',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Define spacing values for consistent layouts',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 24),
          if (spacing.values.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.space_bar_outlined, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No spacing values defined',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          _showAddSpacingDialog(context);
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add Spacing Value'),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            ...spacing.values.entries.map((entry) {
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Container(
                    width: 60,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        entry.key,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ),
                  title: Text(entry.value),
                  subtitle: Text('Scale index: ${spacing.scale.indexOf(int.tryParse(entry.value.replaceAll('px', '')) ?? 0)}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: _parseSpacing(entry.value),
                        height: 20,
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 8),
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') {
                            _showEditSpacingDialog(context, entry.key, entry.value);
                          } else if (value == 'delete') {
                            _deleteSpacing(context, entry.key);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(value: 'edit', child: Text('Edit')),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text('Delete', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
        ),
      ),
    );
  }

  double _parseSpacing(String spacing) {
    try {
      return double.parse(spacing.replaceAll('px', ''));
    } catch (e) {
      return 0;
    }
  }

  void _showAddSpacingDialog(BuildContext context) {
    final keyController = TextEditingController();
    final valueController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Spacing Value'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: keyController,
              decoration: const InputDecoration(
                labelText: 'Key (e.g., 1, 2, 3)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: valueController,
              decoration: const InputDecoration(
                labelText: 'Value (e.g., 4px, 8px)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (keyController.text.isNotEmpty && valueController.text.isNotEmpty) {
                final provider = Provider.of<DesignSystemProvider>(context, listen: false);
                final spacing = provider.designSystem.spacing;
                final updatedValues = Map<String, String>.from(spacing.values);
                updatedValues[keyController.text] = valueController.text;

                final updatedScale = List<int>.from(spacing.scale);
                final spacingValue = int.tryParse(valueController.text.replaceAll('px', '')) ?? 0;
                if (!updatedScale.contains(spacingValue)) {
                  updatedScale.add(spacingValue);
                  updatedScale.sort();
                }

                provider.updateSpacing(models.Spacing(
                  scale: updatedScale,
                  values: updatedValues,
                ));

                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Spacing "${keyController.text}" added!'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditSpacingDialog(BuildContext context, String key, String value) {
    final keyController = TextEditingController(text: key);
    final valueController = TextEditingController(text: value);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Spacing Value'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: keyController,
              decoration: const InputDecoration(
                labelText: 'Key',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: valueController,
              decoration: const InputDecoration(
                labelText: 'Value',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (keyController.text.isNotEmpty && valueController.text.isNotEmpty) {
                final provider = Provider.of<DesignSystemProvider>(context, listen: false);
                final spacing = provider.designSystem.spacing;
                final updatedValues = Map<String, String>.from(spacing.values);
                if (key != keyController.text) {
                  updatedValues.remove(key);
                }
                updatedValues[keyController.text] = valueController.text;

                final updatedScale = List<int>.from(spacing.scale);
                final spacingValue = int.tryParse(valueController.text.replaceAll('px', '')) ?? 0;
                if (!updatedScale.contains(spacingValue)) {
                  updatedScale.add(spacingValue);
                  updatedScale.sort();
                }

                provider.updateSpacing(models.Spacing(
                  scale: updatedScale,
                  values: updatedValues,
                ));

                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Spacing updated!'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _deleteSpacing(BuildContext context, String key) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Spacing Value'),
        content: Text('Are you sure you want to delete spacing "$key"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final provider = Provider.of<DesignSystemProvider>(context, listen: false);
              final spacing = provider.designSystem.spacing;
              final updatedValues = Map<String, String>.from(spacing.values);
              updatedValues.remove(key);

              provider.updateSpacing(models.Spacing(
                scale: spacing.scale,
                values: updatedValues,
              ));

              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Spacing "$key" deleted!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
