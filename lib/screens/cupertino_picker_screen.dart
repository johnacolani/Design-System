import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class CupertinoPickerScreen extends StatefulWidget {
  final bool isColorPickerMode;
  
  const CupertinoPickerScreen({
    super.key,
    this.isColorPickerMode = true,
  });

  @override
  State<CupertinoPickerScreen> createState() => _CupertinoPickerScreenState();
}

class _CupertinoPickerScreenState extends State<CupertinoPickerScreen>
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
        title: const Text('Cupertino (iOS) Design Library'),
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
          CupertinoColorsTab(isColorPickerMode: widget.isColorPickerMode),
          const CupertinoIconsTab(),
          const CupertinoComponentsTab(),
          const CupertinoTypographyTab(),
        ],
      ),
    );
  }
}

// Cupertino Colors Tab
class CupertinoColorsTab extends StatefulWidget {
  final bool isColorPickerMode;
  
  const CupertinoColorsTab({
    super.key,
    this.isColorPickerMode = false,
  });

  @override
  State<CupertinoColorsTab> createState() => _CupertinoColorsTabState();
}

class _CupertinoColorsTabState extends State<CupertinoColorsTab> {
  Color? _selectedColor;

  @override
  Widget build(BuildContext context) {
    final cupertinoColors = _getCupertinoColorPalettes();

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
                'iOS System Colors',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.isColorPickerMode
                    ? 'Tap a color to select it, then click "Use This Color"'
                    : 'Select iOS system colors to add to your design system',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 24),
              ...cupertinoColors.map((color) => _buildColorCard(context, color)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildColorCard(BuildContext context, CupertinoColorItem color) {
    final isSelected = widget.isColorPickerMode && _selectedColor == color.color;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: widget.isColorPickerMode
            ? () {
                setState(() {
                  _selectedColor = color.color;
                });
              }
            : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color.color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.black : Colors.grey[300]!,
                    width: isSelected ? 3 : 1,
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white, size: 24)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      color.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      color.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _colorToHex(color.color),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                            fontFamily: 'monospace',
                          ),
                    ),
                  ],
                ),
              ),
              if (!widget.isColorPickerMode)
                ElevatedButton.icon(
                  onPressed: () {
                    _addColorToDesignSystem(context, color);
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  void _addColorToDesignSystem(BuildContext context, CupertinoColorItem color) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add ${color.name}'),
        content: Text('Add ${color.name} color to your design system?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${color.name} added successfully!'),
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

  List<CupertinoColorItem> _getCupertinoColorPalettes() {
    return [
      CupertinoColorItem(
        name: 'System Blue',
        description: 'Primary system blue color',
        color: CupertinoColors.systemBlue,
      ),
      CupertinoColorItem(
        name: 'System Green',
        description: 'Success and positive actions',
        color: CupertinoColors.systemGreen,
      ),
      CupertinoColorItem(
        name: 'System Indigo',
        description: 'System indigo color',
        color: CupertinoColors.systemIndigo,
      ),
      CupertinoColorItem(
        name: 'System Orange',
        description: 'Warning and attention',
        color: CupertinoColors.systemOrange,
      ),
      CupertinoColorItem(
        name: 'System Pink',
        description: 'System pink color',
        color: CupertinoColors.systemPink,
      ),
      CupertinoColorItem(
        name: 'System Purple',
        description: 'System purple color',
        color: CupertinoColors.systemPurple,
      ),
      CupertinoColorItem(
        name: 'System Red',
        description: 'Error and destructive actions',
        color: CupertinoColors.systemRed,
      ),
      CupertinoColorItem(
        name: 'System Teal',
        description: 'System teal color',
        color: CupertinoColors.systemTeal,
      ),
      CupertinoColorItem(
        name: 'System Yellow',
        description: 'Warning and highlights',
        color: CupertinoColors.systemYellow,
      ),
      CupertinoColorItem(
        name: 'System Grey',
        description: 'Neutral grey color',
        color: CupertinoColors.systemGrey,
      ),
      CupertinoColorItem(
        name: 'System Grey 2',
        description: 'Secondary grey color',
        color: CupertinoColors.systemGrey2,
      ),
      CupertinoColorItem(
        name: 'System Grey 3',
        description: 'Tertiary grey color',
        color: CupertinoColors.systemGrey3,
      ),
      CupertinoColorItem(
        name: 'System Grey 4',
        description: 'Quaternary grey color',
        color: CupertinoColors.systemGrey4,
      ),
      CupertinoColorItem(
        name: 'System Grey 5',
        description: 'Quinary grey color',
        color: CupertinoColors.systemGrey5,
      ),
      CupertinoColorItem(
        name: 'System Grey 6',
        description: 'Senary grey color',
        color: CupertinoColors.systemGrey6,
      ),
      CupertinoColorItem(
        name: 'Label',
        description: 'Text label color (adapts to light/dark mode)',
        color: CupertinoColors.label,
      ),
      CupertinoColorItem(
        name: 'Secondary Label',
        description: 'Secondary text label color',
        color: CupertinoColors.secondaryLabel,
      ),
      CupertinoColorItem(
        name: 'Tertiary Label',
        description: 'Tertiary text label color',
        color: CupertinoColors.tertiaryLabel,
      ),
      CupertinoColorItem(
        name: 'Quaternary Label',
        description: 'Quaternary text label color',
        color: CupertinoColors.quaternaryLabel,
      ),
      CupertinoColorItem(
        name: 'Separator',
        description: 'Separator color',
        color: CupertinoColors.separator,
      ),
      CupertinoColorItem(
        name: 'Opaque Separator',
        description: 'Opaque separator color',
        color: CupertinoColors.opaqueSeparator,
      ),
      CupertinoColorItem(
        name: 'Link',
        description: 'Link color',
        color: CupertinoColors.link,
      ),
      CupertinoColorItem(
        name: 'Placeholder Text',
        description: 'Placeholder text color',
        color: CupertinoColors.placeholderText,
      ),
      CupertinoColorItem(
        name: 'System Background',
        description: 'System background color',
        color: CupertinoColors.systemBackground,
      ),
      CupertinoColorItem(
        name: 'Secondary System Background',
        description: 'Secondary system background color',
        color: CupertinoColors.secondarySystemBackground,
      ),
      CupertinoColorItem(
        name: 'Tertiary System Background',
        description: 'Tertiary system background color',
        color: CupertinoColors.tertiarySystemBackground,
      ),
      CupertinoColorItem(
        name: 'System Grouped Background',
        description: 'System grouped background color',
        color: CupertinoColors.systemGroupedBackground,
      ),
      CupertinoColorItem(
        name: 'Secondary System Grouped Background',
        description: 'Secondary system grouped background color',
        color: CupertinoColors.secondarySystemGroupedBackground,
      ),
      CupertinoColorItem(
        name: 'Tertiary System Grouped Background',
        description: 'Tertiary system grouped background color',
        color: CupertinoColors.tertiarySystemGroupedBackground,
      ),
      CupertinoColorItem(
        name: 'System Fill',
        description: 'System fill color',
        color: CupertinoColors.systemFill,
      ),
      CupertinoColorItem(
        name: 'Secondary System Fill',
        description: 'Secondary system fill color',
        color: CupertinoColors.secondarySystemFill,
      ),
      CupertinoColorItem(
        name: 'Tertiary System Fill',
        description: 'Tertiary system fill color',
        color: CupertinoColors.tertiarySystemFill,
      ),
      CupertinoColorItem(
        name: 'Quaternary System Fill',
        description: 'Quaternary system fill color',
        color: CupertinoColors.quaternarySystemFill,
      ),
    ];
  }
}

class CupertinoColorItem {
  final String name;
  final String description;
  final Color color;

  CupertinoColorItem({
    required this.name,
    required this.description,
    required this.color,
  });
}

// Cupertino Icons Tab
class CupertinoIconsTab extends StatefulWidget {
  const CupertinoIconsTab({super.key});

  @override
  State<CupertinoIconsTab> createState() => _CupertinoIconsTabState();
}

class _CupertinoIconsTabState extends State<CupertinoIconsTab> {
  final TextEditingController _searchController = TextEditingController();
  List<IconData> _filteredIcons = [];
  List<IconData> _allIcons = [];

  @override
  void initState() {
    super.initState();
    _loadCupertinoIcons();
    _searchController.addListener(_filterIcons);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadCupertinoIcons() {
    _allIcons = [
      CupertinoIcons.add,
      CupertinoIcons.add_circled,
      CupertinoIcons.add_circled_solid,
      CupertinoIcons.ant,
      CupertinoIcons.ant_circle,
      CupertinoIcons.ant_circle_fill,
      CupertinoIcons.ant_fill,
      CupertinoIcons.archivebox,
      CupertinoIcons.archivebox_fill,
      CupertinoIcons.arrow_down,
      CupertinoIcons.arrow_down_circle,
      CupertinoIcons.arrow_down_circle_fill,
      CupertinoIcons.arrow_down_square,
      CupertinoIcons.arrow_down_square_fill,
      CupertinoIcons.arrow_left,
      CupertinoIcons.arrow_left_circle,
      CupertinoIcons.arrow_left_circle_fill,
      CupertinoIcons.arrow_left_right,
      CupertinoIcons.arrow_left_right_circle,
      CupertinoIcons.arrow_left_right_circle_fill,
      CupertinoIcons.arrow_left_right_square,
      CupertinoIcons.arrow_left_right_square_fill,
      CupertinoIcons.arrow_left_square,
      CupertinoIcons.arrow_left_square_fill,
      CupertinoIcons.arrow_right,
      CupertinoIcons.arrow_right_circle,
      CupertinoIcons.arrow_right_circle_fill,
      CupertinoIcons.arrow_right_square,
      CupertinoIcons.arrow_right_square_fill,
      CupertinoIcons.arrow_turn_down_left,
      CupertinoIcons.arrow_turn_down_right,
      CupertinoIcons.arrow_turn_up_left,
      CupertinoIcons.arrow_turn_up_right,
      CupertinoIcons.arrow_up,
      CupertinoIcons.arrow_up_circle,
      CupertinoIcons.arrow_up_circle_fill,
      CupertinoIcons.arrow_up_down,
      CupertinoIcons.arrow_up_down_circle,
      CupertinoIcons.arrow_up_down_circle_fill,
      CupertinoIcons.arrow_up_down_square,
      CupertinoIcons.arrow_up_down_square_fill,
      CupertinoIcons.arrow_up_square,
      CupertinoIcons.arrow_up_square_fill,
      CupertinoIcons.arrow_uturn_down,
      CupertinoIcons.arrow_uturn_down_circle,
      CupertinoIcons.arrow_uturn_down_circle_fill,
      CupertinoIcons.arrow_uturn_down_square,
      CupertinoIcons.arrow_uturn_down_square_fill,
      CupertinoIcons.arrow_uturn_left,
      CupertinoIcons.arrow_uturn_left_circle,
      CupertinoIcons.arrow_uturn_left_circle_fill,
      CupertinoIcons.arrow_uturn_left_square,
      CupertinoIcons.arrow_uturn_left_square_fill,
      CupertinoIcons.arrow_uturn_right,
      CupertinoIcons.arrow_uturn_right_circle,
      CupertinoIcons.arrow_uturn_right_circle_fill,
      CupertinoIcons.arrow_uturn_right_square,
      CupertinoIcons.arrow_uturn_right_square_fill,
      CupertinoIcons.arrow_uturn_up,
      CupertinoIcons.arrow_uturn_up_circle,
      CupertinoIcons.arrow_uturn_up_circle_fill,
      CupertinoIcons.arrow_uturn_up_square,
      CupertinoIcons.arrow_uturn_up_square_fill,
      CupertinoIcons.bell,
      CupertinoIcons.bell_fill,
      CupertinoIcons.bell_slash,
      CupertinoIcons.bell_slash_fill,
      CupertinoIcons.book,
      CupertinoIcons.book_fill,
      CupertinoIcons.bookmark,
      CupertinoIcons.bookmark_fill,
      CupertinoIcons.briefcase,
      CupertinoIcons.briefcase_fill,
      CupertinoIcons.bubble_left,
      CupertinoIcons.bubble_left_bubble_right,
      CupertinoIcons.bubble_left_bubble_right_fill,
      CupertinoIcons.bubble_left_fill,
      CupertinoIcons.bubble_middle_bottom,
      CupertinoIcons.bubble_middle_bottom_fill,
      CupertinoIcons.bubble_right,
      CupertinoIcons.bubble_right_fill,
      CupertinoIcons.calendar,
      CupertinoIcons.calendar_badge_minus,
      CupertinoIcons.calendar_badge_plus,
      CupertinoIcons.calendar_today,
      CupertinoIcons.camera,
      CupertinoIcons.camera_fill,
      CupertinoIcons.camera_rotate,
      CupertinoIcons.camera_rotate_fill,
      CupertinoIcons.cart,
      CupertinoIcons.cart_badge_minus,
      CupertinoIcons.cart_badge_plus,
      CupertinoIcons.cart_fill,
      CupertinoIcons.chat_bubble,
      CupertinoIcons.chat_bubble_2,
      CupertinoIcons.chat_bubble_2_fill,
      CupertinoIcons.chat_bubble_fill,
      CupertinoIcons.check_mark,
      CupertinoIcons.check_mark_circled,
      CupertinoIcons.check_mark_circled_solid,
      CupertinoIcons.checkmark_seal,
      CupertinoIcons.checkmark_seal_fill,
      CupertinoIcons.checkmark,
      CupertinoIcons.checkmark_circle,
      CupertinoIcons.checkmark_circle_fill,
      CupertinoIcons.checkmark_rectangle,
      CupertinoIcons.checkmark_rectangle_fill,
      CupertinoIcons.checkmark_seal,
      CupertinoIcons.checkmark_seal_fill,
      CupertinoIcons.checkmark_shield,
      CupertinoIcons.checkmark_shield_fill,
      CupertinoIcons.checkmark_square,
      CupertinoIcons.checkmark_square_fill,
      CupertinoIcons.chevron_down,
      CupertinoIcons.chevron_down_circle,
      CupertinoIcons.chevron_down_circle_fill,
      CupertinoIcons.chevron_down_square,
      CupertinoIcons.chevron_down_square_fill,
      CupertinoIcons.chevron_left,
      CupertinoIcons.chevron_left_2,
      CupertinoIcons.chevron_left_circle,
      CupertinoIcons.chevron_left_circle_fill,
      CupertinoIcons.chevron_left_square,
      CupertinoIcons.chevron_left_square_fill,
      CupertinoIcons.chevron_right,
      CupertinoIcons.chevron_right_2,
      CupertinoIcons.chevron_right_circle,
      CupertinoIcons.chevron_right_circle_fill,
      CupertinoIcons.chevron_right_square,
      CupertinoIcons.chevron_right_square_fill,
      CupertinoIcons.chevron_up,
      CupertinoIcons.chevron_up_circle,
      CupertinoIcons.chevron_up_circle_fill,
      CupertinoIcons.chevron_up_square,
      CupertinoIcons.chevron_up_square_fill,
      CupertinoIcons.circle_bottomthird_split,
      CupertinoIcons.circle_fill,
      CupertinoIcons.circle_grid_3x3,
      CupertinoIcons.circle_grid_3x3_fill,
      CupertinoIcons.circle_grid_3x3,
      CupertinoIcons.circle_grid_3x3_fill,
      CupertinoIcons.circle_lefthalf_fill,
      CupertinoIcons.circle_righthalf_fill,
      CupertinoIcons.clear,
      CupertinoIcons.clear_circled,
      CupertinoIcons.clear_circled_solid,
      CupertinoIcons.clear_fill,
      CupertinoIcons.clear_thick,
      CupertinoIcons.clear_thick_circled,
      CupertinoIcons.clock,
      CupertinoIcons.clock_fill,
      CupertinoIcons.cloud,
      CupertinoIcons.cloud_download,
      CupertinoIcons.cloud_download_fill,
      CupertinoIcons.cloud_fill,
      CupertinoIcons.cloud_upload,
      CupertinoIcons.cloud_upload_fill,
      CupertinoIcons.collections,
      CupertinoIcons.collections_solid,
      CupertinoIcons.color_filter,
      CupertinoIcons.color_filter_fill,
      CupertinoIcons.compass,
      CupertinoIcons.compass_fill,
      CupertinoIcons.control,
      CupertinoIcons.creditcard,
      CupertinoIcons.creditcard_fill,
      CupertinoIcons.crop,
      CupertinoIcons.crop_rotate,
      CupertinoIcons.cube,
      CupertinoIcons.cube_box,
      CupertinoIcons.cube_box_fill,
      CupertinoIcons.cube_fill,
      CupertinoIcons.decrease_indent,
      CupertinoIcons.decrease_quotelevel,
      CupertinoIcons.delete,
      CupertinoIcons.delete_left,
      CupertinoIcons.delete_left_fill,
      CupertinoIcons.delete_right,
      CupertinoIcons.delete_right_fill,
      CupertinoIcons.delete_simple,
      CupertinoIcons.delete_simple,
      CupertinoIcons.device_desktop,
      CupertinoIcons.device_laptop,
      CupertinoIcons.device_phone_portrait,
      CupertinoIcons.doc,
      CupertinoIcons.doc_append,
      CupertinoIcons.doc_chart,
      CupertinoIcons.doc_chart_fill,
      CupertinoIcons.doc_checkmark,
      CupertinoIcons.doc_checkmark_fill,
      CupertinoIcons.doc_circle,
      CupertinoIcons.doc_circle_fill,
      CupertinoIcons.doc_fill,
      CupertinoIcons.doc_on_clipboard,
      CupertinoIcons.doc_on_clipboard_fill,
      CupertinoIcons.doc_on_doc,
      CupertinoIcons.doc_on_doc_fill,
      CupertinoIcons.doc_on_doc,
      CupertinoIcons.doc_on_doc_fill,
      CupertinoIcons.doc_person,
      CupertinoIcons.doc_person_fill,
      CupertinoIcons.doc_richtext,
      CupertinoIcons.doc_richtext,
      CupertinoIcons.doc_text,
      CupertinoIcons.doc_text_fill,
      CupertinoIcons.doc_text_search,
      CupertinoIcons.doc_text_viewfinder,
      CupertinoIcons.money_dollar_circle,
      CupertinoIcons.money_dollar_circle_fill,
      CupertinoIcons.money_dollar,
      CupertinoIcons.down_arrow,
      CupertinoIcons.download_circle,
      CupertinoIcons.download_circle_fill,
      CupertinoIcons.eject,
      CupertinoIcons.eject_fill,
      CupertinoIcons.ellipses_bubble,
      CupertinoIcons.ellipses_bubble_fill,
      CupertinoIcons.ellipsis,
      CupertinoIcons.ellipsis_circle,
      CupertinoIcons.ellipsis_circle_fill,
      CupertinoIcons.envelope,
      CupertinoIcons.envelope_badge,
      CupertinoIcons.envelope_badge_fill,
      CupertinoIcons.envelope_fill,
      CupertinoIcons.envelope_open,
      CupertinoIcons.envelope_open_fill,
      CupertinoIcons.equal,
      CupertinoIcons.equal_circle,
      CupertinoIcons.equal_circle_fill,
      CupertinoIcons.equal_square,
      CupertinoIcons.equal_square_fill,
      CupertinoIcons.escape,
      CupertinoIcons.exclamationmark,
      CupertinoIcons.exclamationmark_circle,
      CupertinoIcons.exclamationmark_circle_fill,
      CupertinoIcons.exclamationmark_octagon,
      CupertinoIcons.exclamationmark_octagon_fill,
      CupertinoIcons.exclamationmark_shield,
      CupertinoIcons.exclamationmark_shield_fill,
      CupertinoIcons.exclamationmark_square,
      CupertinoIcons.exclamationmark_square_fill,
      CupertinoIcons.exclamationmark_triangle,
      CupertinoIcons.exclamationmark_triangle_fill,
      CupertinoIcons.eye,
      CupertinoIcons.eye_fill,
      CupertinoIcons.eye_slash,
      CupertinoIcons.eye_slash_fill,
      CupertinoIcons.eye_solid,
      CupertinoIcons.eye_slash,
      CupertinoIcons.eyedropper,
      CupertinoIcons.eyedropper_full,
      CupertinoIcons.film,
      CupertinoIcons.film_fill,
      CupertinoIcons.flag,
      CupertinoIcons.flag_fill,
      CupertinoIcons.flag_slash,
      CupertinoIcons.flag_slash_fill,
      CupertinoIcons.flame,
      CupertinoIcons.flame_fill,
      CupertinoIcons.folder,
      CupertinoIcons.folder_badge_minus,
      CupertinoIcons.folder_badge_minus,
      CupertinoIcons.folder_badge_person_crop,
      CupertinoIcons.folder_badge_plus,
      CupertinoIcons.folder_fill,
      CupertinoIcons.forward,
      CupertinoIcons.forward_fill,
      CupertinoIcons.game_controller,
      CupertinoIcons.game_controller_solid,
      CupertinoIcons.gear,
      CupertinoIcons.gear_alt,
      CupertinoIcons.gear_alt_fill,
      CupertinoIcons.gear_big,
      CupertinoIcons.gear_solid,
      CupertinoIcons.gift,
      CupertinoIcons.gift_fill,
      CupertinoIcons.globe,
      CupertinoIcons.graph_circle,
      CupertinoIcons.graph_circle_fill,
      CupertinoIcons.graph_square,
      CupertinoIcons.graph_square_fill,
      CupertinoIcons.grid,
      CupertinoIcons.grid_circle,
      CupertinoIcons.grid_circle_fill,
      CupertinoIcons.hand_point_left,
      CupertinoIcons.hand_point_left_fill,
      CupertinoIcons.hand_point_right,
      CupertinoIcons.hand_point_right_fill,
      CupertinoIcons.hand_raised,
      CupertinoIcons.hand_raised_fill,
      CupertinoIcons.hand_raised_slash,
      CupertinoIcons.hand_raised_slash_fill,
      CupertinoIcons.hand_thumbsdown,
      CupertinoIcons.hand_thumbsdown_fill,
      CupertinoIcons.hand_thumbsup,
      CupertinoIcons.hand_thumbsup_fill,
      CupertinoIcons.hare,
      CupertinoIcons.hare_fill,
      CupertinoIcons.headphones,
      CupertinoIcons.heart,
      CupertinoIcons.heart_circle,
      CupertinoIcons.heart_circle_fill,
      CupertinoIcons.heart_fill,
      CupertinoIcons.heart_slash,
      CupertinoIcons.heart_slash_fill,
      CupertinoIcons.helm,
      CupertinoIcons.house,
      CupertinoIcons.house_alt,
      CupertinoIcons.house_alt_fill,
      CupertinoIcons.house_fill,
      CupertinoIcons.hurricane,
      CupertinoIcons.info,
      CupertinoIcons.info_circle,
      CupertinoIcons.info_circle_fill,
      CupertinoIcons.increase_indent,
      CupertinoIcons.increase_quotelevel,
      CupertinoIcons.largecircle_fill_circle,
      CupertinoIcons.lasso,
      CupertinoIcons.layers,
      CupertinoIcons.layers_alt,
      CupertinoIcons.left_chevron,
      CupertinoIcons.light_max,
      CupertinoIcons.light_min,
      CupertinoIcons.link,
      CupertinoIcons.link_circle,
      CupertinoIcons.link_circle_fill,
      CupertinoIcons.list_bullet,
      CupertinoIcons.list_bullet_below_rectangle,
      CupertinoIcons.list_bullet_indent,
      CupertinoIcons.list_dash,
      CupertinoIcons.list_number,
      CupertinoIcons.location,
      CupertinoIcons.location_circle,
      CupertinoIcons.location_circle_fill,
      CupertinoIcons.location_fill,
      CupertinoIcons.location_slash,
      CupertinoIcons.location_slash_fill,
      CupertinoIcons.lock,
      CupertinoIcons.lock_circle,
      CupertinoIcons.lock_circle_fill,
      CupertinoIcons.lock_fill,
      CupertinoIcons.lock_open,
      CupertinoIcons.lock_open_fill,
      CupertinoIcons.lock_rotation,
      CupertinoIcons.lock_rotation_open,
      CupertinoIcons.lock_shield,
      CupertinoIcons.lock_shield_fill,
      CupertinoIcons.lock_slash,
      CupertinoIcons.lock_slash_fill,
      CupertinoIcons.mail,
      CupertinoIcons.map,
      CupertinoIcons.map_fill,
      CupertinoIcons.memories,
      CupertinoIcons.memories_badge_minus,
      CupertinoIcons.memories_badge_plus,
      CupertinoIcons.mic,
      CupertinoIcons.mic_circle,
      CupertinoIcons.mic_circle_fill,
      CupertinoIcons.mic_fill,
      CupertinoIcons.mic_slash,
      CupertinoIcons.mic_slash_fill,
      CupertinoIcons.minus,
      CupertinoIcons.minus_circle,
      CupertinoIcons.minus_circle_fill,
      CupertinoIcons.minus_rectangle,
      CupertinoIcons.minus_rectangle_fill,
      CupertinoIcons.minus_square,
      CupertinoIcons.minus_square_fill,
      CupertinoIcons.money_dollar,
      CupertinoIcons.money_dollar_circle,
      CupertinoIcons.money_dollar_circle_fill,
      CupertinoIcons.money_euro,
      CupertinoIcons.money_euro_circle,
      CupertinoIcons.money_euro_circle_fill,
      CupertinoIcons.money_pound,
      CupertinoIcons.money_pound_circle,
      CupertinoIcons.money_pound_circle_fill,
      CupertinoIcons.money_yen,
      CupertinoIcons.money_yen_circle,
      CupertinoIcons.money_yen_circle_fill,
      CupertinoIcons.moon,
      CupertinoIcons.moon_circle,
      CupertinoIcons.moon_circle_fill,
      CupertinoIcons.moon_fill,
      CupertinoIcons.moon_stars,
      CupertinoIcons.moon_stars_fill,
      CupertinoIcons.moon_zzz,
      CupertinoIcons.moon_zzz_fill,
      CupertinoIcons.music_albums,
      CupertinoIcons.music_albums_fill,
      CupertinoIcons.music_mic,
      CupertinoIcons.music_note,
      CupertinoIcons.music_note_2,
      CupertinoIcons.nosign,
      CupertinoIcons.number,
      CupertinoIcons.number_circle,
      CupertinoIcons.number_circle_fill,
      CupertinoIcons.number_square,
      CupertinoIcons.number_square_fill,
      CupertinoIcons.option,
      CupertinoIcons.paintbrush,
      CupertinoIcons.paintbrush_fill,
      CupertinoIcons.paperclip,
      CupertinoIcons.paperplane,
      CupertinoIcons.paperplane_fill,
      CupertinoIcons.person,
      CupertinoIcons.person_2,
      CupertinoIcons.person_2_fill,
      CupertinoIcons.person_2_square_stack,
      CupertinoIcons.person_2_square_stack_fill,
      CupertinoIcons.person_3,
      CupertinoIcons.person_3_fill,
      CupertinoIcons.person_alt,
      CupertinoIcons.person_alt_circle,
      CupertinoIcons.person_alt_circle_fill,
      CupertinoIcons.person_badge_minus,
      CupertinoIcons.person_badge_minus_fill,
      CupertinoIcons.person_badge_plus,
      CupertinoIcons.person_badge_plus_fill,
      CupertinoIcons.person_circle,
      CupertinoIcons.person_circle_fill,
      CupertinoIcons.person_crop_circle,
      CupertinoIcons.person_crop_circle_badge_checkmark,
      CupertinoIcons.person_crop_circle_badge_minus,
      CupertinoIcons.person_crop_circle_badge_plus,
      CupertinoIcons.person_crop_circle_badge_xmark,
      CupertinoIcons.person_crop_circle_fill,
      CupertinoIcons.person_crop_rectangle,
      CupertinoIcons.person_crop_rectangle_fill,
      CupertinoIcons.person_crop_square,
      CupertinoIcons.person_crop_square_fill,
      CupertinoIcons.person_fill,
      CupertinoIcons.phone,
      CupertinoIcons.phone_arrow_down_left,
      CupertinoIcons.phone_arrow_right,
      CupertinoIcons.phone_arrow_up_right,
      CupertinoIcons.phone_badge_plus,
      CupertinoIcons.phone_circle,
      CupertinoIcons.phone_circle_fill,
      CupertinoIcons.phone_down,
      CupertinoIcons.phone_down_circle,
      CupertinoIcons.phone_down_circle_fill,
      CupertinoIcons.phone_down_fill,
      CupertinoIcons.phone_fill,
      CupertinoIcons.phone_fill_arrow_down_left,
      CupertinoIcons.phone_fill_arrow_right,
      CupertinoIcons.phone_fill_arrow_up_right,
      CupertinoIcons.phone_fill_badge_plus,
      CupertinoIcons.photo,
      CupertinoIcons.photo_fill,
      CupertinoIcons.photo_fill_on_rectangle_fill,
      CupertinoIcons.photo_on_rectangle,
      CupertinoIcons.pin,
      CupertinoIcons.pin_fill,
      CupertinoIcons.pin_slash,
      CupertinoIcons.pin_slash_fill,
      CupertinoIcons.placemark,
      CupertinoIcons.placemark_fill,
      CupertinoIcons.play,
      CupertinoIcons.play_circle,
      CupertinoIcons.play_circle_fill,
      CupertinoIcons.play_fill,
      CupertinoIcons.play_rectangle,
      CupertinoIcons.play_rectangle_fill,
      CupertinoIcons.playpause,
      CupertinoIcons.playpause_fill,
      CupertinoIcons.plus,
      CupertinoIcons.plus_app,
      CupertinoIcons.plus_app_fill,
      CupertinoIcons.plus_bubble,
      CupertinoIcons.plus_bubble_fill,
      CupertinoIcons.plus_circle,
      CupertinoIcons.plus_circle_fill,
      CupertinoIcons.plus_rectangle,
      CupertinoIcons.plus_rectangle_fill,
      CupertinoIcons.plus_slash_minus,
      CupertinoIcons.plus_square,
      CupertinoIcons.plus_square_fill,
      CupertinoIcons.plus_square_on_square,
      CupertinoIcons.power,
      CupertinoIcons.printer,
      CupertinoIcons.printer_fill,
      CupertinoIcons.projective,
      CupertinoIcons.purchased,
      CupertinoIcons.purchased_circle,
      CupertinoIcons.purchased_circle_fill,
      CupertinoIcons.qrcode,
      CupertinoIcons.qrcode_viewfinder,
      CupertinoIcons.question,
      CupertinoIcons.question_circle,
      CupertinoIcons.question_circle_fill,
      CupertinoIcons.question_diamond,
      CupertinoIcons.question_diamond_fill,
      CupertinoIcons.question_square,
      CupertinoIcons.question_square_fill,
      CupertinoIcons.quote_bubble,
      CupertinoIcons.quote_bubble_fill,
      CupertinoIcons.radiowaves_left,
      CupertinoIcons.radiowaves_right,
      CupertinoIcons.rectangle,
      CupertinoIcons.rectangle_arrow_up_right_arrow_down_left,
      CupertinoIcons.rectangle_arrow_up_right_arrow_down_left_slash,
      CupertinoIcons.rectangle_badge_checkmark,
      CupertinoIcons.rectangle_badge_xmark,
      CupertinoIcons.rectangle_compress_vertical,
      CupertinoIcons.rectangle_dock,
      CupertinoIcons.rectangle_expand_vertical,
      CupertinoIcons.rectangle_fill,
      CupertinoIcons.rectangle_fill_on_rectangle_angled_fill,
      CupertinoIcons.rectangle_grid_1x2,
      CupertinoIcons.rectangle_grid_1x2_fill,
      CupertinoIcons.rectangle_grid_2x2,
      CupertinoIcons.rectangle_grid_2x2_fill,
      CupertinoIcons.rectangle_grid_3x2,
      CupertinoIcons.rectangle_grid_3x2_fill,
      CupertinoIcons.rectangle_on_rectangle,
      CupertinoIcons.rectangle_on_rectangle_angled,
      CupertinoIcons.rectangle_paperclip,
      CupertinoIcons.rectangle_stack,
      CupertinoIcons.rectangle_stack_badge_minus,
      CupertinoIcons.rectangle_stack_badge_plus,
      CupertinoIcons.rectangle_stack_fill,
      CupertinoIcons.rectangle_stack_fill_badge_minus,
      CupertinoIcons.rectangle_stack_fill_badge_plus,
      CupertinoIcons.rectangle_stack_person_crop,
      CupertinoIcons.rectangle_stack_person_crop_fill,
      CupertinoIcons.repeat,
      CupertinoIcons.repeat_1,
      CupertinoIcons.restart,
      CupertinoIcons.return_icon,
      CupertinoIcons.rocket,
      CupertinoIcons.rocket_fill,
      CupertinoIcons.rotate_left,
      CupertinoIcons.rotate_left_fill,
      CupertinoIcons.rotate_right,
      CupertinoIcons.rotate_right_fill,
      CupertinoIcons.scissors,
      CupertinoIcons.scissors_alt,
      CupertinoIcons.scope,
      CupertinoIcons.search,
      CupertinoIcons.search_circle,
      CupertinoIcons.search_circle_fill,
      CupertinoIcons.selection_pin_in_out,
      CupertinoIcons.share,
      CupertinoIcons.share_solid,
      CupertinoIcons.share_up,
      CupertinoIcons.shield,
      CupertinoIcons.shield_fill,
      CupertinoIcons.shield_lefthalf_fill,
      CupertinoIcons.shield_slash,
      CupertinoIcons.shield_slash_fill,
      CupertinoIcons.sidebar_left,
      CupertinoIcons.sidebar_right,
      CupertinoIcons.signature,
      CupertinoIcons.slider_horizontal_3,
      CupertinoIcons.slider_horizontal_below_rectangle,
      CupertinoIcons.smallcircle_circle,
      CupertinoIcons.smallcircle_circle_fill,
      CupertinoIcons.smallcircle_fill_circle,
      CupertinoIcons.smoke,
      CupertinoIcons.smoke_fill,
      CupertinoIcons.snow,
      CupertinoIcons.sparkles,
      CupertinoIcons.speaker_1,
      CupertinoIcons.speaker_2,
      CupertinoIcons.speaker_2_fill,
      CupertinoIcons.speaker_3,
      CupertinoIcons.speaker_3_fill,
      CupertinoIcons.speaker_fill,
      CupertinoIcons.speaker_slash,
      CupertinoIcons.speaker_slash_fill,
      CupertinoIcons.speaker_zzz,
      CupertinoIcons.speaker_zzz_fill,
      CupertinoIcons.speedometer,
      CupertinoIcons.square,
      CupertinoIcons.square_arrow_down,
      CupertinoIcons.square_arrow_down_fill,
      CupertinoIcons.square_arrow_down_on_square,
      CupertinoIcons.square_arrow_down_on_square_fill,
      CupertinoIcons.square_arrow_left,
      CupertinoIcons.square_arrow_left_fill,
      CupertinoIcons.square_arrow_right,
      CupertinoIcons.square_arrow_right_fill,
      CupertinoIcons.square_arrow_up,
      CupertinoIcons.square_arrow_up_fill,
      CupertinoIcons.square_arrow_up_on_square,
      CupertinoIcons.square_arrow_up_on_square_fill,
      CupertinoIcons.square_fill,
      CupertinoIcons.square_fill_on_circle_fill,
      CupertinoIcons.square_fill_on_square_fill,
      CupertinoIcons.square_grid_2x2,
      CupertinoIcons.square_grid_2x2_fill,
      CupertinoIcons.square_grid_3x2,
      CupertinoIcons.square_grid_3x2_fill,
      CupertinoIcons.square_grid_4x3_fill,
      CupertinoIcons.square_lefthalf_fill,
      CupertinoIcons.square_list,
      CupertinoIcons.square_list_fill,
      CupertinoIcons.square_on_circle,
      CupertinoIcons.square_on_square,
      CupertinoIcons.square_pencil,
      CupertinoIcons.square_pencil_fill,
      CupertinoIcons.square_righthalf_fill,
      CupertinoIcons.square_split_1x2,
      CupertinoIcons.square_split_1x2_fill,
      CupertinoIcons.square_split_2x1,
      CupertinoIcons.square_split_2x1_fill,
      CupertinoIcons.square_split_2x2,
      CupertinoIcons.square_split_2x2_fill,
      CupertinoIcons.square_stack,
      CupertinoIcons.square_stack_3d_down_dottedline,
      CupertinoIcons.square_stack_3d_down_right,
      CupertinoIcons.square_stack_3d_down_right_fill,
      CupertinoIcons.square_stack_3d_up,
      CupertinoIcons.square_stack_3d_up_fill,
      CupertinoIcons.square_stack_3d_up_slash,
      CupertinoIcons.square_stack_3d_up_slash_fill,
      CupertinoIcons.square_stack_fill,
      CupertinoIcons.star,
      CupertinoIcons.star_circle,
      CupertinoIcons.star_circle_fill,
      CupertinoIcons.star_fill,
      CupertinoIcons.star_lefthalf_fill,
      CupertinoIcons.star_slash,
      CupertinoIcons.star_slash_fill,
      CupertinoIcons.staroflife,
      CupertinoIcons.staroflife_fill,
      CupertinoIcons.stop,
      CupertinoIcons.stop_circle,
      CupertinoIcons.stop_circle_fill,
      CupertinoIcons.stop_fill,
      CupertinoIcons.stopwatch,
      CupertinoIcons.stopwatch_fill,
      CupertinoIcons.strikethrough,
      CupertinoIcons.suit_club,
      CupertinoIcons.suit_club_fill,
      CupertinoIcons.suit_diamond,
      CupertinoIcons.suit_diamond_fill,
      CupertinoIcons.suit_heart,
      CupertinoIcons.suit_heart_fill,
      CupertinoIcons.suit_spade,
      CupertinoIcons.suit_spade_fill,
      CupertinoIcons.sun_dust,
      CupertinoIcons.sun_dust_fill,
      CupertinoIcons.sun_haze,
      CupertinoIcons.sun_haze_fill,
      CupertinoIcons.sun_max,
      CupertinoIcons.sun_max_fill,
      CupertinoIcons.sun_min,
      CupertinoIcons.sun_min_fill,
      CupertinoIcons.sunrise,
      CupertinoIcons.sunrise_fill,
      CupertinoIcons.sunset,
      CupertinoIcons.sunset_fill,
      CupertinoIcons.t_bubble,
      CupertinoIcons.t_bubble_fill,
      CupertinoIcons.table,
      CupertinoIcons.table_badge_more,
      CupertinoIcons.table_badge_more_fill,
      CupertinoIcons.table_fill,
      CupertinoIcons.tag,
      CupertinoIcons.tag_circle,
      CupertinoIcons.tag_circle_fill,
      CupertinoIcons.tag_fill,
      CupertinoIcons.text_aligncenter,
      CupertinoIcons.text_alignleft,
      CupertinoIcons.text_alignright,
      CupertinoIcons.text_append,
      CupertinoIcons.text_badge_checkmark,
      CupertinoIcons.text_badge_minus,
      CupertinoIcons.text_badge_plus,
      CupertinoIcons.text_badge_star,
      CupertinoIcons.text_badge_xmark,
      CupertinoIcons.text_bubble,
      CupertinoIcons.text_bubble_fill,
      CupertinoIcons.text_cursor,
      CupertinoIcons.text_insert,
      CupertinoIcons.text_justify,
      CupertinoIcons.text_justifyleft,
      CupertinoIcons.text_justifyright,
      CupertinoIcons.text_quote,
      CupertinoIcons.textbox,
      CupertinoIcons.textformat,
      CupertinoIcons.textformat_123,
      CupertinoIcons.textformat_abc,
      CupertinoIcons.textformat_abc_dottedunderline,
      CupertinoIcons.textformat_alt,
      CupertinoIcons.textformat_size,
      CupertinoIcons.textformat_subscript,
      CupertinoIcons.textformat_superscript,
      CupertinoIcons.thermometer,
      CupertinoIcons.thermometer_snowflake,
      CupertinoIcons.thermometer_sun,
      CupertinoIcons.ticket,
      CupertinoIcons.ticket_fill,
      CupertinoIcons.timelapse,
      CupertinoIcons.timer,
      CupertinoIcons.timer_fill,
      CupertinoIcons.tornado,
      CupertinoIcons.tortoise,
      CupertinoIcons.tortoise_fill,
      CupertinoIcons.tray,
      CupertinoIcons.tray_2,
      CupertinoIcons.tray_2_fill,
      CupertinoIcons.tray_arrow_down,
      CupertinoIcons.tray_arrow_down_fill,
      CupertinoIcons.tray_arrow_up,
      CupertinoIcons.tray_arrow_up_fill,
      CupertinoIcons.tray_fill,
      CupertinoIcons.tray_full,
      CupertinoIcons.tray_full_fill,
      CupertinoIcons.triangle,
      CupertinoIcons.triangle_fill,
      CupertinoIcons.triangle_lefthalf_fill,
      CupertinoIcons.triangle_righthalf_fill,
      CupertinoIcons.tropicalstorm,
      CupertinoIcons.tuningfork,
      CupertinoIcons.tv,
      CupertinoIcons.tv_fill,
      CupertinoIcons.tv_music_note,
      CupertinoIcons.tv_music_note_fill,
      CupertinoIcons.umbrella,
      CupertinoIcons.umbrella_fill,
      CupertinoIcons.underline,
      CupertinoIcons.upload_circle,
      CupertinoIcons.upload_circle_fill,
      CupertinoIcons.videocam,
      CupertinoIcons.viewfinder,
      CupertinoIcons.viewfinder_circle,
      CupertinoIcons.viewfinder_circle_fill,
      CupertinoIcons.wand_rays,
      CupertinoIcons.wand_rays_inverse,
      CupertinoIcons.wand_stars,
      CupertinoIcons.wand_stars_inverse,
      CupertinoIcons.waveform,
      CupertinoIcons.waveform_circle,
      CupertinoIcons.waveform_circle_fill,
      CupertinoIcons.waveform_path,
      CupertinoIcons.waveform_path_ecg,
      CupertinoIcons.wifi,
      CupertinoIcons.wifi_exclamationmark,
      CupertinoIcons.wifi_slash,
      CupertinoIcons.wind,
      CupertinoIcons.wind_snow,
      CupertinoIcons.wrench,
      CupertinoIcons.wrench_fill,
      CupertinoIcons.xmark,
      CupertinoIcons.xmark_circle,
      CupertinoIcons.xmark_circle_fill,
      CupertinoIcons.xmark_octagon,
      CupertinoIcons.xmark_octagon_fill,
      CupertinoIcons.xmark_rectangle,
      CupertinoIcons.xmark_rectangle_fill,
      CupertinoIcons.xmark_seal,
      CupertinoIcons.xmark_seal_fill,
      CupertinoIcons.xmark_shield,
      CupertinoIcons.xmark_shield_fill,
      CupertinoIcons.xmark_square,
      CupertinoIcons.xmark_square_fill,
      CupertinoIcons.zzz,
    ];
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
              hintText: 'Search Cupertino icons...',
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

  void _addIconToDesignSystem(BuildContext context, IconData icon) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Icon'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64),
            const SizedBox(height: 16),
            Text('Add "${_getIconName(icon)}" to your design system?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${_getIconName(icon)} added successfully!'),
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
}

// Cupertino Components Tab
class CupertinoComponentsTab extends StatelessWidget {
  const CupertinoComponentsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Cupertino Components',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Browse and add iOS-style components to your design system',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
        ),
        const SizedBox(height: 24),
        _buildComponentCard(
          context,
          'Buttons',
          'CupertinoButton styles',
          CupertinoIcons.arrow_right_circle,
          Colors.blue,
          _buildButtonExamples(),
        ),
        _buildComponentCard(
          context,
          'Navigation',
          'NavigationBar, TabBar',
          CupertinoIcons.bars,
          Colors.grey,
          _buildNavigationExamples(),
        ),
        _buildComponentCard(
          context,
          'Inputs',
          'Text fields, Search bars',
          CupertinoIcons.textbox,
          Colors.orange,
          _buildInputExamples(),
        ),
        _buildComponentCard(
          context,
          'Alerts & Actions',
          'AlertDialog, ActionSheet',
          CupertinoIcons.exclamationmark_triangle,
          Colors.red,
          _buildAlertExamples(),
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
        CupertinoButton(
          onPressed: () {},
          child: const Text('Cupertino Button'),
        ),
        const SizedBox(height: 8),
        CupertinoButton.filled(
          onPressed: () {},
          child: const Text('Filled Button'),
        ),
        const SizedBox(height: 8),
        CupertinoButton(
          color: CupertinoColors.destructiveRed,
          onPressed: () {},
          child: const Text('Destructive Button'),
        ),
      ],
    );
  }

  Widget _buildNavigationExamples() {
    return Column(
      children: [
        Container(
          height: 50,
          decoration: BoxDecoration(
            color: CupertinoColors.systemGrey6,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Text('Navigation Bar Example'),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 50,
          decoration: BoxDecoration(
            color: CupertinoColors.systemGrey6,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Text('Tab Bar Example'),
          ),
        ),
      ],
    );
  }

  Widget _buildInputExamples() {
    return Column(
      children: [
        CupertinoTextField(
          placeholder: 'Cupertino Text Field',
          padding: const EdgeInsets.all(12),
        ),
        const SizedBox(height: 16),
        CupertinoSearchTextField(
          placeholder: 'Search...',
        ),
      ],
    );
  }

  Widget _buildAlertExamples() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: CupertinoColors.systemGrey6,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Column(
            children: [
              Text('Alert Dialog Example'),
              SizedBox(height: 8),
              Text('Action Sheet Example'),
            ],
          ),
        ),
      ],
    );
  }

  void _addComponentToDesignSystem(BuildContext context, String componentName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$componentName added to design system!'),
        backgroundColor: Colors.green,
      ),
    );
  }
}

