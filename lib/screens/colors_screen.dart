import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import '../providers/design_system_provider.dart';
import '../models/design_system.dart' as models;

class ColorsScreen extends StatefulWidget {
  const ColorsScreen({super.key});

  @override
  State<ColorsScreen> createState() => _ColorsScreenState();
}

class _ColorsScreenState extends State<ColorsScreen> {
  String _selectedCategory = 'primary';

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DesignSystemProvider>(context);
    final colors = provider.designSystem.colors;

    final categories = [
      {'key': 'primary', 'name': 'Primary Colors', 'color': Colors.deepPurple},
      {'key': 'semantic', 'name': 'Semantic Colors', 'color': Colors.blue},
      if (colors.blue != null)
        {'key': 'blue', 'name': 'Blue Palette', 'color': Colors.blue},
      if (colors.green != null)
        {'key': 'green', 'name': 'Green Palette', 'color': Colors.green},
      if (colors.orange != null)
        {'key': 'orange', 'name': 'Orange Palette', 'color': Colors.orange},
      if (colors.purple != null)
        {'key': 'purple', 'name': 'Purple Palette', 'color': Colors.purple},
      if (colors.red != null)
        {'key': 'red', 'name': 'Red Palette', 'color': Colors.red},
      if (colors.grey != null)
        {'key': 'grey', 'name': 'Grey Palette', 'color': Colors.grey},
    ];

    Map<String, dynamic> currentCategory = colors.primary;
    Color accentColor = Colors.deepPurple;

