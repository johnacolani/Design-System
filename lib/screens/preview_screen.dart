import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:google_fonts/google_fonts.dart';
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
    
    final titleStyle = pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold);
    final headerStyle = pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900);
    final subHeaderStyle = pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold);

    // Page 1: Colors
    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      build: (pw.Context context) => [
        pw.Header(level: 0, child: pw.Text(ds.name, style: titleStyle)),
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
        _buildPdfTypographyDetailed(ds),
        pw.SizedBox(height: 30),
        pw.Text('3. Spacing & Grid', style: headerStyle),
        pw.SizedBox(height: 10),
        _buildPdfSpacingDetailed(ds),
        pw.SizedBox(height: 10),
        _buildPdfGridDetailed(ds),
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
        _buildPdfBorderRadiusDetailed(ds),
        pw.SizedBox(height: 20),
        pw.Text('Shadow Tokens', style: subHeaderStyle),
        _buildPdfShadowsDetailed(ds),
      ],
    ));

    // Page 4: Components & Assets
    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      build: (pw.Context context) => [
        pw.Text('5. Component Library', style: headerStyle),
        pw.SizedBox(height: 10),
        _buildPdfComponentsDetailed(ds),
        pw.SizedBox(height: 30),
        pw.Text('6. Iconography', style: headerStyle),
        pw.SizedBox(height: 10),
        _buildPdfIconsDetailed(ds),
      ],
    ));

    // Page 5: Advanced (Gradients, Roles, Tokens, Motion)
    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      build: (pw.Context context) => [
        pw.Text('7. Advanced Tokens', style: headerStyle),
        pw.SizedBox(height: 10),
        pw.Text('Gradients', style: subHeaderStyle),
        _buildPdfGradientsDetailed(ds),
        pw.SizedBox(height: 20),
        pw.Text('Roles', style: subHeaderStyle),
        _buildPdfRolesDetailed(ds),
        pw.SizedBox(height: 20),
        pw.Text('Semantic Tokens', style: subHeaderStyle),
        _buildPdfSemanticTokensDetailed(ds),
        pw.SizedBox(height: 20),
        pw.Text('Motion Tokens', style: subHeaderStyle),
        _buildPdfMotionTokensDetailed(ds),
      ],
    ));
    
    return pdf;
  }

  // --- PDF WIDGETS (SYNCHRONIZED WITH ON-SCREEN SHAPES) ---

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

  pw.Widget _buildPdfTypographyDetailed(models.DesignSystem ds) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Primary Font: ${ds.typography.fontFamily.primary}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 10),
        ...ds.typography.textStyles.entries.map((e) => 
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(e.key, style: pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
              pw.Text('Sample Text in Style', style: pw.TextStyle(fontSize: 12)),
              pw.SizedBox(height: 4),
            ],
          )
        ),
      ],
    );
  }

  pw.Widget _buildPdfSpacingDetailed(models.DesignSystem ds) {
    return pw.Wrap(
      spacing: 10,
      runSpacing: 10,
      children: ds.spacing.values.entries.map((e) {
        final size = _parsePx(e.value);
        return pw.Column(children: [
          pw.Container(width: size / 2, height: size / 2, color: PdfColors.blue100, border: pw.Border.all(color: PdfColors.blue300, width: 0.5)),
          pw.Text('${e.key}', style: const pw.TextStyle(fontSize: 6)),
        ]);
      }).toList(),
    );
  }

  pw.Widget _buildPdfGridDetailed(models.DesignSystem ds) {
    return pw.Text('Grid: ${ds.grid.columns} columns / ${ds.grid.gutter} gutter', style: pw.TextStyle(fontSize: 10));
  }

  pw.Widget _buildPdfBorderRadiusDetailed(models.DesignSystem ds) {
    final base = _parsePx(ds.borderRadius.base);
    return pw.Row(children: [
      pw.Container(width: 40, height: 40, decoration: pw.BoxDecoration(borderRadius: pw.BorderRadius.circular(base / 2), border: pw.Border.all(color: PdfColors.blue))),
      pw.SizedBox(width: 10),
      pw.Text('Radius: ${ds.borderRadius.base}'),
    ]);
  }

  pw.Widget _buildPdfShadowsDetailed(models.DesignSystem ds) {
    return pw.Column(children: ds.shadows.values.entries.map((e) => pw.Text('${e.key}: ${e.value.value}', style: pw.TextStyle(fontSize: 10))).toList());
  }

  pw.Widget _buildPdfComponentsDetailed(models.DesignSystem ds) {
    final list = [...ds.components.buttons.entries, ...ds.components.inputs.entries, ...ds.components.cards.entries];
    final radius = _parsePx(ds.borderRadius.base);
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: list.map((e) {
        final desc = e.value is Map ? e.value['description']?.toString() ?? '' : '';
        return pw.Container(
          margin: const pw.EdgeInsets.only(bottom: 5),
          padding: const pw.EdgeInsets.all(5),
          decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey300), borderRadius: pw.BorderRadius.circular(radius / 4)),
          child: pw.Text('${e.key}: $desc', style: const pw.TextStyle(fontSize: 8)),
        );
      }).toList(),
    );
  }

  pw.Widget _buildPdfIconsDetailed(models.DesignSystem ds) {
    return pw.Wrap(spacing: 15, children: ds.icons.sizes.entries.map((e) => pw.Text('${e.key}: ${e.value}', style: pw.TextStyle(fontSize: 10))).toList());
  }

  pw.Widget _buildPdfGradientsDetailed(models.DesignSystem ds) {
    return pw.Column(children: ds.gradients.values.entries.map((e) => pw.Text('${e.key}: ${e.value.colors.join(" -> ")}', style: pw.TextStyle(fontSize: 10))).toList());
  }

  pw.Widget _buildPdfRolesDetailed(models.DesignSystem ds) {
    return pw.Column(children: ds.roles.values.entries.map((e) => pw.Text('${e.key}: ${e.value.primaryColor}', style: pw.TextStyle(fontSize: 10))).toList());
  }

  pw.Widget _buildPdfSemanticTokensDetailed(models.DesignSystem ds) {
    return pw.Column(children: ds.semanticTokens.color.entries.map((e) => pw.Text('${e.key} -> ${e.value['baseTokenReference']}', style: pw.TextStyle(fontSize: 10))).toList());
  }

  pw.Widget _buildPdfMotionTokensDetailed(models.DesignSystem ds) {
    return pw.Column(children: ds.motionTokens.duration.entries.map((e) => pw.Text('${e.key}: ${e.value}', style: pw.TextStyle(fontSize: 10))).toList());
  }

  // --- UI SCREEN BUILDER ---

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DesignSystemProvider>(context);
    final ds = provider.designSystem;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Design System Preview'),
        actions: [
          IconButton(icon: const Icon(Icons.picture_as_pdf), onPressed: _exportAsPdf, tooltip: 'Export PDF'),
        ],
      ),
      body: ScreenBodyPadding(
        verticalPadding: 0,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeading('1. Core Colors'),
              _buildTwoColumnColors(ds),
              const Divider(height: 40),
              
              _buildHeading('2. Typography'),
              _buildTypographyFull(ds),
              const Divider(height: 40),

              _buildHeading('3. Layout & Shape'),
              _buildLayoutFull(ds),
              const Divider(height: 40),

              _buildHeading('4. Components & Assets'),
              _buildComponentsDetailed(ds),
              const Divider(height: 40),

              _buildHeading('5. Advanced Tokens'),
              _buildAdvancedFull(ds),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeading(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue)),
    );
  }

  Widget _buildTwoColumnColors(models.DesignSystem ds) {
    if (ds.colors.primary.isEmpty && ds.colors.semantic.isEmpty) {
      return _buildPlaceholder('Colors (Primary & Semantic)');
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildShortColorList('Primary', ds.colors.primary)),
        const SizedBox(width: 20),
        Expanded(child: _buildShortColorList('Semantic', ds.colors.semantic)),
      ],
    );
  }

  Widget _buildShortColorList(String title, Map<String, dynamic> colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey)),
        const SizedBox(height: 8),
        ...colors.entries.map((e) {
          final hex = e.value is Map ? e.value['value'] : e.value.toString();
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(children: [
              Container(width: 20, height: 20, decoration: BoxDecoration(color: _parseColor(hex), borderRadius: BorderRadius.circular(4))),
              const SizedBox(width: 8),
              Expanded(child: Text(e.key, style: const TextStyle(fontSize: 10), overflow: TextOverflow.ellipsis)),
            ]),
          );
        }),
      ],
    );
  }

  Widget _buildTypographyFull(models.DesignSystem ds) {
    if (ds.typography.textStyles.isEmpty) return _buildPlaceholder('Typography & Text Styles');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Primary Font: ${ds.typography.fontFamily.primary}', style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        ...ds.typography.textStyles.entries.map((e) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(e.key, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
              Text('The quick brown fox jumps over the lazy dog', 
                style: _getSafeFont(ds.typography.fontFamily.primary, 
                  fontSize: _parsePx(e.value.fontSize),
                  fontWeight: _intToWeight(e.value.fontWeight)
                )
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildLayoutFull(models.DesignSystem ds) {
    final hasLayout = ds.spacing.values.isNotEmpty || ds.grid.columns > 0;
    if (!hasLayout) return _buildPlaceholder('Spacing & Grid');

    final baseRadius = _parsePx(ds.borderRadius.base);
    final largeRadius = _parsePx(ds.borderRadius.lg);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Spacing Scale', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: ds.spacing.values.entries.map((e) {
            final size = _parsePx(e.value);
            return Column(
              children: [
                Container(width: size, height: size, decoration: BoxDecoration(color: Colors.blue.shade100, border: Border.all(color: Colors.blue.shade300))),
                const SizedBox(height: 4),
                Text('${e.key} (${e.value})', style: const TextStyle(fontSize: 8)),
              ],
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        const Text('Grid System', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 12),
        Container(
          height: 40,
          width: double.infinity,
          decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300)),
          child: Row(
            children: List.generate(ds.grid.columns, (i) => Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                color: Colors.pink.withOpacity(0.1),
              ),
            )),
          ),
        ),
        Text('Columns: ${ds.grid.columns} | Gutter: ${ds.grid.gutter}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
        const SizedBox(height: 24),
        const Text('Border Radius', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildRadiusSample('Base', baseRadius, ds.borderRadius.base),
            const SizedBox(width: 32),
            _buildRadiusSample('Large', largeRadius, ds.borderRadius.lg),
          ],
        ),
      ],
    );
  }

  Widget _buildRadiusSample(String label, double radius, String value) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            border: Border.all(color: Colors.blue, width: 2),
            borderRadius: BorderRadius.circular(radius),
          ),
          child: const Center(child: Icon(Icons.rounded_corner, color: Colors.blue, size: 20)),
        ),
        const SizedBox(height: 8),
        Text('$label: $value', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildComponentsDetailed(models.DesignSystem ds) {
    final hasComponents = ds.components.buttons.isNotEmpty || 
                         ds.components.inputs.isNotEmpty || 
                         ds.components.cards.isNotEmpty ||
                         ds.components.navigation.isNotEmpty ||
                         ds.components.avatars.isNotEmpty;

    if (!hasComponents) return _buildPlaceholder('Component Library');

    final baseRadius = _parsePx(ds.borderRadius.base);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildComponentCategory('Buttons', ds.components.buttons, baseRadius),
        _buildComponentCategory('Text Fields / Inputs', ds.components.inputs, baseRadius),
        _buildComponentCategory('Cards', ds.components.cards, baseRadius),
        _buildComponentCategory('Navigation Components', ds.components.navigation, baseRadius),
        _buildComponentCategory('Avatars', ds.components.avatars, 100), // Avatars usually circle
        const SizedBox(height: 16),
        const Text('Icon Sizes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: ds.icons.sizes.entries.map((e) {
            final size = _parsePx(e.value);
            return Column(
              children: [
                Icon(Icons.star, size: size),
                Text('${e.key} (${e.value})', style: const TextStyle(fontSize: 8)),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildComponentCategory(String name, Map<String, dynamic> tokens, double radius) {
    if (tokens.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.blueGrey)),
          const SizedBox(height: 8),
          ...tokens.entries.map((e) {
            final desc = e.value is Map ? e.value['description']?.toString() ?? '' : '';
            return Container(
              margin: const EdgeInsets.only(bottom: 4),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white, 
                border: Border.all(color: Colors.grey.shade200), 
                borderRadius: BorderRadius.circular(radius)
              ),
              child: Row(
                children: [
                  Text(e.key, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                  if (desc.isNotEmpty) ...[
                    const Text(' — ', style: TextStyle(color: Colors.grey)),
                    Expanded(child: Text(desc, style: const TextStyle(fontSize: 10, color: Colors.grey))),
                  ],
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildAdvancedFull(models.DesignSystem ds) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Gradients: ${ds.gradients.values.length} defined'),
        Text('Roles: ${ds.roles.values.length} defined'),
        Text('Semantic Tokens: ${ds.semanticTokens.color.length} mapped'),
        Text('Motion: ${ds.motionTokens.duration.length} durations'),
      ],
    );
  }

  Widget _buildPlaceholder(String section) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
      child: Text('No data for $section. Add tokens in the dashboard.', style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
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
