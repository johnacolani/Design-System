import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/design_library_components.dart';
import '../data/material_icons_catalog.dart';
import '../providers/design_system_provider.dart';
import '../models/design_system.dart' as models;

class MaterialPickerScreen extends StatefulWidget {
  final bool isColorPickerMode;
  
  const MaterialPickerScreen({
    super.key,
    this.isColorPickerMode = true,
  });

  @override
  State<MaterialPickerScreen> createState() => _MaterialPickerScreenState();
}

class _MaterialPickerScreenState extends State<MaterialPickerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Material Design Library'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.palette), text: 'Colors'),
            Tab(icon: Icon(Icons.image), text: 'Icons'),
            Tab(icon: Icon(Icons.widgets), text: 'Components'),
            Tab(icon: Icon(Icons.text_fields), text: 'Typography'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          MaterialColorsTab(isColorPickerMode: widget.isColorPickerMode),
          const MaterialIconsTab(),
          const MaterialComponentsTab(),
          const MaterialTypographyTab(),
        ],
      ),
    );
  }
}

// Material Colors Tab
class MaterialColorsTab extends StatefulWidget {
  final bool isColorPickerMode;
  
  const MaterialColorsTab({
    super.key,
    this.isColorPickerMode = false,
  });

  @override
  State<MaterialColorsTab> createState() => _MaterialColorsTabState();
}

class _MaterialColorsTabState extends State<MaterialColorsTab> {
  Color? _selectedColor;

