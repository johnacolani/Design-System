import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/design_system_provider.dart';
import '../models/design_system.dart' as models;

class RolesScreen extends StatefulWidget {
  const RolesScreen({super.key});

  @override
  State<RolesScreen> createState() => _RolesScreenState();
}

class _RolesScreenState extends State<RolesScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DesignSystemProvider>(context);
    final roles = provider.designSystem.roles;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Roles'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showAddRoleDialog(context);
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Role-Based Colors',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Define color schemes for different user roles',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 24),
          if (roles.values.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.person_outline, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No roles defined',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          _showAddRoleDialog(context);
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add Role'),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            ...roles.values.entries.map((entry) {
              return _buildRoleCard(context, entry.key, entry.value);
            }),
        ],
      ),
    );
  }

  Widget _buildRoleCard(
    BuildContext context,
    String name,
    models.RoleValue role,
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
                  name.toUpperCase(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showEditRoleDialog(context, name, role);
                    } else if (value == 'delete') {
                      _deleteRole(context, name);
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
            _buildColorRow(context, 'Primary Color', role.primaryColor),
            const SizedBox(height: 12),
            _buildColorRow(context, 'Accent Color', role.accentColor),
            const SizedBox(height: 12),
            _buildColorRow(context, 'Background', role.background),
          ],
        ),
      ),
    );
  }

  Widget _buildColorRow(BuildContext context, String label, String colorValue) {
    Color? color = _parseColor(colorValue);

    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color ?? Colors.grey,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              Text(
                colorValue,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color? _parseColor(String colorString) {
    try {
      if (colorString.startsWith('#')) {
        return Color(int.parse(colorString.substring(1), radix: 16) + 0xFF000000);
      } else if (colorString.startsWith('rgb')) {
        // Simple RGB parsing - in production, use a proper parser
        return Colors.blue;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  void _showAddRoleDialog(BuildContext context) {
    final nameController = TextEditingController();
    final primaryController = TextEditingController(text: '#3B82F6');
    final accentController = TextEditingController(text: '#8B5CF6');
    final backgroundController = TextEditingController(text: '#FFFFFF');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Role'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Role Name (e.g., admin, user, guest)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: primaryController,
                decoration: const InputDecoration(
                  labelText: 'Primary Color (e.g., #3B82F6)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: accentController,
                decoration: const InputDecoration(
                  labelText: 'Accent Color (e.g., #8B5CF6)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: backgroundController,
                decoration: const InputDecoration(
                  labelText: 'Background Color (e.g., #FFFFFF)',
                  border: OutlineInputBorder(),
                ),
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
                  primaryController.text.isNotEmpty &&
                  accentController.text.isNotEmpty &&
                  backgroundController.text.isNotEmpty) {
                final provider = Provider.of<DesignSystemProvider>(context, listen: false);
                final roles = provider.designSystem.roles;
                final updatedRoles = Map<String, models.RoleValue>.from(roles.values);

                updatedRoles[nameController.text] = models.RoleValue(
                  primaryColor: primaryController.text,
                  accentColor: accentController.text,
                  background: backgroundController.text,
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
                  gradients: provider.designSystem.gradients,
                  roles: models.Roles(values: updatedRoles),
                  semanticTokens: provider.designSystem.semanticTokens,
                  motionTokens: provider.designSystem.motionTokens,
                  lastModified: provider.designSystem.lastModified,
                  versionHistory: provider.designSystem.versionHistory,
                ));

                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Role "${nameController.text}" added!'),
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

  void _showEditRoleDialog(
    BuildContext context,
    String name,
    models.RoleValue role,
  ) {
    final nameController = TextEditingController(text: name);
    final primaryController = TextEditingController(text: role.primaryColor);
    final accentController = TextEditingController(text: role.accentColor);
    final backgroundController = TextEditingController(text: role.background);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Role'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Role Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: primaryController,
                decoration: const InputDecoration(
                  labelText: 'Primary Color',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: accentController,
                decoration: const InputDecoration(
                  labelText: 'Accent Color',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: backgroundController,
                decoration: const InputDecoration(
                  labelText: 'Background Color',
                  border: OutlineInputBorder(),
                ),
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
                  primaryController.text.isNotEmpty &&
                  accentController.text.isNotEmpty &&
                  backgroundController.text.isNotEmpty) {
                final provider = Provider.of<DesignSystemProvider>(context, listen: false);
                final roles = provider.designSystem.roles;
                final updatedRoles = Map<String, models.RoleValue>.from(roles.values);
                if (name != nameController.text) {
                  updatedRoles.remove(name);
                }
                updatedRoles[nameController.text] = models.RoleValue(
                  primaryColor: primaryController.text,
                  accentColor: accentController.text,
                  background: backgroundController.text,
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
                  gradients: provider.designSystem.gradients,
                  roles: models.Roles(values: updatedRoles),
                  semanticTokens: provider.designSystem.semanticTokens,
                  motionTokens: provider.designSystem.motionTokens,
                  lastModified: provider.designSystem.lastModified,
                  versionHistory: provider.designSystem.versionHistory,
                ));

                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Role updated!'),
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

  void _deleteRole(BuildContext context, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Role'),
        content: Text('Are you sure you want to delete role "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final provider = Provider.of<DesignSystemProvider>(context, listen: false);
              final roles = provider.designSystem.roles;
              final updatedRoles = Map<String, models.RoleValue>.from(roles.values);
              updatedRoles.remove(name);

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
                gradients: provider.designSystem.gradients,
                roles: models.Roles(values: updatedRoles),
                semanticTokens: provider.designSystem.semanticTokens,
                motionTokens: provider.designSystem.motionTokens,
                lastModified: provider.designSystem.lastModified,
                versionHistory: provider.designSystem.versionHistory,
              ));

              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Role "$name" deleted!'),
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
