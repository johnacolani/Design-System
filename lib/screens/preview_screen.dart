import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../providers/design_system_provider.dart';
import '../models/design_system.dart' as models;
import '../utils/screen_body_padding.dart';

class PreviewScreen extends StatefulWidget {
  const PreviewScreen({super.key});

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  Future<void> _exportAsPdf() async {
    if (!mounted) return;
    
    try {
      final provider = Provider.of<DesignSystemProvider>(context, listen: false);
      final designSystem = provider.designSystem;

      final pdf = await _generatePdf(designSystem);
      
      if (!mounted) return;

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: '${designSystem.name.replaceAll(' ', '_')}_Design_System.pdf',
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF generated successfully!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<pw.Document> _generatePdf(models.DesignSystem ds) async {
    final pdf = pw.Document();
    
    final headerStyle = pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900);
    final subHeaderStyle = pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold);

    // Page 1: Cover & Core Colors
    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      build: (pw.Context context) => [
        pw.Header(level: 0, child: pw.Text(ds.name, style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold))),
        pw.Text('Design System Documentation - v${ds.version}'),
        pw.SizedBox(height: 20),
        pw.Divider(),
        pw.SizedBox(height: 20),
        pw.Text('1. Core Colors', style: headerStyle),
        pw.SizedBox(height: 10),
        _buildPdfColors(ds),
      ],
    ));

    // Page 2: Typography & Spacing
    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      build: (pw.Context context) => [
        pw.Text('2. Typography', style: headerStyle),
        pw.SizedBox(height: 10),
        _buildPdfTypography(ds),
        pw.SizedBox(height: 30),
        pw.Text('3. Spacing Scale', style: headerStyle),
        pw.SizedBox(height: 10),
        _buildPdfSpacing(ds),
      ],
    ));

    // Page 3: Shapes & Shadows
    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      build: (pw.Context context) => [
        pw.Text('4. Shapes & Shadows', style: headerStyle),
        pw.SizedBox(height: 10),
        pw.Text('Border Radius', style: subHeaderStyle),
        _buildPdfBorderRadius(ds),
        pw.SizedBox(height: 20),
        pw.Text('Shadow Tokens', style: subHeaderStyle),
        _buildPdfShadows(ds),
      ],
    ));

    // Page 4: Components & Assets
    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      build: (pw.Context context) => [
        pw.Text('5. Component Library', style: headerStyle),
        pw.SizedBox(height: 10),
        _buildPdfComponents(ds),
        pw.SizedBox(height: 30),
        pw.Text('6. Iconography', style: headerStyle),
        pw.SizedBox(height: 10),
        _buildPdfIcons(ds),
      ],
    ));

    // Page 5: Advanced & Motion
    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      build: (pw.Context context) => [
        pw.Text('7. Advanced Tokens', style: headerStyle),
        pw.SizedBox(height: 10),
        pw.Text('Gradients', style: subHeaderStyle),
        _buildPdfGradients(ds),
        pw.SizedBox(height: 20),
        pw.Text('Semantic Tokens', style: subHeaderStyle),
        _buildPdfSemanticTokens(ds),
        pw.SizedBox(height: 20),
        pw.Text('Motion & Animation', style: subHeaderStyle),
        _buildPdfMotionTokens(ds),
      ],
    ));
    
    return pdf;
  }

  pw.Widget _buildPdfColors(models.DesignSystem ds) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Primary Colors', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
        pw.SizedBox(height: 8),
        _buildPdfSwatchGroup(ds.colors.primary),
        pw.SizedBox(height: 20),
        pw.Text('Semantic Colors', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
        pw.SizedBox(height: 8),
        _buildPdfSwatchGroup(ds.colors.semantic),
      ],
    );
  }

  pw.Widget _buildPdfSwatchGroup(Map<String, dynamic> colors) {
    // Helper to group variations
    Map<String, List<MapEntry<String, dynamic>>> groups = {};
    for (final e in colors.entries) {
      String base = e.key;
      if (base.contains('_dark')) base = base.split('_dark')[0];
      if (base.contains('_light')) base = base.split('_light')[0];
      groups.putIfAbsent(base, () => []).add(e);
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: groups.entries.map((group) {
        return pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 10),
          child: pw.Wrap(
            spacing: 5,
            runSpacing: 5,
            children: group.value.map((e) {
              final hex = e.value is Map ? e.value['value'] : e.value.toString();
              return pw.Column(children: [
                pw.Container(width: 35, height: 35, decoration: pw.BoxDecoration(color: _parsePdfColor(hex), border: pw.Border.all(width: 0.5))),
                pw.Text(hex.toUpperCase(), style: const pw.TextStyle(fontSize: 5)),
              ]);
            }).toList(),
          ),
        );
      }).toList(),
    );
  }

  pw.Widget _buildPdfTypography(models.DesignSystem ds) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Primary Font: ${ds.typography.fontFamily.primary}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 10),
        ...ds.typography.textStyles.entries.map((e) => 
          pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 4),
            child: pw.Text('${e.key}: ${e.value.fontSize} / Weight ${e.value.fontWeight}', style: pw.TextStyle(fontSize: 10)),
          )
        ),
      ],
    );
  }

  pw.Widget _buildPdfSpacing(models.DesignSystem ds) {
    return pw.Wrap(spacing: 15, children: ds.spacing.values.entries.map((e) => pw.Text('${e.key}: ${e.value}', style: pw.TextStyle(fontSize: 10))).toList());
  }

  pw.Widget _buildPdfBorderRadius(models.DesignSystem ds) {
    return pw.Text('Base: ${ds.borderRadius.base} | Large: ${ds.borderRadius.lg}', style: pw.TextStyle(fontSize: 10));
  }

  pw.Widget _buildPdfShadows(models.DesignSystem ds) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: ds.shadows.values.entries.map((e) => pw.Text('${e.key}: ${e.value.value}', style: pw.TextStyle(fontSize: 10))).toList(),
    );
  }

  pw.Widget _buildPdfComponents(models.DesignSystem ds) {
    final list = [...ds.components.buttons.keys, ...ds.components.inputs.keys, ...ds.components.cards.keys];
    return pw.Wrap(spacing: 10, children: list.map((s) => pw.Text(s, style: pw.TextStyle(fontSize: 10))).toList());
  }

  pw.Widget _buildPdfIcons(models.DesignSystem ds) {
    return pw.Wrap(spacing: 15, children: ds.icons.sizes.entries.map((e) => pw.Text('${e.key}: ${e.value}', style: pw.TextStyle(fontSize: 10))).toList());
  }

  pw.Widget _buildPdfGradients(models.DesignSystem ds) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: ds.gradients.values.entries.map((e) => pw.Text('${e.key}: ${e.value.colors.join(" -> ")}', style: pw.TextStyle(fontSize: 10))).toList(),
    );
  }

  pw.Widget _buildPdfSemanticTokens(models.DesignSystem ds) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: ds.semanticTokens.color.entries.map((e) => pw.Text('${e.key} -> ${e.value['baseTokenReference']}', style: pw.TextStyle(fontSize: 10))).toList(),
    );
  }

  pw.Widget _buildPdfMotionTokens(models.DesignSystem ds) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: ds.motionTokens.duration.entries.map((e) => pw.Text('${e.key}: ${e.value}', style: pw.TextStyle(fontSize: 10))).toList(),
    );
  }

  pw.Widget _buildPdfGrid(models.DesignSystem ds) {
    return pw.Text('Grid Columns: ${ds.grid.columns} | Gutter: ${ds.grid.gutter}', style: pw.TextStyle(fontSize: 10));
  }

  PdfColor _parsePdfColor(String hex) {
    try {
      final h = hex.replaceAll('#', '');
      return PdfColor.fromInt(int.parse(h.length == 6 ? 'FF$h' : h, radix: 16));
    } catch (_) { return PdfColors.black; }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DesignSystemProvider>(context);
    final ds = provider.designSystem;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Design System Preview'),
        actions: [
          IconButton(icon: const Icon(Icons.picture_as_pdf), onPressed: _exportAsPdf, tooltip: 'Export Documentation'),
        ],
      ),
      body: ScreenBodyPadding(
        verticalPadding: 0,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('1. Core Colors'),
              _buildTwoColumnColors(ds),
              const Divider(height: 60),
              _buildSectionTitle('2. Typography'),
              _buildTypographyPreview(ds),
              const Divider(height: 60),
              _buildSectionTitle('3. Tokens & Motion'),
              _buildTokenPreview(ds),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue)),
    );
  }

  Widget _buildTwoColumnColors(models.DesignSystem ds) {
    Map<String, List<MapEntry<String, dynamic>>> groupColors(Map<String, dynamic> colorMap) {
      final groups = <String, List<MapEntry<String, dynamic>>>{};
      for (final entry in colorMap.entries) {
        String baseName = entry.key;
        if (baseName.contains('_dark')) baseName = baseName.split('_dark')[0];
        if (baseName.contains('_light')) baseName = baseName.split('_light')[0];
        groups.putIfAbsent(baseName, () => []).add(entry);
      }
      return groups;
    }

    final primaryGroups = groupColors(ds.colors.primary);
    final semanticGroups = groupColors(ds.colors.semantic);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildGroupedColorList('Primary Colors', primaryGroups)),
        const SizedBox(width: 32),
        Expanded(child: _buildGroupedColorList('Semantic Colors', semanticGroups)),
      ],
    );
  }

  Widget _buildGroupedColorList(String title, Map<String, List<MapEntry<String, dynamic>>> groups) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey)),
        const SizedBox(height: 16),
        ...groups.entries.expand((group) => [
          ...group.value.map((e) {
            final hex = e.value is Map ? e.value['value'] : e.value.toString();
            return _buildShortColorRow(hex, e.key);
          }),
          const SizedBox(height: 12),
          const Divider(height: 1, thickness: 0.5),
          const SizedBox(height: 12),
        ]),
      ],
    );
  }

  Widget _buildShortColorRow(String colorHex, String name) {
    Color? color = _parseColor(colorHex);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 65,
            child: Text(colorHex.toUpperCase(), style: const TextStyle(fontSize: 9, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 8),
          Container(width: 36, height: 40, decoration: BoxDecoration(color: color ?? Colors.grey, borderRadius: BorderRadius.circular(4))),
          const SizedBox(width: 10),
          Expanded(child: Text(name, style: const TextStyle(fontSize: 11), overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  Widget _buildTypographyPreview(models.DesignSystem ds) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: ds.typography.textStyles.entries.map((e) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(e.key, style: TextStyle(fontSize: _parseSize(e.value.fontSize))),
      )).toList(),
    );
  }

  Widget _buildTokenPreview(models.DesignSystem ds) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Spacing Tokens: ${ds.spacing.values.length}'),
        Text('Motion Tokens: ${ds.motionTokens.duration.length}'),
        Text('Semantic Tokens: ${ds.semanticTokens.color.length}'),
      ],
    );
  }

  Color _parseColor(String h) => Color(int.parse(h.replaceAll('#', 'FF'), radix: 16));
  double _parseSize(String s) => double.tryParse(s.replaceAll('px', '')) ?? 14.0;
  double _parsePx(String s) => double.tryParse(s.replaceAll('px', '')) ?? 14.0;
}