    switch (_selectedCategory) {
      case 'primary':
        currentCategory = colors.primary;
        accentColor = Colors.deepPurple;
        break;
      case 'semantic':
        currentCategory = colors.semantic;
        accentColor = Colors.blue;
        break;
      case 'blue':
        currentCategory = colors.blue ?? {};
        accentColor = Colors.blue;
        break;
      case 'green':
        currentCategory = colors.green ?? {};
        accentColor = Colors.green;
        break;
      case 'orange':
        currentCategory = colors.orange ?? {};
        accentColor = Colors.orange;
        break;
      case 'purple':
        currentCategory = colors.purple ?? {};
        accentColor = Colors.purple;
        break;
      case 'red':
        currentCategory = colors.red ?? {};
        accentColor = Colors.red;
        break;
      case 'grey':
        currentCategory = colors.grey ?? {};
        accentColor = Colors.grey;
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Colors'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (category) {
              setState(() {
                _selectedCategory = category;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'primary', child: Text('Primary Colors')),
              const PopupMenuItem(value: 'semantic', child: Text('Semantic Colors')),
              if (colors.blue != null)
                const PopupMenuItem(value: 'blue', child: Text('Blue Palette')),
              if (colors.green != null)
                const PopupMenuItem(value: 'green', child: Text('Green Palette')),
              if (colors.orange != null)
                const PopupMenuItem(value: 'orange', child: Text('Orange Palette')),
              if (colors.purple != null)
                const PopupMenuItem(value: 'purple', child: Text('Purple Palette')),
              if (colors.red != null)
                const PopupMenuItem(value: 'red', child: Text('Red Palette')),
              if (colors.grey != null)
                const PopupMenuItem(value: 'grey', child: Text('Grey Palette')),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'add_category',
                child: Row(
                  children: [
                    Icon(Icons.add, size: 18),
                    SizedBox(width: 8),
                    Text('Add Category'),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showAddColorDialog(context, _selectedCategory);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: accentColor.withOpacity(0.1),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 24,
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    categories.firstWhere((c) => c['key'] == _selectedCategory)['name'] as String,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: currentCategory.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.palette_outlined, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No colors in this category',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: () {
                            _showAddColorDialog(context, _selectedCategory);
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Add Color'),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: currentCategory.length,
                    itemBuilder: (context, index) {
                      final entry = currentCategory.entries.elementAt(index);
                      return _buildColorCard(context, entry.key, entry.value, _selectedCategory);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorCard(
    BuildContext context,
    String name,
    dynamic colorData,
    String category,
  ) {
    Color color;
    String description = '';

    if (colorData is Map) {
      final value = colorData['value'] as String? ?? '#000000';
      color = _parseColor(value);
      description = colorData['description'] as String? ?? '';
    } else {
      color = Colors.grey;
    }

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          _showEditColorDialog(context, name, colorData, category);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                height: 100,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, size: 18),
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showEditColorDialog(context, name, colorData, category);
                      } else if (value == 'delete') {
                        _deleteColor(context, name, category);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 18),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 18, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                _colorToHex(color),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                      fontFamily: 'monospace',
                    ),
              ),
              if (description.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _parseColor(String colorString) {
    try {
      if (colorString.startsWith('#')) {
        return Color(int.parse(colorString.substring(1), radix: 16) + 0xFF000000);
      } else if (colorString.startsWith('rgba')) {
        final matches = RegExp(r'rgba\((\d+),\s*(\d+),\s*(\d+),\s*([\d.]+)\)')
            .firstMatch(colorString);
        if (matches != null) {
          return Color.fromRGBO(
            int.parse(matches.group(1)!),
            int.parse(matches.group(2)!),
            int.parse(matches.group(3)!),
            double.parse(matches.group(4)!),
          );
        }
      }
    } catch (e) {
      // Invalid color
    }
    return Colors.grey;
  }

  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  void _showAddColorDialog(BuildContext context, String category) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    Color selectedColor = Colors.blue;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Color'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Color Name',
                    hintText: 'e.g., primaryBlue',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (Optional)',
                    hintText: 'Describe this color',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                const Text('Pick Color:', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: ColorPicker(
                    pickerColor: selectedColor,
                    onColorChanged: (color) {
                      setDialogState(() {
                        selectedColor = color;
                      });
                    },
                    displayThumbColor: true,
                    enableAlpha: true,
                    pickerAreaHeightPercent: 0.8,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: selectedColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _colorToHex(selectedColor),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
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
                if (nameController.text.isNotEmpty) {
                  _addColor(
                    context,
                    category,
                    nameController.text,
                    selectedColor,
                    descriptionController.text,
                  );
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditColorDialog(
    BuildContext context,
    String name,
    dynamic colorData,
    String category,
  ) {
    final nameController = TextEditingController(text: name);
    final descriptionController = TextEditingController(
      text: colorData is Map ? (colorData['description'] as String? ?? '') : '',
    );
    Color selectedColor = Colors.blue;

    if (colorData is Map) {
      final value = colorData['value'] as String? ?? '#000000';
      selectedColor = _parseColor(value);
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Color'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Color Name',
                    border: OutlineInputBorder(),
                  ),
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
                const SizedBox(height: 16),
                const Text('Pick Color:', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: ColorPicker(
                    pickerColor: selectedColor,
                    onColorChanged: (color) {
                      setDialogState(() {
                        selectedColor = color;
                      });
                    },
                    displayThumbColor: true,
                    enableAlpha: true,
                    pickerAreaHeightPercent: 0.8,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: selectedColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _colorToHex(selectedColor),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
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
                if (nameController.text.isNotEmpty) {
                  _updateColor(
                    context,
                    category,
                    name,
                    nameController.text,
                    selectedColor,
                    descriptionController.text,
                  );
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _addColor(
    BuildContext context,
    String category,
    String name,
    Color color,
    String description,
  ) {
    final provider = Provider.of<DesignSystemProvider>(context, listen: false);
    final colors = provider.designSystem.colors;
    final colorHex = _colorToHex(color);

    final colorData = {
      'value': colorHex,
      'type': 'color',
      'description': description,
    };

    Map<String, dynamic> updatedCategory = {};
    switch (category) {
      case 'primary':
        updatedCategory = Map<String, dynamic>.from(colors.primary);
        updatedCategory[name] = colorData;
        provider.updateColors(models.Colors(
          primary: updatedCategory,
          semantic: colors.semantic,
          blue: colors.blue,
          green: colors.green,
          orange: colors.orange,
          purple: colors.purple,
          red: colors.red,
          grey: colors.grey,
          white: colors.white,
          text: colors.text,
          input: colors.input,
          roleSpecific: colors.roleSpecific,
        ));
        break;
      case 'semantic':
        updatedCategory = Map<String, dynamic>.from(colors.semantic);
        updatedCategory[name] = colorData;
        provider.updateColors(models.Colors(
          primary: colors.primary,
          semantic: updatedCategory,
          blue: colors.blue,
          green: colors.green,
          orange: colors.orange,
          purple: colors.purple,
          red: colors.red,
          grey: colors.grey,
          white: colors.white,
          text: colors.text,
          input: colors.input,
          roleSpecific: colors.roleSpecific,
        ));
        break;
      // Add other categories similarly
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Color "$name" added successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _updateColor(
    BuildContext context,
    String category,
    String oldName,
    String newName,
    Color color,
    String description,
  ) {
    final provider = Provider.of<DesignSystemProvider>(context, listen: false);
    final colors = provider.designSystem.colors;
    final colorHex = _colorToHex(color);

    final colorData = {
      'value': colorHex,
      'type': 'color',
      'description': description,
    };

    Map<String, dynamic> updatedCategory = {};
    switch (category) {
      case 'primary':
        updatedCategory = Map<String, dynamic>.from(colors.primary);
        if (oldName != newName) {
          updatedCategory.remove(oldName);
        }
        updatedCategory[newName] = colorData;
        provider.updateColors(models.Colors(
          primary: updatedCategory,
          semantic: colors.semantic,
          blue: colors.blue,
          green: colors.green,
          orange: colors.orange,
          purple: colors.purple,
          red: colors.red,
          grey: colors.grey,
          white: colors.white,
          text: colors.text,
          input: colors.input,
          roleSpecific: colors.roleSpecific,
        ));
        break;
      case 'semantic':
        updatedCategory = Map<String, dynamic>.from(colors.semantic);
        if (oldName != newName) {
          updatedCategory.remove(oldName);
        }
        updatedCategory[newName] = colorData;
        provider.updateColors(models.Colors(
          primary: colors.primary,
          semantic: updatedCategory,
          blue: colors.blue,
          green: colors.green,
          orange: colors.orange,
          purple: colors.purple,
          red: colors.red,
          grey: colors.grey,
          white: colors.white,
          text: colors.text,
          input: colors.input,
          roleSpecific: colors.roleSpecific,
        ));
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Color "$newName" updated successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _deleteColor(BuildContext context, String name, String category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Color'),
        content: Text('Are you sure you want to delete "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final provider = Provider.of<DesignSystemProvider>(context, listen: false);
              final colors = provider.designSystem.colors;

              Map<String, dynamic> updatedCategory = {};
              switch (category) {
                case 'primary':
                  updatedCategory = Map<String, dynamic>.from(colors.primary);
                  updatedCategory.remove(name);
                  provider.updateColors(models.Colors(
                    primary: updatedCategory,
                    semantic: colors.semantic,
                    blue: colors.blue,
                    green: colors.green,
                    orange: colors.orange,
                    purple: colors.purple,
                    red: colors.red,
                    grey: colors.grey,
                    white: colors.white,
                    text: colors.text,
                    input: colors.input,
                    roleSpecific: colors.roleSpecific,
                  ));
                  break;
                case 'semantic':
                  updatedCategory = Map<String, dynamic>.from(colors.semantic);
                  updatedCategory.remove(name);
                  provider.updateColors(models.Colors(
                    primary: colors.primary,
                    semantic: updatedCategory,
                    blue: colors.blue,
                    green: colors.green,
                    orange: colors.orange,
                    purple: colors.purple,
                    red: colors.red,
                    grey: colors.grey,
                    white: colors.white,
                    text: colors.text,
                    input: colors.input,
                    roleSpecific: colors.roleSpecific,
                  ));
                  break;
              }

              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Color "$name" deleted successfully!'),
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
