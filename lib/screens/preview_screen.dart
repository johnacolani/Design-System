import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart' show compute, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/design_system_provider.dart';
import '../models/design_system.dart' as models;
import '../models/design_system_wrapper.dart';
import '../utils/design_system_html_builder.dart';
import '../utils/design_system_pdf_builder.dart';
import '../utils/screen_body_padding.dart';
import '../widgets/dynamic_material_icon.dart';
import '../utils/html_downloader_stub.dart' if (dart.library.html) '../utils/html_downloader_web.dart' as html_downloader;

/// Visual shell for the preview page (aligned with clean design-doc pages like ServiceFlow).
class _PreviewDocTheme {
  static const Color pageBg = Color(0xFFF5F2EB);
  static const Color pageFg = Color(0xFF1A1917);
  static const Color textSecondary = Color(0xFF5C5A56);
  static const Color textTertiary = Color(0xFF6D6A65);
  static const Color accent = Color(0xFF6FA8A1);
  static const Color card = Color(0xFFFFFCF7);
  static const Color cardMuted = Color(0xFFFAF7F2);
  static Color get cardBorder => pageFg.withValues(alpha: 0.08);
  static List<BoxShadow> cardShadow = [
    BoxShadow(color: pageFg.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 2)),
  ];
}

class PreviewScreen extends StatefulWidget {
  const PreviewScreen({super.key});

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  bool _isExportingPdf = false;
  bool _isExportingHtml = false;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _keyColors = GlobalKey();
  final GlobalKey _keyTypography = GlobalKey();
  final GlobalKey _keyLayout = GlobalKey();
  final GlobalKey _keyShadows = GlobalKey();
  final GlobalKey _keyEffects = GlobalKey();
  final GlobalKey _keyComponents = GlobalKey();
  final GlobalKey _keyAdvanced = GlobalKey();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSection(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeOutCubic,
        alignment: 0.05,
      );
    }
  }

  Future<void> _exportAsPdf() async {
    if (!mounted || _isExportingPdf) return;
    setState(() => _isExportingPdf = true);

    await Future.delayed(Duration.zero);

    try {
      final provider = Provider.of<DesignSystemProvider>(context, listen: false);
      final designSystem = provider.designSystem;

      // Let the "Generating PDF..." overlay paint (critical on web where PDF runs on same thread).
      await Future.delayed(const Duration(milliseconds: 350));
      if (!mounted) return;
      final wrapper = DesignSystemWrapper(designSystem: designSystem);
      final Uint8List pdfBytes = kIsWeb
          ? await generatePdfBytesFromJsonChunked(wrapper.toJson())
          : await compute(generatePdfBytesFromJson, wrapper.toJson());
      if (!mounted) return;

      // Brief yield so UI can update before opening the print dialog.
      await Future.delayed(const Duration(milliseconds: 50));
      if (!mounted) return;

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdfBytes,
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
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isExportingPdf = false);
    }
  }

  Future<void> _exportAsHtml() async {
    if (!mounted || _isExportingHtml) return;
    setState(() => _isExportingHtml = true);
    try {
      final provider = Provider.of<DesignSystemProvider>(context, listen: false);
      final designSystem = provider.designSystem;
      final html = buildDesignSystemHtml(designSystem);
      final fileName = '${designSystem.name.isEmpty ? 'Design_System' : designSystem.name.replaceAll(' ', '_')}_Design_System.html';
      await html_downloader.downloadHtmlFile(fileName, html);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('HTML exported successfully!'), backgroundColor: Colors.green),
      );
    } catch (e) {
      if (!mounted) return;
      final msg = kIsWeb ? 'HTML export failed: $e' : 'HTML export is currently supported on web.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isExportingHtml = false);
    }
  }

  /// Builds the PDF asynchronously, yielding to the UI after each page so the app doesn't freeze.
  Future<pw.Document> _generatePdfAsync(models.DesignSystem ds) async {
    final pdf = pw.Document();
    final titleStyle = pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold);
    final headerStyle = pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900);

    // Page 1: Cover + Colors (all palettes)
    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      build: (pw.Context context) => [
        pw.Header(level: 0, child: pw.Text(ds.name, style: titleStyle)),
        if (ds.description.isNotEmpty) pw.Padding(padding: const pw.EdgeInsets.only(bottom: 12), child: pw.Text(ds.description, style: pw.TextStyle(fontSize: 11, color: PdfColors.grey700))),
        pw.Text('Version ${ds.version}', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
        pw.SizedBox(height: 20),
        pw.Text('1. Colors', style: headerStyle),
        pw.SizedBox(height: 10),
        _buildPdfColorsFull(ds),
      ],
    ));
    await Future.delayed(Duration.zero);

    // Page 2: Typography + Spacing & Grid
    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      build: (pw.Context context) => [
        pw.Text('2. Typography', style: headerStyle),
        pw.SizedBox(height: 10),
        _buildPdfTypographyFull(ds),
        pw.SizedBox(height: 24),
        pw.Text('3. Spacing & Grid', style: headerStyle),
        pw.SizedBox(height: 10),
        _buildPdfSpacingDetailed(ds),
        pw.SizedBox(height: 10),
        _buildPdfGridDetailed(ds),
      ],
    ));
    await Future.delayed(Duration.zero);

    // Page 3: Border Radius, Shadows, Effects
    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      build: (pw.Context context) => [
        pw.Text('4. Border Radius', style: headerStyle),
        pw.SizedBox(height: 8),
        _buildPdfBorderRadiusFull(ds),
        pw.SizedBox(height: 20),
        pw.Text('5. Shadows', style: headerStyle),
        pw.SizedBox(height: 8),
        _buildPdfShadowsDetailed(ds),
        pw.SizedBox(height: 20),
        pw.Text('6. Effects', style: headerStyle),
        pw.SizedBox(height: 8),
        _buildPdfEffectsDetailed(ds),
      ],
    ));
    await Future.delayed(Duration.zero);

    // Page 4: Component Library + Icons
    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      build: (pw.Context context) => [
        pw.Text('7. Component Library', style: headerStyle),
        pw.SizedBox(height: 10),
        _buildPdfComponentsFull(ds),
        pw.SizedBox(height: 24),
        pw.Text('8. Iconography', style: headerStyle),
        pw.SizedBox(height: 10),
        _buildPdfIconsDetailed(ds),
      ],
    ));
    await Future.delayed(Duration.zero);

    // Page 5: Gradients, Roles, Semantic, Motion, Version history
    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      build: (pw.Context context) => [
        pw.Text('9. Gradients', style: headerStyle),
        pw.SizedBox(height: 8),
        _buildPdfGradientsDetailed(ds),
        pw.SizedBox(height: 20),
        pw.Text('10. Roles', style: headerStyle),
        pw.SizedBox(height: 8),
        _buildPdfRolesDetailed(ds),
        pw.SizedBox(height: 20),
        pw.Text('11. Semantic Tokens', style: headerStyle),
        pw.SizedBox(height: 8),
        _buildPdfSemanticTokensFull(ds),
        pw.SizedBox(height: 20),
        pw.Text('12. Motion Tokens', style: headerStyle),
        pw.SizedBox(height: 8),
        _buildPdfMotionTokensFull(ds),
        pw.SizedBox(height: 20),
        pw.Text('13. Version History', style: headerStyle),
        pw.SizedBox(height: 8),
        _buildPdfVersionHistory(ds),
      ],
    ));

    return pdf;
  }

  pw.Document _generatePdfSync(models.DesignSystem ds) {
    final pdf = pw.Document();
    final titleStyle = pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold);
    final headerStyle = pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900);
    final subHeaderStyle = pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold);

    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      build: (pw.Context context) => [
        pw.Header(level: 0, child: pw.Text(ds.name, style: titleStyle)),
        if (ds.description.isNotEmpty) pw.Padding(padding: const pw.EdgeInsets.only(bottom: 12), child: pw.Text(ds.description, style: pw.TextStyle(fontSize: 11, color: PdfColors.grey700))),
        pw.Text('Version ${ds.version}', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
        pw.SizedBox(height: 20),
        pw.Text('1. Colors', style: headerStyle),
        pw.SizedBox(height: 10),
        _buildPdfColorsFull(ds),
      ],
    ));
    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      build: (pw.Context context) => [
        pw.Text('2. Typography', style: headerStyle),
        pw.SizedBox(height: 10),
        _buildPdfTypographyFull(ds),
        pw.SizedBox(height: 24),
        pw.Text('3. Spacing & Grid', style: headerStyle),
        pw.SizedBox(height: 10),
        _buildPdfSpacingDetailed(ds),
        pw.SizedBox(height: 10),
        _buildPdfGridDetailed(ds),
      ],
    ));
    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      build: (pw.Context context) => [
        pw.Text('4. Border Radius', style: headerStyle),
        pw.SizedBox(height: 8),
        _buildPdfBorderRadiusFull(ds),
        pw.SizedBox(height: 20),
        pw.Text('5. Shadows', style: headerStyle),
        pw.SizedBox(height: 8),
        _buildPdfShadowsDetailed(ds),
        pw.SizedBox(height: 20),
        pw.Text('6. Effects', style: headerStyle),
        pw.SizedBox(height: 8),
        _buildPdfEffectsDetailed(ds),
      ],
    ));
    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      build: (pw.Context context) => [
        pw.Text('7. Component Library', style: headerStyle),
        pw.SizedBox(height: 10),
        _buildPdfComponentsFull(ds),
        pw.SizedBox(height: 24),
        pw.Text('8. Iconography', style: headerStyle),
        pw.SizedBox(height: 10),
        _buildPdfIconsDetailed(ds),
      ],
    ));
    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      build: (pw.Context context) => [
        pw.Text('9. Gradients', style: headerStyle),
        pw.SizedBox(height: 8),
        _buildPdfGradientsDetailed(ds),
        pw.SizedBox(height: 20),
        pw.Text('10. Roles', style: headerStyle),
        pw.SizedBox(height: 8),
        _buildPdfRolesDetailed(ds),
        pw.SizedBox(height: 20),
        pw.Text('11. Semantic Tokens', style: headerStyle),
        pw.SizedBox(height: 8),
        _buildPdfSemanticTokensFull(ds),
        pw.SizedBox(height: 20),
        pw.Text('12. Motion Tokens', style: headerStyle),
        pw.SizedBox(height: 8),
        _buildPdfMotionTokensFull(ds),
        pw.SizedBox(height: 20),
        pw.Text('13. Version History', style: headerStyle),
        pw.SizedBox(height: 8),
        _buildPdfVersionHistory(ds),
      ],
    ));
    return pdf;
  }

  Future<pw.Document> _generatePdf(models.DesignSystem ds) async {
    return _generatePdfAsync(ds);
  }

  // --- PDF WIDGETS (all design system elements) ---

  pw.Widget _buildPdfColorsFull(models.DesignSystem ds) {
    final c = ds.colors;
    final sections = <pw.Widget>[];
    void addPalette(String title, Map<String, dynamic>? palette) {
      if (palette != null && palette.isNotEmpty) {
        sections.add(pw.Text(title, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)));
        sections.add(pw.SizedBox(height: 6));
        sections.add(_buildPdfSwatchGroup(palette));
        sections.add(pw.SizedBox(height: 16));
      }
    }
    addPalette('Primary', c.primary);
    addPalette('Semantic', c.semantic);
    addPalette('Blue', c.blue);
    addPalette('Green', c.green);
    addPalette('Orange', c.orange);
    addPalette('Purple', c.purple);
    addPalette('Red', c.red);
    addPalette('Grey', c.grey);
    addPalette('White', c.white);
    addPalette('Text', c.text);
    addPalette('Input', c.input);
    addPalette('Role-specific', c.roleSpecific);
    if (sections.isEmpty) sections.add(pw.Text('No colors defined.', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600)));
    return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: sections);
  }

  pw.Widget _buildPdfSwatchGroup(Map<String, dynamic> colors) {
    return pw.Wrap(
      spacing: 10,
      runSpacing: 10,
      children: colors.entries.map((e) {
        final val = e.value is Map ? e.value['value'] : e.value.toString();
        return pw.Column(children: [
          pw.Container(width: 40, height: 40, decoration: pw.BoxDecoration(color: _parsePdfColor(val), border: pw.Border.all(width: 0.5))),
          pw.SizedBox(height: 2),
          pw.Text(e.key, style: const pw.TextStyle(fontSize: 6)),
        ]);
      }).toList(),
    );
  }

  pw.Widget _buildPdfTypographyFull(models.DesignSystem ds) {
    final t = ds.typography;
    final children = <pw.Widget>[
      pw.Text('Font family: ${t.fontFamily.primary}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
      if (t.fontFamily.fallback.isNotEmpty) pw.Text('Fallback: ${t.fontFamily.fallback}', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
      pw.SizedBox(height: 10),
    ];
    if (t.fontWeights.isNotEmpty) {
      children.add(pw.Text('Weights', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)));
      children.add(pw.SizedBox(height: 4));
      children.add(pw.Wrap(
        spacing: 8,
        runSpacing: 4,
        children: t.fontWeights.entries.map((e) => pw.Text('${e.key}: ${e.value}', style: const pw.TextStyle(fontSize: 9))).toList(),
      ));
      children.add(pw.SizedBox(height: 10));
    }
    if (t.fontSizes.isNotEmpty) {
      children.add(pw.Text('Sizes', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)));
      children.add(pw.SizedBox(height: 4));
      children.add(pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: t.fontSizes.entries.map((e) => pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 2),
          child: pw.Text('${e.key}: ${e.value.value} (line-height: ${e.value.lineHeight})', style: const pw.TextStyle(fontSize: 9)),
        )).toList(),
      ));
      children.add(pw.SizedBox(height: 10));
    }
    if (t.textStyles.isNotEmpty) {
      children.add(pw.Text('Text styles', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)));
      children.add(pw.SizedBox(height: 4));
      children.addAll(t.textStyles.entries.map((e) => pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 4),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(e.key, style: pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
            pw.Text('Sample in ${e.key}', style: pw.TextStyle(fontSize: 10)),
          ],
        ),
      )));
    }
    if (children.length <= 3) children.add(pw.Text('No typography defined.', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600)));
    return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: children);
  }

  pw.Widget _buildPdfSpacingDetailed(models.DesignSystem ds) {
    return pw.Wrap(
      spacing: 10,
      runSpacing: 10,
      children: ds.spacing.values.entries.map((e) {
        final size = _parsePx(e.value);
        return pw.Column(children: [
          pw.Container(
            width: size / 2,
            height: size / 2,
            decoration: pw.BoxDecoration(
              color: PdfColors.blue100,
              border: pw.Border.all(color: PdfColors.blue300, width: 0.5),
            ),
          ),
          pw.Text(e.key, style: const pw.TextStyle(fontSize: 6)),
        ]);
      }).toList(),
    );
  }

  pw.Widget _buildPdfGridDetailed(models.DesignSystem ds) {
    return pw.Text('Grid: ${ds.grid.columns} columns / ${ds.grid.gutter} gutter', style: pw.TextStyle(fontSize: 10));
  }

  pw.Widget _buildPdfBorderRadiusFull(models.DesignSystem ds) {
    final r = ds.borderRadius;
    final entries = [
      ('none', r.none),
      ('sm', r.sm),
      ('base', r.base),
      ('md', r.md),
      ('lg', r.lg),
      ('xl', r.xl),
      ('full', r.full),
    ];
    return pw.Wrap(
      spacing: 12,
      runSpacing: 12,
      children: entries.map((e) => pw.Column(
        mainAxisSize: pw.MainAxisSize.min,
        children: [
          pw.Container(
            width: 36,
            height: 36,
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.blue),
              borderRadius: pw.BorderRadius.circular(e.$2 == '9999px' ? 18 : (_parsePx(e.$2) / 2).clamp(0.0, 18.0)),
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text('${e.$1}: ${e.$2}', style: const pw.TextStyle(fontSize: 8)),
        ],
      )).toList(),
    );
  }

  pw.Widget _buildPdfShadowsDetailed(models.DesignSystem ds) {
    return pw.Column(children: ds.shadows.values.entries.map((e) => pw.Text('${e.key}: ${e.value.value}', style: pw.TextStyle(fontSize: 10))).toList());
  }

  pw.Widget _buildPdfComponentsFull(models.DesignSystem ds) {
    final comp = ds.components;
    final radius = _parsePx(ds.borderRadius.base) / 4;
    final categories = [
      ('Buttons', comp.buttons),
      ('Cards', comp.cards),
      ('Inputs', comp.inputs),
      ('Navigation', comp.navigation),
      ('Avatars', comp.avatars),
      ('Modals', comp.modals ?? {}),
      ('Tables', comp.tables ?? {}),
      ('Progress', comp.progress ?? {}),
      ('Alerts', comp.alerts ?? {}),
    ];
    final children = <pw.Widget>[];
    for (final cat in categories) {
      if (cat.$2.isEmpty) continue;
      children.add(pw.Text(cat.$1, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)));
      children.add(pw.SizedBox(height: 4));
      children.addAll(cat.$2.entries.map((e) {
        final desc = e.value is Map ? e.value['description']?.toString() ?? '' : '';
        return pw.Container(
          margin: const pw.EdgeInsets.only(bottom: 4),
          padding: const pw.EdgeInsets.all(5),
          decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey300), borderRadius: pw.BorderRadius.circular(radius)),
          child: pw.Text('${e.key}${desc.isNotEmpty ? ': $desc' : ''}', style: const pw.TextStyle(fontSize: 8)),
        );
      }));
      children.add(pw.SizedBox(height: 12));
    }
    if (children.isEmpty) children.add(pw.Text('No components defined.', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600)));
    return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: children);
  }

  pw.Widget _buildPdfIconsDetailed(models.DesignSystem ds) {
    final parts = <pw.Widget>[];
    if (ds.icons.projectIcons.isNotEmpty) {
      parts.add(pw.Text('Project icons', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)));
      for (final e in ds.icons.projectIcons) {
        parts.add(pw.Padding(
          padding: const pw.EdgeInsets.only(left: 8, top: 2),
          child: pw.Text('• ${e.label} (codePoint 0x${e.codePoint.toRadixString(16)})', style: const pw.TextStyle(fontSize: 9)),
        ));
      }
      parts.add(pw.SizedBox(height: 8));
    }
    parts.add(pw.Text('Sizes', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)));
    parts.add(pw.Wrap(
      spacing: 15,
      children: ds.icons.sizes.entries.map((e) => pw.Text('${e.key}: ${e.value}', style: pw.TextStyle(fontSize: 10))).toList(),
    ));
    return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: parts);
  }

  pw.Widget _buildPdfGradientsDetailed(models.DesignSystem ds) {
    return pw.Column(children: ds.gradients.values.entries.map((e) => pw.Text('${e.key}: ${e.value.colors.join(" -> ")}', style: pw.TextStyle(fontSize: 10))).toList());
  }

  pw.Widget _buildPdfRolesDetailed(models.DesignSystem ds) {
    return pw.Column(children: ds.roles.values.entries.map((e) => pw.Text('${e.key}: ${e.value.primaryColor}', style: pw.TextStyle(fontSize: 10))).toList());
  }

  pw.Widget _buildPdfEffectsDetailed(models.DesignSystem ds) {
    final e = ds.effects;
    final lines = <pw.Widget>[];
    if (e.glassMorphism != null && e.glassMorphism!.isNotEmpty) {
      lines.add(pw.Text('Glass morphism', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)));
      for (final entry in e.glassMorphism!.entries) {
        lines.add(pw.Text('  ${entry.key}: ${entry.value}', style: const pw.TextStyle(fontSize: 9)));
      }
      lines.add(pw.SizedBox(height: 8));
    }
    if (e.darkOverlay != null && e.darkOverlay!.isNotEmpty) {
      lines.add(pw.Text('Dark overlay', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)));
      for (final entry in e.darkOverlay!.entries) {
        lines.add(pw.Text('  ${entry.key}: ${entry.value}', style: const pw.TextStyle(fontSize: 9)));
      }
    }
    if (lines.isEmpty) lines.add(pw.Text('No effects defined.', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600)));
    return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: lines);
  }

  pw.Widget _buildPdfSemanticTokensFull(models.DesignSystem ds) {
    final st = ds.semanticTokens;
    final children = <pw.Widget>[];
    void addSection(String title, Map<String, dynamic> map) {
      if (map.isEmpty) return;
      children.add(pw.Text(title, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)));
      children.add(pw.SizedBox(height: 4));
      for (final e in map.entries) {
        final v = e.value;
        final ref = v is Map ? v['baseTokenReference'] ?? v['reference'] ?? v.toString() : v.toString();
        children.add(pw.Text('  ${e.key} → $ref', style: const pw.TextStyle(fontSize: 9)));
      }
      children.add(pw.SizedBox(height: 8));
    }
    addSection('Color', st.color);
    addSection('Typography', st.typography);
    addSection('Spacing', st.spacing);
    addSection('Shadow', st.shadow);
    addSection('Border radius', st.borderRadius);
    if (children.isEmpty) children.add(pw.Text('No semantic tokens defined.', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600)));
    return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: children);
  }

  pw.Widget _buildPdfMotionTokensFull(models.DesignSystem ds) {
    final mt = ds.motionTokens;
    final children = <pw.Widget>[];
    if (mt.duration.isNotEmpty) {
      children.add(pw.Text('Duration', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)));
      children.add(pw.SizedBox(height: 4));
      for (final e in mt.duration.entries) {
        children.add(pw.Text('  ${e.key}: ${e.value}', style: const pw.TextStyle(fontSize: 9)));
      }
      children.add(pw.SizedBox(height: 8));
    }
    if (mt.easing.isNotEmpty) {
      children.add(pw.Text('Easing', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)));
      children.add(pw.SizedBox(height: 4));
      for (final e in mt.easing.entries) {
        children.add(pw.Text('  ${e.key}: ${e.value}', style: const pw.TextStyle(fontSize: 9)));
      }
    }
    if (children.isEmpty) children.add(pw.Text('No motion tokens defined.', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600)));
    return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: children);
  }

  pw.Widget _buildPdfVersionHistory(models.DesignSystem ds) {
    final history = ds.versionHistory ?? [];
    if (history.isEmpty) return pw.Text('No version history.', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600));
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: history.take(15).map((v) {
        return pw.Container(
          margin: const pw.EdgeInsets.only(bottom: 6),
          padding: const pw.EdgeInsets.all(6),
          decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey300), borderRadius: pw.BorderRadius.circular(4)),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('${v.version} — ${v.date}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
              if (v.changes.isNotEmpty) pw.Text(v.changes.join('; '), style: const pw.TextStyle(fontSize: 8)),
              if (v.description != null && v.description!.isNotEmpty) pw.Text(v.description!, style: pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
            ],
          ),
        );
      }).toList(),
    );
  }

  // --- UI SCREEN BUILDER ---

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DesignSystemProvider>(context);
    final ds = provider.designSystem;
    final titleStyle = GoogleFonts.roboto(
      fontSize: 22,
      fontWeight: FontWeight.w700,
      color: _PreviewDocTheme.pageFg,
      height: 1.25,
    );
    final leadStyle = GoogleFonts.roboto(
      fontSize: 14,
      height: 1.5,
      color: _PreviewDocTheme.textSecondary,
    );

    return Stack(
      children: [
        Scaffold(
          backgroundColor: _PreviewDocTheme.pageBg,
          appBar: AppBar(
            backgroundColor: _PreviewDocTheme.pageBg,
            foregroundColor: _PreviewDocTheme.pageFg,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            title: Text('Preview', style: GoogleFonts.roboto(fontWeight: FontWeight.w600, color: _PreviewDocTheme.pageFg)),
            actions: [
              IconButton(
                icon: _isExportingHtml
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.language),
                onPressed: _isExportingHtml ? null : _exportAsHtml,
                tooltip: 'Export HTML',
              ),
              IconButton(
                icon: _isExportingPdf ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.picture_as_pdf),
                onPressed: _isExportingPdf ? null : _exportAsPdf,
                tooltip: 'Export PDF',
              ),
            ],
          ),
          body: ScreenBodyPadding(
            verticalPadding: 0,
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 80),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHero(context, ds),
                      const SizedBox(height: 20),
                      _buildTocNav(),
                      const SizedBox(height: 40),
                      KeyedSubtree(
                        key: _keyColors,
                        child: _buildDocSection(
                          title: 'Color',
                          lead: 'Core palettes and semantic ramps from your design system. Swatches reflect saved tokens.',
                          titleStyle: titleStyle,
                          leadStyle: leadStyle,
                          child: _buildTwoColumnColors(ds),
                        ),
                      ),
                      const SizedBox(height: 48),
                      KeyedSubtree(
                        key: _keyTypography,
                        child: _buildDocSection(
                          title: 'Typography',
                          lead: 'Font family, weights, sizes, and text styles.',
                          titleStyle: titleStyle,
                          leadStyle: leadStyle,
                          child: _buildTypographyFull(ds),
                        ),
                      ),
                      const SizedBox(height: 48),
                      KeyedSubtree(
                        key: _keyLayout,
                        child: _buildDocSection(
                          title: 'Layout & shape',
                          lead: 'Spacing scale, grid, and border radius.',
                          titleStyle: titleStyle,
                          leadStyle: leadStyle,
                          child: _buildLayoutFull(ds),
                        ),
                      ),
                      const SizedBox(height: 48),
                      KeyedSubtree(
                        key: _keyShadows,
                        child: _buildDocSection(
                          title: 'Shadows',
                          lead: 'Elevation and component shadow tokens.',
                          titleStyle: titleStyle,
                          leadStyle: leadStyle,
                          child: _buildShadowsSection(ds),
                        ),
                      ),
                      const SizedBox(height: 48),
                      KeyedSubtree(
                        key: _keyEffects,
                        child: _buildDocSection(
                          title: 'Visual effects',
                          lead: 'Glass morphism and overlays.',
                          titleStyle: titleStyle,
                          leadStyle: leadStyle,
                          child: _buildEffectsSection(ds),
                        ),
                      ),
                      const SizedBox(height: 48),
                      KeyedSubtree(
                        key: _keyComponents,
                        child: _buildDocSection(
                          title: 'Components & assets',
                          lead: 'Registered components, project icons, and icon sizes.',
                          titleStyle: titleStyle,
                          leadStyle: leadStyle,
                          child: _buildComponentsDetailed(ds),
                        ),
                      ),
                      const SizedBox(height: 48),
                      KeyedSubtree(
                        key: _keyAdvanced,
                        child: _buildDocSection(
                          title: 'Advanced tokens',
                          lead: 'Gradients, roles, semantic aliases, and motion.',
                          titleStyle: titleStyle,
                          leadStyle: leadStyle,
                          child: _buildAdvancedFull(ds),
                        ),
                      ),
                      const SizedBox(height: 32),
                      _buildDocFooter(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        if (_isExportingPdf)
          Material(
            color: Colors.black54,
            child: Center(
              child: Card(
                color: _PreviewDocTheme.card,
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: _PreviewDocTheme.cardBorder)),
                margin: const EdgeInsets.all(48),
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(color: _PreviewDocTheme.accent),
                      const SizedBox(height: 24),
                      Text('Generating PDF...', style: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.w600, color: _PreviewDocTheme.pageFg)),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHero(BuildContext context, models.DesignSystem ds) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          ds.name.isEmpty ? 'Design system' : ds.name,
          style: GoogleFonts.roboto(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.02 * 16,
            height: 1.2,
            color: _PreviewDocTheme.pageFg,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Version ${ds.version}${ds.description.isNotEmpty ? ' — ${ds.description}' : ''}',
          style: GoogleFonts.roboto(fontSize: 14, height: 1.5, color: _PreviewDocTheme.textSecondary),
        ),
        const SizedBox(height: 24),
        Divider(height: 1, thickness: 1, color: _PreviewDocTheme.cardBorder),
      ],
    );
  }

  Widget _buildTocNav() {
    final items = <(String label, GlobalKey key)>[
      ('Color', _keyColors),
      ('Typography', _keyTypography),
      ('Layout', _keyLayout),
      ('Shadows', _keyShadows),
      ('Effects', _keyEffects),
      ('Components', _keyComponents),
      ('Advanced', _keyAdvanced),
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((e) {
        return Material(
          color: _PreviewDocTheme.accent.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(999),
          child: InkWell(
            onTap: () => _scrollToSection(e.$2),
            borderRadius: BorderRadius.circular(999),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: _PreviewDocTheme.accent.withValues(alpha: 0.32)),
              ),
              child: Text(
                e.$1,
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: _PreviewDocTheme.accent,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDocSection({
    required String title,
    required String lead,
    required TextStyle titleStyle,
    required TextStyle leadStyle,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: titleStyle),
        const SizedBox(height: 8),
        Container(width: double.infinity, height: 2, color: _PreviewDocTheme.accent),
        const SizedBox(height: 8),
        Text(lead, style: leadStyle),
        const SizedBox(height: 20),
        child,
      ],
    );
  }

  Widget _buildDocFooter() {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(height: 1, thickness: 1, color: _PreviewDocTheme.cardBorder),
          const SizedBox(height: 16),
          Text(
            'Live preview of your saved tokens. Export to PDF from the toolbar when you need a shareable snapshot.',
            style: GoogleFonts.roboto(fontSize: 13, color: _PreviewDocTheme.textTertiary, height: 1.45),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(String sectionTitle, Widget child) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _PreviewDocTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _PreviewDocTheme.cardBorder),
        boxShadow: _PreviewDocTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            sectionTitle,
            style: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.w700, color: _PreviewDocTheme.pageFg),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  String _toHex(String raw) {
    String h = raw.toString().replaceAll('#', '').trim().toUpperCase();
    if (h.length == 6) return '#$h';
    return raw.toString();
  }

  /// Preferred order: primary first, then analogous and semantic groups, then other palettes.
  static const List<String> _colorGroupOrder = ['primary', 'analogous', 'success', 'error', 'warning', 'info', 'secondary'];

  /// Collect (name, hex) from a color map (primary, semantic, blue, etc.).
  List<(String name, String hex)> _colorMapToEntries(Map<String, dynamic>? map) {
    if (map == null || map.isEmpty) return [];
    final list = <(String name, String hex)>[];
    for (final e in map.entries) {
      final val = e.value;
      if (val is Map && val['value'] != null) {
        list.add((e.key, val['value'].toString()));
      } else if (val is! Map) {
        list.add((e.key, val.toString()));
      }
    }
    return list;
  }

  Widget _buildTwoColumnColors(models.DesignSystem ds) {
    final allTokens = _collectAllColorTokens(ds);
    if (allTokens.isEmpty) {
      return _buildPlaceholder('Colors (add Primary or Semantic in Colors screen)');
    }
    final coreEntries = _coreSurfaceEntries(allTokens);
    final primaryRamp = _rampEntries(allTokens, 'primary');
    final t1Ramp = _rampEntries(allTokens, 'tetradic_1');
    final t2Ramp = _rampEntries(allTokens, 'tetradic_2');
    final t4Ramp = _rampEntries(allTokens, 'tetradic_4');
    final triadic3Ramp = _rampEntries(allTokens, 'triadic_3');
    final fallback = allTokens.entries
        .where((e) =>
            e.key.startsWith('triadic_') ||
            e.key.startsWith('analogous') ||
            e.key.startsWith('secondary') ||
            e.key.startsWith('success') ||
            e.key.startsWith('warning') ||
            e.key.startsWith('error') ||
            e.key.startsWith('info'))
        .map((e) => (e.key, e.value))
        .toList()
      ..sort((a, b) => _naturalCompare(a.$1, b.$1));

    final cards = <Widget>[
      _buildColorSwatchCard('Core & surfaces', coreEntries.isEmpty ? allTokens.entries.take(7).map((e) => (e.key, e.value)).toList() : coreEntries),
    ];
    if (primaryRamp.isNotEmpty) {
      cards.add(_buildColorSwatchCard(
        'Primary (teal) ramp — primary_dark1...10 / primary_light1...10',
        primaryRamp,
      ));
    }
    if (t1Ramp.isNotEmpty) {
      cards.add(_buildColorSwatchCard('Coral — teal complement (CTA / highlights)', t1Ramp));
    }
    if (t2Ramp.isNotEmpty) {
      cards.add(_buildColorSwatchCard('Purple — secondary', t2Ramp));
    }
    if (t4Ramp.isNotEmpty) {
      cards.add(_buildColorSwatchCard('Gold — purple complement (soft accent)', t4Ramp));
    }
    if (triadic3Ramp.isNotEmpty) {
      cards.add(_buildColorSwatchCard('Triadic 3 ramp', triadic3Ramp));
    }
    if (cards.length == 1 && fallback.isNotEmpty) {
      cards.add(_buildColorSwatchCard('Additional ramps', fallback.take(22).toList()));
    }

    return _buildSectionCard(
      'Colors',
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < cards.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            cards[i],
          ],
        ],
      ),
    );
  }

  Map<String, String> _collectAllColorTokens(models.DesignSystem ds) {
    final c = ds.colors;
    final maps = <Map<String, dynamic>?>[
      c.primary,
      c.semantic,
      c.blue,
      c.green,
      c.orange,
      c.purple,
      c.red,
      c.grey,
      c.white,
      c.text,
      c.input,
      c.roleSpecific,
    ];
    final out = <String, String>{};
    for (final map in maps) {
      for (final e in _colorMapToEntries(map)) {
        out[e.$1] = _toHex(e.$2);
      }
    }
    return out;
  }

  List<(String name, String hex)> _coreSurfaceEntries(Map<String, String> allTokens) {
    final preferred = <String>[
      'primary',
      'coral',
      'secondary',
      'gold',
      'appBackground',
      'appBackgroundDark',
      'coral_muted',
    ];
    final result = <(String name, String hex)>[];
    for (final name in preferred) {
      if (allTokens.containsKey(name)) result.add((name, allTokens[name]!));
    }
    return result;
  }

  List<(String name, String hex)> _rampEntries(Map<String, String> allTokens, String prefix) {
    final dark = <(int, String, String)>[];
    final light = <(int, String, String)>[];
    String? base;
    for (final e in allTokens.entries) {
      final darkMatch = RegExp('^${RegExp.escape(prefix)}_dark(\\d+)\$').firstMatch(e.key);
      if (darkMatch != null) {
        dark.add((int.parse(darkMatch.group(1)!), e.key, e.value));
        continue;
      }
      final lightMatch = RegExp('^${RegExp.escape(prefix)}_light(\\d+)\$').firstMatch(e.key);
      if (lightMatch != null) {
        light.add((int.parse(lightMatch.group(1)!), e.key, e.value));
        continue;
      }
      if (e.key == prefix) {
        base = e.value;
      }
    }
    dark.sort((a, b) => b.$1.compareTo(a.$1));
    light.sort((a, b) => a.$1.compareTo(b.$1));
    final list = <(String name, String hex)>[];
    list.addAll(dark.map((e) => (e.$2, e.$3)));
    if (base != null) list.add((prefix, base));
    list.addAll(light.map((e) => (e.$2, e.$3)));
    return list;
  }

  Widget _buildColorSwatchCard(String title, List<(String name, String hex)> entries) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _PreviewDocTheme.cardBorder),
        color: _PreviewDocTheme.card,
        boxShadow: _PreviewDocTheme.cardShadow,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.w700, color: _PreviewDocTheme.pageFg),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final cols = width > 980 ? 6 : width > 820 ? 5 : width > 640 ? 4 : width > 480 ? 3 : 2;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  // A tiny extra height prevents 1px text overflow on web/font rounding.
                  mainAxisExtent: 132,
                ),
                itemCount: entries.length,
                itemBuilder: (context, index) {
                  final e = entries[index];
                  return _buildColorSwatchTile(e.$1, e.$2);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildColorSwatchTile(String name, String hexRaw) {
    final hex = _toHex(hexRaw);
    final color = _parseColor(hex);
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          await Clipboard.setData(ClipboardData(text: hex));
          if (!mounted) return;
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Copied $hex'),
              duration: const Duration(milliseconds: 1200),
            ),
          );
        },
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _PreviewDocTheme.cardBorder),
            color: Colors.white,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 72,
                color: color,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.roboto(fontSize: 11, fontWeight: FontWeight.w500, color: _PreviewDocTheme.textSecondary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        hex,
                        style: GoogleFonts.robotoMono(fontSize: 13, fontWeight: FontWeight.w600, color: _PreviewDocTheme.pageFg),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _capitalize(String s) {
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

  /// Groups color tokens. Analogous split into sub-components: analogous_1_dark, analogous_1_light, etc.
  /// So analogous_1_dark1, analogous_1_dark2 -> "Analogous 01 Dark"; analogous_1_light1 -> "Analogous 01 Light".
  Map<String, List<(String name, String hex)>> _groupColorsByPrefix(List<(String name, String hex)> entries) {
    final map = <String, List<(String name, String hex)>>{};
    for (final e in entries) {
      final parts = e.$1.split('_');
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
        key = first.isEmpty ? e.$1.toLowerCase() : first;
      }
      map.putIfAbsent(key, () => []).add(e);
    }
    for (final list in map.values) {
      list.sort((a, b) => _naturalCompare(a.$1, b.$1));
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

  Widget _buildColorGroupColumn(String title, List<(String name, String hex)> entries) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _PreviewDocTheme.cardBorder),
        boxShadow: _PreviewDocTheme.cardShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: _PreviewDocTheme.cardMuted,
              border: Border(bottom: BorderSide(color: _PreviewDocTheme.cardBorder)),
            ),
            child: Text(
              title,
              style: GoogleFonts.roboto(fontSize: 13, fontWeight: FontWeight.w600, color: _PreviewDocTheme.pageFg),
            ),
          ),
          ...entries.asMap().entries.map((e) => _buildColorRow(e.value.$1, e.value.$2, showBorder: e.key < entries.length - 1)),
        ],
      ),
    );
  }

  Widget _buildColorRow(String tokenName, String hexRaw, {bool showBorder = true}) {
    final hex = _toHex(hexRaw);
    final color = _parseColor(hex);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _PreviewDocTheme.card,
        border: showBorder ? Border(bottom: BorderSide(color: _PreviewDocTheme.cardBorder)) : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 76,
            child: Text(
              hex,
              style: GoogleFonts.robotoMono(fontSize: 12, fontWeight: FontWeight.w600, color: _PreviewDocTheme.pageFg),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 48,
            height: 28,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: _PreviewDocTheme.cardBorder),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              tokenName,
              style: GoogleFonts.roboto(fontSize: 13, fontWeight: FontWeight.w500, color: _PreviewDocTheme.pageFg),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  List<(String name, String hex)> _colorEntries(Map<String, dynamic> colors) {
    final list = <(String, String)>[];
    for (final e in colors.entries) {
      final val = e.value;
      if (val is Map && val['value'] != null) {
        list.add((e.key, val['value'].toString()));
      } else if (val is! Map) {
        list.add((e.key, val.toString()));
      }
    }
    return list;
  }


  Widget _buildTypographyFull(models.DesignSystem ds) {
    final t = ds.typography;
    final hasAny = t.fontWeights.isNotEmpty || t.fontSizes.isNotEmpty || t.textStyles.isNotEmpty;
    if (!hasAny) return _buildPlaceholder('Typography (add Font Family, Weights, Sizes or Styles)');
    final primaryFont = t.fontFamily.primary;

    return _buildSectionCard('Typography', Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Font Family
        _buildTypographySubheading('Font Family'),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _PreviewDocTheme.cardBorder),
            color: _PreviewDocTheme.card,
          ),
          child: Row(
            children: [
              _buildTypographyLabel('Primary'),
              const SizedBox(width: 16),
              Expanded(
                child: Text(primaryFont, style: _getSafeFont(primaryFont, fontSize: 16)),
              ),
            ],
          ),
        ),
        if (t.fontFamily.fallback.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _PreviewDocTheme.cardBorder),
              color: _PreviewDocTheme.card,
            ),
            child: Row(
              children: [
                _buildTypographyLabel('Fallback'),
                const SizedBox(width: 16),
                Expanded(child: Text(t.fontFamily.fallback, style: const TextStyle(fontSize: 16))),
              ],
            ),
          ),
        ],
        if (t.fontWeights.isNotEmpty) ...[
          const SizedBox(height: 24),
          _buildTypographySubheading('Weights'),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _PreviewDocTheme.cardBorder),
              color: _PreviewDocTheme.card,
            ),
            child: Column(
              children: _buildTypographyWeightRows(primaryFont, t.fontWeights),
            ),
          ),
        ],
        if (t.fontSizes.isNotEmpty) ...[
          const SizedBox(height: 24),
          _buildTypographySubheading('Sizes'),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _PreviewDocTheme.cardBorder),
              color: _PreviewDocTheme.card,
            ),
            child: Column(
              children: _buildTypographySizeRows(primaryFont, t.fontSizes),
            ),
          ),
        ],
        if (t.textStyles.isNotEmpty) ...[
          const SizedBox(height: 24),
          _buildTypographySubheading('Styles'),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _PreviewDocTheme.cardBorder),
              color: _PreviewDocTheme.card,
            ),
            child: Column(
              children: () {
                final entries = t.textStyles.entries.toList();
                return List.generate(entries.length, (i) {
                  final e = entries[i];
                  final showBorder = i < entries.length - 1;
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      border: showBorder ? Border(bottom: BorderSide(color: _PreviewDocTheme.cardBorder)) : null,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 140,
                          child: Text(e.key, style: GoogleFonts.roboto(fontSize: 13, fontWeight: FontWeight.w600, color: _PreviewDocTheme.pageFg)),
                        ),
                        Expanded(
                          child: Text(
                            'The quick brown fox jumps over the lazy dog',
                            style: _getSafeFont(e.value.fontFamily, fontSize: _parsePx(e.value.fontSize), fontWeight: _intToWeight(e.value.fontWeight)),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          '${e.value.fontSize} · ${e.value.fontWeight}',
                          style: GoogleFonts.roboto(fontSize: 12, color: _PreviewDocTheme.textSecondary),
                        ),
                      ],
                    ),
                  );
                });
              }(),
            ),
          ),
        ],
      ],
    ));
  }

  Widget _buildTypographySubheading(String title) {
    return Text(
      title,
      style: GoogleFonts.roboto(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.06 * 11,
        color: const Color(0xFF7B6F9D),
      ),
    );
  }

  Widget _buildTypographyLabel(String label) {
    return SizedBox(
      width: 80,
      child: Text(label, style: GoogleFonts.roboto(fontSize: 13, color: _PreviewDocTheme.textSecondary)),
    );
  }

  List<Widget> _buildTypographyWeightRows(String fontFamily, Map<String, int> weights) {
    final entries = weights.entries.toList();
    return List.generate(entries.length, (i) {
      final e = entries[i];
      final showBorder = i < entries.length - 1;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: showBorder ? Border(bottom: BorderSide(color: _PreviewDocTheme.cardBorder)) : null,
        ),
        child: Row(
          children: [
            SizedBox(width: 100, child: Text(e.key, style: GoogleFonts.roboto(fontSize: 13, fontWeight: FontWeight.w600, color: _PreviewDocTheme.pageFg))),
            const SizedBox(width: 16),
            SizedBox(width: 48, child: Text('${e.value}', style: GoogleFonts.roboto(fontSize: 12, color: _PreviewDocTheme.textSecondary))),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'Sample weight ${e.key}',
                style: _getSafeFont(fontFamily, fontSize: 16, fontWeight: _intToWeight(e.value)),
              ),
            ),
          ],
        ),
      );
    });
  }

  List<Widget> _buildTypographySizeRows(String fontFamily, Map<String, models.FontSize> sizes) {
    final entries = sizes.entries.toList();
    return List.generate(entries.length, (i) {
      final e = entries[i];
      final showBorder = i < entries.length - 1;
      final sizePx = _parsePx(e.value.value);
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: showBorder ? Border(bottom: BorderSide(color: _PreviewDocTheme.cardBorder)) : null,
        ),
        child: Row(
          children: [
            SizedBox(width: 80, child: Text(e.key, style: GoogleFonts.roboto(fontSize: 13, fontWeight: FontWeight.w600, color: _PreviewDocTheme.pageFg))),
            const SizedBox(width: 16),
            SizedBox(width: 56, child: Text(e.value.value, style: GoogleFonts.roboto(fontSize: 12, color: _PreviewDocTheme.textSecondary))),
            const SizedBox(width: 8),
            SizedBox(width: 48, child: Text('LH ${e.value.lineHeight}', style: GoogleFonts.roboto(fontSize: 11, color: _PreviewDocTheme.textTertiary))),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'Sample at ${e.value.value}',
                style: _getSafeFont(fontFamily, fontSize: sizePx),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildLayoutFull(models.DesignSystem ds) {
    final hasLayout = ds.spacing.values.isNotEmpty || ds.grid.columns > 0;
    if (!hasLayout) return _buildPlaceholder('Spacing & Grid');

    final radiusEntries = [
      ('None', ds.borderRadius.none),
      ('Small', ds.borderRadius.sm),
      ('Base', ds.borderRadius.base),
      ('Medium', ds.borderRadius.md),
      ('Large', ds.borderRadius.lg),
      ('Extra Large', ds.borderRadius.xl),
      ('Full', ds.borderRadius.full),
    ];

    return _buildSectionCard('Layout & Shape', Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Spacing scale', style: GoogleFonts.roboto(fontWeight: FontWeight.w600, fontSize: 14, color: _PreviewDocTheme.pageFg)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: ds.spacing.values.entries.map((e) {
            final size = _parsePx(e.value);
            return Column(
              children: [
                Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    color: _PreviewDocTheme.accent.withValues(alpha: 0.14),
                    border: Border.all(color: _PreviewDocTheme.accent.withValues(alpha: 0.35)),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(height: 4),
                Text('${e.key} (${e.value})', style: GoogleFonts.roboto(fontSize: 11, color: _PreviewDocTheme.textSecondary)),
              ],
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        Text('Grid system', style: GoogleFonts.roboto(fontWeight: FontWeight.w600, fontSize: 14, color: _PreviewDocTheme.pageFg)),
        const SizedBox(height: 12),
        Container(
          height: 48,
          width: double.infinity,
          decoration: BoxDecoration(border: Border.all(color: _PreviewDocTheme.cardBorder), borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: List.generate(ds.grid.columns, (i) => Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF7B6F9D).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            )),
          ),
        ),
        const SizedBox(height: 6),
        Text('Columns: ${ds.grid.columns} · Gutter: ${ds.grid.gutter}', style: GoogleFonts.roboto(fontSize: 12, color: _PreviewDocTheme.textSecondary)),
        const SizedBox(height: 24),
        Text('Border radius', style: GoogleFonts.roboto(fontWeight: FontWeight.w600, fontSize: 14, color: _PreviewDocTheme.pageFg)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 20,
          runSpacing: 20,
          children: radiusEntries.map((e) => _buildRadiusSample(e.$1, _parseRadius(e.$2), e.$2)).toList(),
        ),
      ],
    ));
  }

  double _parseRadius(String value) {
    if (value == '9999px' || value.toLowerCase() == 'full') return 9999;
    return _parsePx(value);
  }

  Widget _buildRadiusSample(String label, double radius, String value) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: _PreviewDocTheme.cardMuted,
            border: Border.all(color: _PreviewDocTheme.accent, width: 2),
            borderRadius: BorderRadius.circular(radius),
          ),
          child: const Center(child: Icon(Icons.rounded_corner, color: _PreviewDocTheme.accent, size: 20)),
        ),
        const SizedBox(height: 8),
        Text('$label: $value', style: GoogleFonts.roboto(fontSize: 10, fontWeight: FontWeight.w500, color: _PreviewDocTheme.pageFg)),
      ],
    );
  }

  Widget _buildShadowsSection(models.DesignSystem ds) {
    if (ds.shadows.values.isEmpty) {
      return _buildSectionCard('Shadows', Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(
          'No shadows in design system. Add tokens in the Shadows screen (elevation and component shadows).',
          style: GoogleFonts.roboto(fontSize: 13, color: _PreviewDocTheme.textSecondary, height: 1.45),
        ),
      ));
    }
    return _buildSectionCard('Shadows', Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: () {
        final entries = ds.shadows.values.entries.toList();
        return List.generate(entries.length, (i) {
          final e = entries[i];
          final showBorder = i < entries.length - 1;
          final boxShadow = _parseShadowToBoxShadow(e.value.value);
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              border: showBorder ? Border(bottom: BorderSide(color: _PreviewDocTheme.cardBorder)) : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 120,
                      child: Text(e.key, style: GoogleFonts.roboto(fontSize: 14, fontWeight: FontWeight.w600, color: _PreviewDocTheme.pageFg)),
                    ),
                    Expanded(
                      child: _buildShadowContextPreview(e.key, boxShadow),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  e.value.value,
                  style: GoogleFonts.robotoMono(fontSize: 11, color: _PreviewDocTheme.textSecondary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        });
      }(),
    ));
  }

  Widget _buildShadowContextPreview(String tokenName, BoxShadow boxShadow) {
    final shadow = [boxShadow];
    final name = tokenName.toLowerCase();
    // Card: content card with shadow
    if (name == 'card') {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: shadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(height: 8, width: 60, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(4))),
            const SizedBox(height: 8),
            Container(height: 6, width: double.infinity, decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 4),
            Container(height: 6, width: 120, decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(2))),
          ],
        ),
      );
    }
    // FAB: floating action button
    if (name == 'fab') {
      return Align(
        alignment: Alignment.centerLeft,
        child: Material(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(16),
          elevation: 0,
          shadowColor: Colors.transparent,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: shadow,
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 28),
          ),
        ),
      );
    }
    // Button
    if (name == 'button') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(8),
          boxShadow: shadow,
        ),
        child: const Text('Button', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
      );
    }
    // Dropdown / popover
    if (name == 'dropdown') {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: shadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _dropdownItem('Option A'),
            _dropdownItem('Option B'),
            _dropdownItem('Option C'),
          ],
        ),
      );
    }
    // Modal / dialog
    if (name == 'modal') {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: shadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dialog title', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade800)),
            const SizedBox(height: 8),
            Text('Content goes here.', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: () {}, child: const Text('Cancel')),
                const SizedBox(width: 8),
                FilledButton(onPressed: () {}, child: const Text('OK')),
              ],
            ),
          ],
        ),
      );
    }
    // Tooltip
    if (name == 'tooltip') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey.shade800,
          borderRadius: BorderRadius.circular(6),
          boxShadow: shadow,
        ),
        child: const Text('Tooltip text', style: TextStyle(color: Colors.white, fontSize: 12)),
      );
    }
    // App bar
    if (name == 'app-bar') {
      return Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
          boxShadow: shadow,
        ),
        alignment: Alignment.centerLeft,
        child: Text('App bar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey.shade800)),
      );
    }
    // Input focus
    if (name == 'input-focus') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue, width: 2),
          boxShadow: shadow,
        ),
        child: Text('Input field', style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
      );
    }
    // Sheet / drawer
    if (name == 'sheet') {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: shadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 32, height: 4, decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 12),
            Text('Sheet content', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.grey.shade800)),
          ],
        ),
      );
    }
    // Elevation scale (sm, md, lg, xl) or unknown: simple raised surface
    return Container(
      width: 80,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: shadow,
      ),
      child: const Center(child: Icon(Icons.square, color: Colors.grey, size: 24)),
    );
  }

  Widget _dropdownItem(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          Icon(Icons.check_box_outline_blank, size: 18, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(fontSize: 13, color: Colors.grey.shade800)),
        ],
      ),
    );
  }

  Widget _buildEffectsSection(models.DesignSystem ds) {
    final effects = ds.effects;
    final hasAny = effects.glassMorphism != null || effects.darkOverlay != null;
    if (!hasAny) {
      return _buildSectionCard('Visual Effects', Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(
          'No effects in design system. Add Glass Morphism or Dark Overlay in the Effects screen.',
          style: GoogleFonts.roboto(fontSize: 13, color: _PreviewDocTheme.textSecondary, height: 1.45),
        ),
      ));
    }
    return _buildSectionCard('Visual Effects', Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (effects.glassMorphism != null) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text('Glass morphism', style: GoogleFonts.roboto(fontSize: 14, fontWeight: FontWeight.w600, color: _PreviewDocTheme.pageFg)),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 120,
              width: double.infinity,
              child: _buildEffectPreview('glassMorphism', effects.glassMorphism!),
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (effects.darkOverlay != null) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text('Dark overlay', style: GoogleFonts.roboto(fontSize: 14, fontWeight: FontWeight.w600, color: _PreviewDocTheme.pageFg)),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 120,
              width: double.infinity,
              child: _buildEffectPreview('darkOverlay', effects.darkOverlay!),
            ),
          ),
        ],
      ],
    ));
  }

  Widget _buildEffectPreview(String effectKey, Map<String, dynamic> effectData) {
    if (effectKey == 'glassMorphism') {
      final bg = _parseRgbaForEffect(effectData['background']?.toString() ?? 'rgba(255,255,255,0.1)');
      final blurSigma = _parseBlurForEffect(effectData['backdrop']?.toString() ?? 'blur(10px)');
      return Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.blue.shade200, Colors.purple.shade200],
              ),
            ),
          ),
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
                child: Container(
                  width: 160,
                  height: 72,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
                  ),
                  child: const Center(
                    child: Text('Glass panel', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }
    if (effectKey == 'darkOverlay') {
      final overlayColor = _parseRgbaForEffect(effectData['background']?.toString() ?? 'rgba(26,26,46,0.8)');
      return Stack(
        fit: StackFit.expand,
        children: [
          Container(
            color: Colors.grey[100],
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.image_outlined, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 8),
                  Text('Content behind', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                ],
              ),
            ),
          ),
          Container(
            color: overlayColor,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('Overlay on top', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
              ),
            ),
          ),
        ],
      );
    }
    return Container(color: Colors.grey[200], child: const Center(child: Text('Preview')));
  }

  double _parseBlurForEffect(String value) {
    final match = RegExp(r'blur\s*\(\s*(\d+(?:\.\d+)?)\s*px\s*\)', caseSensitive: false).firstMatch(value);
    if (match != null) {
      final n = double.tryParse(match.group(1)!);
      if (n != null) return n.clamp(0.0, 50.0);
    }
    return 10.0;
  }

  Color _parseRgbaForEffect(String value) {
    final match = RegExp(r'rgba?\s*\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*(?:,\s*([\d.]+)\s*)?\)').firstMatch(value);
    if (match != null) {
      final r = int.parse(match.group(1)!).clamp(0, 255);
      final g = int.parse(match.group(2)!).clamp(0, 255);
      final b = int.parse(match.group(3)!).clamp(0, 255);
      final a = match.group(4) != null ? double.tryParse(match.group(4)!) ?? 1.0 : 1.0;
      return Color.fromRGBO(r, g, b, a.clamp(0.0, 1.0));
    }
    return Colors.black26;
  }

  BoxShadow _parseShadowToBoxShadow(String shadowValue) {
    try {
      final parts = shadowValue.trim().split(RegExp(r'\s+'));
      if (parts.length >= 3) {
        final offsetX = double.tryParse(parts[0].replaceAll('px', '')) ?? 0.0;
        final offsetY = double.tryParse(parts[1].replaceAll('px', '')) ?? 0.0;
        final blurRadius = double.tryParse(parts[2].replaceAll('px', '')) ?? 0.0;
        double spreadRadius = 0.0;
        Color color = Colors.black;
        double opacity = 0.1;
        if (parts.length >= 4) spreadRadius = double.tryParse(parts[3].replaceAll('px', '')) ?? 0.0;
        for (int i = 0; i < parts.length; i++) {
          if (parts[i].startsWith('rgba')) {
            final match = RegExp(r'rgba?\((\d+),\s*(\d+),\s*(\d+)(?:,\s*([\d.]+))?\)').firstMatch(parts[i]);
            if (match != null) {
              color = Color.fromRGBO(int.parse(match.group(1)!), int.parse(match.group(2)!), int.parse(match.group(3)!), match.group(4) != null ? double.parse(match.group(4)!) : 1.0);
              opacity = match.group(4) != null ? double.parse(match.group(4)!) : 0.1;
            }
            break;
          }
        }
        return BoxShadow(offset: Offset(offsetX, offsetY), blurRadius: blurRadius, spreadRadius: spreadRadius, color: color.withOpacity(opacity));
      }
    } catch (_) {}
    return BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2));
  }

  Widget _buildComponentsDetailed(models.DesignSystem ds) {
    final hasComponents = ds.components.buttons.isNotEmpty ||
                         ds.components.inputs.isNotEmpty ||
                         ds.components.cards.isNotEmpty ||
                         ds.components.navigation.isNotEmpty ||
                         ds.components.avatars.isNotEmpty;
    final hasProjectIcons = ds.icons.projectIcons.isNotEmpty;
    final hasIconSizes = ds.icons.sizes.isNotEmpty;

    if (!hasComponents && !hasProjectIcons && !hasIconSizes) {
      return _buildPlaceholder('Component Library');
    }

    final baseRadius = _parsePx(ds.borderRadius.base);
    final previewIconSize = _parsePx(ds.icons.sizes['md'] ?? '24px');

    return _buildSectionCard('Components & Assets', Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildComponentCategory('Buttons', ds.components.buttons, baseRadius),
        _buildComponentCategory('Text Fields / Inputs', ds.components.inputs, baseRadius),
        _buildComponentCategory('Cards', ds.components.cards, baseRadius),
        _buildComponentCategory('Navigation', ds.components.navigation, baseRadius),
        _buildComponentCategory('Avatars', ds.components.avatars, 100),
        if (hasProjectIcons) ...[
          const SizedBox(height: 8),
          Text('Project icons', style: GoogleFonts.roboto(fontWeight: FontWeight.w600, fontSize: 14, color: _PreviewDocTheme.pageFg)),
          const SizedBox(height: 4),
          Text(
            'Icons defined for this product (Icons screen)',
            style: GoogleFonts.roboto(fontSize: 11, color: _PreviewDocTheme.textSecondary),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: ds.icons.projectIcons.map((e) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _PreviewDocTheme.card,
                      border: Border.all(color: _PreviewDocTheme.cardBorder),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DynamicMaterialIcon(
                      codePoint: e.codePoint,
                      size: previewIconSize,
                      color: _PreviewDocTheme.pageFg,
                    ),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: 88,
                    child: Text(
                      e.label,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.roboto(fontSize: 10, fontWeight: FontWeight.w500, color: _PreviewDocTheme.textSecondary),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
        if (hasIconSizes) ...[
          const SizedBox(height: 16),
          Text('Icon sizes', style: GoogleFonts.roboto(fontWeight: FontWeight.w600, fontSize: 14, color: _PreviewDocTheme.pageFg)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: ds.icons.sizes.entries.map((e) {
              final size = _parsePx(e.value);
              return Column(
                children: [
                  Icon(Icons.star, size: size, color: _PreviewDocTheme.textSecondary),
                  const SizedBox(height: 4),
                  Text('${e.key} (${e.value})', style: GoogleFonts.roboto(fontSize: 11, color: _PreviewDocTheme.textSecondary)),
                ],
              );
            }).toList(),
          ),
        ],
      ],
    ));
  }

  Widget _buildComponentCategory(String name, Map<String, dynamic> tokens, double radius) {
    if (tokens.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, style: GoogleFonts.roboto(fontWeight: FontWeight.w600, fontSize: 11, letterSpacing: 0.07 * 11, color: const Color(0xFF7B6F9D))),
          const SizedBox(height: 8),
          ...tokens.entries.map((e) {
            final desc = e.value is Map ? e.value['description']?.toString() ?? '' : '';
            return Container(
              margin: const EdgeInsets.only(bottom: 4),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _PreviewDocTheme.cardMuted,
                border: Border.all(color: _PreviewDocTheme.cardBorder),
                borderRadius: BorderRadius.circular(radius.clamp(8, 16)),
              ),
              child: Row(
                children: [
                  Text(e.key, style: GoogleFonts.roboto(fontWeight: FontWeight.w600, fontSize: 11, color: _PreviewDocTheme.pageFg)),
                  if (desc.isNotEmpty) ...[
                    Text(' — ', style: GoogleFonts.roboto(color: _PreviewDocTheme.textTertiary)),
                    Expanded(child: Text(desc, style: GoogleFonts.roboto(fontSize: 10, color: _PreviewDocTheme.textSecondary))),
                  ],
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAdvancedFull(models.DesignSystem ds) {
    final hasAdvanced = ds.gradients.values.isNotEmpty || ds.roles.values.isNotEmpty ||
        ds.semanticTokens.color.isNotEmpty || ds.motionTokens.duration.isNotEmpty;
    if (!hasAdvanced) return _buildPlaceholder('Advanced Tokens');

    return _buildSectionCard('Advanced Tokens', Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (ds.gradients.values.isNotEmpty) _buildTokenList('Gradients', ds.gradients.values.entries.map((e) => e.key).toList()),
        if (ds.gradients.values.isNotEmpty && (ds.roles.values.isNotEmpty || ds.semanticTokens.color.isNotEmpty || ds.motionTokens.duration.isNotEmpty)) const SizedBox(height: 16),
        if (ds.roles.values.isNotEmpty) _buildTokenList('Roles', ds.roles.values.entries.map((e) => e.key).toList()),
        if (ds.roles.values.isNotEmpty && (ds.semanticTokens.color.isNotEmpty || ds.motionTokens.duration.isNotEmpty)) const SizedBox(height: 16),
        if (ds.semanticTokens.color.isNotEmpty) _buildTokenList('Semantic Tokens', ds.semanticTokens.color.keys.toList()),
        if (ds.semanticTokens.color.isNotEmpty && ds.motionTokens.duration.isNotEmpty) const SizedBox(height: 16),
        if (ds.motionTokens.duration.isNotEmpty) _buildTokenList('Motion', ds.motionTokens.duration.keys.toList()),
      ],
    ));
  }

  Widget _buildTokenList(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.roboto(fontWeight: FontWeight.w600, fontSize: 14, color: _PreviewDocTheme.pageFg)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: items.map((s) => Chip(
            label: Text(s, style: GoogleFonts.roboto(fontSize: 12, color: _PreviewDocTheme.pageFg)),
            padding: EdgeInsets.zero,
            backgroundColor: _PreviewDocTheme.accent.withValues(alpha: 0.12),
            side: BorderSide(color: _PreviewDocTheme.cardBorder),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildPlaceholder(String section) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _PreviewDocTheme.cardMuted,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _PreviewDocTheme.cardBorder),
      ),
      child: Text(
        'No data for $section. Add tokens in the dashboard.',
        style: GoogleFonts.roboto(fontStyle: FontStyle.italic, color: _PreviewDocTheme.textSecondary, fontSize: 14, height: 1.45),
      ),
    );
  }

  // --- HELPERS ---
  TextStyle _getSafeFont(String name, {double? fontSize, FontWeight? fontWeight}) {
    try { return GoogleFonts.getFont(name, fontSize: fontSize, fontWeight: fontWeight); }
    catch (e) { return TextStyle(fontSize: fontSize, fontWeight: fontWeight); }
  }
  FontWeight _intToWeight(int w) => FontWeight.values[(w ~/ 100 - 1).clamp(0, 8)];
  Color _parseColor(String h) => Color(int.parse(h.replaceAll('#', 'FF'), radix: 16));
  PdfColor _parsePdfColor(String hex) {
    try {
      final h = hex.replaceAll('#', '');
      return PdfColor.fromInt(int.parse(h.length == 6 ? 'FF$h' : h, radix: 16));
    } catch (_) { return PdfColors.black; }
  }
  double _parsePx(String s) => double.tryParse(s.replaceAll('px', '')) ?? 14.0;
}