  @override
  Widget build(BuildContext context) {
    final materialColors = _getMaterialColorPalettes();

    return Column(
      children: [
        if (widget.isColorPickerMode && _selectedColor != null)
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue[50],
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: _selectedColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey[300]!, width: 2),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selected Color',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.blue[900],
                        ),
                      ),
                      Text(
                        '#${_selectedColor!.value.toRadixString(16).substring(2).toUpperCase()}',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop(_selectedColor);
                  },
                  icon: const Icon(Icons.check),
                  label: const Text('Use This Color'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Material Design 3 Color Palettes',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.isColorPickerMode
                    ? 'Tap a color to select it, then click "Use This Color"'
                    : 'Select a color palette to add to your design system',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 24),
              ...materialColors.map((palette) => _buildColorPaletteCard(context, palette)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildColorPaletteCard(BuildContext context, MaterialColorPalette palette) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: palette.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        palette.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      Text(
                        palette.description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ),
                if (!widget.isColorPickerMode)
                  ElevatedButton.icon(
                    onPressed: () {
                      _addPaletteToDesignSystem(context, palette);
                    },
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add'),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: palette.shades.entries.map((entry) {
                final isSelected = widget.isColorPickerMode && _selectedColor == entry.value;
                return GestureDetector(
                  onTap: widget.isColorPickerMode
                      ? () {
                          setState(() {
                            _selectedColor = entry.value;
                          });
                        }
                      : null,
                  child: Tooltip(
                    message: '${entry.key}: ${_colorToHex(entry.value)}',
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: entry.value,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected ? Colors.black : Colors.grey[300]!,
                          width: isSelected ? 3 : 0.5,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, color: Colors.white, size: 20)
                          : null,
                    ),
                  ),
                );
              }).toList(),
            ),
            // Also make primary color selectable
            if (widget.isColorPickerMode) ...[
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedColor = palette.primary;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _selectedColor == palette.primary ? Colors.blue[50] : Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _selectedColor == palette.primary ? Colors.blue : Colors.grey[300]!,
                      width: _selectedColor == palette.primary ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: palette.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Primary Color: ${_colorToHex(palette.primary)}',
                          style: TextStyle(
                            fontWeight: _selectedColor == palette.primary ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ),
                      if (_selectedColor == palette.primary)
                        const Icon(Icons.check, color: Colors.blue),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _addPaletteToDesignSystem(BuildContext context, MaterialColorPalette palette) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add ${palette.name} Palette'),
        content: Text(
          'This will add the ${palette.name} color palette to your design system. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final provider = Provider.of<DesignSystemProvider>(context, listen: false);
              final colors = provider.designSystem.colors;
              
              // Convert palette name to lowercase for the color category
              final categoryName = palette.name.toLowerCase();
              
              // Create a map for this color palette with all shades
              final paletteMap = <String, dynamic>{};
              palette.shades.forEach((shade, color) {
                final colorHex = '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
                paletteMap['$categoryName$shade'] = {
                  'value': colorHex,
                  'type': 'color',
                  'description': '${palette.name} $shade',
                };
              });
              
              // Add primary color from palette
              final primaryHex = '#${palette.primary.value.toRadixString(16).substring(2).toUpperCase()}';
              paletteMap[categoryName] = {
                'value': primaryHex,
                'type': 'color',
                'description': '${palette.name} primary color',
              };
              
              // Update colors based on category
              Map<String, dynamic> updatedPrimary = Map<String, dynamic>.from(colors.primary);
              Map<String, dynamic>? updatedBlue = colors.blue != null ? Map<String, dynamic>.from(colors.blue!) : null;
              Map<String, dynamic>? updatedGreen = colors.green != null ? Map<String, dynamic>.from(colors.green!) : null;
              Map<String, dynamic>? updatedOrange = colors.orange != null ? Map<String, dynamic>.from(colors.orange!) : null;
              Map<String, dynamic>? updatedPurple = colors.purple != null ? Map<String, dynamic>.from(colors.purple!) : null;
              Map<String, dynamic>? updatedRed = colors.red != null ? Map<String, dynamic>.from(colors.red!) : null;
              Map<String, dynamic>? updatedGrey = colors.grey != null ? Map<String, dynamic>.from(colors.grey!) : null;
              
              // Add to appropriate category
              switch (categoryName) {
                case 'blue':
                  updatedBlue ??= {};
                  updatedBlue.addAll(paletteMap);
                  break;
                case 'green':
                  updatedGreen ??= {};
                  updatedGreen.addAll(paletteMap);
                  break;
                case 'orange':
                  updatedOrange ??= {};
                  updatedOrange.addAll(paletteMap);
                  break;
                case 'purple':
                  updatedPurple ??= {};
                  updatedPurple.addAll(paletteMap);
                  break;
                case 'red':
                  updatedRed ??= {};
                  updatedRed.addAll(paletteMap);
                  break;
                case 'grey':
                case 'gray':
                  updatedGrey ??= {};
                  updatedGrey.addAll(paletteMap);
                  break;
                default:
                  // Add to primary if no specific category
                  updatedPrimary.addAll(paletteMap);
              }
              
              // Update design system
              final updatedColors = models.Colors(
                primary: updatedPrimary,
                semantic: colors.semantic,
                blue: updatedBlue,
                green: updatedGreen,
                orange: updatedOrange,
                purple: updatedPurple,
                red: updatedRed,
                grey: updatedGrey,
                white: colors.white,
                text: colors.text,
                input: colors.input,
                roleSpecific: colors.roleSpecific,
              );
              
              provider.updateColors(updatedColors);
              
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${palette.name} palette added successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  List<MaterialColorPalette> _getMaterialColorPalettes() {
    return [
      MaterialColorPalette(
        name: 'Blue',
        description: 'Primary blue palette',
        primary: Colors.blue,
        shades: {
          '50': Colors.blue.shade50,
          '100': Colors.blue.shade100,
          '200': Colors.blue.shade200,
          '300': Colors.blue.shade300,
          '400': Colors.blue.shade400,
          '500': Colors.blue.shade500,
          '600': Colors.blue.shade600,
          '700': Colors.blue.shade700,
          '800': Colors.blue.shade800,
          '900': Colors.blue.shade900,
        },
      ),
      MaterialColorPalette(
        name: 'Green',
        description: 'Success and positive actions',
        primary: Colors.green,
        shades: {
          '50': Colors.green.shade50,
          '100': Colors.green.shade100,
          '200': Colors.green.shade200,
          '300': Colors.green.shade300,
          '400': Colors.green.shade400,
          '500': Colors.green.shade500,
          '600': Colors.green.shade600,
          '700': Colors.green.shade700,
          '800': Colors.green.shade800,
          '900': Colors.green.shade900,
        },
      ),
      MaterialColorPalette(
        name: 'Red',
        description: 'Error and destructive actions',
        primary: Colors.red,
        shades: {
          '50': Colors.red.shade50,
          '100': Colors.red.shade100,
          '200': Colors.red.shade200,
          '300': Colors.red.shade300,
          '400': Colors.red.shade400,
          '500': Colors.red.shade500,
          '600': Colors.red.shade600,
          '700': Colors.red.shade700,
          '800': Colors.red.shade800,
          '900': Colors.red.shade900,
        },
      ),
      MaterialColorPalette(
        name: 'Orange',
        description: 'Warning and attention',
        primary: Colors.orange,
        shades: {
          '50': Colors.orange.shade50,
          '100': Colors.orange.shade100,
          '200': Colors.orange.shade200,
          '300': Colors.orange.shade300,
          '400': Colors.orange.shade400,
          '500': Colors.orange.shade500,
          '600': Colors.orange.shade600,
          '700': Colors.orange.shade700,
          '800': Colors.orange.shade800,
          '900': Colors.orange.shade900,
        },
      ),
      MaterialColorPalette(
        name: 'Purple',
        description: 'Creative and premium',
        primary: Colors.purple,
        shades: {
          '50': Colors.purple.shade50,
          '100': Colors.purple.shade100,
          '200': Colors.purple.shade200,
          '300': Colors.purple.shade300,
          '400': Colors.purple.shade400,
          '500': Colors.purple.shade500,
          '600': Colors.purple.shade600,
          '700': Colors.purple.shade700,
          '800': Colors.purple.shade800,
          '900': Colors.purple.shade900,
        },
      ),
      MaterialColorPalette(
        name: 'Teal',
        description: 'Calm and professional',
        primary: Colors.teal,
        shades: {
          '50': Colors.teal.shade50,
          '100': Colors.teal.shade100,
          '200': Colors.teal.shade200,
          '300': Colors.teal.shade300,
          '400': Colors.teal.shade400,
          '500': Colors.teal.shade500,
          '600': Colors.teal.shade600,
          '700': Colors.teal.shade700,
          '800': Colors.teal.shade800,
          '900': Colors.teal.shade900,
        },
      ),
      MaterialColorPalette(
        name: 'Indigo',
        description: 'Deep and sophisticated',
        primary: Colors.indigo,
        shades: {
          '50': Colors.indigo.shade50,
          '100': Colors.indigo.shade100,
          '200': Colors.indigo.shade200,
          '300': Colors.indigo.shade300,
          '400': Colors.indigo.shade400,
          '500': Colors.indigo.shade500,
          '600': Colors.indigo.shade600,
          '700': Colors.indigo.shade700,
          '800': Colors.indigo.shade800,
          '900': Colors.indigo.shade900,
        },
      ),
      MaterialColorPalette(
        name: 'Pink',
        description: 'Playful and energetic',
        primary: Colors.pink,
        shades: {
          '50': Colors.pink.shade50,
          '100': Colors.pink.shade100,
          '200': Colors.pink.shade200,
          '300': Colors.pink.shade300,
          '400': Colors.pink.shade400,
          '500': Colors.pink.shade500,
          '600': Colors.pink.shade600,
          '700': Colors.pink.shade700,
          '800': Colors.pink.shade800,
          '900': Colors.pink.shade900,
        },
      ),
    ];
  }
}

class MaterialColorPalette {
  final String name;
  final String description;
  final Color primary;
  final Map<String, Color> shades;

  MaterialColorPalette({
    required this.name,
    required this.description,
    required this.primary,
    required this.shades,
  });
}

// Material Icons Tab
class MaterialIconsTab extends StatefulWidget {
  const MaterialIconsTab({super.key});

  @override
  State<MaterialIconsTab> createState() => _MaterialIconsTabState();
}

class _MaterialIconsTabState extends State<MaterialIconsTab> {
  final TextEditingController _searchController = TextEditingController();
  List<IconData> _filteredIcons = [];
  List<IconData> _allIcons = [];

  @override
  void initState() {
    super.initState();
    _loadMaterialIcons();
    _searchController.addListener(_filterIcons);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadMaterialIcons() {
    _allIcons = List<IconData>.from(kMaterialIconsCatalog);
    _filteredIcons = _allIcons;
  }

  void _filterIcons() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredIcons = _allIcons;
      } else {
        _filteredIcons = _allIcons.where((icon) {
          final iconName = icon.toString().toLowerCase();
          return iconName.contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search icons...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
            ),
          ),
        ),
        Expanded(
          child: _filteredIcons.isEmpty
              ? Center(
                  child: Text(
                    'No icons found',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1,
                  ),
                  itemCount: _filteredIcons.length,
                  itemBuilder: (context, index) {
                    final icon = _filteredIcons[index];
                    return _buildIconCard(context, icon);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildIconCard(BuildContext context, IconData icon) {
    return Card(
      child: InkWell(
        onTap: () {
          _addIconToDesignSystem(context, icon);
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32),
            const SizedBox(height: 8),
            Text(
              _getIconName(icon),
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  String _getIconName(IconData icon) {
    final iconString = icon.toString();
    final match = RegExp(r"'([^']+)'").firstMatch(iconString);
    return match?.group(1) ?? 'icon';
  }

  void _addIconToDesignSystem(BuildContext tabContext, IconData icon) {
    final labelCtrl = TextEditingController(text: _getIconName(icon));
    showDialog(
      context: tabContext,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Material icon'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(child: Icon(icon, size: 56)),
              const SizedBox(height: 16),
              TextField(
                controller: labelCtrl,
                decoration: const InputDecoration(
                  labelText: 'Usage name',
                  hintText: 'e.g. Tab — Home',
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 8),
              Text(
                'Add to project icons to show them in Design System Preview and exports.',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(tabContext).showSnackBar(
                SnackBar(
                  content: Text('Use Icon(${_getIconName(icon)}) in code. Sizes: Icons screen.'),
                ),
              );
            },
            child: const Text('Code hint'),
          ),
          FilledButton(
            onPressed: () {
              final prov = Provider.of<DesignSystemProvider>(dialogContext, listen: false);
              final ds = prov.designSystem;
              final ic = ds.icons;
              final label = labelCtrl.text.trim().isEmpty ? _getIconName(icon) : labelCtrl.text.trim();
              final entry = models.ProjectIconEntry(
                id: 'pi_${DateTime.now().microsecondsSinceEpoch}',
                label: label,
                codePoint: icon.codePoint,
              );
              Navigator.pop(dialogContext);
              prov.updateDesignSystem(models.DesignSystem(
                name: ds.name,
                version: ds.version,
                description: ds.description,
                created: ds.created,
                colors: ds.colors,
                typography: ds.typography,
                spacing: ds.spacing,
                borderRadius: ds.borderRadius,
                shadows: ds.shadows,
                effects: ds.effects,
                components: ds.components,
                grid: ds.grid,
                icons: models.Icons(sizes: ic.sizes, projectIcons: [...ic.projectIcons, entry]),
                gradients: ds.gradients,
                roles: ds.roles,
                semanticTokens: ds.semanticTokens,
                motionTokens: ds.motionTokens,
                lastModified: ds.lastModified,
                versionHistory: ds.versionHistory,
                componentVersions: ds.componentVersions,
              ));
              ScaffoldMessenger.of(tabContext).showSnackBar(
                SnackBar(content: Text('“$label” added — see Icons & Preview')),
              );
            },
            child: const Text('Add to project'),
          ),
        ],
      ),
    );
  }
}

// Material Components Tab
class MaterialComponentsTab extends StatelessWidget {
  const MaterialComponentsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Material Design Components',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Browse and add Material components to your design system',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
        ),
        const SizedBox(height: 24),
        _buildComponentCard(
          context,
          'Buttons',
          'Primary, Secondary, Icon buttons',
          Icons.smart_button,
          Colors.blue,
          _buildButtonExamples(),
        ),
        _buildComponentCard(
          context,
          'Cards',
          'Elevated, Filled, Outlined cards',
          Icons.credit_card,
          Colors.green,
          _buildCardExamples(),
        ),
        _buildComponentCard(
          context,
          'Inputs',
          'Text fields, Text areas',
          Icons.input,
          Colors.orange,
          _buildInputExamples(),
        ),
      ],
    );
  }

  Widget _buildComponentCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
    Widget examples,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        leading: Icon(icon, color: color),
        title: Text(title),
        subtitle: Text(description),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: examples,
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: () {
                _addComponentToDesignSystem(context, title);
              },
              icon: const Icon(Icons.add),
              label: Text('Add $title to Design System'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtonExamples() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
          onPressed: () {},
          child: const Text('Elevated Button'),
        ),
        const SizedBox(height: 8),
        FilledButton(
          onPressed: () {},
          child: const Text('Filled Button'),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: () {},
          child: const Text('Outlined Button'),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () {},
          child: const Text('Text Button'),
        ),
        const SizedBox(height: 8),
        IconButton.filled(
          onPressed: () {},
          icon: const Icon(Icons.favorite),
        ),
      ],
    );
  }

  Widget _buildCardExamples() {
    return Column(
      children: [
        Card(
          child: const ListTile(
            leading: Icon(Icons.info),
            title: Text('Elevated Card'),
            subtitle: Text('Default card with elevation'),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          elevation: 0,
          color: Colors.grey[100],
          child: const ListTile(
            leading: Icon(Icons.info),
            title: Text('Filled Card'),
            subtitle: Text('Card with background color'),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Colors.grey),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const ListTile(
            leading: Icon(Icons.info),
            title: Text('Outlined Card'),
            subtitle: Text('Card with border'),
          ),
        ),
      ],
    );
  }

  Widget _buildInputExamples() {
    return Column(
      children: [
        TextField(
          decoration: InputDecoration(
            labelText: 'Standard Text Field',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          decoration: InputDecoration(
            labelText: 'Filled Text Field',
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          maxLines: 3,
          decoration: InputDecoration(
            labelText: 'Text Area',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  void _addComponentToDesignSystem(BuildContext context, String componentName) {
    final provider = Provider.of<DesignSystemProvider>(context, listen: false);
    final comp = provider.designSystem.components;
    Map<String, dynamic>? toAdd;
    switch (componentName) {
      case 'Buttons':
        toAdd = DesignLibraryComponents.materialButtons;
        break;
      case 'Cards':
        toAdd = DesignLibraryComponents.materialCards;
        break;
      case 'Inputs':
        toAdd = DesignLibraryComponents.materialInputs;
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$componentName — add from Components screen'), backgroundColor: Colors.blue),
        );
        return;
    }

    final updatedButtons = Map<String, dynamic>.from(comp.buttons);
    final updatedCards = Map<String, dynamic>.from(comp.cards);
    final updatedInputs = Map<String, dynamic>.from(comp.inputs);
    var added = 0;
    if (componentName == 'Buttons') {
      for (final e in toAdd.entries) {
        if (!updatedButtons.containsKey(e.key)) {
          updatedButtons[e.key] = Map<String, dynamic>.from(e.value);
          added++;
        }
      }
    } else if (componentName == 'Cards') {
      for (final e in toAdd.entries) {
        if (!updatedCards.containsKey(e.key)) {
          updatedCards[e.key] = Map<String, dynamic>.from(e.value);
          added++;
        }
      }
    } else if (componentName == 'Inputs') {
      for (final e in toAdd.entries) {
        if (!updatedInputs.containsKey(e.key)) {
          updatedInputs[e.key] = Map<String, dynamic>.from(e.value);
          added++;
        }
      }
    }

    final ds = provider.designSystem;
    provider.updateDesignSystem(models.DesignSystem(
      name: ds.name,
      version: ds.version,
      description: ds.description,
      created: ds.created,
      colors: ds.colors,
      typography: ds.typography,
      spacing: ds.spacing,
      borderRadius: ds.borderRadius,
      shadows: ds.shadows,
      effects: ds.effects,
      components: models.Components(
        buttons: updatedButtons,
        cards: updatedCards,
        inputs: updatedInputs,
        navigation: comp.navigation,
        avatars: comp.avatars,
        modals: comp.modals,
        tables: comp.tables,
        progress: comp.progress,
        alerts: comp.alerts,
      ),
      grid: ds.grid,
      icons: ds.icons,
      gradients: ds.gradients,
      roles: ds.roles,
      semanticTokens: ds.semanticTokens,
      motionTokens: ds.motionTokens,
      lastModified: ds.lastModified,
      versionHistory: ds.versionHistory,
      componentVersions: ds.componentVersions,
    ));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(added > 0 ? 'Added $added Material $componentName to your project — see Components & Preview' : 'Those $componentName are already in your project'),
        backgroundColor: added > 0 ? Colors.green : Colors.blue,
      ),
    );
  }
}

// Material Typography Tab
class MaterialTypographyTab extends StatelessWidget {
  const MaterialTypographyTab({super.key});

  @override
  Widget build(BuildContext context) {
    final textStyles = _getMaterialTextStyles();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Material Design Typography',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Select typography styles to add to your design system',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
        ),
        const SizedBox(height: 24),
        ...textStyles.map((style) => _buildTypographyCard(context, style)),
      ],
    );
  }

  Widget _buildTypographyCard(BuildContext context, MaterialTextStyle style) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        style.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${style.fontSize}px / ${style.fontWeight} / ${style.lineHeight}px',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                              fontFamily: 'monospace',
                            ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    _addTypographyToDesignSystem(context, style);
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                style.sampleText,
                style: TextStyle(
                  fontSize: style.fontSize,
                  fontWeight: FontWeight.values[style.fontWeight ~/ 100 - 1],
                  height: style.lineHeight / style.fontSize,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addTypographyToDesignSystem(BuildContext context, MaterialTextStyle style) {
    final provider = Provider.of<DesignSystemProvider>(context, listen: false);
    final typo = provider.designSystem.typography;
    final key = 'material_${style.name.toLowerCase().replaceAll(' ', '_')}';
    if (typo.textStyles.containsKey(key)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('“${style.name}” is already in your project — see Typography'),
          backgroundColor: Colors.blue,
        ),
      );
      return;
    }
    final lineHeightStr = style.fontSize > 0
        ? (style.lineHeight / style.fontSize).toStringAsPrecision(3)
        : '1.25';
    final updated = Map<String, models.TextStyle>.from(typo.textStyles)
      ..[key] = models.TextStyle(
        fontFamily: typo.fontFamily.primary,
        fontSize: '${style.fontSize.toInt()}px',
        fontWeight: style.fontWeight,
        lineHeight: lineHeightStr,
      );
    provider.updateTypography(models.Typography(
      fontFamily: typo.fontFamily,
      fontWeights: typo.fontWeights,
      fontSizes: typo.fontSizes,
      textStyles: updated,
    ));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('“${style.name}” added — see Typography & Preview'),
        backgroundColor: Colors.green,
      ),
    );
  }

  List<MaterialTextStyle> _getMaterialTextStyles() {
    return [
      MaterialTextStyle(
        name: 'Display Large',
        fontSize: 57,
        fontWeight: 400,
        lineHeight: 64,
        sampleText: 'Display Large',
      ),
      MaterialTextStyle(
        name: 'Display Medium',
        fontSize: 45,
        fontWeight: 400,
        lineHeight: 52,
        sampleText: 'Display Medium',
      ),
      MaterialTextStyle(
        name: 'Display Small',
        fontSize: 36,
        fontWeight: 400,
        lineHeight: 44,
        sampleText: 'Display Small',
      ),
      MaterialTextStyle(
        name: 'Headline Large',
        fontSize: 32,
        fontWeight: 400,
        lineHeight: 40,
        sampleText: 'Headline Large',
      ),
      MaterialTextStyle(
        name: 'Headline Medium',
        fontSize: 28,
        fontWeight: 400,
        lineHeight: 36,
        sampleText: 'Headline Medium',
      ),
      MaterialTextStyle(
        name: 'Headline Small',
        fontSize: 24,
        fontWeight: 400,
        lineHeight: 32,
        sampleText: 'Headline Small',
      ),
      MaterialTextStyle(
        name: 'Title Large',
        fontSize: 22,
        fontWeight: 500,
        lineHeight: 28,
        sampleText: 'Title Large',
      ),
      MaterialTextStyle(
        name: 'Title Medium',
        fontSize: 16,
        fontWeight: 500,
        lineHeight: 24,
        sampleText: 'Title Medium',
      ),
      MaterialTextStyle(
        name: 'Title Small',
        fontSize: 14,
        fontWeight: 500,
        lineHeight: 20,
        sampleText: 'Title Small',
      ),
      MaterialTextStyle(
        name: 'Body Large',
        fontSize: 16,
        fontWeight: 400,
        lineHeight: 24,
        sampleText: 'Body Large - The quick brown fox jumps over the lazy dog',
      ),
      MaterialTextStyle(
        name: 'Body Medium',
        fontSize: 14,
        fontWeight: 400,
        lineHeight: 20,
        sampleText: 'Body Medium - The quick brown fox jumps over the lazy dog',
      ),
      MaterialTextStyle(
        name: 'Body Small',
        fontSize: 12,
        fontWeight: 400,
        lineHeight: 16,
        sampleText: 'Body Small - The quick brown fox jumps over the lazy dog',
      ),
      MaterialTextStyle(
        name: 'Label Large',
        fontSize: 14,
        fontWeight: 500,
        lineHeight: 20,
        sampleText: 'Label Large',
      ),
      MaterialTextStyle(
        name: 'Label Medium',
        fontSize: 12,
        fontWeight: 500,
        lineHeight: 16,
        sampleText: 'Label Medium',
      ),
      MaterialTextStyle(
        name: 'Label Small',
        fontSize: 11,
        fontWeight: 500,
        lineHeight: 16,
        sampleText: 'Label Small',
      ),
    ];
  }
}

class MaterialTextStyle {
  final String name;
  final double fontSize;
  final int fontWeight;
  final double lineHeight;
  final String sampleText;

  MaterialTextStyle({
    required this.name,
    required this.fontSize,
    required this.fontWeight,
    required this.lineHeight,
    required this.sampleText,
  });
}
