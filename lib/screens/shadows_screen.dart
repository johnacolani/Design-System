import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/design_system_provider.dart';
import '../models/design_system.dart' as models;

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
      body: ListView(
        padding: const EdgeInsets.all(16),
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
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  'Preview',
                  style: Theme.of(context).textTheme.bodyLarge,
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
    final valueController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Shadow'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name (e.g., sm, md, lg)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: valueController,
                decoration: const InputDecoration(
                  labelText: 'Shadow Value (e.g., 0 1px 2px rgba(0, 0, 0, 0.05))',
                  border: OutlineInputBorder(),
                  hintText: '0 1px 2px rgba(0, 0, 0, 0.05)',
                ),
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
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty && valueController.text.isNotEmpty) {
                final provider = Provider.of<DesignSystemProvider>(context, listen: false);
                final shadows = provider.designSystem.shadows;
                final updatedShadows = Map<String, models.ShadowValue>.from(shadows.values);
                updatedShadows[nameController.text] = models.ShadowValue(
                  value: valueController.text,
                  description: descriptionController.text.isEmpty
                      ? null
                      : descriptionController.text,
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
                ));

                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Shadow "${nameController.text}" added!'),
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

  void _showEditShadowDialog(
    BuildContext context,
    String name,
    models.ShadowValue shadow,
  ) {
    final nameController = TextEditingController(text: name);
    final valueController = TextEditingController(text: shadow.value);
    final descriptionController = TextEditingController(text: shadow.description ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Shadow'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: valueController,
                decoration: const InputDecoration(
                  labelText: 'Shadow Value',
                  border: OutlineInputBorder(),
                ),
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
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty && valueController.text.isNotEmpty) {
                final provider = Provider.of<DesignSystemProvider>(context, listen: false);
                final shadows = provider.designSystem.shadows;
                final updatedShadows = Map<String, models.ShadowValue>.from(shadows.values);
                if (name != nameController.text) {
                  updatedShadows.remove(name);
                }
                updatedShadows[nameController.text] = models.ShadowValue(
                  value: valueController.text,
                  description: descriptionController.text.isEmpty
                      ? null
                      : descriptionController.text,
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
                ));

                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Shadow updated!'),
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
}
