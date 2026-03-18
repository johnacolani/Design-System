import 'dart:math' as math;

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
                  begin: _linearGradientAlignments(gradient.direction).$1,
                  end: _linearGradientAlignments(gradient.direction).$2,
                  colors: gradient.colors.map((c) => _parseColor(c)).toList(),
                  stops: _normalizedStops(gradient),
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

  /// CSS-style angle: 0° = up, 90° = right (same as linear-gradient in CSS).
  (Alignment, Alignment) _linearGradientAlignments(String direction) {
    final d = direction.trim().toLowerCase();
    final degMatch = RegExp(r'^(\d+(?:\.\d+)?)deg$').firstMatch(d);
    if (degMatch != null) {
      final deg = double.tryParse(degMatch.group(1)!);
      if (deg != null) {
        final rad = deg * math.pi / 180;
        final dx = math.sin(rad);
        final dy = -math.cos(rad);
        return (Alignment(-dx, -dy), Alignment(dx, dy));
      }
    }
    switch (d) {
      case 'to right':
        return (Alignment.centerLeft, Alignment.centerRight);
      case 'to bottom':
        return (Alignment.topCenter, Alignment.bottomCenter);
      case 'to bottom right':
        return (Alignment.topLeft, Alignment.bottomRight);
      default:
        return (Alignment.topLeft, Alignment.bottomRight);
    }
  }

  List<double>? _normalizedStops(models.GradientValue g) {
    if (g.colors.length < 2) return null;
    if (g.stops.length != g.colors.length) return null;
    return g.stops.map((s) => (s / 100).clamp(0.0, 1.0)).toList();
  }

  static const List<String> _directionPresets = [
    'to right',
    'to bottom',
    'to bottom right',
    '0deg',
    '45deg',
    '90deg',
    '135deg',
    '180deg',
    '225deg',
    '270deg',
    '315deg',
  ];

  static String _directionMenuLabel(String v) {
    switch (v) {
      case 'to right':
        return 'To right';
      case 'to bottom':
        return 'To bottom';
      case 'to bottom right':
        return 'To bottom right';
      default:
        return v;
    }
  }

  /// Ensures [current] appears exactly once so DropdownButtonFormField does not assert.
  List<DropdownMenuItem<String>> _directionDropdownItems(String current) {
    final ordered = <String>[];
    final seen = <String>{};
    for (final p in _directionPresets) {
      if (seen.add(p)) ordered.add(p);
    }
    final c = current.trim();
    if (c.isNotEmpty && !seen.contains(c)) {
      ordered.add(c);
    }
    return ordered
        .map(
          (v) => DropdownMenuItem<String>(
            value: v,
            child: Text(_directionMenuLabel(v)),
          ),
        )
        .toList();
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
                Builder(
                  builder: (ctx) {
                    final dirVal =
                        selectedDirection.trim().isEmpty ? 'to right' : selectedDirection.trim();
                    return DropdownButtonFormField<String>(
                      value: dirVal,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      items: _directionDropdownItems(dirVal),
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() {
                            selectedDirection = value;
                          });
                        }
                      },
                    );
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
                Builder(
                  builder: (ctx) {
                    final dirVal =
                        selectedDirection.trim().isEmpty ? 'to right' : selectedDirection.trim();
                    return DropdownButtonFormField<String>(
                      value: dirVal,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      items: _directionDropdownItems(dirVal),
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() {
                            selectedDirection = value;
                          });
                        }
                      },
                    );
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
