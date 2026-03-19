import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/design_system_provider.dart';
import '../models/design_system.dart' as models;
import '../utils/screen_body_padding.dart';
import '../widgets/project_icon_picker_page.dart';

class IconsScreen extends StatefulWidget {
  const IconsScreen({super.key});

  @override
  State<IconsScreen> createState() => _IconsScreenState();
}

class _IconsScreenState extends State<IconsScreen> {
  TokenDisplayGroup? _selectedGroup;
  bool _contentReady = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _contentReady = true);
    });
  }

  void _applyIconsUpdateForGroup(TokenDisplayGroup group, models.Icons icons) {
    final p = Provider.of<DesignSystemProvider>(context, listen: false);
    if (group.platforms.length == 1 && !p.isMultiPlatform) {
      final d = p.designSystem;
      p.updateDesignSystem(models.DesignSystem(
        name: d.name, version: d.version, description: d.description, created: d.created,
        colors: d.colors, typography: d.typography, spacing: d.spacing, borderRadius: d.borderRadius,
        shadows: d.shadows, effects: d.effects, components: d.components, grid: d.grid,
        icons: icons, gradients: d.gradients, roles: d.roles, semanticTokens: d.semanticTokens,
        motionTokens: d.motionTokens, lastModified: d.lastModified, versionHistory: d.versionHistory,
        componentVersions: d.componentVersions, targetPlatforms: d.targetPlatforms, platformOverrides: d.platformOverrides,
      ));
    } else {
      p.updateIconsForGroup(group, icons);
    }
  }

  models.Icons _getIconsForGroup(TokenDisplayGroup group) {
    final p = Provider.of<DesignSystemProvider>(context, listen: false);
    if (group.platforms.length == 1 && !p.isMultiPlatform) return p.designSystem.icons;
    return p.designSystemForPlatform(group.primaryPlatform).icons;
  }

  TokenDisplayGroup _effectiveGroup(BuildContext context) {
    final p = Provider.of<DesignSystemProvider>(context, listen: false);
    final groups = p.designTokenDisplayGroups;
    return _selectedGroup ?? groups.first;
  }

  Widget _buildGroupSelector(DesignSystemProvider provider) {
    final groups = provider.designTokenDisplayGroups;
    if (groups.length < 2) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Row(
        children: [
          Text('Platform:', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              children: groups.map((g) {
                final isSelected = _selectedGroup == g;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(g.label),
                    selected: isSelected,
                    onSelected: (selected) { if (selected) setState(() => _selectedGroup = g); },
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_contentReady) {
      return Scaffold(
        appBar: AppBar(title: const Text('Icons')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    final provider = Provider.of<DesignSystemProvider>(context);
    final groups = provider.designTokenDisplayGroups;
    if (groups.isNotEmpty && _selectedGroup == null) _selectedGroup = groups.first;
    final icons = _getIconsForGroup(_effectiveGroup(context));

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
          _buildGroupSelector(provider),
          Text(
            'Project icons',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Icons your product uses (nav, actions, empty states). They appear in Design System Preview and exports.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 16),
          if (icons.projectIcons.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(Icons.widgets_outlined, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 12),
                    Text(
                      'No project icons yet',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add icons to document what your team should use in the UI.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () => _addProjectIcon(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Add project icon'),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: icons.projectIcons.map((e) {
                final iconData = IconData(e.codePoint, fontFamily: 'MaterialIcons');
                final md = _parseSizePx(icons.sizes['md'] ?? '24px');
                return Chip(
                  avatar: Icon(iconData, size: md * 0.85),
                  label: SizedBox(
                    width: 120,
                    child: Text(
                      e.label,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                  deleteIcon: const Icon(Icons.close, size: 18),
                  onDeleted: () => _removeProjectIcon(context, e.id),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => _addProjectIcon(context),
              icon: const Icon(Icons.add),
              label: const Text('Add project icon'),
            ),
          ],
          const SizedBox(height: 32),
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

  double _parseSizePx(String size) => _parseSize(size);

  String _materialIconName(IconData icon) {
    final m = RegExp(r"'([^']+)'").firstMatch(icon.toString());
    return m?.group(1) ?? 'icon';
  }

  Future<void> _addProjectIcon(BuildContext context) async {
    final icon = await Navigator.of(context).push<IconData>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (ctx) => const ProjectIconPickerPage(),
      ),
    );
    if (!context.mounted || icon == null) return;

    final defaultLabel = _materialIconName(icon);
    final labelCtrl = TextEditingController(text: defaultLabel);

    final label = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Label for this icon'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48),
            const SizedBox(height: 16),
            TextField(
              controller: labelCtrl,
              decoration: const InputDecoration(
                labelText: 'Usage name',
                hintText: 'e.g. Tab — Home, Toolbar — Search',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, labelCtrl.text.trim().isEmpty ? defaultLabel : labelCtrl.text.trim()),
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (!context.mounted || label == null) return;

    final provider = Provider.of<DesignSystemProvider>(context, listen: false);
    final i = provider.designSystem.icons;
    final entry = models.ProjectIconEntry(
      id: 'pi_${DateTime.now().microsecondsSinceEpoch}',
      label: label,
      codePoint: icon.codePoint,
    );
    _applyIcons(context, models.Icons(
      sizes: i.sizes,
      projectIcons: [...i.projectIcons, entry],
    ));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Added “$label” — see Preview')),
    );
  }

  void _removeProjectIcon(BuildContext context, String id) {
    final i = _getIconsForGroup(_effectiveGroup(context));
    _applyIcons(context, models.Icons(
      sizes: i.sizes,
      projectIcons: i.projectIcons.where((e) => e.id != id).toList(),
    ));
  }

  void _applyIcons(BuildContext context, models.Icons icons) {
    _applyIconsUpdateForGroup(_effectiveGroup(context), icons);
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
                final icons = _getIconsForGroup(_effectiveGroup(context));
                final updatedSizes = Map<String, String>.from(icons.sizes);
                updatedSizes[nameController.text] = sizeController.text;
                _applyIconsUpdateForGroup(_effectiveGroup(context),models.Icons(sizes: updatedSizes, projectIcons: icons.projectIcons));
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
                final icons = _getIconsForGroup(_effectiveGroup(context));
                final updatedSizes = Map<String, String>.from(icons.sizes);
                if (name != nameController.text) updatedSizes.remove(name);
                updatedSizes[nameController.text] = sizeController.text;
                _applyIconsUpdateForGroup(_effectiveGroup(context),models.Icons(sizes: updatedSizes, projectIcons: icons.projectIcons));
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
              final icons = _getIconsForGroup(_effectiveGroup(context));
              final updatedSizes = Map<String, String>.from(icons.sizes);
              updatedSizes.remove(name);
              _applyIconsUpdateForGroup(_effectiveGroup(context),models.Icons(sizes: updatedSizes, projectIcons: icons.projectIcons));
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
