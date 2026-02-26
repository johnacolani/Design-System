import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../providers/design_system_provider.dart';
import '../models/design_system.dart' as models;
import '../utils/screen_body_padding.dart';
import 'color_picker_screen.dart';

class ShadowsScreen extends StatefulWidget {
  const ShadowsScreen({super.key});

  @override
  State<ShadowsScreen> createState() => _ShadowsScreenState();
}

class _ShadowsScreenState extends State<ShadowsScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DesignSystemProvider>(context);
    final shadows = provider.designSystem.shadows;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shadows'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showAddShadowDialog(context);
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
            'Shadow Definitions',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Define shadow values for elevation and depth',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 24),
          if (shadows.values.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.auto_awesome_outlined, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No shadows defined',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          _showAddShadowDialog(context);
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add Shadow'),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            ...shadows.values.entries.map((entry) {
              return _buildShadowCard(context, entry.key, entry.value);
            }),
        ],
        ),
      ),
    );
  }

  Widget _buildShadowCard(
    BuildContext context,
    String name,
    models.ShadowValue shadow,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 4,
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
                      _showEditShadowDialog(context, name, shadow);
                    } else if (value == 'delete') {
                      _deleteShadow(context, name);
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
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [_parseShadow(shadow.value)],
                  ),
                  child: const Icon(Icons.auto_awesome, size: 32, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              shadow.value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                    fontFamily: 'monospace',
                  ),
            ),
            if (shadow.description != null && shadow.description!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                shadow.description!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showAddShadowDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    
    // Shadow parameters with defaults
    double offsetX = 0.0;
    double offsetY = 2.0;
    double blurRadius = 4.0;
    double spreadRadius = 0.0;
    Color shadowColor = Colors.black;
    double opacity = 0.1;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          final shadowValue = _buildShadowValue(offsetX, offsetY, blurRadius, spreadRadius, shadowColor, opacity);
          
          return AlertDialog(
            title: const Text('Add Shadow'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name (e.g., sm, md, lg)',
                      border: OutlineInputBorder(),
                      hintText: 'Enter shadow name',
                    ),
                    autofocus: true,
                  ),
                  const SizedBox(height: 24),
                  
                  // Preview
                  Container(
                    width: double.infinity,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Center(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              offset: Offset(offsetX, offsetY),
                              blurRadius: blurRadius,
                              spreadRadius: spreadRadius,
                              color: shadowColor.withOpacity(opacity),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.auto_awesome, size: 32, color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // X Offset
                  Text('X Offset: ${offsetX.toStringAsFixed(1)}px', 
                    style: const TextStyle(fontWeight: FontWeight.w500)),
                  Slider(
                    value: offsetX,
                    min: -20.0,
                    max: 20.0,
                    divisions: 80,
                    label: '${offsetX.toStringAsFixed(1)}px',
                    onChanged: (value) {
                      setDialogState(() => offsetX = value);
                    },
                  ),
                  
                  // Y Offset
                  Text('Y Offset: ${offsetY.toStringAsFixed(1)}px', 
                    style: const TextStyle(fontWeight: FontWeight.w500)),
                  Slider(
                    value: offsetY,
                    min: -20.0,
                    max: 20.0,
                    divisions: 80,
                    label: '${offsetY.toStringAsFixed(1)}px',
                    onChanged: (value) {
                      setDialogState(() => offsetY = value);
                    },
                  ),
                  
                  // Blur Radius
                  Text('Blur Radius: ${blurRadius.toStringAsFixed(1)}px', 
                    style: const TextStyle(fontWeight: FontWeight.w500)),
                  Slider(
                    value: blurRadius,
                    min: 0.0,
                    max: 50.0,
                    divisions: 100,
                    label: '${blurRadius.toStringAsFixed(1)}px',
                    onChanged: (value) {
                      setDialogState(() => blurRadius = value);
                    },
                  ),
                  
                  // Spread Radius
                  Text('Spread Radius: ${spreadRadius.toStringAsFixed(1)}px', 
                    style: const TextStyle(fontWeight: FontWeight.w500)),
                  Slider(
                    value: spreadRadius,
                    min: -10.0,
                    max: 20.0,
                    divisions: 60,
                    label: '${spreadRadius.toStringAsFixed(1)}px',
                    onChanged: (value) {
                      setDialogState(() => spreadRadius = value);
                    },
                  ),
                  
                  // Opacity
                  Text('Opacity: ${(opacity * 100).toStringAsFixed(0)}%', 
                    style: const TextStyle(fontWeight: FontWeight.w500)),
                  Slider(
                    value: opacity,
                    min: 0.0,
                    max: 1.0,
                    divisions: 100,
                    label: '${(opacity * 100).toStringAsFixed(0)}%',
                    onChanged: (value) {
                      setDialogState(() => opacity = value);
                    },
                  ),
                  
                  // Color picker
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: 'Shadow Color',
                            border: const OutlineInputBorder(),
                            suffixIcon: Container(
                              margin: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: shadowColor,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: Colors.grey),
                              ),
                            ),
                          ),
                          controller: TextEditingController(
                            text: '#${shadowColor.value.toRadixString(16).substring(2).toUpperCase()}',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.colorize),
                        onPressed: () async {
                          final result = await Navigator.of(dialogContext).push<Map<String, dynamic>>(
                            MaterialPageRoute(
                              builder: (_) => const ColorPickerScreen(),
                            ),
                          );
                          if (result != null && result['color'] != null) {
                            setDialogState(() {
                              shadowColor = result['color'] as Color;
                            });
                          }
                        },
                        tooltip: 'Pick Color',
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Generated CSS value (read-only)
                  TextField(
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Generated CSS Value',
                      border: OutlineInputBorder(),
                      helperText: 'This value will be saved',
                    ),
                    controller: TextEditingController(text: shadowValue),
                    maxLines: 2,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description (Optional)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (nameController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter a shadow name'),
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 2),
                      ),
                    );
                    return;
                  }
                  
                  final provider = Provider.of<DesignSystemProvider>(context, listen: false);
                  final shadows = provider.designSystem.shadows;
                  final updatedShadows = Map<String, models.ShadowValue>.from(shadows.values);
                  updatedShadows[nameController.text.trim()] = models.ShadowValue(
                    value: shadowValue,
                    description: descriptionController.text.trim().isEmpty
                        ? null
                        : descriptionController.text.trim(),
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
                    shadows: models.Shadows(values: updatedShadows),
                    effects: provider.designSystem.effects,
                    components: provider.designSystem.components,
                    grid: provider.designSystem.grid,
                    icons: provider.designSystem.icons,
                    gradients: provider.designSystem.gradients,
                    roles: provider.designSystem.roles,
                    semanticTokens: provider.designSystem.semanticTokens,
                    motionTokens: provider.designSystem.motionTokens,
                    lastModified: DateTime.now().toIso8601String(),
                    versionHistory: provider.designSystem.versionHistory,
                  ));

                  Navigator.of(dialogContext).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Shadow "${nameController.text.trim()}" added!'),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                child: const Text('Add'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showEditShadowDialog(
    BuildContext context,
    String name,
    models.ShadowValue shadow,
  ) {
    final nameController = TextEditingController(text: name);
    final descriptionController = TextEditingController(text: shadow.description ?? '');
    
    // Parse existing shadow values
    final shadowParams = _parseShadowToParams(shadow.value);
    double offsetX = shadowParams['offsetX'] ?? 0.0;
    double offsetY = shadowParams['offsetY'] ?? 2.0;
    double blurRadius = shadowParams['blurRadius'] ?? 4.0;
    double spreadRadius = shadowParams['spreadRadius'] ?? 0.0;
    Color shadowColor = shadowParams['color'] ?? Colors.black;
    double opacity = shadowParams['opacity'] ?? 0.1;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          final shadowValue = _buildShadowValue(offsetX, offsetY, blurRadius, spreadRadius, shadowColor, opacity);
          
          return AlertDialog(
            title: const Text('Edit Shadow'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                    autofocus: true,
                  ),
                  const SizedBox(height: 24),
                  
                  // Preview
                  Container(
                    width: double.infinity,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Center(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              offset: Offset(offsetX, offsetY),
                              blurRadius: blurRadius,
                              spreadRadius: spreadRadius,
                              color: shadowColor.withOpacity(opacity),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.auto_awesome, size: 32, color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // X Offset
                  Text('X Offset: ${offsetX.toStringAsFixed(1)}px', 
                    style: const TextStyle(fontWeight: FontWeight.w500)),
                  Slider(
                    value: offsetX,
                    min: -20.0,
                    max: 20.0,
                    divisions: 80,
                    label: '${offsetX.toStringAsFixed(1)}px',
                    onChanged: (value) {
                      setDialogState(() => offsetX = value);
                    },
                  ),
                  
                  // Y Offset
                  Text('Y Offset: ${offsetY.toStringAsFixed(1)}px', 
                    style: const TextStyle(fontWeight: FontWeight.w500)),
                  Slider(
                    value: offsetY,
                    min: -20.0,
                    max: 20.0,
                    divisions: 80,
                    label: '${offsetY.toStringAsFixed(1)}px',
                    onChanged: (value) {
                      setDialogState(() => offsetY = value);
                    },
                  ),
                  
                  // Blur Radius
                  Text('Blur Radius: ${blurRadius.toStringAsFixed(1)}px', 
                    style: const TextStyle(fontWeight: FontWeight.w500)),
                  Slider(
                    value: blurRadius,
                    min: 0.0,
                    max: 50.0,
                    divisions: 100,
                    label: '${blurRadius.toStringAsFixed(1)}px',
                    onChanged: (value) {
                      setDialogState(() => blurRadius = value);
                    },
                  ),
                  
                  // Spread Radius
                  Text('Spread Radius: ${spreadRadius.toStringAsFixed(1)}px', 
                    style: const TextStyle(fontWeight: FontWeight.w500)),
                  Slider(
                    value: spreadRadius,
                    min: -10.0,
                    max: 20.0,
                    divisions: 60,
                    label: '${spreadRadius.toStringAsFixed(1)}px',
                    onChanged: (value) {
                      setDialogState(() => spreadRadius = value);
                    },
                  ),
                  
                  // Opacity
                  Text('Opacity: ${(opacity * 100).toStringAsFixed(0)}%', 
                    style: const TextStyle(fontWeight: FontWeight.w500)),
                  Slider(
                    value: opacity,
                    min: 0.0,
                    max: 1.0,
                    divisions: 100,
                    label: '${(opacity * 100).toStringAsFixed(0)}%',
                    onChanged: (value) {
                      setDialogState(() => opacity = value);
                    },
                  ),
                  
                  // Color picker
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: 'Shadow Color',
                            border: const OutlineInputBorder(),
                            suffixIcon: Container(
                              margin: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: shadowColor,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: Colors.grey),
                              ),
                            ),
                          ),
                          controller: TextEditingController(
                            text: '#${shadowColor.value.toRadixString(16).substring(2).toUpperCase()}',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.colorize),
                        onPressed: () async {
                          final result = await Navigator.of(dialogContext).push<Map<String, dynamic>>(
                            MaterialPageRoute(
                              builder: (_) => const ColorPickerScreen(),
                            ),
                          );
                          if (result != null && result['color'] != null) {
                            setDialogState(() {
                              shadowColor = result['color'] as Color;
                            });
                          }
                        },
                        tooltip: 'Pick Color',
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Generated CSS value (read-only)
                  TextField(
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Generated CSS Value',
                      border: OutlineInputBorder(),
                      helperText: 'This value will be saved',
                    ),
                    controller: TextEditingController(text: shadowValue),
                    maxLines: 2,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description (Optional)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (nameController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter a shadow name'),
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 2),
                      ),
                    );
                    return;
                  }
                  
                  final provider = Provider.of<DesignSystemProvider>(context, listen: false);
                  final shadows = provider.designSystem.shadows;
                  final updatedShadows = Map<String, models.ShadowValue>.from(shadows.values);
                  if (name != nameController.text.trim()) {
                    updatedShadows.remove(name);
                  }
                  updatedShadows[nameController.text.trim()] = models.ShadowValue(
                    value: shadowValue,
                    description: descriptionController.text.trim().isEmpty
                        ? null
                        : descriptionController.text.trim(),
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
                    shadows: models.Shadows(values: updatedShadows),
                    effects: provider.designSystem.effects,
                    components: provider.designSystem.components,
                    grid: provider.designSystem.grid,
                    icons: provider.designSystem.icons,
                    gradients: provider.designSystem.gradients,
                    roles: provider.designSystem.roles,
                    semanticTokens: provider.designSystem.semanticTokens,
                    motionTokens: provider.designSystem.motionTokens,
                    lastModified: DateTime.now().toIso8601String(),
                    versionHistory: provider.designSystem.versionHistory,
                  ));

                  Navigator.of(dialogContext).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Shadow updated!'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _deleteShadow(BuildContext context, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Shadow'),
        content: Text('Are you sure you want to delete shadow "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final provider = Provider.of<DesignSystemProvider>(context, listen: false);
              final shadows = provider.designSystem.shadows;
              final updatedShadows = Map<String, models.ShadowValue>.from(shadows.values);
              updatedShadows.remove(name);

              provider.updateDesignSystem(models.DesignSystem(
                name: provider.designSystem.name,
                version: provider.designSystem.version,
                description: provider.designSystem.description,
                created: provider.designSystem.created,
                colors: provider.designSystem.colors,
                typography: provider.designSystem.typography,
                spacing: provider.designSystem.spacing,
                borderRadius: provider.designSystem.borderRadius,
                shadows: models.Shadows(values: updatedShadows),
                effects: provider.designSystem.effects,
                components: provider.designSystem.components,
                grid: provider.designSystem.grid,
                icons: provider.designSystem.icons,
                gradients: provider.designSystem.gradients,
                roles: provider.designSystem.roles,
                semanticTokens: provider.designSystem.semanticTokens,
                motionTokens: provider.designSystem.motionTokens,
                lastModified: provider.designSystem.lastModified,
                versionHistory: provider.designSystem.versionHistory,
              ));

              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Shadow "$name" deleted!'),
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

  // Parse CSS shadow string to BoxShadow
  BoxShadow _parseShadow(String shadowValue) {
    try {
      // Try to parse CSS shadow format: "offsetX offsetY blurRadius spreadRadius color"
      // Example: "0 2px 4px 0 rgba(0, 0, 0, 0.1)"
      final parts = shadowValue.trim().split(RegExp(r'\s+'));
      if (parts.length >= 3) {
        final offsetX = double.tryParse(parts[0].replaceAll('px', '')) ?? 0.0;
        final offsetY = double.tryParse(parts[1].replaceAll('px', '')) ?? 0.0;
        final blurRadius = double.tryParse(parts[2].replaceAll('px', '')) ?? 0.0;
        double spreadRadius = 0.0;
        Color color = Colors.black;
        double opacity = 0.1;

        if (parts.length >= 4) {
          spreadRadius = double.tryParse(parts[3].replaceAll('px', '')) ?? 0.0;
        }

        // Try to parse color (could be rgba, rgb, or hex)
        String? colorStr;
        if (parts.length >= 5) {
          colorStr = parts.sublist(4).join(' ');
        } else if (parts.length >= 4 && parts[3].contains('rgba') || parts[3].contains('rgb')) {
          colorStr = parts[3];
        }

        if (colorStr != null) {
          final rgbaMatch = RegExp(r'rgba?\((\d+),\s*(\d+),\s*(\d+)(?:,\s*([\d.]+))?\)').firstMatch(colorStr);
          if (rgbaMatch != null) {
            color = Color.fromRGBO(
              int.parse(rgbaMatch.group(1)!),
              int.parse(rgbaMatch.group(2)!),
              int.parse(rgbaMatch.group(3)!),
              rgbaMatch.group(4) != null ? double.parse(rgbaMatch.group(4)!) : 1.0,
            );
            opacity = rgbaMatch.group(4) != null ? double.parse(rgbaMatch.group(4)!) : 1.0;
          }
        }

        return BoxShadow(
          offset: Offset(offsetX, offsetY),
          blurRadius: blurRadius,
          spreadRadius: spreadRadius,
          color: color.withOpacity(opacity),
        );
      }
    } catch (e) {
      // If parsing fails, return default shadow
    }
    return BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 4,
      offset: const Offset(0, 2),
    );
  }

  // Parse shadow to parameters map
  Map<String, dynamic> _parseShadowToParams(String shadowValue) {
    try {
      final parts = shadowValue.trim().split(RegExp(r'\s+'));
      if (parts.length >= 3) {
        final offsetX = double.tryParse(parts[0].replaceAll('px', '')) ?? 0.0;
        final offsetY = double.tryParse(parts[1].replaceAll('px', '')) ?? 0.0;
        final blurRadius = double.tryParse(parts[2].replaceAll('px', '')) ?? 0.0;
        double spreadRadius = 0.0;
        Color color = Colors.black;
        double opacity = 0.1;

        if (parts.length >= 4) {
          spreadRadius = double.tryParse(parts[3].replaceAll('px', '')) ?? 0.0;
        }

        String? colorStr;
        if (parts.length >= 5) {
          colorStr = parts.sublist(4).join(' ');
        } else if (parts.length >= 4 && (parts[3].contains('rgba') || parts[3].contains('rgb'))) {
          colorStr = parts[3];
        }

        if (colorStr != null) {
          final rgbaMatch = RegExp(r'rgba?\((\d+),\s*(\d+),\s*(\d+)(?:,\s*([\d.]+))?\)').firstMatch(colorStr);
          if (rgbaMatch != null) {
            color = Color.fromRGBO(
              int.parse(rgbaMatch.group(1)!),
              int.parse(rgbaMatch.group(2)!),
              int.parse(rgbaMatch.group(3)!),
              rgbaMatch.group(4) != null ? double.parse(rgbaMatch.group(4)!) : 1.0,
            );
            opacity = rgbaMatch.group(4) != null ? double.parse(rgbaMatch.group(4)!) : 1.0;
          }
        }

        return {
          'offsetX': offsetX,
          'offsetY': offsetY,
          'blurRadius': blurRadius,
          'spreadRadius': spreadRadius,
          'color': color,
          'opacity': opacity,
        };
      }
    } catch (e) {
      // Return defaults if parsing fails
    }
    return {
      'offsetX': 0.0,
      'offsetY': 2.0,
      'blurRadius': 4.0,
      'spreadRadius': 0.0,
      'color': Colors.black,
      'opacity': 0.1,
    };
  }

  // Build CSS shadow value from parameters
  String _buildShadowValue(double offsetX, double offsetY, double blurRadius, double spreadRadius, Color color, double opacity) {
    final r = color.red;
    final g = color.green;
    final b = color.blue;
    final finalOpacity = opacity;
    
    return '${offsetX.toStringAsFixed(0)}px ${offsetY.toStringAsFixed(0)}px ${blurRadius.toStringAsFixed(0)}px ${spreadRadius.toStringAsFixed(0)}px rgba($r, $g, $b, ${finalOpacity.toStringAsFixed(2)})';
  }
}
