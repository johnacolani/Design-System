import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/design_system_provider.dart';
import '../models/design_system.dart' as models;
import 'dashboard_screen.dart';
import '../utils/screen_body_padding.dart';

class TypographyScreen extends StatefulWidget {
  const TypographyScreen({super.key});

  @override
  State<TypographyScreen> createState() => _TypographyScreenState();
}

/// Context / use-case for typography. Suggestions show fonts that fit the choice.
const Map<String, List<String>> _typographyContextSuggestions = {
  'Professional': ['Inter', 'Source Sans 3', 'Open Sans', 'Lato', 'Nunito Sans', 'Work Sans', 'DM Sans'],
  'Enterprise': ['Roboto', 'IBM Plex Sans', 'Work Sans', 'Open Sans', 'Lato', 'Montserrat', 'Ubuntu'],
  'Creative': ['Playfair Display', 'Merriweather', 'Lora', 'Cormorant Garamond', 'Libre Baskerville', 'Crimson Text'],
  'Editorial': ['Georgia', 'Merriweather', 'Lora', 'Crimson Text', 'Libre Baskerville', 'Source Serif 4'],
  'Friendly': ['Nunito', 'Quicksand', 'Comfortaa', 'Varela Round', 'Patrick Hand', 'Baloo 2'],
  'Modern': ['Inter', 'DM Sans', 'Plus Jakarta Sans', 'Manrope', 'Outfit', 'Sora', 'Figtree'],
};

/// Default weight value -> display name (100 Thin, 200 ExtraLight, ...).
const Map<int, String> _weightDisplayNames = {
  100: 'Thin',
  200: 'ExtraLight',
  300: 'Light',
  400: 'Regular',
  500: 'Medium',
  600: 'SemiBold',
  700: 'Bold',
  800: 'ExtraBold',
  900: 'Black',
};

class _TypographyScreenState extends State<TypographyScreen> {
  late List<String> _googleFonts;
  String? _previewPrimaryFont;
  String _searchQuery = '';
  String? _selectedContext;
  TokenDisplayGroup? _selectedGroup;
  bool _contentReady = false;

  void _applyTypographyUpdateForGroup(TokenDisplayGroup group, models.Typography t) {
    final p = Provider.of<DesignSystemProvider>(context, listen: false);
    if (group.platforms.length == 1 && !p.isMultiPlatform) p.updateTypography(t);
    else p.updateTypographyForGroup(group, t);
  }

