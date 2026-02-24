import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/design_system_provider.dart';
import '../models/design_system.dart' as models;

class EffectsScreen extends StatefulWidget {
  const EffectsScreen({super.key});

  @override
  State<EffectsScreen> createState() => _EffectsScreenState();
}

class _EffectsScreenState extends State<EffectsScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DesignSystemProvider>(context);
    final effects = provider.designSystem.effects;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Effects'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showAddEffectDialog(context);
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Visual Effects',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Define visual effects like glass morphism and overlays',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 24),
          if (effects.glassMorphism == null && effects.darkOverlay == null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.auto_awesome_outlined, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No effects defined',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          _showAddEffectDialog(context);
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add Effect'),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else ...[
            if (effects.glassMorphism != null)
              _buildEffectCard(
                context,
                'Glass Morphism',
                effects.glassMorphism!,
                Icons.blur_on,
                Colors.blue,
              ),
            if (effects.darkOverlay != null)
              _buildEffectCard(
                context,
                'Dark Overlay',
                effects.darkOverlay!,
                Icons.layers,
                Colors.grey,
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildEffectCard(
    BuildContext context,
    String name,
    Map<String, dynamic> effectData,
    IconData icon,
    Color color,
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
                Row(
                  children: [
                    Icon(icon, color: color),
                    const SizedBox(width: 12),
                    Text(
                      name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showEditEffectDialog(context, name.toLowerCase().replaceAll(' ', '_'), effectData);
                    } else if (value == 'delete') {
                      _deleteEffect(context, name.toLowerCase().replaceAll(' ', '_'));
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
            ...effectData.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      entry.key,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Text(
                      entry.value.toString(),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showAddEffectDialog(BuildContext context) {
    String selectedEffect = 'glassMorphism';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Effect'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Select effect type:'),
              const SizedBox(height: 16),
              RadioListTile<String>(
                title: const Text('Glass Morphism'),
                value: 'glassMorphism',
                groupValue: selectedEffect,
                onChanged: (value) {
                  setDialogState(() {
                    selectedEffect = value!;
                  });
                },
              ),
              RadioListTile<String>(
                title: const Text('Dark Overlay'),
                value: 'darkOverlay',
                groupValue: selectedEffect,
                onChanged: (value) {
                  setDialogState(() {
                    selectedEffect = value!;
                  });
                },
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
                Navigator.of(context).pop();
                _showEffectDetailsDialog(context, selectedEffect);
              },
              child: const Text('Next'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEffectDetailsDialog(BuildContext context, String effectType) {
    final backgroundController = TextEditingController();
    final backdropController = TextEditingController();
    final borderController = TextEditingController();
    final descriptionController = TextEditingController();

    if (effectType == 'glassMorphism') {
      backgroundController.text = 'rgba(255, 255, 255, 0.1)';
      backdropController.text = 'blur(10px)';
      borderController.text = '1px solid rgba(255, 255, 255, 0.2)';
      descriptionController.text = 'Glass morphism effect';
    } else {
      backgroundController.text = 'rgba(26, 26, 46, 0.8)';
      descriptionController.text = 'Dark overlay for modals and cards';
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add ${effectType == 'glassMorphism' ? 'Glass Morphism' : 'Dark Overlay'}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: backgroundController,
                decoration: const InputDecoration(
                  labelText: 'Background',
                  border: OutlineInputBorder(),
                ),
              ),
              if (effectType == 'glassMorphism') ...[
                const SizedBox(height: 16),
                TextField(
                  controller: backdropController,
                  decoration: const InputDecoration(
                    labelText: 'Backdrop Filter',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: borderController,
                  decoration: const InputDecoration(
                    labelText: 'Border',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
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
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final provider = Provider.of<DesignSystemProvider>(context, listen: false);
              final effects = provider.designSystem.effects;

              Map<String, dynamic>? glassMorphism = effects.glassMorphism;
              Map<String, dynamic>? darkOverlay = effects.darkOverlay;

              if (effectType == 'glassMorphism') {
                glassMorphism = {
                  'background': backgroundController.text,
                  'backdrop': backdropController.text,
                  'border': borderController.text,
                  'description': descriptionController.text,
                };
              } else {
                darkOverlay = {
                  'background': backgroundController.text,
                  'description': descriptionController.text,
                };
              }

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
                effects: models.Effects(
                  glassMorphism: glassMorphism,
                  darkOverlay: darkOverlay,
                ),
                components: provider.designSystem.components,
                grid: provider.designSystem.grid,
                icons: provider.designSystem.icons,
                gradients: provider.designSystem.gradients,
                roles: provider.designSystem.roles,
              ));

              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${effectType == 'glassMorphism' ? 'Glass Morphism' : 'Dark Overlay'} added!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditEffectDialog(
    BuildContext context,
    String effectType,
    Map<String, dynamic> effectData,
  ) {
    final backgroundController = TextEditingController(
      text: effectData['background']?.toString() ?? '',
    );
    final backdropController = TextEditingController(
      text: effectData['backdrop']?.toString() ?? '',
    );
    final borderController = TextEditingController(
      text: effectData['border']?.toString() ?? '',
    );
    final descriptionController = TextEditingController(
      text: effectData['description']?.toString() ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit ${effectType == 'glassMorphism' ? 'Glass Morphism' : 'Dark Overlay'}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: backgroundController,
                decoration: const InputDecoration(
                  labelText: 'Background',
                  border: OutlineInputBorder(),
                ),
              ),
              if (effectType == 'glassMorphism') ...[
                const SizedBox(height: 16),
                TextField(
                  controller: backdropController,
                  decoration: const InputDecoration(
                    labelText: 'Backdrop Filter',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: borderController,
                  decoration: const InputDecoration(
                    labelText: 'Border',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
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
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final provider = Provider.of<DesignSystemProvider>(context, listen: false);
              final effects = provider.designSystem.effects;

              Map<String, dynamic>? glassMorphism = effects.glassMorphism;
              Map<String, dynamic>? darkOverlay = effects.darkOverlay;

              if (effectType == 'glassMorphism') {
                glassMorphism = {
                  'background': backgroundController.text,
                  'backdrop': backdropController.text,
                  'border': borderController.text,
                  'description': descriptionController.text,
                };
              } else {
                darkOverlay = {
                  'background': backgroundController.text,
                  'description': descriptionController.text,
                };
              }

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
                effects: models.Effects(
                  glassMorphism: glassMorphism,
                  darkOverlay: darkOverlay,
                ),
                components: provider.designSystem.components,
                grid: provider.designSystem.grid,
                icons: provider.designSystem.icons,
                gradients: provider.designSystem.gradients,
                roles: provider.designSystem.roles,
              ));

              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Effect updated!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _deleteEffect(BuildContext context, String effectType) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Effect'),
        content: Text('Are you sure you want to delete this effect?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final provider = Provider.of<DesignSystemProvider>(context, listen: false);
              final effects = provider.designSystem.effects;

              Map<String, dynamic>? glassMorphism = effects.glassMorphism;
              Map<String, dynamic>? darkOverlay = effects.darkOverlay;

              if (effectType == 'glassMorphism') {
                glassMorphism = null;
              } else {
                darkOverlay = null;
              }

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
                effects: models.Effects(
                  glassMorphism: glassMorphism,
                  darkOverlay: darkOverlay,
                ),
                components: provider.designSystem.components,
                grid: provider.designSystem.grid,
                icons: provider.designSystem.icons,
                gradients: provider.designSystem.gradients,
                roles: provider.designSystem.roles,
              ));

              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Effect deleted!'),
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
