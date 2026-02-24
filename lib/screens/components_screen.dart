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
                _selectedCategory = ['buttons', 'cards', 'inputs', 'navigation', 'avatars'][index];
              });
            },
            tabs: const [
              Tab(icon: Icon(Icons.smart_button), text: 'Buttons'),
              Tab(icon: Icon(Icons.credit_card), text: 'Cards'),
              Tab(icon: Icon(Icons.input), text: 'Inputs'),
              Tab(icon: Icon(Icons.navigation), text: 'Navigation'),
              Tab(icon: Icon(Icons.person), text: 'Avatars'),
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
                      'No ${category} defined',
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
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(name),
        subtitle: Text('$category component'),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (componentData is Map)
                  ...componentData.entries.map((entry) {
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

  void _showAddComponentDialog(BuildContext context, String category) {
    final nameController = TextEditingController();
    final heightController = TextEditingController();
    final borderRadiusController = TextEditingController();
    final paddingController = TextEditingController();
    final fontSizeController = TextEditingController();
    final fontWeightController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add ${category.substring(0, 1).toUpperCase()}${category.substring(1)} Component'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                                  : components.avatars,
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

                updatedCategory[nameController.text] = componentData;

                final updatedButtons = category == 'buttons'
                    ? updatedCategory
                    : components.buttons;
                final updatedCards = category == 'cards' ? updatedCategory : components.cards;
                final updatedInputs =
                    category == 'inputs' ? updatedCategory : components.inputs;
                final updatedNavigation = category == 'navigation'
                    ? updatedCategory
                    : components.navigation;
                final updatedAvatars =
                    category == 'avatars' ? updatedCategory : components.avatars;

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
                  ),
                  grid: provider.designSystem.grid,
                  icons: provider.designSystem.icons,
                  gradients: provider.designSystem.gradients,
                  roles: provider.designSystem.roles,
                ));

                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${category.substring(0, 1).toUpperCase()}${category.substring(1)} component "${nameController.text}" added!'),
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

  void _showEditComponentDialog(
    BuildContext context,
    String category,
    String name,
    dynamic componentData,
  ) {
    // Similar to add dialog but with pre-filled values
    _showAddComponentDialog(context, category);
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
                                : components.avatars,
              );
              updatedCategory.remove(name);

              final updatedButtons = category == 'buttons'
                  ? updatedCategory
                  : components.buttons;
              final updatedCards = category == 'cards' ? updatedCategory : components.cards;
              final updatedInputs =
                  category == 'inputs' ? updatedCategory : components.inputs;
              final updatedNavigation = category == 'navigation'
                  ? updatedCategory
                  : components.navigation;
              final updatedAvatars =
                  category == 'avatars' ? updatedCategory : components.avatars;

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
                ),
                grid: provider.designSystem.grid,
                icons: provider.designSystem.icons,
                gradients: provider.designSystem.gradients,
                roles: provider.designSystem.roles,
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
