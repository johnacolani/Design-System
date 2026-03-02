import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/design_system_provider.dart';
import '../models/design_system.dart' as models;
import '../services/color_palette_service.dart';
import '../utils/screen_body_padding.dart';
import 'color_picker_screen.dart';
import 'semantic_tokens_screen.dart';

class ColorsScreen extends StatefulWidget {
  const ColorsScreen({super.key});

  @override
  State<ColorsScreen> createState() => _ColorsScreenState();
}

class _ColorsScreenState extends State<ColorsScreen> {
  String _selectedCategory = 'primary';
  Color? _editDialogSelectedColor;

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

    Map<String, dynamic> currentCategory;
    Color accentColor;

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
      default:
        currentCategory = {}; // Fallback for unknown category
        accentColor = Colors.grey; // Fallback for unknown category
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Navigate back to Dashboard (preserve navigation stack)
            Navigator.of(context).pop();
          },
          tooltip: 'Back to Design Tokens',
        ),
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
      body: ScreenBodyPadding(
        verticalPadding: 0,
        child: Column(
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
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: currentCategory.length,
                      itemBuilder: (context, index) {
                        final entry = currentCategory.entries.elementAt(index);
                        return _buildColorRow(context, entry.key, entry.value, _selectedCategory);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorRow(
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
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          _showEditColorDialog(context, name, colorData, category);
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              SizedBox(
                width: 80,
                child: Text(
                  _colorToHex(color),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[800],
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 120,
                height: 40,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.grey.shade300, width: 1),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    if (description.isNotEmpty)
                      Text(
                        description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                              fontSize: 11,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, size: 20),
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
    return '#${color.value.toRadixString(16).toUpperCase().substring(2)}';
  }

  Color _getContrastColor(Color color) {
    // Calculate relative luminance using component accessors
    final luminance = (0.299 * color.red + 0.587 * color.green + 0.114 * color.blue);
    return luminance > 128 ? Colors.black : Colors.white; // Adjusted threshold for 0-255 range
  }

  void _showAddColorDialog(BuildContext context, String category) {
    _showAddColorDialogWithColor(context, category, Colors.blue, '', '');
  }

  void _showAddColorDialogWithColor(
    BuildContext context,
    String category,
    Color initialColor,
    String initialName,
    String initialDescription,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        final nameController = TextEditingController(text: initialName);
        final descriptionController = TextEditingController(text: initialDescription);
        Color selectedColor = initialColor;
        Map<String, String>? storedPrimaryToDark;
        Map<String, String>? storedPrimaryToLight;
        List<ColorSuggestion>? storedSuggestions;
        
        return StatefulBuilder(
          builder: (stContext, setDialogState) {
            return AlertDialog(
              title: Text(category == 'semantic' ? 'Add Semantic Color' : 'Add Color'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (category == 'semantic') ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue[200]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'About Semantic Colors',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[900],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Semantic colors represent meaning (e.g., "success", "error", "warning"). '
                              'Pick a color below, then map it to semantic tokens in the Semantic Tokens screen.',
                              style: TextStyle(
                                color: Colors.blue[800],
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextButton.icon(
                              onPressed: () {
                                Navigator.of(stContext).pop(); // Close this dialog
                                Navigator.of(stContext).push(
                                  MaterialPageRoute(
                                    builder: (_) => const SemanticTokensScreen(),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.link, size: 16),
                              label: const Text('Go to Semantic Tokens'),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: category == 'semantic' ? 'Semantic Color Name' : 'Color Name',
                        hintText: category == 'semantic' ? 'e.g., success, error, warning' : 'e.g., primaryBlue',
                        border: const OutlineInputBorder(),
                        helperText: category == 'semantic' 
                            ? 'Use meaningful names like "success", "error", "info"'
                            : null,
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
                    ElevatedButton.icon(
                      onPressed: () async {
                        // Store values before navigating
                        final name = nameController.text;
                        final description = descriptionController.text;
                        
                        // Navigate to color picker WITHOUT closing dialog
                        final result = await Navigator.of(stContext).push<Map<String, dynamic>>(
                          MaterialPageRoute(
                            builder: (_) => ColorPickerScreen(
                              category: category,
                            ),
                          ),
                        );
                        
                        if (result != null && stContext.mounted) {
                          // Get the selected color
                          Color? pickedColor;
                          Map<String, String>? primaryToDark;
                          Map<String, String>? primaryToLight;
                          List<ColorSuggestion>? suggestions;
                          
                          // Check if multiple colors were selected
                          if (result.containsKey('colors') && (result['colors'] as List).isNotEmpty) {
                            final colorsList = result['colors'] as List<Color>;
                            pickedColor = colorsList.first; // Use first color for display
                            primaryToDark = result['primaryToDark'] as Map<String, String>?;
                            primaryToLight = result['primaryToLight'] as Map<String, String>?;
                            suggestions = result['suggestions'] as List<ColorSuggestion>?;
                            
                            // If name is provided and multiple colors, add all directly
                            if (name.isNotEmpty && colorsList.length > 1) {
                              Navigator.of(stContext).pop(); // Close dialog
                              
                              // Add each color with auto-generated name
                              for (int i = 0; i < colorsList.length; i++) {
                                final color = colorsList[i];
                                final colorName = '$name ${i + 1}';
                                
                                _addColorWithScales(
                                  stContext,
                                  colorName,
                                  description,
                                  color,
                                  primaryToDark ?? {},
                                  primaryToLight ?? {},
                                  suggestions ?? [],
                                  category,
                                );
                              }
                              
                              if (stContext.mounted) {
                                ScaffoldMessenger.of(stContext).showSnackBar(
                                  SnackBar(
                                    content: Text('Added ${colorsList.length} color${colorsList.length > 1 ? 's' : ''}'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                              return;
                            }
                          } else if (result.containsKey('color')) {
                            // Single color
                            pickedColor = result['color'] as Color?;
                            primaryToDark = result['primaryToDark'] as Map<String, String>?;
                            primaryToLight = result['primaryToLight'] as Map<String, String>?;
                            suggestions = result['suggestions'] as List<ColorSuggestion>?;
                          }
                          
                          if (pickedColor != null) {
                            // Update the dialog state to show selected color and store scales
                            setDialogState(() {
                              selectedColor = pickedColor!;
                              storedPrimaryToDark = primaryToDark;
                              storedPrimaryToLight = primaryToLight;
                              storedSuggestions = suggestions;
                            });
                          }
                        }
                      },
                      icon: const Icon(Icons.palette),
                      label: Text(category == 'semantic' 
                          ? 'Browse Palettes & Pick Semantic Color'
                          : 'Browse Color Palettes & Get Suggestions'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text('Or pick color:', style: TextStyle(fontWeight: FontWeight.w600)),
                        if (category == 'semantic') ...[
                          const SizedBox(width: 8),
                          Tooltip(
                            message: 'Tap the color box below to open the color picker',
                            child: Icon(Icons.help_outline, size: 16, color: Colors.grey[600]),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Hex color input field
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              labelText: 'Or paste hex color',
                              hintText: '#FF5733',
                              prefixIcon: const Icon(Icons.color_lens, size: 20),
                              border: const OutlineInputBorder(),
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            ),
                            onChanged: (value) {
                              if (value.isNotEmpty && value.startsWith('#')) {
                                try {
                                  final color = _parseColor(value);
                                  setDialogState(() {
                                    selectedColor = color;
                                  });
                                } catch (e) {
                                  // Invalid color, ignore
                                }
                              }
                            },
                            onSubmitted: (value) {
                              if (value.isNotEmpty && value.startsWith('#')) {
                                try {
                                  final color = _parseColor(value);
                                  setDialogState(() {
                                    selectedColor = color;
                                  });
                                } catch (e) {
                                  // Invalid color, ignore
                                }
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: selectedColor,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[300]!, width: 2),
                          ),
                          child: Center(
                            child: Text(
                              _colorToHex(selectedColor).substring(1),
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: _getContrastColor(selectedColor),
                                fontFamily: 'monospace',
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () async {
                        final result = await Navigator.of(stContext).push<Map<String, dynamic>>(
                          MaterialPageRoute(
                            builder: (_) => const ColorPickerScreen(),
                          ),
                        );
                        if (result != null && result['color'] != null && stContext.mounted) {
                          setDialogState(() {
                            selectedColor = result['color'] as Color;
                          });
                        }
                      },
                      child: Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: selectedColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!, width: 2),
                        ),
                        child: Stack(
                          children: [
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.colorize, size: 48, color: Colors.white),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Tap to pick color',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              bottom: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  _colorToHex(selectedColor),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'monospace',
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(stContext).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (nameController.text.isNotEmpty) {
                      // Use stored scales if available (from color picker), otherwise generate new ones
                      final primaryToDark = storedPrimaryToDark ?? ColorPaletteService.generatePrimaryToDark(selectedColor, steps: 10);
                      final primaryToLight = storedPrimaryToLight ?? ColorPaletteService.generatePrimaryToLight(selectedColor, steps: 10);
                      final suggestions = storedSuggestions ?? [];
                      
                      _addColorWithScales(
                        stContext,
                        nameController.text,
                        descriptionController.text,
                        selectedColor,
                        primaryToDark,
                        primaryToLight,
                        suggestions,
                        category,
                      );
                      Navigator.of(stContext).pop();
                      
                      // Show helpful message for semantic colors
                      if (category == 'semantic' && stContext.mounted) {
                        // Hide any existing snackbars first
                        ScaffoldMessenger.of(stContext).hideCurrentSnackBar();
                        
                        // Use a timer to ensure it dismisses even if user navigates
                        Future.delayed(const Duration(seconds: 4), () {
                          if (stContext.mounted) {
                            ScaffoldMessenger.of(stContext).hideCurrentSnackBar();
                          }
                        });
                        
                        ScaffoldMessenger.of(stContext).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(Icons.check_circle, color: Colors.white),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text(
                                        'Semantic color added!',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        'Go to Semantic Tokens to map it to base colors',
                                        style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.9)),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            backgroundColor: Colors.green,
                            duration: const Duration(seconds: 4),
                            behavior: SnackBarBehavior.floating,
                            action: SnackBarAction(
                              label: 'Go to Tokens',
                              textColor: Colors.white,
                              onPressed: () {
                                ScaffoldMessenger.of(stContext).hideCurrentSnackBar();
                                Navigator.of(stContext).push(
                                  MaterialPageRoute(
                                    builder: (_) => const SemanticTokensScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      }
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditColorDialog(
    BuildContext context,
    String name,
    dynamic colorData,
    String category,
  ) {
    _editDialogSelectedColor = colorData is Map && colorData['color'] != null
        ? colorData['color'] as Color
        : Colors.grey;
    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (stContext, setDialogState) => AlertDialog(
          title: const Text('Edit Color'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: TextEditingController(text: name),
                  decoration: const InputDecoration(
                    labelText: 'Color Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: TextEditingController(
                    text: colorData is Map ? (colorData['description'] as String? ?? '') : '',
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Description (Optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                const Text('Pick Color:', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () async {
                    final result = await Navigator.of(stContext).push<Map<String, dynamic>>(
                      MaterialPageRoute(
                        builder: (_) => const ColorPickerScreen(),
                      ),
                    );
                    if (result != null && result['color'] != null && stContext.mounted) {
                      setDialogState(() {
                        _editDialogSelectedColor = result['color'] as Color;
                      });
                    }
                  },
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: _editDialogSelectedColor ?? Colors.grey,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!, width: 2),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.colorize, size: 48, color: Colors.white),
                              const SizedBox(height: 8),
                              const Text(
                                'Tap to pick color',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              _colorToHex(_editDialogSelectedColor ?? Colors.grey),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'monospace',
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(stContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final newNameController = TextEditingController(text: name);
                final newDescriptionController = TextEditingController(
                  text: colorData is Map ? (colorData['description'] as String? ?? '') : '',
                );

                if (newNameController.text.isNotEmpty) {
                  _updateColor(
                    stContext,
                    category,
                    name,
                    newNameController.text,
                    _editDialogSelectedColor ?? Colors.grey,
                    newDescriptionController.text,
                  );
                  Navigator.of(stContext).pop();
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _addColorWithScales(
    BuildContext context,
    String name,
    String description,
    Color color,
    Map<String, String> primaryToDark,
    Map<String, String> primaryToLight,
    List<ColorSuggestion> suggestions,
    String category,
  ) {
    if (!context.mounted) return;
    
    final provider = Provider.of<DesignSystemProvider>(context, listen: false);
    final colors = provider.designSystem.colors;
    final colorHex = _colorToHex(color);

    // Build color data map with all scales
    final colorData = <String, dynamic>{
      'value': colorHex,
      'type': 'color',
      'description': description,
    };

    Map<String, dynamic> updatedCategory;
    
    // Add primary color
    switch (category) {
      case 'primary':
        updatedCategory = Map<String, dynamic>.from(colors.primary);
        updatedCategory[name] = colorData;
        
        // Add dark scale variations
        primaryToDark.forEach((key, value) {
          if (key != 'primary') {
            updatedCategory['${name}_$key'] = {
              'value': value,
              'type': 'color',
              'description': 'Dark variation $key of $name',
            };
          }
        });
        
        // Add light scale variations
        primaryToLight.forEach((key, value) {
          if (key != 'primary') {
            updatedCategory['${name}_$key'] = {
              'value': value,
              'type': 'color',
              'description': 'Light variation $key of $name',
            };
          }
        });
        
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
      case 'secondary': // Assuming 'secondary' should also go into semantic, or a new category should be added.
        updatedCategory = Map<String, dynamic>.from(colors.semantic);
        updatedCategory[name] = colorData;
        
        // Add dark scale variations
        primaryToDark.forEach((key, value) {
          if (key != 'primary') {
            updatedCategory['${name}_$key'] = {
              'value': value,
              'type': 'color',
              'description': 'Dark variation $key of $name',
            };
          }
        });
        
        // Add light scale variations
        primaryToLight.forEach((key, value) {
          if (key != 'primary') {
            updatedCategory['${name}_$key'] = {
              'value': value,
              'type': 'color',
              'description': 'Light variation $key of $name',
            };
          }
        });
        
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
      default:
        // For other categories, just add the color
        _addColor(context, category, name, color, description);
        return;
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Color "$name" added with ${primaryToDark.length + primaryToLight.length - 2} variations!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _addColor(
    BuildContext context,
    String category,
    String name,
    Color color,
    String description,
  ) {
    if (!context.mounted) return;
    final provider = Provider.of<DesignSystemProvider>(context, listen: false);
    final colors = provider.designSystem.colors;
    final colorHex = _colorToHex(color);

    final colorData = {
      'value': colorHex,
      'type': 'color',
      'description': description,
    };

    Map<String, dynamic> updatedCategory;
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
      default:
        // For other categories like blue, green, etc., add directly
        // Assuming there's a corresponding field in models.Colors
        // This part needs adjustment based on actual models.Colors structure
        if (category == 'blue') {
          final tempMap = Map<String, dynamic>.from(colors.blue ?? {});
          tempMap[name] = colorData;
          provider.updateColors(models.Colors(
            primary: colors.primary,
            semantic: colors.semantic,
            blue: tempMap,
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
        } else if (category == 'green') {
          final tempMap = Map<String, dynamic>.from(colors.green ?? {});
          tempMap[name] = colorData;
          provider.updateColors(models.Colors(
            primary: colors.primary,
            semantic: colors.semantic,
            blue: colors.blue,
            green: tempMap,
            orange: colors.orange,
            purple: colors.purple,
            red: colors.red,
            grey: colors.grey,
            white: colors.white,
            text: colors.text,
            input: colors.input,
            roleSpecific: colors.roleSpecific,
          ));
        } else if (category == 'orange') {
          final tempMap = Map<String, dynamic>.from(colors.orange ?? {});
          tempMap[name] = colorData;
          provider.updateColors(models.Colors(
            primary: colors.primary,
            semantic: colors.semantic,
            blue: colors.blue,
            green: colors.green,
            orange: tempMap,
            purple: colors.purple,
            red: colors.red,
            grey: colors.grey,
            white: colors.white,
            text: colors.text,
            input: colors.input,
            roleSpecific: colors.roleSpecific,
          ));
        } else if (category == 'purple') {
          final tempMap = Map<String, dynamic>.from(colors.purple ?? {});
          tempMap[name] = colorData;
          provider.updateColors(models.Colors(
            primary: colors.primary,
            semantic: colors.semantic,
            blue: colors.blue,
            green: colors.green,
            orange: colors.orange,
            purple: tempMap,
            red: colors.red,
            grey: colors.grey,
            white: colors.white,
            text: colors.text,
            input: colors.input,
            roleSpecific: colors.roleSpecific,
          ));
        } else if (category == 'red') {
          final tempMap = Map<String, dynamic>.from(colors.red ?? {});
          tempMap[name] = colorData;
          provider.updateColors(models.Colors(
            primary: colors.primary,
            semantic: colors.semantic,
            blue: colors.blue,
            green: colors.green,
            orange: colors.orange,
            purple: colors.purple,
            red: tempMap,
            grey: colors.grey,
            white: colors.white,
            text: colors.text,
            input: colors.input,
            roleSpecific: colors.roleSpecific,
          ));
        } else if (category == 'grey') {
          final tempMap = Map<String, dynamic>.from(colors.grey ?? {});
          tempMap[name] = colorData;
          provider.updateColors(models.Colors(
            primary: colors.primary,
            semantic: colors.semantic,
            blue: colors.blue,
            green: colors.green,
            orange: colors.orange,
            purple: colors.purple,
            red: colors.red,
            grey: tempMap,
            white: colors.white,
            text: colors.text,
            input: colors.input,
            roleSpecific: colors.roleSpecific,
          ));
        }
        break;
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Color "$name" added successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _updateColor(
    BuildContext context,
    String category,
    String oldName,
    String newName,
    Color color,
    String description,
  ) {
    if (!context.mounted) return;
    final provider = Provider.of<DesignSystemProvider>(context, listen: false);
    final colors = provider.designSystem.colors;
    final colorHex = _colorToHex(color);

    final colorData = {
      'value': colorHex,
      'type': 'color',
      'description': description,
    };

    Map<String, dynamic> updatedCategory;
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
      default:
        // For other categories like blue, green, etc., update directly
        // This part needs adjustment based on actual models.Colors structure
        if (category == 'blue') {
          final tempMap = Map<String, dynamic>.from(colors.blue ?? {});
          if (oldName != newName) {
            tempMap.remove(oldName);
          }
          tempMap[newName] = colorData;
          provider.updateColors(models.Colors(
            primary: colors.primary,
            semantic: colors.semantic,
            blue: tempMap,
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
        } else if (category == 'green') {
          final tempMap = Map<String, dynamic>.from(colors.green ?? {});
          if (oldName != newName) {
            tempMap.remove(oldName);
          }
          tempMap[newName] = colorData;
          provider.updateColors(models.Colors(
            primary: colors.primary,
            semantic: colors.semantic,
            blue: colors.blue,
            green: tempMap,
            orange: colors.orange,
            purple: colors.purple,
            red: colors.red,
            grey: colors.grey,
            white: colors.white,
            text: colors.text,
            input: colors.input,
            roleSpecific: colors.roleSpecific,
          ));
        } else if (category == 'orange') {
          final tempMap = Map<String, dynamic>.from(colors.orange ?? {});
          if (oldName != newName) {
            tempMap.remove(oldName);
          }
          tempMap[newName] = colorData;
          provider.updateColors(models.Colors(
            primary: colors.primary,
            semantic: colors.semantic,
            blue: colors.blue,
            green: colors.green,
            orange: tempMap,
            purple: colors.purple,
            red: colors.red,
            grey: colors.grey,
            white: colors.white,
            text: colors.text,
            input: colors.input,
            roleSpecific: colors.roleSpecific,
          ));
        } else if (category == 'purple') {
          final tempMap = Map<String, dynamic>.from(colors.purple ?? {});
          if (oldName != newName) {
            tempMap.remove(oldName);
          }
          tempMap[newName] = colorData;
          provider.updateColors(models.Colors(
            primary: colors.primary,
            semantic: colors.semantic,
            blue: colors.blue,
            green: colors.green,
            orange: colors.orange,
            purple: tempMap,
            red: colors.red,
            grey: colors.grey,
            white: colors.white,
            text: colors.text,
            input: colors.input,
            roleSpecific: colors.roleSpecific,
          ));
        } else if (category == 'red') {
          final tempMap = Map<String, dynamic>.from(colors.red ?? {});
          if (oldName != newName) {
            tempMap.remove(oldName);
          }
          tempMap[newName] = colorData;
          provider.updateColors(models.Colors(
            primary: colors.primary,
            semantic: colors.semantic,
            blue: colors.blue,
            green: colors.green,
            orange: colors.orange,
            purple: colors.purple,
            red: tempMap,
            grey: colors.grey,
            white: colors.white,
            text: colors.text,
            input: colors.input,
            roleSpecific: colors.roleSpecific,
          ));
        } else if (category == 'grey') {
          final tempMap = Map<String, dynamic>.from(colors.grey ?? {});
          if (oldName != newName) {
            tempMap.remove(oldName);
          }
          tempMap[newName] = colorData;
          provider.updateColors(models.Colors(
            primary: colors.primary,
            semantic: colors.semantic,
            blue: colors.blue,
            green: colors.green,
            orange: colors.orange,
            purple: colors.purple,
            red: colors.red,
            grey: tempMap,
            white: colors.white,
            text: colors.text,
            input: colors.input,
            roleSpecific: colors.roleSpecific,
          ));
        }
        break;
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Color "$newName" updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _deleteColor(BuildContext context, String name, String category) {
    if (!context.mounted) return;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Color'),
        content: Text('Are you sure you want to delete "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (!context.mounted) return;
              Navigator.of(dialogContext).pop();
              
              final provider = Provider.of<DesignSystemProvider>(context, listen: false);
              final colors = provider.designSystem.colors;

              Map<String, dynamic> updatedCategory;
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
                default:
                  // For other categories, remove directly
                  // This part needs adjustment based on actual models.Colors structure
                  if (category == 'blue') {
                    final tempMap = Map<String, dynamic>.from(colors.blue ?? {});
                    tempMap.remove(name);
                    provider.updateColors(models.Colors(
                      primary: colors.primary,
                      semantic: colors.semantic,
                      blue: tempMap,
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
                  } else if (category == 'green') {
                    final tempMap = Map<String, dynamic>.from(colors.green ?? {});
                    tempMap.remove(name);
                    provider.updateColors(models.Colors(
                      primary: colors.primary,
                      semantic: colors.semantic,
                      blue: colors.blue,
                      green: tempMap,
                      orange: colors.orange,
                      purple: colors.purple,
                      red: colors.red,
                      grey: colors.grey,
                      white: colors.white,
                      text: colors.text,
                      input: colors.input,
                      roleSpecific: colors.roleSpecific,
                    ));
                  } else if (category == 'orange') {
                    final tempMap = Map<String, dynamic>.from(colors.orange ?? {});
                    tempMap.remove(name);
                    provider.updateColors(models.Colors(
                      primary: colors.primary,
                      semantic: colors.semantic,
                      blue: colors.blue,
                      green: colors.green,
                      orange: tempMap,
                      purple: colors.purple,
                      red: colors.red,
                      grey: colors.grey,
                      white: colors.white,
                      text: colors.text,
                      input: colors.input,
                      roleSpecific: colors.roleSpecific,
                    ));
                  } else if (category == 'purple') {
                    final tempMap = Map<String, dynamic>.from(colors.purple ?? {});
                    tempMap.remove(name);
                    provider.updateColors(models.Colors(
                      primary: colors.primary,
                      semantic: colors.semantic,
                      blue: colors.blue,
                      green: colors.green,
                      orange: colors.orange,
                      purple: tempMap,
                      red: colors.red,
                      grey: colors.grey,
                      white: colors.white,
                      text: colors.text,
                      input: colors.input,
                      roleSpecific: colors.roleSpecific,
                    ));
                  } else if (category == 'red') {
                    final tempMap = Map<String, dynamic>.from(colors.red ?? {});
                    tempMap.remove(name);
                    provider.updateColors(models.Colors(
                      primary: colors.primary,
                      semantic: colors.semantic,
                      blue: colors.blue,
                      green: colors.green,
                      orange: colors.orange,
                      purple: colors.purple,
                      red: tempMap,
                      grey: colors.grey,
                      white: colors.white,
                      text: colors.text,
                      input: colors.input,
                      roleSpecific: colors.roleSpecific,
                    ));
                  } else if (category == 'grey') {
                    final tempMap = Map<String, dynamic>.from(colors.grey ?? {});
                    tempMap.remove(name);
                    provider.updateColors(models.Colors(
                      primary: colors.primary,
                      semantic: colors.semantic,
                      blue: colors.blue,
                      green: colors.green,
                      orange: colors.orange,
                      purple: colors.purple,
                      red: colors.red,
                      grey: tempMap,
                      white: colors.white,
                      text: colors.text,
                      input: colors.input,
                      roleSpecific: colors.roleSpecific,
                    ));
                  }
                  break;
              }

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Color "$name" deleted successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class ColorSuggestion {
  final Color color;
  final String name;

  ColorSuggestion({required this.color, required this.name});
}
