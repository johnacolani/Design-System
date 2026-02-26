import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/design_system_provider.dart';
import '../models/design_system.dart' as models;
import '../utils/screen_body_padding.dart';

class IconsScreen extends StatefulWidget {
  const IconsScreen({super.key});

  @override
  State<IconsScreen> createState() => _IconsScreenState();
}

class _IconsScreenState extends State<IconsScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DesignSystemProvider>(context);
    final icons = provider.designSystem.icons;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Icons'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showAddIconSizeDialog(context);
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
            'Icon Sizes',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Define standard icon sizes for consistent iconography',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 24),
          if (icons.sizes.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.image_outlined, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No icon sizes defined',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          _showAddIconSizeDialog(context);
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add Icon Size'),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            ...icons.sizes.entries.map((entry) {
              return _buildIconSizeCard(context, entry.key, entry.value);
            }),
        ],
        ),
      ),
    );
  }

  Widget _buildIconSizeCard(BuildContext context, String name, String size) {
    final sizeValue = _parseSize(size);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: sizeValue,
              height: sizeValue,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.blue, width: 2),
              ),
              child: Icon(
                Icons.star,
                size: sizeValue * 0.6,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name.toUpperCase(),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    size,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                          fontFamily: 'monospace',
                        ),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  _showEditIconSizeDialog(context, name, size);
                } else if (value == 'delete') {
                  _deleteIconSize(context, name);
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
  }

  double _parseSize(String size) {
    try {
      return double.parse(size.replaceAll('px', ''));
    } catch (e) {
      return 24;
    }
  }

  void _showAddIconSizeDialog(BuildContext context) {
    final nameController = TextEditingController();
    final sizeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Icon Size'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Size Name (e.g., xs, sm, md, lg)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: sizeController,
              decoration: const InputDecoration(
                labelText: 'Size Value (e.g., 24px)',
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
              if (nameController.text.isNotEmpty && sizeController.text.isNotEmpty) {
                final provider = Provider.of<DesignSystemProvider>(context, listen: false);
                final icons = provider.designSystem.icons;
                final updatedSizes = Map<String, String>.from(icons.sizes);
                updatedSizes[nameController.text] = sizeController.text;

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
                  icons: models.Icons(sizes: updatedSizes),
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
                    content: Text('Icon size "${nameController.text}" added!'),
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

  void _showEditIconSizeDialog(BuildContext context, String name, String size) {
    final nameController = TextEditingController(text: name);
    final sizeController = TextEditingController(text: size);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Icon Size'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Size Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: sizeController,
              decoration: const InputDecoration(
                labelText: 'Size Value',
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
              if (nameController.text.isNotEmpty && sizeController.text.isNotEmpty) {
                final provider = Provider.of<DesignSystemProvider>(context, listen: false);
                final icons = provider.designSystem.icons;
                final updatedSizes = Map<String, String>.from(icons.sizes);
                if (name != nameController.text) {
                  updatedSizes.remove(name);
                }
                updatedSizes[nameController.text] = sizeController.text;

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
                  icons: models.Icons(sizes: updatedSizes),
                  gradients: provider.designSystem.gradients,
                  roles: provider.designSystem.roles,
                  semanticTokens: provider.designSystem.semanticTokens,
                  motionTokens: provider.designSystem.motionTokens,
                  lastModified: provider.designSystem.lastModified,
                  versionHistory: provider.designSystem.versionHistory,
                ));

                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Icon size updated!'),
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

  void _deleteIconSize(BuildContext context, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Icon Size'),
        content: Text('Are you sure you want to delete icon size "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final provider = Provider.of<DesignSystemProvider>(context, listen: false);
              final icons = provider.designSystem.icons;
              final updatedSizes = Map<String, String>.from(icons.sizes);
              updatedSizes.remove(name);

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
                icons: models.Icons(sizes: updatedSizes),
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
                  content: Text('Icon size "$name" deleted!'),
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