  models.Typography _getTypographyForGroup(TokenDisplayGroup group) {
    final p = Provider.of<DesignSystemProvider>(context, listen: false);
    if (group.platforms.length == 1 && !p.isMultiPlatform) return p.designSystem.typography;
    return p.designSystemForPlatform(group.primaryPlatform).typography;
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
  void initState() {
    super.initState();
    _googleFonts = GoogleFonts.asMap().keys.toList();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _contentReady = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_contentReady) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).pop()),
          title: const Text('Typography'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    final provider = Provider.of<DesignSystemProvider>(context);
    final groups = provider.designTokenDisplayGroups;
    if (groups.isNotEmpty && _selectedGroup == null) _selectedGroup = groups.first;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const DashboardScreen()),
            ),
          ),
          title: const Text('Typography'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.font_download), text: 'Font Family'),
              Tab(icon: Icon(Icons.format_bold), text: 'Weights'),
              Tab(icon: Icon(Icons.text_fields), text: 'Sizes'),
              Tab(icon: Icon(Icons.style), text: 'Styles'),
            ],
          ),
        ),
        body: ScreenBodyPadding(
          verticalPadding: 0,
          child: Column(
            children: [
              _buildGroupSelector(provider),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildFontFamilyTab(),
                    _buildFontWeightsTab(),
                    _buildFontSizesTab(),
                    _buildTextStylesTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  TextStyle _getSafeFont(String fontName, {double? fontSize, FontWeight? fontWeight, Color? color}) {
    try {
      return GoogleFonts.getFont(
        fontName,
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
      );
    } catch (e) {
      return TextStyle(
        fontFamily: 'sans-serif',
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
      );
    }
  }

  Widget _buildFontFamilyTab() {
    final provider = Provider.of<DesignSystemProvider>(context);
    final typography = _getTypographyForGroup(_effectiveGroup(context));
    final currentPrimary = _previewPrimaryFont ?? typography.fontFamily.primary;

    final filteredFonts = _googleFonts
        .where((font) => font.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Column(
      children: [
        // Preview Header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            children: [
              const Text('Live Preview', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 12),
              Text(
                'The quick brown fox jumps over the lazy dog',
                style: _getSafeFont(currentPrimary, fontSize: 24),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text('Viewing: $currentPrimary', style: const TextStyle(fontSize: 12, color: Colors.blue, fontWeight: FontWeight.bold)),
              if (_previewPrimaryFont != null && _previewPrimaryFont != typography.fontFamily.primary) ...[
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    _applyTypographyUpdateForGroup(_effectiveGroup(context),models.Typography(
                      fontFamily: models.FontFamily(
                        primary: _previewPrimaryFont!,
                        fallback: typography.fontFamily.fallback,
                      ),
                      fontWeights: typography.fontWeights,
                      fontSizes: typography.fontSizes,
                      textStyles: typography.textStyles,
                    ));
                    setState(() => _previewPrimaryFont = null);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Font Applied!'), backgroundColor: Colors.green),
                    );
                  },
                  icon: const Icon(Icons.save),
                  label: const Text('Apply to Design System'),
                ),
              ],
            ],
          ),
        ),
        
        // Context selector: choose use-case to see suggested fonts
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Use case', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600, color: Colors.grey[700])),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _typographyContextSuggestions.keys.map((contextName) {
                  final isSelected = _selectedContext == contextName;
                  return FilterChip(
                    label: Text(contextName),
                    selected: isSelected,
                    onSelected: (v) => setState(() => _selectedContext = v ? contextName : null),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        // Suggested fonts for selected context
        if (_selectedContext != null) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Suggested for $_selectedContext', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.blue)),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: (_typographyContextSuggestions[_selectedContext] ?? []).where((f) => _googleFonts.contains(f)).map((font) {
                      final isSelected = currentPrimary == font;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Material(
                          elevation: isSelected ? 2 : 0,
                          borderRadius: BorderRadius.circular(8),
                          color: isSelected ? Colors.blue[50] : Colors.grey[100],
                          child: InkWell(
                            onTap: () => setState(() => _previewPrimaryFont = font),
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              child: Text(font, style: _getSafeFont(font, fontSize: 14)),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        // Search Bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            onChanged: (val) => setState(() => _searchQuery = val),
            decoration: InputDecoration(
              hintText: 'Search 1000+ Google Fonts...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
        ),

        // Font List (Optimized with scroll detection or limiting initial view)
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredFonts.length > 500 ? 500 : filteredFonts.length, // Limit for performance
            itemBuilder: (context, index) {
              final font = filteredFonts[index];
              final isSelected = currentPrimary == font;
              
              return Card(
                elevation: isSelected ? 2 : 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: isSelected ? Colors.blue : Colors.grey[200]!, width: isSelected ? 2 : 1),
                ),
                child: ListTile(
                  title: Text(font),
                  trailing: Text('Abc 123', style: _getSafeFont(font, fontSize: 16)),
                  onTap: () => setState(() => _previewPrimaryFont = font),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFontWeightsTab() {
    final provider = Provider.of<DesignSystemProvider>(context);
    final typography = _getTypographyForGroup(_effectiveGroup(context));
    final currentFont = _previewPrimaryFont ?? typography.fontFamily.primary;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Font Weights', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _resetFontWeightsToDefaults(context),
                  icon: const Icon(Icons.restore, size: 18),
                  label: const Text('Reset defaults'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(onPressed: () => _showAddFontWeightDialog(context), icon: const Icon(Icons.add), label: const Text('Add')),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text('Default: 100 Thin, 200 ExtraLight, 300 Light, 400 Regular, 500 Medium, 600 SemiBold, 700 Bold, 800 ExtraBold, 900 Black', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        const SizedBox(height: 16),
        ...typography.fontWeights.entries.map((entry) => Card(
          child: ListTile(
            title: Text(entry.key, style: _getSafeFont(currentFont, fontWeight: _intToWeight(entry.value))),
            subtitle: Text('${entry.value} ${_weightDisplayNames[entry.value] ?? ''}'),
            trailing: PopupMenuButton<String>(
              onSelected: (val) {
                if (val == 'edit') _showEditFontWeightDialog(context, entry.key, entry.value);
                if (val == 'delete') _deleteFontWeight(context, entry.key);
              },
              itemBuilder: (ctx) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
              ],
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildFontSizesTab() {
    final provider = Provider.of<DesignSystemProvider>(context);
    final typography = _getTypographyForGroup(_effectiveGroup(context));
    final currentFont = _previewPrimaryFont ?? typography.fontFamily.primary;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Font Sizes', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _resetFontSizesToDefaults(context),
                  icon: const Icon(Icons.restore, size: 18),
                  label: const Text('Reset defaults'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(onPressed: () => _showAddFontSizeDialog(context), icon: const Icon(Icons.add), label: const Text('Add')),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text('Default: Display 48, Heading 32, Title 24, Subtitle 20, Body 16, Caption 14, Label 12', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        const SizedBox(height: 16),
        ...typography.fontSizes.entries.map((entry) => Card(
          child: ListTile(
            title: Text(entry.key, style: _getSafeFont(currentFont, fontSize: _parseFontSize(entry.value.value))),
            subtitle: Text('Size: ${entry.value.value} / Line Height: ${entry.value.lineHeight}'),
            trailing: PopupMenuButton<String>(
              onSelected: (val) {
                if (val == 'edit') _showEditFontSizeDialog(context, entry.key, entry.value);
                if (val == 'delete') _deleteFontSize(context, entry.key);
              },
              itemBuilder: (ctx) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
              ],
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildTextStylesTab() {
    final provider = Provider.of<DesignSystemProvider>(context);
    final typography = _getTypographyForGroup(_effectiveGroup(context));
    final currentFont = _previewPrimaryFont ?? typography.fontFamily.primary;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Text Styles', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            PopupMenuButton<String>(
              onSelected: (v) => v == 'custom' ? _showAddTextStyleDialog(context) : (v == 'material' ? _showMaterialPicker(context) : _showCupertinoPicker(context)),
              itemBuilder: (ctx) => [
                const PopupMenuItem(value: 'custom', child: Text('Custom')),
                const PopupMenuItem(value: 'material', child: Text('Material Library')),
                const PopupMenuItem(value: 'cupertino', child: Text('Cupertino Library')),
              ],
              child: ElevatedButton.icon(onPressed: null, icon: const Icon(Icons.add), label: const Text('Add Style')),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...typography.textStyles.entries.map((entry) => Card(
          child: ListTile(
            title: Text(entry.key, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Size: ${entry.value.fontSize} • Weight: ${entry.value.fontWeight}'),
                const SizedBox(height: 8),
                Text(
                  'Sample Text',
                  style: _getSafeFont(
                    currentFont,
                    fontSize: _parseFontSize(entry.value.fontSize),
                    fontWeight: _intToWeight(entry.value.fontWeight),
                    color: entry.value.color != null ? _parseColor(entry.value.color!) : null,
                  ),
                ),
              ],
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (val) {
                if (val == 'edit') _showEditTextStyleDialog(context, entry.key, entry.value);
                if (val == 'delete') _deleteTextStyle(context, entry.key);
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
        )),
      ],
    );
  }

  // --- Helpers ---

  FontWeight _intToWeight(int w) => FontWeight.values[(w ~/ 100 - 1).clamp(0, 8)];
  double _parseFontSize(String s) => double.tryParse(s.replaceAll('px', '')) ?? 14.0;

  void _showAddFontWeightDialog(BuildContext context) {
    final name = TextEditingController();
    final val = TextEditingController();
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Add Font Weight'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: name, decoration: const InputDecoration(labelText: 'Name (e.g. bold)')), TextField(controller: val, decoration: const InputDecoration(labelText: 'Value (100-900)'))]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        ElevatedButton(onPressed: () {
          final p = Provider.of<DesignSystemProvider>(context, listen: false);
          final t = _getTypographyForGroup(_effectiveGroup(context));
          final updated = Map<String, int>.from(t.fontWeights)..[name.text] = int.tryParse(val.text) ?? 400;
          p.updateTypography(models.Typography(fontFamily: t.fontFamily, fontWeights: updated, fontSizes: t.fontSizes, textStyles: t.textStyles));
          Navigator.pop(ctx);
        }, child: const Text('Add')),
      ],
    ));
  }

  void _showEditFontWeightDialog(BuildContext context, String key, int currentVal) {
    final valController = TextEditingController(text: currentVal.toString());
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: Text('Edit Weight: $key'),
      content: TextField(controller: valController, decoration: const InputDecoration(labelText: 'Value (100-900)')),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        ElevatedButton(onPressed: () {
          final p = Provider.of<DesignSystemProvider>(context, listen: false);
          final t = _getTypographyForGroup(_effectiveGroup(context));
          final updated = Map<String, int>.from(t.fontWeights)..[key] = int.tryParse(valController.text) ?? currentVal;
          p.updateTypography(models.Typography(fontFamily: t.fontFamily, fontWeights: updated, fontSizes: t.fontSizes, textStyles: t.textStyles));
          Navigator.pop(ctx);
        }, child: const Text('Save')),
      ],
    ));
  }

  void _deleteFontWeight(BuildContext context, String k) {
    final p = Provider.of<DesignSystemProvider>(context, listen: false);
    final t = _getTypographyForGroup(_effectiveGroup(context));
    final updated = Map<String, int>.from(t.fontWeights)..remove(k);
    p.updateTypography(models.Typography(fontFamily: t.fontFamily, fontWeights: updated, fontSizes: t.fontSizes, textStyles: t.textStyles));
  }

  void _resetFontWeightsToDefaults(BuildContext context) {
    final p = Provider.of<DesignSystemProvider>(context, listen: false);
    final t = _getTypographyForGroup(_effectiveGroup(context));
    p.updateTypography(models.Typography(
      fontFamily: t.fontFamily,
      fontWeights: Map<String, int>.from(models.Typography.empty().fontWeights),
      fontSizes: t.fontSizes,
      textStyles: t.textStyles,
    ));
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Weights reset to defaults (100 Thin … 900 Black)'), backgroundColor: Colors.green));
  }

  void _resetFontSizesToDefaults(BuildContext context) {
    final p = Provider.of<DesignSystemProvider>(context, listen: false);
    final t = _getTypographyForGroup(_effectiveGroup(context));
    p.updateTypography(models.Typography(
      fontFamily: t.fontFamily,
      fontWeights: t.fontWeights,
      fontSizes: Map<String, models.FontSize>.from(models.Typography.empty().fontSizes),
      textStyles: t.textStyles,
    ));
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sizes reset to defaults (Display 48 … Label 12)'), backgroundColor: Colors.green));
  }

  void _showAddFontSizeDialog(BuildContext context) {
    final name = TextEditingController();
    final size = TextEditingController();
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Add Font Size'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: name, decoration: const InputDecoration(labelText: 'Name (e.g. lg)')), TextField(controller: size, decoration: const InputDecoration(labelText: 'Size (px)'))]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        ElevatedButton(onPressed: () {
          final p = Provider.of<DesignSystemProvider>(context, listen: false);
          final t = _getTypographyForGroup(_effectiveGroup(context));
          final updated = Map<String, models.FontSize>.from(t.fontSizes)..[name.text] = models.FontSize(value: '${size.text}px', lineHeight: '1.2');
          p.updateTypography(models.Typography(fontFamily: t.fontFamily, fontWeights: t.fontWeights, fontSizes: updated, textStyles: t.textStyles));
          Navigator.pop(ctx);
        }, child: const Text('Add')),
      ],
    ));
  }

  void _showEditFontSizeDialog(BuildContext context, String key, models.FontSize current) {
    final sizeController = TextEditingController(text: current.value.replaceAll('px', ''));
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: Text('Edit Size: $key'),
      content: TextField(controller: sizeController, decoration: const InputDecoration(labelText: 'Size (px)')),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        ElevatedButton(onPressed: () {
          final p = Provider.of<DesignSystemProvider>(context, listen: false);
          final t = _getTypographyForGroup(_effectiveGroup(context));
          final updated = Map<String, models.FontSize>.from(t.fontSizes)..[key] = models.FontSize(value: '${sizeController.text}px', lineHeight: current.lineHeight);
          p.updateTypography(models.Typography(fontFamily: t.fontFamily, fontWeights: t.fontWeights, fontSizes: updated, textStyles: t.textStyles));
          Navigator.pop(ctx);
        }, child: const Text('Save')),
      ],
    ));
  }

  void _deleteFontSize(BuildContext context, String k) {
    final p = Provider.of<DesignSystemProvider>(context, listen: false);
    final t = _getTypographyForGroup(_effectiveGroup(context));
    final updated = Map<String, models.FontSize>.from(t.fontSizes)..remove(k);
    p.updateTypography(models.Typography(fontFamily: t.fontFamily, fontWeights: t.fontWeights, fontSizes: updated, textStyles: t.textStyles));
  }

  void _showAddTextStyleDialog(BuildContext context) {
    final provider = Provider.of<DesignSystemProvider>(context, listen: false);
    final t = _getTypographyForGroup(_effectiveGroup(context));
    final name = TextEditingController();
    String selectedFont = t.fontFamily.primary;
    String selectedWeightKey = t.fontWeights.isNotEmpty ? t.fontWeights.keys.first : 'regular';
    String selectedSizeKey = t.fontSizes.isNotEmpty ? t.fontSizes.keys.first : 'base';

    final weightKeys = t.fontWeights.keys.toList();
    final sizeKeys = t.fontSizes.keys.toList();
    if (weightKeys.isEmpty) weightKeys.add('regular');
    if (sizeKeys.isEmpty) sizeKeys.add('base');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Add Text Style'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: name,
                  decoration: const InputDecoration(labelText: 'Style Name (e.g. Heading 1, Body)'),
                ),
                const SizedBox(height: 16),
                const Text('Font', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                OutlinedButton.icon(
                  icon: const Icon(Icons.font_download),
                  label: Text(selectedFont),
                  onPressed: () => _showFontPickerForStyle(
                    context,
                    currentFont: selectedFont,
                    primaryFont: t.fontFamily.primary,
                    fallbackFont: t.fontFamily.fallback,
                    onSelected: (font) => setDialogState(() => selectedFont = font),
                  ),
                  style: OutlinedButton.styleFrom(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Weight', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                DropdownButtonFormField<String>(
                  initialValue: selectedWeightKey,
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                  items: weightKeys.map((k) => DropdownMenuItem(value: k, child: Text('$k (${t.fontWeights[k] ?? 400})'))).toList(),
                  onChanged: (v) => setDialogState(() => selectedWeightKey = v ?? selectedWeightKey),
                ),
                const SizedBox(height: 16),
                const Text('Size', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                DropdownButtonFormField<String>(
                  initialValue: selectedSizeKey,
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                  items: sizeKeys.map((k) {
                    final sz = t.fontSizes[k];
                    return DropdownMenuItem(value: k, child: Text(sz != null ? '$k (${sz.value}, ${sz.lineHeight})' : k));
                  }).toList(),
                  onChanged: (v) => setDialogState(() => selectedSizeKey = v ?? selectedSizeKey),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (name.text.trim().isEmpty) return;
                final weight = t.fontWeights[selectedWeightKey] ?? 400;
                final sizeToken = t.fontSizes[selectedSizeKey];
                final fontSize = sizeToken?.value ?? '16px';
                final lineHeight = sizeToken?.lineHeight ?? '1.5';
                final updated = Map<String, models.TextStyle>.from(t.textStyles)
                  ..[name.text.trim()] = models.TextStyle(
                    fontFamily: selectedFont,
                    fontSize: fontSize,
                    fontWeight: weight,
                    lineHeight: lineHeight,
                  );
                _applyTypographyUpdateForGroup(_effectiveGroup(context),models.Typography(
                  fontFamily: t.fontFamily,
                  fontWeights: t.fontWeights,
                  fontSizes: t.fontSizes,
                  textStyles: updated,
                ));
                Navigator.pop(ctx);
                setState(() {});
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteTextStyle(BuildContext context, String k) {
    final p = Provider.of<DesignSystemProvider>(context, listen: false);
    final t = _getTypographyForGroup(_effectiveGroup(context));
    final updated = Map<String, models.TextStyle>.from(t.textStyles)..remove(k);
    p.updateTypography(models.Typography(fontFamily: t.fontFamily, fontWeights: t.fontWeights, fontSizes: t.fontSizes, textStyles: updated));
  }

  void _showFontPickerForStyle(
    BuildContext context, {
    required String currentFont,
    required String primaryFont,
    required String fallbackFont,
    required void Function(String font) onSelected,
  }) {
    String searchQuery = '';
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) {
          final filteredFonts = _googleFonts
              .where((f) => f.toLowerCase().contains(searchQuery.toLowerCase()))
              .toList();
          return AlertDialog(
          title: const Text('Choose font'),
          content: SizedBox(
            width: 320,
            height: 420,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'From Font Family (your chosen font)',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue),
                ),
                const SizedBox(height: 8),
                ListTile(
                  title: Text(primaryFont, style: _getSafeFont(primaryFont, fontSize: 16)),
                  subtitle: const Text('Primary – selected in Font Family tab'),
                  selected: currentFont == primaryFont,
                  onTap: () {
                    onSelected(primaryFont);
                    Navigator.pop(ctx);
                  },
                ),
                ListTile(
                  title: Text(fallbackFont, style: const TextStyle(fontSize: 16)),
                  subtitle: const Text('Fallback'),
                  selected: currentFont == fallbackFont,
                  onTap: () {
                    onSelected(fallbackFont);
                    Navigator.pop(ctx);
                  },
                ),
                const Divider(height: 24),
                const Text(
                  'Or pick from all fonts',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search fonts...',
                    prefixIcon: Icon(Icons.search),
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (v) => setState(() => searchQuery = v),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredFonts.length > 200 ? 200 : filteredFonts.length,
                    itemBuilder: (c, i) {
                      final font = filteredFonts[i];
                      return ListTile(
                        dense: true,
                        title: Text(font, style: _getSafeFont(font, fontSize: 14)),
                        selected: currentFont == font,
                        onTap: () {
                          onSelected(font);
                          Navigator.pop(ctx);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ],
        );
        },
      ),
    );
  }

  void _showMaterialPicker(BuildContext context) {
    final styles = {
      'Display Large': const TextStyle(fontSize: 57, fontWeight: FontWeight.w400),
      'Headline Medium': const TextStyle(fontSize: 28, fontWeight: FontWeight.w400),
      'Title Small': const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      'Body Medium': const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
    };
    _showPresetDialog(context, 'Material Styles', styles);
  }

  void _showCupertinoPicker(BuildContext context) {
    final styles = {
      'Large Title': const TextStyle(fontSize: 34, fontWeight: FontWeight.w400),
      'Title 1': const TextStyle(fontSize: 28, fontWeight: FontWeight.w400),
      'Headline': const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
      'Footnote': const TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
    };
    _showPresetDialog(context, 'Cupertino Styles', styles);
  }

  void _showPresetDialog(BuildContext context, String title, Map<String, TextStyle> styles) {
    String? selectedName;
    TextStyle? selectedStyle;
    showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, setState) => AlertDialog(
      title: Text(title),
      content: SizedBox(width: 400, height: 500, child: Column(children: [
        if (selectedStyle != null) Container(padding: const EdgeInsets.all(16), margin: const EdgeInsets.only(bottom: 12), decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)), child: Text('Abc 123', style: selectedStyle!.copyWith(fontSize: 24))),
        Expanded(child: ListView.separated(itemCount: styles.length, separatorBuilder: (c, i) => const Divider(), itemBuilder: (c, i) {
          final n = styles.keys.elementAt(i);
          final s = styles.values.elementAt(i);
          return ListTile(title: Text(n), selected: selectedName == n, onTap: () => setState(() { selectedName = n; selectedStyle = s; }));
        })),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        ElevatedButton(onPressed: selectedName == null ? null : () {
          final p = Provider.of<DesignSystemProvider>(context, listen: false);
          final t = _getTypographyForGroup(_effectiveGroup(context));
          final updated = Map<String, models.TextStyle>.from(t.textStyles)..[selectedName!] = models.TextStyle(fontFamily: t.fontFamily.primary, fontSize: '${selectedStyle!.fontSize?.toInt()}px', fontWeight: selectedStyle!.fontWeight?.value ?? 400, lineHeight: '1.5');
          p.updateTypography(models.Typography(fontFamily: t.fontFamily, fontWeights: t.fontWeights, fontSizes: t.fontSizes, textStyles: updated));
          Navigator.pop(ctx);
        }, child: const Text('Add Style')),
      ],
    )));
  }

  void _showEditTextStyleDialog(BuildContext context, String key, models.TextStyle style) {
    final provider = Provider.of<DesignSystemProvider>(context, listen: false);
    final t = _getTypographyForGroup(_effectiveGroup(context));
    final nameController = TextEditingController(text: key);
    String selectedFont = (style.fontFamily == t.fontFamily.fallback) ? t.fontFamily.fallback : t.fontFamily.primary;
    String selectedWeightKey = 'regular';
    for (final e in t.fontWeights.entries) {
      if (e.value == style.fontWeight) {
        selectedWeightKey = e.key;
        break;
      }
    }
    if (!t.fontWeights.containsKey(selectedWeightKey) && t.fontWeights.isNotEmpty) {
      selectedWeightKey = t.fontWeights.keys.first;
    }
    String selectedSizeKey = 'base';
    for (final e in t.fontSizes.entries) {
      if (e.value.value == style.fontSize) {
        selectedSizeKey = e.key;
        break;
      }
    }
    if (!t.fontSizes.containsKey(selectedSizeKey) && t.fontSizes.isNotEmpty) {
      selectedSizeKey = t.fontSizes.keys.first;
    }

    final weightKeys = t.fontWeights.keys.toList();
    final sizeKeys = t.fontSizes.keys.toList();
    if (weightKeys.isEmpty) weightKeys.add('regular');
    if (sizeKeys.isEmpty) sizeKeys.add('base');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Edit Text Style'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Style Name'),
                ),
                const SizedBox(height: 16),
                const Text('Font', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                OutlinedButton.icon(
                  icon: const Icon(Icons.font_download),
                  label: Text(selectedFont),
                  onPressed: () => _showFontPickerForStyle(
                    context,
                    currentFont: selectedFont,
                    primaryFont: t.fontFamily.primary,
                    fallbackFont: t.fontFamily.fallback,
                    onSelected: (font) => setDialogState(() => selectedFont = font),
                  ),
                  style: OutlinedButton.styleFrom(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Weight', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                DropdownButtonFormField<String>(
                  initialValue: selectedWeightKey,
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                  items: weightKeys.map((k) => DropdownMenuItem(value: k, child: Text('$k (${t.fontWeights[k] ?? 400})'))).toList(),
                  onChanged: (v) => setDialogState(() => selectedWeightKey = v ?? selectedWeightKey),
                ),
                const SizedBox(height: 16),
                const Text('Size', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                DropdownButtonFormField<String>(
                  initialValue: selectedSizeKey,
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                  items: sizeKeys.map((k) {
                    final sz = t.fontSizes[k];
                    return DropdownMenuItem(value: k, child: Text(sz != null ? '$k (${sz.value}, ${sz.lineHeight})' : k));
                  }).toList(),
                  onChanged: (v) => setDialogState(() => selectedSizeKey = v ?? selectedSizeKey),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final newName = nameController.text.trim();
                if (newName.isEmpty) return;
                final weight = t.fontWeights[selectedWeightKey] ?? style.fontWeight;
                final sizeToken = t.fontSizes[selectedSizeKey];
                final fontSize = sizeToken?.value ?? style.fontSize;
                final lineHeight = sizeToken?.lineHeight ?? style.lineHeight;
                final updated = Map<String, models.TextStyle>.from(t.textStyles);
                updated.remove(key);
                updated[newName] = models.TextStyle(
                  fontFamily: selectedFont,
                  fontSize: fontSize,
                  fontWeight: weight,
                  lineHeight: lineHeight,
                  color: style.color,
                  textDecoration: style.textDecoration,
                );
                _applyTypographyUpdateForGroup(_effectiveGroup(context),models.Typography(
                  fontFamily: t.fontFamily,
                  fontWeights: t.fontWeights,
                  fontSizes: t.fontSizes,
                  textStyles: updated,
                ));
                Navigator.pop(ctx);
                setState(() {});
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Color? _parseColor(String colorHex) {
    try {
      String hex = colorHex.replaceAll('#', '');
      if (hex.length == 6) hex = 'FF$hex';
      return Color(int.parse(hex, radix: 16));
    } catch (e) {
      return null;
    }
  }
}
