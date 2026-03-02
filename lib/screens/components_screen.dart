import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/design_system_provider.dart';
import '../models/design_system.dart' as models;

class ComponentsScreen extends StatefulWidget {
  const ComponentsScreen({super.key});

  @override
  State<ComponentsScreen> createState() => _ComponentsScreenState();
}

class _ComponentsScreenState extends State<ComponentsScreen> {
  String _selectedCategory = 'buttons';

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DesignSystemProvider>(context);
    final components = provider.designSystem.components;

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Components'),
          bottom: TabBar(
            onTap: (index) {
              setState(() {
                _selectedCategory = ['buttons', 'cards', 'inputs', 'navigation', 'avatars', 'modals', 'tables', 'progress', 'alerts'][index];
              });
            },
            tabs: const [
              Tab(icon: Icon(Icons.smart_button), text: 'Buttons'),
              Tab(icon: Icon(Icons.credit_card), text: 'Cards'),
              Tab(icon: Icon(Icons.input), text: 'Inputs'),
              Tab(icon: Icon(Icons.navigation), text: 'Navigation'),
              Tab(icon: Icon(Icons.person), text: 'Avatars'),
              Tab(icon: Icon(Icons.window), text: 'Modals'),
              Tab(icon: Icon(Icons.table_chart), text: 'Tables'),
              Tab(icon: Icon(Icons.track_changes), text: 'Progress'),
              Tab(icon: Icon(Icons.notifications), text: 'Alerts'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildComponentCategoryTab(context, 'buttons', components.buttons, Icons.smart_button),
            _buildComponentCategoryTab(context, 'cards', components.cards, Icons.credit_card),
            _buildComponentCategoryTab(context, 'inputs', components.inputs, Icons.input),
            _buildComponentCategoryTab(context, 'navigation', components.navigation, Icons.navigation),
            _buildComponentCategoryTab(context, 'avatars', components.avatars, Icons.person),
            _buildComponentCategoryTab(context, 'modals', components.modals ?? {}, Icons.window),
            _buildComponentCategoryTab(context, 'tables', components.tables ?? {}, Icons.table_chart),
            _buildComponentCategoryTab(context, 'progress', components.progress ?? {}, Icons.track_changes),
            _buildComponentCategoryTab(context, 'alerts', components.alerts ?? {}, Icons.notifications),
          ],
        ),
      ),
    );
  }

  Widget _buildComponentCategoryTab(
    BuildContext context,
    String category,
    Map<String, dynamic> componentMap,
    IconData icon,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              category.toUpperCase(),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                _showAddComponentDialog(context, category);
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Component'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (componentMap.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Column(
                  children: [
                    Icon(icon, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'No $category defined',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          ...componentMap.entries.map((entry) {
            return _buildComponentCard(context, category, entry.key, entry.value);
          }),
      ],
    );
  }

  Widget _buildComponentCard(
    BuildContext context,
    String category,
    String name,
    dynamic componentData,
  ) {
    final hasStates = componentData is Map && componentData.containsKey('states');
    final states = hasStates ? componentData['states'] as Map<String, dynamic>? : null;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(name),
        subtitle: Text('$category component${hasStates ? ' • ${states?.length ?? 0} states' : ''}'),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Show component states if they exist
                if (hasStates && states != null && states.isNotEmpty) ...[
                  Text(
                    'Component States',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: states.entries.map((stateEntry) {
                      return Chip(
                        label: Text(stateEntry.key),
                        avatar: Icon(
                          _getStateIcon(stateEntry.key),
                          size: 16,
                        ),
                        backgroundColor: _getStateColor(stateEntry.key).withOpacity(0.1),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                ],
                // Show base properties
                Text(
                  'Properties',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                if (componentData is Map)
                  ...componentData.entries.where((entry) => entry.key != 'states').map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            entry.key,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          Flexible(
                            child: Text(
                              entry.value.toString(),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontFamily: 'monospace',
                              ),
                              textAlign: TextAlign.end,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        _showEditComponentDialog(context, category, name, componentData);
                      },
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('Edit'),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () {
                        _deleteComponent(context, category, name);
                      },
                      icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                      label: const Text('Delete', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStateIcon(String state) {
    switch (state.toLowerCase()) {
      case 'default':
        return Icons.circle;
      case 'hover':
        return Icons.mouse;
      case 'active':
        return Icons.touch_app;
      case 'focus':
        return Icons.center_focus_strong;
      case 'disabled':
        return Icons.block;
      case 'loading':
        return Icons.hourglass_empty;
      default:
        return Icons.label;
    }
  }

  Color _getStateColor(String state) {
    switch (state.toLowerCase()) {
      case 'default':
        return Colors.blue;
      case 'hover':
        return Colors.green;
      case 'active':
        return Colors.orange;
      case 'focus':
        return Colors.purple;
      case 'disabled':
        return Colors.grey;
      case 'loading':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  void _showAddComponentDialog(BuildContext context, String category) {
    _showComponentDialog(context, category, null, null);
  }

  void _showComponentDialog(BuildContext context, String category, String? existingName, dynamic existingData) {
    final nameController = TextEditingController(text: existingName ?? '');
    final heightController = TextEditingController(text: existingData is Map ? (existingData['height']?.toString() ?? '') : '');
    final borderRadiusController = TextEditingController(text: existingData is Map ? (existingData['borderRadius']?.toString() ?? '') : '');
    final paddingController = TextEditingController(text: existingData is Map ? (existingData['padding']?.toString() ?? '') : '');
    final fontSizeController = TextEditingController(text: existingData is Map ? (existingData['fontSize']?.toString() ?? '') : '');
    final fontWeightController = TextEditingController(text: existingData is Map ? (existingData['fontWeight']?.toString() ?? '') : '');
    
    // State management
    final Set<String> selectedStates = {};
    if (existingData is Map && existingData.containsKey('states')) {
      selectedStates.addAll((existingData['states'] as Map<String, dynamic>).keys);
    } else if (category == 'buttons' || category == 'inputs') {
      // Default states for buttons and inputs
      selectedStates.addAll(['default', 'hover', 'active', 'focus', 'disabled']);
    }
    
    final availableStates = ['default', 'hover', 'active', 'focus', 'disabled', 'loading'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('${existingName != null ? 'Edit' : 'Add'} ${category.substring(0, 1).toUpperCase()}${category.substring(1)} Component'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Component Name (e.g., primary, secondary)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: heightController,
                  decoration: const InputDecoration(
                    labelText: 'Height (e.g., 50px)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: borderRadiusController,
                  decoration: const InputDecoration(
                    labelText: 'Border Radius (e.g., 12px)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: paddingController,
                  decoration: const InputDecoration(
                    labelText: 'Padding (e.g., 12px 24px)',
                    border: OutlineInputBorder(),
                  ),
                ),
                if (category == 'buttons') ...[
                  const SizedBox(height: 16),
                  TextField(
                    controller: fontSizeController,
                    decoration: const InputDecoration(
                      labelText: 'Font Size (e.g., 20px)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: fontWeightController,
                    decoration: const InputDecoration(
                      labelText: 'Font Weight (e.g., 500)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ],
                // Component States Section
                if (category == 'buttons' || category == 'inputs') ...[
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    'Component States',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Select which states this component supports:',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: availableStates.map((state) {
                      final isSelected = selectedStates.contains(state);
                      return FilterChip(
                        label: Text(state),
                        selected: isSelected,
                        avatar: Icon(
                          _getStateIcon(state),
                          size: 16,
                          color: isSelected ? Colors.white : null,
                        ),
                        onSelected: (selected) {
                          setDialogState(() {
                            if (selected) {
                              selectedStates.add(state);
                            } else {
                              selectedStates.remove(state);
                            }
                          });
                        },
                        selectedColor: _getStateColor(state),
                        checkmarkColor: Colors.white,
                      );
                    }).toList(),
                  ),
                ],
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
                if (nameController.text.isNotEmpty) {
                  final provider = Provider.of<DesignSystemProvider>(context, listen: false);
                  final components = provider.designSystem.components;
                  final updatedCategory = Map<String, dynamic>.from(
                    category == 'buttons'
                        ? components.buttons
                        : category == 'cards'
                            ? components.cards
                            : category == 'inputs'
                                ? components.inputs
                                : category == 'navigation'
                                    ? components.navigation
                                    : category == 'avatars'
                                        ? components.avatars
                                        : category == 'modals'
                                            ? (components.modals ?? {})
                                            : category == 'tables'
                                                ? (components.tables ?? {})
                                                : category == 'progress'
                                                    ? (components.progress ?? {})
                                                    : (components.alerts ?? {}),
                  );

                  final componentData = <String, dynamic>{
                    if (heightController.text.isNotEmpty) 'height': heightController.text,
                    if (borderRadiusController.text.isNotEmpty)
                      'borderRadius': borderRadiusController.text,
                    if (paddingController.text.isNotEmpty) 'padding': paddingController.text,
                    if (fontSizeController.text.isNotEmpty) 'fontSize': fontSizeController.text,
                    if (fontWeightController.text.isNotEmpty)
                      'fontWeight': int.tryParse(fontWeightController.text) ?? 400,
                  };

                  // Add states if any are selected
                  if (selectedStates.isNotEmpty) {
                    final statesMap = <String, dynamic>{};
                    for (final state in selectedStates) {
                      statesMap[state] = {
                        'enabled': true,
                        'description': '${state.substring(0, 1).toUpperCase()}${state.substring(1)} state',
                      };
                    }
                    componentData['states'] = statesMap;
                  }

                  updatedCategory[nameController.text] = componentData;

                  final updatedButtons = category == 'buttons' ? updatedCategory : components.buttons;
                  final updatedCards = category == 'cards' ? updatedCategory : components.cards;
                  final updatedInputs = category == 'inputs' ? updatedCategory : components.inputs;
                  final updatedNavigation = category == 'navigation' ? updatedCategory : components.navigation;
                  final updatedAvatars = category == 'avatars' ? updatedCategory : components.avatars;
                  final updatedModals = category == 'modals' ? updatedCategory : (components.modals ?? {});
                  final updatedTables = category == 'tables' ? updatedCategory : (components.tables ?? {});
                  final updatedProgress = category == 'progress' ? updatedCategory : (components.progress ?? {});
                  final updatedAlerts = category == 'alerts' ? updatedCategory : (components.alerts ?? {});

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
                    components: models.Components(
                      buttons: updatedButtons,
                      cards: updatedCards,
                      inputs: updatedInputs,
                      navigation: updatedNavigation,
                      avatars: updatedAvatars,
                      modals: updatedModals,
                      tables: updatedTables,
                      progress: updatedProgress,
                      alerts: updatedAlerts,
                    ),
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
                      content: Text('${category.substring(0, 1).toUpperCase()}${category.substring(1)} component "${nameController.text}" ${existingName != null ? 'updated' : 'added'}!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: Text(existingName != null ? 'Update' : 'Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditComponentDialog(
    BuildContext context,
    String category,
    String name,
    dynamic componentData,
  ) {
    _showComponentDialog(context, category, name, componentData);
  }

  void _deleteComponent(BuildContext context, String category, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Component'),
        content: Text('Are you sure you want to delete "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final provider = Provider.of<DesignSystemProvider>(context, listen: false);
              final components = provider.designSystem.components;
              final updatedCategory = Map<String, dynamic>.from(
                category == 'buttons'
                    ? components.buttons
                    : category == 'cards'
                        ? components.cards
                        : category == 'inputs'
                            ? components.inputs
                            : category == 'navigation'
                                ? components.navigation
                                : category == 'avatars'
                                    ? components.avatars
                                    : category == 'modals'
                                        ? (components.modals ?? {})
                                        : category == 'tables'
                                            ? (components.tables ?? {})
                                            : category == 'progress'
                                                ? (components.progress ?? {})
                                                : (components.alerts ?? {}),
              );
              updatedCategory.remove(name);

              final updatedButtons = category == 'buttons' ? updatedCategory : components.buttons;
              final updatedCards = category == 'cards' ? updatedCategory : components.cards;
              final updatedInputs = category == 'inputs' ? updatedCategory : components.inputs;
              final updatedNavigation = category == 'navigation' ? updatedCategory : components.navigation;
              final updatedAvatars = category == 'avatars' ? updatedCategory : components.avatars;
              final updatedModals = category == 'modals' ? updatedCategory : (components.modals ?? {});
              final updatedTables = category == 'tables' ? updatedCategory : (components.tables ?? {});
              final updatedProgress = category == 'progress' ? updatedCategory : (components.progress ?? {});
              final updatedAlerts = category == 'alerts' ? updatedCategory : (components.alerts ?? {});

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
                  components: models.Components(
                    buttons: updatedButtons,
                    cards: updatedCards,
                    inputs: updatedInputs,
                    navigation: updatedNavigation,
                    avatars: updatedAvatars,
                    modals: updatedModals,
                    tables: updatedTables,
                    progress: updatedProgress,
                    alerts: updatedAlerts,
                  ),
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
                  content: Text('Component "$name" deleted!'),
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
