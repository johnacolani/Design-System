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

class _TypographyScreenState extends State<TypographyScreen> {
  // Use all available Google Fonts
  late List<String> _googleFonts;
  
  String? _previewPrimaryFont;
  String _searchQuery = '';
  
  @override
  void initState() {
    super.initState();
    _googleFonts = GoogleFonts.asMap().keys.toList();
  }

  @override
  Widget build(BuildContext context) {
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
          child: TabBarView(
            children: [
              _buildFontFamilyTab(),
              _buildFontWeightsTab(),
              _buildFontSizesTab(),
              _buildTextStylesTab(),
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
    final typography = provider.designSystem.typography;
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
                    provider.updateTypography(models.Typography(
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
    final typography = provider.designSystem.typography;
    final currentFont = _previewPrimaryFont ?? typography.fontFamily.primary;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Font Weights', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ElevatedButton.icon(onPressed: () => _showAddFontWeightDialog(context), icon: const Icon(Icons.add), label: const Text('Add')),
          ],
        ),
        const SizedBox(height: 16),
        ...typography.fontWeights.entries.map((entry) => Card(
          child: ListTile(
            title: Text(entry.key, style: _getSafeFont(currentFont, fontWeight: _intToWeight(entry.value))),
            subtitle: Text('Weight Value: ${entry.value}'),
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
    final typography = provider.designSystem.typography;
    final currentFont = _previewPrimaryFont ?? typography.fontFamily.primary;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Font Sizes', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ElevatedButton.icon(onPressed: () => _showAddFontSizeDialog(context), icon: const Icon(Icons.add), label: const Text('Add')),
          ],
        ),
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
    final typography = provider.designSystem.typography;
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
          final t = p.designSystem.typography;
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
          final t = p.designSystem.typography;
          final updated = Map<String, int>.from(t.fontWeights)..[key] = int.tryParse(valController.text) ?? currentVal;
          p.updateTypography(models.Typography(fontFamily: t.fontFamily, fontWeights: updated, fontSizes: t.fontSizes, textStyles: t.textStyles));
          Navigator.pop(ctx);
        }, child: const Text('Save')),
      ],
    ));
  }

  void _deleteFontWeight(BuildContext context, String k) {
    final p = Provider.of<DesignSystemProvider>(context, listen: false);
    final t = p.designSystem.typography;
    final updated = Map<String, int>.from(t.fontWeights)..remove(k);
    p.updateTypography(models.Typography(fontFamily: t.fontFamily, fontWeights: updated, fontSizes: t.fontSizes, textStyles: t.textStyles));
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
          final t = p.designSystem.typography;
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
          final t = p.designSystem.typography;
          final updated = Map<String, models.FontSize>.from(t.fontSizes)..[key] = models.FontSize(value: '${sizeController.text}px', lineHeight: current.lineHeight);
          p.updateTypography(models.Typography(fontFamily: t.fontFamily, fontWeights: t.fontWeights, fontSizes: updated, textStyles: t.textStyles));
          Navigator.pop(ctx);
        }, child: const Text('Save')),
      ],
    ));
  }

  void _deleteFontSize(BuildContext context, String k) {
    final p = Provider.of<DesignSystemProvider>(context, listen: false);
    final t = p.designSystem.typography;
    final updated = Map<String, models.FontSize>.from(t.fontSizes)..remove(k);
    p.updateTypography(models.Typography(fontFamily: t.fontFamily, fontWeights: t.fontWeights, fontSizes: updated, textStyles: t.textStyles));
  }

  void _showAddTextStyleDialog(BuildContext context) {
    final name = TextEditingController();
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Add Text Style'),
      content: TextField(controller: name, decoration: const InputDecoration(labelText: 'Style Name')),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        ElevatedButton(onPressed: () {
          final p = Provider.of<DesignSystemProvider>(context, listen: false);
          final t = p.designSystem.typography;
          final updated = Map<String, models.TextStyle>.from(t.textStyles)..[name.text] = models.TextStyle(fontFamily: t.fontFamily.primary, fontSize: '16px', fontWeight: 400, lineHeight: '24px');
          p.updateTypography(models.Typography(fontFamily: t.fontFamily, fontWeights: t.fontWeights, fontSizes: t.fontSizes, textStyles: updated));
          Navigator.pop(ctx);
        }, child: const Text('Add')),
      ],
    ));
  }

  void _deleteTextStyle(BuildContext context, String k) {
    final p = Provider.of<DesignSystemProvider>(context, listen: false);
    final t = p.designSystem.typography;
    final updated = Map<String, models.TextStyle>.from(t.textStyles)..remove(k);
    p.updateTypography(models.Typography(fontFamily: t.fontFamily, fontWeights: t.fontWeights, fontSizes: t.fontSizes, textStyles: updated));
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
          final t = p.designSystem.typography;
          final updated = Map<String, models.TextStyle>.from(t.textStyles)..[selectedName!] = models.TextStyle(fontFamily: t.fontFamily.primary, fontSize: '${selectedStyle!.fontSize?.toInt()}px', fontWeight: selectedStyle!.fontWeight?.value ?? 400, lineHeight: '1.5');
          p.updateTypography(models.Typography(fontFamily: t.fontFamily, fontWeights: t.fontWeights, fontSizes: t.fontSizes, textStyles: updated));
          Navigator.pop(ctx);
        }, child: const Text('Add Style')),
      ],
    )));
  }

  void _showEditTextStyleDialog(BuildContext context, String key, models.TextStyle style) {
    // Basic implementation for now to satisfy button tap
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
