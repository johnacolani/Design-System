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
  final GlobalKey<PopupMenuButtonState<String>> _categoryMenuKey = GlobalKey<PopupMenuButtonState<String>>();
  bool _contentReady = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _contentReady = true);
    });
  }

  void _applyColorsUpdateForGroup(TokenDisplayGroup group, models.Colors newColors) {
    final p = Provider.of<DesignSystemProvider>(context, listen: false);
    if (group.platforms.length == 1 && !p.isMultiPlatform) {
      p.updateColors(newColors);
    } else {
      p.updateColorsForGroup(group, newColors);
    }
  }

  models.Colors _getColorsForGroup(TokenDisplayGroup group) {
    final p = Provider.of<DesignSystemProvider>(context, listen: false);
    if (group.platforms.length == 1 && !p.isMultiPlatform) return p.designSystem.colors;
    return p.designSystemForPlatform(group.primaryPlatform).colors;
  }

  String _categoryDisplayName(List<Map<String, dynamic>> categories, String key) {
    for (final c in categories) {
      if (c['key'] == key && c['name'] != null) return c['name'] as String;
    }
    final fallbacks = <String, String>{
      'primary': 'Primary Colors', 'semantic': 'Semantic Colors',
      'blue': 'Blue Palette', 'green': 'Green Palette', 'orange': 'Orange Palette',
      'purple': 'Purple Palette', 'red': 'Red Palette', 'grey': 'Grey Palette',
    };
    return fallbacks[key] ?? key;
  }

  @override
  Widget build(BuildContext context) {
    if (!_contentReady) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).pop()),
          title: const Text('Colors'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    final provider = Provider.of<DesignSystemProvider>(context);
    final groups = provider.designTokenDisplayGroups;
    final firstGroup = groups.isNotEmpty ? groups.first : null;
    final colors = firstGroup != null ? _getColorsForGroup(firstGroup) : provider.designSystem.colors;

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
            key: _categoryMenuKey,
            onSelected: (category) {
              if (category == 'add_category') {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Use color palettes (Blue, Green, etc.) from the menu, or add colors to Primary/Semantic.')));
                return;
              }
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
          if (firstGroup != null)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showAddColorDialog(context, _selectedCategory, firstGroup!),
            ),
        ],
      ),
      body: ScreenBodyPadding(
        verticalPadding: 0,
        child: groups.length >= 2
            ? _buildTwoColumnLayout(context, provider, groups, categories, accentColor)
            : _buildSingleColumnLayout(context, firstGroup!, colors, currentCategory, categories, accentColor),
      ),
    );
  }

  Widget _buildSingleColumnLayout(
    BuildContext context,
    TokenDisplayGroup group,
    models.Colors colors,
    Map<String, dynamic> currentCategory,
    List<Map<String, dynamic>> categories,
    Color accentColor,
  ) {
    return Column(
      children: [
        InkWell(
          onTap: () => _categoryMenuKey.currentState?.showButtonMenu(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: accentColor.withOpacity(0.1),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 24,
                  decoration: BoxDecoration(color: accentColor, borderRadius: BorderRadius.circular(2)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _categoryDisplayName(categories, _selectedCategory),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                Icon(Icons.arrow_drop_down, color: Colors.grey[700]),
              ],
            ),
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
                      Text('No colors in this category', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[600])),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: () => _showAddColorDialog(context, _selectedCategory, group),
                        icon: const Icon(Icons.add),
                        label: const Text('Add Color'),
                      ),
                    ],
                  ),
                )
              : _buildColorsGroupedByTypeWithGroup(context, currentCategory, _selectedCategory, group),
        ),
      ],
    );
  }

  Widget _buildTwoColumnLayout(
    BuildContext context,
    DesignSystemProvider provider,
    List<TokenDisplayGroup> groups,
    List<Map<String, dynamic>> categories,
    Color accentColor,
  ) {
    return Column(
      children: [
        InkWell(
          onTap: () => _categoryMenuKey.currentState?.showButtonMenu(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: accentColor.withOpacity(0.1),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 24,
                  decoration: BoxDecoration(color: accentColor, borderRadius: BorderRadius.circular(2)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _categoryDisplayName(categories, _selectedCategory),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                Icon(Icons.arrow_drop_down, color: Colors.grey[700]),
              ],
            ),
          ),
        ),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildColorsColumnForGroup(context, groups[0], categories, accentColor)),
              Container(width: 1, color: Theme.of(context).dividerColor),
              Expanded(child: _buildColorsColumnForGroup(context, groups[1], categories, accentColor)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildColorsColumnForGroup(
    BuildContext context,
    TokenDisplayGroup group,
    List<Map<String, dynamic>> categories,
    Color accentColor,
  ) {
    final colors = _getColorsForGroup(group);
    Map<String, dynamic> currentCategory;
    switch (_selectedCategory) {
      case 'primary': currentCategory = colors.primary; break;
      case 'semantic': currentCategory = colors.semantic; break;
      case 'blue': currentCategory = colors.blue ?? {}; break;
      case 'green': currentCategory = colors.green ?? {}; break;
      case 'orange': currentCategory = colors.orange ?? {}; break;
      case 'purple': currentCategory = colors.purple ?? {}; break;
      case 'red': currentCategory = colors.red ?? {}; break;
      case 'grey': currentCategory = colors.grey ?? {}; break;
      default: currentCategory = {};
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            group.label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (currentCategory.isEmpty)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.palette_outlined, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 12),
                  Text('No colors', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600])),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () => _showAddColorDialog(context, _selectedCategory, group),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add Color'),
                  ),
                ],
              ),
            )
          else
            _buildColorsGroupedByTypeWithGroup(context, currentCategory, _selectedCategory, group),
        ],
      ),
    );
  }

  Widget _buildColorRow(
    BuildContext context,
    String name,
    dynamic colorData,
    String category, [
    TokenDisplayGroup? group,
  ]) {
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
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: InkWell(
        onTap: () {
          if (group != null) _showEditColorDialog(context, name, colorData, category, group);
          else _showEditColorDialog(context, name, colorData, category, Provider.of<DesignSystemProvider>(context, listen: false).designTokenDisplayGroups.first);
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
                  final g = group ?? Provider.of<DesignSystemProvider>(context, listen: false).designTokenDisplayGroups.first;
                  if (value == 'edit') {
                    _showEditColorDialog(context, name, colorData, category, g);
                  } else if (value == 'delete') {
                    _deleteColor(context, name, category, g);
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

  static const List<String> _colorGroupOrder = ['primary', 'analogous', 'success', 'error', 'warning', 'info', 'secondary'];

  /// Same grouping as Preview: analogous_1_dark, analogous_1_light, etc.; primary, success, etc.
  Map<String, List<MapEntry<String, dynamic>>> _groupColorsByPrefix(Map<String, dynamic> category) {
    final map = <String, List<MapEntry<String, dynamic>>>{};
    for (final e in category.entries) {
      final parts = e.key.split('_');
      String key;
      final first = parts.isNotEmpty ? parts[0].toLowerCase() : '';
      final analogousNumMatch = RegExp(r'^analogous(\d+)$').firstMatch(first);
      if (analogousNumMatch != null && parts.length >= 2) {
        final subPart = parts.length >= 3 ? parts[2] : parts[1];
        final sub = subPart.toLowerCase().replaceAll(RegExp(r'\d+$'), '');
        key = 'analogous_${analogousNumMatch.group(1)}_${sub.isEmpty ? subPart.toLowerCase() : sub}';
      } else if (analogousNumMatch != null) {
        key = 'analogous_${analogousNumMatch.group(1)}';
      } else if (first == 'analogous' && parts.length >= 3) {
        final third = parts[2].toLowerCase().replaceAll(RegExp(r'\d+$'), '');
        key = 'analogous_${parts[1]}_${third.isEmpty ? parts[2].toLowerCase() : third}';
      } else if (first == 'analogous' && parts.length >= 2) {
        key = '${first}_${parts[1]}';
      } else if (parts.length >= 2 && int.tryParse(parts[1]) != null) {
        key = '${first}_${parts[1]}';
      } else {
        key = first.isEmpty ? e.key.toLowerCase() : first;
      }
      map.putIfAbsent(key, () => []).add(e);
    }
    for (final list in map.values) {
      list.sort((a, b) => _naturalCompare(a.key, b.key));
    }
    return map;
  }

  /// Compare strings with numeric parts as numbers (e.g. dark1, dark2, dark10).
  int _naturalCompare(String a, String b) {
    final aParts = _splitForNaturalSort(a);
    final bParts = _splitForNaturalSort(b);
    for (var i = 0; i < aParts.length && i < bParts.length; i++) {
      final ap = aParts[i];
      final bp = bParts[i];
      final aNum = int.tryParse(ap);
      final bNum = int.tryParse(bp);
      if (aNum != null && bNum != null) {
        final c = aNum.compareTo(bNum);
        if (c != 0) return c;
      } else {
        final c = ap.compareTo(bp);
        if (c != 0) return c;
      }
    }
    return aParts.length.compareTo(bParts.length);
  }

  List<String> _splitForNaturalSort(String s) {
    final list = <String>[];
    var i = 0;
    while (i < s.length) {
      if (RegExp(r'[0-9]').hasMatch(s[i])) {
        var j = i;
        while (j < s.length && RegExp(r'[0-9]').hasMatch(s[j])) {
          j++;
        }
        list.add(s.substring(i, j));
        i = j;
      } else {
        var j = i;
        while (j < s.length && !RegExp(r'[0-9]').hasMatch(s[j])) {
          j++;
        }
        list.add(s.substring(i, j));
        i = j;
      }
    }
    return list;
  }

  Widget _buildColorsGroupedByTypeWithGroup(BuildContext context, Map<String, dynamic> category, String categoryKey, TokenDisplayGroup group) {
    return _buildColorsGroupedByType(context, category, group);
  }

  Widget _buildColorsGroupedByType(BuildContext context, Map<String, dynamic> category, [TokenDisplayGroup? group]) {
    final groups = _groupColorsByPrefix(category);
    if (groups.isEmpty) return const SizedBox.shrink();
    final orderedKeys = <String>[];
    if (groups.containsKey('primary')) orderedKeys.add('primary');
    final analogousKeys = groups.keys.where((k) => k.startsWith('analogous_')).toList()
      ..sort((a, b) => _naturalCompare(a, b));
    for (final k in analogousKeys) orderedKeys.add(k);
    for (final k in _colorGroupOrder) {
      if (groups.containsKey(k) && !orderedKeys.contains(k)) orderedKeys.add(k);
    }
    for (final k in groups.keys) {
      if (!orderedKeys.contains(k)) orderedKeys.add(k);
    }
    final n = orderedKeys.length;
    final firstColumnCount = n <= 2 ? 1 : (n + 1) ~/ 2;
    final leftKeys = orderedKeys.take(firstColumnCount).toList();
    final rightKeys = orderedKeys.skip(firstColumnCount).toList();

    Widget buildColumn(List<String> keys) {
      if (keys.isEmpty) return const SizedBox.shrink();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < keys.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            _buildColorGroupColumn(
              context,
              _capitalizeGroupTitle(keys[i]),
              groups[keys[i]]!,
              _selectedCategory,
              group,
            ),
          ],
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: buildColumn(leftKeys)),
            if (rightKeys.isNotEmpty) ...[
              const SizedBox(width: 12),
              Expanded(child: buildColumn(rightKeys)),
            ],
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  /// Same display as Preview: "Analogous 01 Dark", "Analogous 01 Light", "Analogous 01", "Primary", etc.
  String _capitalizeGroupTitle(String s) {
    if (s.isEmpty) return s;
    final lower = s.toLowerCase();
    final analogousSubMatch = RegExp(r'^analogous_(\d+)_(.+)$').firstMatch(lower);
    if (analogousSubMatch != null) {
      final numStr = analogousSubMatch.group(1)!;
      final sub = analogousSubMatch.group(2)!;
      final num = int.tryParse(numStr);
      final label = num != null ? num.toString().padLeft(2, '0') : numStr;
      final subCap = sub.isEmpty ? sub : sub[0].toUpperCase() + sub.substring(1).toLowerCase();
      return 'Analogous $label $subCap';
    }
    final analogousMatch = RegExp(r'^analogous_(\d+)$').firstMatch(lower);
    if (analogousMatch != null) {
      final numStr = analogousMatch.group(1)!;
      final num = int.tryParse(numStr);
      final label = num != null ? num.toString().padLeft(2, '0') : numStr;
      return 'Analogous $label';
    }
    return s
        .split('_')
        .map((part) => part.isEmpty ? part : part[0].toUpperCase() + part.substring(1).toLowerCase())
        .join(' ');
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1).toLowerCase();
  }

  Widget _buildColorGroupColumn(
    BuildContext context,
    String title,
    List<MapEntry<String, dynamic>> entries,
    String category,
    TokenDisplayGroup? group,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(7)),
              border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
          ),
          ...entries.map((e) => _buildColorRow(context, e.key, e.value, category, group)),
        ],
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

  void _showAddColorDialog(BuildContext context, String category, TokenDisplayGroup group) {
    _showAddColorDialogWithColor(context, category, Colors.blue, '', '', group);
  }

  void _showAddColorDialogWithColor(
    BuildContext context,
    String category,
    Color initialColor,
    String initialName,
    String initialDescription,
    TokenDisplayGroup group,
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
                                  group,
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
                        group,
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
    TokenDisplayGroup group,
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
                    group,
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
    TokenDisplayGroup group,
  ) {
    if (!context.mounted) return;
    
    final colors = _getColorsForGroup(group);
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
        
        _applyColorsUpdateForGroup(group,models.Colors(
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
        
        _applyColorsUpdateForGroup(group,models.Colors(
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
        _addColor(context, category, name, color, description, group);
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
    TokenDisplayGroup group,
  ) {
    if (!context.mounted) return;
    final colors = _getColorsForGroup(group);
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
        _applyColorsUpdateForGroup(group,models.Colors(
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
        _applyColorsUpdateForGroup(group,models.Colors(
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
          _applyColorsUpdateForGroup(group,models.Colors(
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
          _applyColorsUpdateForGroup(group,models.Colors(
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
          _applyColorsUpdateForGroup(group,models.Colors(
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
          _applyColorsUpdateForGroup(group,models.Colors(
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
          _applyColorsUpdateForGroup(group,models.Colors(
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
          _applyColorsUpdateForGroup(group,models.Colors(
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
    TokenDisplayGroup group,
  ) {
    if (!context.mounted) return;
    final colors = _getColorsForGroup(group);
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
        _applyColorsUpdateForGroup(group,models.Colors(
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
        _applyColorsUpdateForGroup(group,models.Colors(
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
          _applyColorsUpdateForGroup(group,models.Colors(
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
          _applyColorsUpdateForGroup(group,models.Colors(
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
          _applyColorsUpdateForGroup(group,models.Colors(
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
          _applyColorsUpdateForGroup(group,models.Colors(
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
          _applyColorsUpdateForGroup(group,models.Colors(
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
          _applyColorsUpdateForGroup(group,models.Colors(
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

  void _deleteColor(BuildContext context, String name, String category, TokenDisplayGroup group) {
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
              
              final colors = _getColorsForGroup(group);

              Map<String, dynamic> updatedCategory;
              switch (category) {
                case 'primary':
                  updatedCategory = Map<String, dynamic>.from(colors.primary);
                  updatedCategory.remove(name);
                  _applyColorsUpdateForGroup(group,models.Colors(
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
                  _applyColorsUpdateForGroup(group,models.Colors(
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
                    _applyColorsUpdateForGroup(group,models.Colors(
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
                    _applyColorsUpdateForGroup(group,models.Colors(
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
                    _applyColorsUpdateForGroup(group,models.Colors(
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
                    _applyColorsUpdateForGroup(group,models.Colors(
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
                    _applyColorsUpdateForGroup(group,models.Colors(
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
                    _applyColorsUpdateForGroup(group,models.Colors(
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
