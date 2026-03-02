import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/design_system_provider.dart';
import '../models/design_system.dart' as models;
import '../utils/screen_body_padding.dart';

class GradientsScreen extends StatefulWidget {
  const GradientsScreen({super.key});

  @override
  State<GradientsScreen> createState() => _GradientsScreenState();
}

class _GradientsScreenState extends State<GradientsScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DesignSystemProvider>(context);
    final gradients = provider.designSystem.gradients;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gradients'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showAddGradientDialog(context);
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
            'Gradient Definitions',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Define gradient color transitions for backgrounds and effects',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 24),
          if (gradients.values.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.gradient, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No gradients defined',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          _showAddGradientDialog(context);
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add Gradient'),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            ...gradients.values.entries.map((entry) {
              return _buildGradientCard(context, entry.key, entry.value);
            }),
        ],
        ),
      ),
    );
  }

  Widget _buildGradientCard(
    BuildContext context,
    String name,
    models.GradientValue gradient,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showEditGradientDialog(context, name, gradient);
                    } else if (value == 'delete') {
                      _deleteGradient(context, name);
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
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: _getGradientBegin(gradient.direction),
                  end: _getGradientEnd(gradient.direction),
                  colors: gradient.colors.map((c) => _parseColor(c)).toList(),
                  stops: gradient.stops.map((s) => s / 100).toList(),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Type: ${gradient.type}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            Text(
              'Direction: ${gradient.direction}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            Text(
              'Colors: ${gradient.colors.join(', ')}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                    fontFamily: 'monospace',
                  ),
            ),
          ],
        ),
      ),
    );
  }

  AlignmentGeometry _getGradientBegin(String direction) {
    switch (direction.toLowerCase()) {
      case 'to right':
        return Alignment.centerLeft;
      case 'to bottom':
        return Alignment.topCenter;
      case 'to bottom right':
        return Alignment.topLeft;
      default:
        return Alignment.centerLeft;
    }
  }

  AlignmentGeometry _getGradientEnd(String direction) {
    switch (direction.toLowerCase()) {
      case 'to right':
        return Alignment.centerRight;
      case 'to bottom':
        return Alignment.bottomCenter;
      case 'to bottom right':
        return Alignment.bottomRight;
      default:
        return Alignment.centerRight;
    }
  }

  Color _parseColor(String colorString) {
    try {
      if (colorString.startsWith('#')) {
        return Color(int.parse(colorString.substring(1), radix: 16) + 0xFF000000);
      } else if (colorString.startsWith('rgb')) {
        // Simple RGB parsing - in production, use a proper parser
        return Colors.blue;
      }
      return Colors.blue;
    } catch (e) {
      return Colors.blue;
    }
  }

  void _showAddGradientDialog(BuildContext context) {
    String selectedType = 'linear';
    String selectedDirection = 'to right';
    final nameController = TextEditingController();
    final color1Controller = TextEditingController(text: '#3B82F6');
    final color2Controller = TextEditingController(text: '#8B5CF6');
    final stop1Controller = TextEditingController(text: '0');
    final stop2Controller = TextEditingController(text: '100');

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Gradient'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Gradient Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Type:'),
                RadioListTile<String>(
                  title: const Text('Linear'),
                  value: 'linear',
                  groupValue: selectedType,
                  onChanged: (value) {
                    setDialogState(() {
                      selectedType = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                const Text('Direction:'),
                DropdownButtonFormField<String>(
                  initialValue: selectedDirection,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'to right', child: Text('To Right')),
                    DropdownMenuItem(value: 'to bottom', child: Text('To Bottom')),
                    DropdownMenuItem(value: 'to bottom right', child: Text('To Bottom Right')),
                  ],
                  onChanged: (value) {
                    setDialogState(() {
                      selectedDirection = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: color1Controller,
                  decoration: const InputDecoration(
                    labelText: 'Color 1 (e.g., #3B82F6)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: stop1Controller,
                  decoration: const InputDecoration(
                    labelText: 'Stop 1 (0-100)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: color2Controller,
                  decoration: const InputDecoration(
                    labelText: 'Color 2 (e.g., #8B5CF6)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: stop2Controller,
                  decoration: const InputDecoration(
                    labelText: 'Stop 2 (0-100)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty &&
                    color1Controller.text.isNotEmpty &&
                    color2Controller.text.isNotEmpty) {
                  final provider = Provider.of<DesignSystemProvider>(context, listen: false);
                  final gradients = provider.designSystem.gradients;
                  final updatedGradients = Map<String, models.GradientValue>.from(gradients.values);

                  updatedGradients[nameController.text] = models.GradientValue(
                    type: selectedType,
                    direction: selectedDirection,
                    colors: [color1Controller.text, color2Controller.text],
                    stops: [
                      int.tryParse(stop1Controller.text) ?? 0,
                      int.tryParse(stop2Controller.text) ?? 100,
                    ],
                  );

                  provider.updateDesignSystem(models.DesignSystem(
                    name: provider.designSystem.name,
                    version: provider.designSystem.version,
                    description: provider.designSystem.description,
                    created: provider.designSystem.created,
                    colors: provider.designSystem.colors,
                    typography: provider.designSystem.typography,
                    spacing: provider.designSystem.spacing,
                    borderRadius: provider.designSystem.borderRadius,
                    shadows: provider.designSystem.shadows,
                    effects: provider.designSystem.effects,
                    components: provider.designSystem.components,
                    grid: provider.designSystem.grid,
                    icons: provider.designSystem.icons,
                    gradients: models.Gradients(values: updatedGradients),
                    roles: provider.designSystem.roles,
                    semanticTokens: provider.designSystem.semanticTokens,
                    motionTokens: provider.designSystem.motionTokens,
                    lastModified: provider.designSystem.lastModified,
                    versionHistory: provider.designSystem.versionHistory,
                  ));

                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gradient "${nameController.text}" added!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditGradientDialog(
    BuildContext context,
    String name,
    models.GradientValue gradient,
  ) {
    String selectedType = gradient.type;
    String selectedDirection = gradient.direction;
    final nameController = TextEditingController(text: name);
    final color1Controller = TextEditingController(text: gradient.colors[0]);
    final color2Controller = TextEditingController(
      text: gradient.colors.length > 1 ? gradient.colors[1] : '',
    );
    final stop1Controller = TextEditingController(text: gradient.stops[0].toString());
    final stop2Controller = TextEditingController(
      text: gradient.stops.length > 1 ? gradient.stops[1].toString() : '100',
    );

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Gradient'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Gradient Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Type:'),
                RadioListTile<String>(
                  title: const Text('Linear'),
                  value: 'linear',
                  groupValue: selectedType,
                  onChanged: (value) {
                    setDialogState(() {
                      selectedType = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                const Text('Direction:'),
                DropdownButtonFormField<String>(
                  initialValue: selectedDirection,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'to right', child: Text('To Right')),
                    DropdownMenuItem(value: 'to bottom', child: Text('To Bottom')),
                    DropdownMenuItem(value: 'to bottom right', child: Text('To Bottom Right')),
                  ],
                  onChanged: (value) {
                    setDialogState(() {
                      selectedDirection = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: color1Controller,
                  decoration: const InputDecoration(
                    labelText: 'Color 1',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: stop1Controller,
                  decoration: const InputDecoration(
                    labelText: 'Stop 1',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: color2Controller,
                  decoration: const InputDecoration(
                    labelText: 'Color 2',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: stop2Controller,
                  decoration: const InputDecoration(
                    labelText: 'Stop 2',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty &&
                    color1Controller.text.isNotEmpty &&
                    color2Controller.text.isNotEmpty) {
                  final provider = Provider.of<DesignSystemProvider>(context, listen: false);
                  final gradients = provider.designSystem.gradients;
                  final updatedGradients = Map<String, models.GradientValue>.from(gradients.values);
                  if (name != nameController.text) {
                    updatedGradients.remove(name);
                  }
                  updatedGradients[nameController.text] = models.GradientValue(
                    type: selectedType,
                    direction: selectedDirection,
                    colors: [color1Controller.text, color2Controller.text],
                    stops: [
                      int.tryParse(stop1Controller.text) ?? 0,
                      int.tryParse(stop2Controller.text) ?? 100,
                    ],
                  );

                  provider.updateDesignSystem(models.DesignSystem(
                    name: provider.designSystem.name,
                    version: provider.designSystem.version,
                    description: provider.designSystem.description,
                    created: provider.designSystem.created,
                    colors: provider.designSystem.colors,
                    typography: provider.designSystem.typography,
                    spacing: provider.designSystem.spacing,
                    borderRadius: provider.designSystem.borderRadius,
                    shadows: provider.designSystem.shadows,
                    effects: provider.designSystem.effects,
                    components: provider.designSystem.components,
                    grid: provider.designSystem.grid,
                    icons: provider.designSystem.icons,
                    gradients: models.Gradients(values: updatedGradients),
                    roles: provider.designSystem.roles,
                    semanticTokens: provider.designSystem.semanticTokens,
                    motionTokens: provider.designSystem.motionTokens,
                    lastModified: provider.designSystem.lastModified,
                    versionHistory: provider.designSystem.versionHistory,
                  ));

                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Gradient updated!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteGradient(BuildContext context, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Gradient'),
        content: Text('Are you sure you want to delete gradient "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final provider = Provider.of<DesignSystemProvider>(context, listen: false);
              final gradients = provider.designSystem.gradients;
              final updatedGradients = Map<String, models.GradientValue>.from(gradients.values);
              updatedGradients.remove(name);

              provider.updateDesignSystem(models.DesignSystem(
                name: provider.designSystem.name,
                version: provider.designSystem.version,
                description: provider.designSystem.description,
                created: provider.designSystem.created,
                colors: provider.designSystem.colors,
                typography: provider.designSystem.typography,
                spacing: provider.designSystem.spacing,
                borderRadius: provider.designSystem.borderRadius,
                shadows: provider.designSystem.shadows,
                effects: provider.designSystem.effects,
                components: provider.designSystem.components,
                grid: provider.designSystem.grid,
                icons: provider.designSystem.icons,
                gradients: models.Gradients(values: updatedGradients),
                roles: provider.designSystem.roles,
                semanticTokens: provider.designSystem.semanticTokens,
                motionTokens: provider.designSystem.motionTokens,
                lastModified: provider.designSystem.lastModified,
                versionHistory: provider.designSystem.versionHistory,
              ));

              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Gradient "$name" deleted!'),
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
