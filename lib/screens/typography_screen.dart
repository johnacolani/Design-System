import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/design_system_provider.dart';
import '../models/design_system.dart' as models;
import 'home_screen.dart';

class TypographyScreen extends StatefulWidget {
  const TypographyScreen({super.key});

  @override
  State<TypographyScreen> createState() => _TypographyScreenState();
}

class _TypographyScreenState extends State<TypographyScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const HomeScreen()),
                (route) => false,
              );
            },
            tooltip: 'Home',
          ),
          title: const Text('Typography'),
          bottom: TabBar(
            onTap: (index) {
              setState(() {
                _selectedTab = index;
              });
            },
            tabs: const [
              Tab(icon: Icon(Icons.font_download), text: 'Font Family'),
              Tab(icon: Icon(Icons.format_bold), text: 'Font Weights'),
              Tab(icon: Icon(Icons.text_fields), text: 'Font Sizes'),
              Tab(icon: Icon(Icons.style), text: 'Text Styles'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildFontFamilyTab(),
            _buildFontWeightsTab(),
            _buildFontSizesTab(),
            _buildTextStylesTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildFontFamilyTab() {
    final provider = Provider.of<DesignSystemProvider>(context);
    final typography = provider.designSystem.typography;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Font Family',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        _showEditFontFamilyDialog(context);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildInfoRow('Primary Font', typography.fontFamily.primary),
                const Divider(),
                _buildInfoRow('Fallback Font', typography.fontFamily.fallback),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFontWeightsTab() {
    final provider = Provider.of<DesignSystemProvider>(context);
    final typography = provider.designSystem.typography;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Font Weights',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                _showAddFontWeightDialog(context);
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Weight'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (typography.fontWeights.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.format_bold_outlined, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'No font weights defined',
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
          Card(
            child: Column(
              children: typography.fontWeights.entries.map((entry) {
                return ListTile(
                  title: Text(entry.key),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        entry.value.toString(),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(width: 8),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert),
                        onSelected: (value) {
                          if (value == 'edit') {
                            _showEditFontWeightDialog(context, entry.key, entry.value);
                          } else if (value == 'delete') {
                            _deleteFontWeight(context, entry.key);
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
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildFontSizesTab() {
    final provider = Provider.of<DesignSystemProvider>(context);
    final typography = provider.designSystem.typography;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Font Sizes',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                _showAddFontSizeDialog(context);
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Size'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (typography.fontSizes.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.text_fields_outlined, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'No font sizes defined',
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
          ...typography.fontSizes.entries.map((entry) {
            final fontSize = entry.value;
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                title: Text(entry.key),
                subtitle: Text(
                  '${fontSize.value} / ${fontSize.lineHeight}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontFamily: 'monospace',
                  ),
                ),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showEditFontSizeDialog(context, entry.key, fontSize);
                    } else if (value == 'delete') {
                      _deleteFontSize(context, entry.key);
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
              ),
            );
          }),
      ],
    );
  }

  Widget _buildTextStylesTab() {
    final provider = Provider.of<DesignSystemProvider>(context);
    final typography = provider.designSystem.typography;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Text Styles',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                _showAddTextStyleDialog(context);
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Style'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (typography.textStyles.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.style_outlined, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'No text styles defined',
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
          ...typography.textStyles.entries.map((entry) {
            final style = entry.value;
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                title: Text(entry.key),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${style.fontSize} / ${style.fontWeight} / ${style.lineHeight}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sample Text',
                      style: TextStyle(
                        fontSize: _parseFontSize(style.fontSize),
                        fontWeight: FontWeight.values[style.fontWeight ~/ 100 - 1],
                        height: _parseLineHeight(style.lineHeight) / _parseFontSize(style.fontSize),
                      ),
                    ),
                  ],
                ),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showEditTextStyleDialog(context, entry.key, style);
                    } else if (value == 'delete') {
                      _deleteTextStyle(context, entry.key);
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
              ),
            );
          }),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(
            value,
            style: TextStyle(color: Colors.grey[600], fontFamily: 'monospace'),
          ),
        ],
      ),
    );
  }

  double _parseFontSize(String fontSize) {
    try {
      return double.parse(fontSize.replaceAll('px', ''));
    } catch (e) {
      return 14.0;
    }
  }

  double _parseLineHeight(String lineHeight) {
    try {
      return double.parse(lineHeight.replaceAll('px', ''));
    } catch (e) {
      return 20.0;
    }
  }

  void _showEditFontFamilyDialog(BuildContext context) {
    final provider = Provider.of<DesignSystemProvider>(context);
    final typography = provider.designSystem.typography;
    final primaryController = TextEditingController(text: typography.fontFamily.primary);
    final fallbackController = TextEditingController(text: typography.fontFamily.fallback);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Font Family'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: primaryController,
              decoration: const InputDecoration(
                labelText: 'Primary Font',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: fallbackController,
              decoration: const InputDecoration(
                labelText: 'Fallback Font',
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
                final updatedTypography = models.Typography(
                  fontFamily: models.FontFamily(
                  primary: primaryController.text,
                  fallback: fallbackController.text,
                ),
                fontWeights: typography.fontWeights,
                fontSizes: typography.fontSizes,
                textStyles: typography.textStyles,
              );
              provider.updateTypography(updatedTypography);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Font family updated!'),
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

  void _showAddFontWeightDialog(BuildContext context) {
    final nameController = TextEditingController();
    final weightController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Font Weight'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name (e.g., regular, bold)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: weightController,
              decoration: const InputDecoration(
                labelText: 'Weight (100-900)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
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
              if (nameController.text.isNotEmpty && weightController.text.isNotEmpty) {
                final provider = Provider.of<DesignSystemProvider>(context, listen: false);
                final typography = provider.designSystem.typography;
                final updatedWeights = Map<String, int>.from(typography.fontWeights);
                updatedWeights[nameController.text] = int.parse(weightController.text);

                final updatedTypography = models.Typography(
                  fontFamily: typography.fontFamily,
                  fontWeights: updatedWeights,
                  fontSizes: typography.fontSizes,
                  textStyles: typography.textStyles,
                );
                provider.updateTypography(updatedTypography);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Font weight "${nameController.text}" added!'),
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

  void _showEditFontWeightDialog(BuildContext context, String name, int weight) {
    final nameController = TextEditingController(text: name);
    final weightController = TextEditingController(text: weight.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Font Weight'),
        content: Column(
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
              controller: weightController,
              decoration: const InputDecoration(
                labelText: 'Weight (100-900)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
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
              if (nameController.text.isNotEmpty && weightController.text.isNotEmpty) {
                final provider = Provider.of<DesignSystemProvider>(context, listen: false);
                final typography = provider.designSystem.typography;
                final updatedWeights = Map<String, int>.from(typography.fontWeights);
                if (name != nameController.text) {
                  updatedWeights.remove(name);
                }
                updatedWeights[nameController.text] = int.parse(weightController.text);

                final updatedTypography = models.Typography(
                  fontFamily: typography.fontFamily,
                  fontWeights: updatedWeights,
                  fontSizes: typography.fontSizes,
                  textStyles: typography.textStyles,
                );
                provider.updateTypography(updatedTypography);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Font weight updated!'),
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

  void _deleteFontWeight(BuildContext context, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Font Weight'),
        content: Text('Are you sure you want to delete "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final provider = Provider.of<DesignSystemProvider>(context, listen: false);
              final typography = provider.designSystem.typography;
              final updatedWeights = Map<String, int>.from(typography.fontWeights);
              updatedWeights.remove(name);

              final updatedTypography = models.Typography(
                fontFamily: typography.fontFamily,
                fontWeights: updatedWeights,
                fontSizes: typography.fontSizes,
                textStyles: typography.textStyles,
              );
              provider.updateTypography(updatedTypography);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Font weight "$name" deleted!'),
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

  void _showAddFontSizeDialog(BuildContext context) {
    final nameController = TextEditingController();
    final sizeController = TextEditingController();
    final lineHeightController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Font Size'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name (e.g., base, lg)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: sizeController,
                decoration: const InputDecoration(
                  labelText: 'Size (e.g., 14px)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: lineHeightController,
                decoration: const InputDecoration(
                  labelText: 'Line Height (e.g., 20px)',
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
                  sizeController.text.isNotEmpty &&
                  lineHeightController.text.isNotEmpty) {
                final provider = Provider.of<DesignSystemProvider>(context, listen: false);
                final typography = provider.designSystem.typography;
                final updatedSizes = Map<String, models.FontSize>.from(typography.fontSizes);
                updatedSizes[nameController.text] = models.FontSize(
                  value: sizeController.text,
                  lineHeight: lineHeightController.text,
                  description: descriptionController.text.isEmpty
                      ? null
                      : descriptionController.text,
                );

                final updatedTypography = models.Typography(
                  fontFamily: typography.fontFamily,
                  fontWeights: typography.fontWeights,
                  fontSizes: updatedSizes,
                  textStyles: typography.textStyles,
                );
                provider.updateTypography(updatedTypography);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Font size "${nameController.text}" added!'),
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

  void _showEditFontSizeDialog(BuildContext context, String name, models.FontSize fontSize) {
    final nameController = TextEditingController(text: name);
    final sizeController = TextEditingController(text: fontSize.value);
    final lineHeightController = TextEditingController(text: fontSize.lineHeight);
    final descriptionController = TextEditingController(text: fontSize.description ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Font Size'),
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
                controller: sizeController,
                decoration: const InputDecoration(
                  labelText: 'Size',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: lineHeightController,
                decoration: const InputDecoration(
                  labelText: 'Line Height',
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
                  sizeController.text.isNotEmpty &&
                  lineHeightController.text.isNotEmpty) {
                final provider = Provider.of<DesignSystemProvider>(context, listen: false);
                final typography = provider.designSystem.typography;
                final updatedSizes = Map<String, models.FontSize>.from(typography.fontSizes);
                if (name != nameController.text) {
                  updatedSizes.remove(name);
                }
                updatedSizes[nameController.text] = models.FontSize(
                  value: sizeController.text,
                  lineHeight: lineHeightController.text,
                  description: descriptionController.text.isEmpty
                      ? null
                      : descriptionController.text,
                );

                final updatedTypography = models.Typography(
                  fontFamily: typography.fontFamily,
                  fontWeights: typography.fontWeights,
                  fontSizes: updatedSizes,
                  textStyles: typography.textStyles,
                );
                provider.updateTypography(updatedTypography);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Font size updated!'),
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

  void _deleteFontSize(BuildContext context, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Font Size'),
        content: Text('Are you sure you want to delete "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final provider = Provider.of<DesignSystemProvider>(context, listen: false);
              final typography = provider.designSystem.typography;
              final updatedSizes = Map<String, models.FontSize>.from(typography.fontSizes);
              updatedSizes.remove(name);

              final updatedTypography = models.Typography(
                fontFamily: typography.fontFamily,
                fontWeights: typography.fontWeights,
                fontSizes: updatedSizes,
                textStyles: typography.textStyles,
              );
              provider.updateTypography(updatedTypography);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Font size "$name" deleted!'),
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

  void _showAddTextStyleDialog(BuildContext context) {
    final provider = Provider.of<DesignSystemProvider>(context);
    final typography = provider.designSystem.typography;

    final nameController = TextEditingController();
    String? selectedFontFamily = typography.fontFamily.primary;
    String? selectedFontSize;
    int selectedFontWeight = 400;
    String? selectedLineHeight;
    final colorController = TextEditingController();
    String? selectedTextDecoration;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Text Style'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Style Name (e.g., h1, body)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedFontFamily,
                  decoration: const InputDecoration(
                    labelText: 'Font Family',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: typography.fontFamily.primary,
                      child: Text(typography.fontFamily.primary),
                    ),
                    DropdownMenuItem(
                      value: typography.fontFamily.fallback,
                      child: Text(typography.fontFamily.fallback),
                    ),
                  ],
                  onChanged: (value) {
                    setDialogState(() {
                      selectedFontFamily = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedFontSize,
                  decoration: const InputDecoration(
                    labelText: 'Font Size',
                    border: OutlineInputBorder(),
                  ),
                  items: typography.fontSizes.entries.map((entry) {
                    return DropdownMenuItem(
                      value: entry.value.value,
                      child: Text('${entry.key}: ${entry.value.value}'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      selectedFontSize = value;
                      if (value != null) {
                        final fontSize = typography.fontSizes.values.firstWhere(
                          (fs) => fs.value == value,
                        );
                        selectedLineHeight = fontSize.lineHeight;
                      }
                    });
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  value: selectedFontWeight,
                  decoration: const InputDecoration(
                    labelText: 'Font Weight',
                    border: OutlineInputBorder(),
                  ),
                  items: typography.fontWeights.entries.map((entry) {
                    return DropdownMenuItem(
                      value: entry.value,
                      child: Text('${entry.key}: ${entry.value}'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      selectedFontWeight = value ?? 400;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: colorController,
                  decoration: const InputDecoration(
                    labelText: 'Color (Optional, e.g., #000000)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedTextDecoration,
                  decoration: const InputDecoration(
                    labelText: 'Text Decoration (Optional)',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('None')),
                    DropdownMenuItem(value: 'underline', child: Text('Underline')),
                    DropdownMenuItem(value: 'line-through', child: Text('Line Through')),
                  ],
                  onChanged: (value) {
                    setDialogState(() {
                      selectedTextDecoration = value;
                    });
                  },
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
                    selectedFontSize != null &&
                    selectedLineHeight != null) {
                final updatedStyles = Map<String, models.TextStyle>.from(typography.textStyles);
                updatedStyles[nameController.text] = models.TextStyle(
                    fontFamily: selectedFontFamily ?? '',
                    fontSize: selectedFontSize ?? '',
                    fontWeight: selectedFontWeight,
                    lineHeight: selectedLineHeight ?? '',
                    color: colorController.text.isEmpty ? null : colorController.text,
                    textDecoration: selectedTextDecoration,
                  );

                  final updatedTypography = models.Typography(
                    fontFamily: typography.fontFamily,
                    fontWeights: typography.fontWeights,
                    fontSizes: typography.fontSizes,
                    textStyles: updatedStyles,
                  );
                  provider.updateTypography(updatedTypography);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Text style "${nameController.text}" added!'),
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

  void _showEditTextStyleDialog(BuildContext context, String name, models.TextStyle style) {
    final provider = Provider.of<DesignSystemProvider>(context);
    final typography = provider.designSystem.typography;

    final nameController = TextEditingController(text: name);
    String? selectedFontFamily = style.fontFamily;
    String? selectedFontSize = style.fontSize;
    int selectedFontWeight = style.fontWeight;
    String? selectedLineHeight = style.lineHeight;
    final colorController = TextEditingController(text: style.color ?? '');
    String? selectedTextDecoration = style.textDecoration;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Text Style'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Style Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedFontFamily,
                  decoration: const InputDecoration(
                    labelText: 'Font Family',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: typography.fontFamily.primary,
                      child: Text(typography.fontFamily.primary),
                    ),
                    DropdownMenuItem(
                      value: typography.fontFamily.fallback,
                      child: Text(typography.fontFamily.fallback),
                    ),
                  ],
                  onChanged: (value) {
                    setDialogState(() {
                      selectedFontFamily = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedFontSize,
                  decoration: const InputDecoration(
                    labelText: 'Font Size',
                    border: OutlineInputBorder(),
                  ),
                  items: typography.fontSizes.entries.map((entry) {
                    return DropdownMenuItem(
                      value: entry.value.value,
                      child: Text('${entry.key}: ${entry.value.value}'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      selectedFontSize = value;
                      if (value != null) {
                        final fontSize = typography.fontSizes.values.firstWhere(
                          (fs) => fs.value == value,
                        );
                        selectedLineHeight = fontSize.lineHeight;
                      }
                    });
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  value: selectedFontWeight,
                  decoration: const InputDecoration(
                    labelText: 'Font Weight',
                    border: OutlineInputBorder(),
                  ),
                  items: typography.fontWeights.entries.map((entry) {
                    return DropdownMenuItem(
                      value: entry.value,
                      child: Text('${entry.key}: ${entry.value}'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      selectedFontWeight = value ?? 400;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: colorController,
                  decoration: const InputDecoration(
                    labelText: 'Color (Optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedTextDecoration,
                  decoration: const InputDecoration(
                    labelText: 'Text Decoration',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('None')),
                    DropdownMenuItem(value: 'underline', child: Text('Underline')),
                    DropdownMenuItem(value: 'line-through', child: Text('Line Through')),
                  ],
                  onChanged: (value) {
                    setDialogState(() {
                      selectedTextDecoration = value;
                    });
                  },
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
                    selectedFontSize != null &&
                    selectedLineHeight != null) {
                  final updatedStyles = Map<String, models.TextStyle>.from(typography.textStyles);
                  if (name != nameController.text) {
                    updatedStyles.remove(name);
                  }
                  updatedStyles[nameController.text] = models.TextStyle(
                    fontFamily: selectedFontFamily ?? '',
                    fontSize: selectedFontSize ?? '',
                    fontWeight: selectedFontWeight,
                    lineHeight: selectedLineHeight ?? '',
                    color: colorController.text.isEmpty ? null : colorController.text,
                    textDecoration: selectedTextDecoration,
                  );

                  final updatedTypography = models.Typography(
                    fontFamily: typography.fontFamily,
                    fontWeights: typography.fontWeights,
                    fontSizes: typography.fontSizes,
                    textStyles: updatedStyles,
                  );
                  provider.updateTypography(updatedTypography);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Text style updated!'),
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

  void _deleteTextStyle(BuildContext context, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Text Style'),
        content: Text('Are you sure you want to delete "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final provider = Provider.of<DesignSystemProvider>(context, listen: false);
              final typography = provider.designSystem.typography;
              final updatedStyles = Map<String, models.TextStyle>.from(typography.textStyles);
              updatedStyles.remove(name);

              final updatedTypography = models.Typography(
                fontFamily: typography.fontFamily,
                fontWeights: typography.fontWeights,
                fontSizes: typography.fontSizes,
                textStyles: updatedStyles,
              );
              provider.updateTypography(updatedTypography);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Text style "$name" deleted!'),
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