// Cupertino Typography Tab
class CupertinoTypographyTab extends StatelessWidget {
  const CupertinoTypographyTab({super.key});

  @override
  Widget build(BuildContext context) {
    final textStyles = _getCupertinoTextStyles();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'iOS Typography Styles',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Select iOS typography styles to add to your design system',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
        ),
        const SizedBox(height: 24),
        ...textStyles.map((style) => _buildTypographyCard(context, style)),
      ],
    );
  }

  Widget _buildTypographyCard(BuildContext context, CupertinoTextStyle style) {
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
                        '${style.fontSize}pt / ${style.fontWeight} / ${style.lineHeight}pt',
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

  void _addTypographyToDesignSystem(BuildContext context, CupertinoTextStyle style) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${style.name} added to design system!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  List<CupertinoTextStyle> _getCupertinoTextStyles() {
    return [
      CupertinoTextStyle(
        name: 'Large Title',
        fontSize: 34,
        fontWeight: 400,
        lineHeight: 41,
        sampleText: 'Large Title',
      ),
      CupertinoTextStyle(
        name: 'Title 1',
        fontSize: 28,
        fontWeight: 400,
        lineHeight: 34,
        sampleText: 'Title 1',
      ),
      CupertinoTextStyle(
        name: 'Title 2',
        fontSize: 22,
        fontWeight: 400,
        lineHeight: 28,
        sampleText: 'Title 2',
      ),
      CupertinoTextStyle(
        name: 'Title 3',
        fontSize: 20,
        fontWeight: 400,
        lineHeight: 25,
        sampleText: 'Title 3',
      ),
      CupertinoTextStyle(
        name: 'Headline',
        fontSize: 17,
        fontWeight: 600,
        lineHeight: 22,
        sampleText: 'Headline',
      ),
      CupertinoTextStyle(
        name: 'Body',
        fontSize: 17,
        fontWeight: 400,
        lineHeight: 22,
        sampleText: 'Body - The quick brown fox jumps over the lazy dog',
      ),
      CupertinoTextStyle(
        name: 'Callout',
        fontSize: 16,
        fontWeight: 400,
        lineHeight: 21,
        sampleText: 'Callout - The quick brown fox jumps over the lazy dog',
      ),
      CupertinoTextStyle(
        name: 'Subheadline',
        fontSize: 15,
        fontWeight: 400,
        lineHeight: 20,
        sampleText: 'Subheadline - The quick brown fox jumps over the lazy dog',
      ),
      CupertinoTextStyle(
        name: 'Footnote',
        fontSize: 13,
        fontWeight: 400,
        lineHeight: 18,
        sampleText: 'Footnote - The quick brown fox jumps over the lazy dog',
      ),
      CupertinoTextStyle(
        name: 'Caption 1',
        fontSize: 12,
        fontWeight: 400,
        lineHeight: 16,
        sampleText: 'Caption 1 - The quick brown fox jumps over the lazy dog',
      ),
      CupertinoTextStyle(
        name: 'Caption 2',
        fontSize: 11,
        fontWeight: 400,
        lineHeight: 13,
        sampleText: 'Caption 2 - The quick brown fox jumps over the lazy dog',
      ),
    ];
  }
}

class CupertinoTextStyle {
  final String name;
  final double fontSize;
  final int fontWeight;
  final double lineHeight;
  final String sampleText;

  CupertinoTextStyle({
    required this.name,
    required this.fontSize,
    required this.fontWeight,
    required this.lineHeight,
    required this.sampleText,
  });
}
