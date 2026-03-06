// PDF generation for design system. Top-level entry so it can run in a background isolate
// and avoid freezing the UI (especially on web).

import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/design_system.dart' as models;
import '../models/design_system_wrapper.dart';

/// Top-level entry for [compute]. Builds the full design system PDF and returns bytes.
/// Use on mobile/desktop where compute runs in a separate isolate.
Future<Uint8List> generatePdfBytesFromJson(Map<String, dynamic> json) async {
  final ds = DesignSystemWrapper.fromJson(json).designSystem;
  final pdf = _buildDocument(ds);
  return pdf.save();
}

/// Async builder that yields to the event loop between pages and sections.
/// Use on web where compute() does not use a separate thread, to avoid "Page Unresponsive".
Future<Uint8List> generatePdfBytesFromJsonChunked(Map<String, dynamic> json) async {
  final ds = DesignSystemWrapper.fromJson(json).designSystem;
  final pdf = await _buildDocumentChunked(ds);
  return pdf.save();
}

Future<pw.Document> _buildDocumentChunked(models.DesignSystem ds) async {
  final pdf = pw.Document();
  final titleStyle = pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold);
  final headerStyle = pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900);

  final page1 = await _buildPage1WidgetsChunked(ds, titleStyle, headerStyle);
  pdf.addPage(pw.MultiPage(pageFormat: PdfPageFormat.a4, margin: const pw.EdgeInsets.all(40), build: (pw.Context context) => page1));
  await Future.delayed(Duration.zero);

  final page2 = await _buildPage2WidgetsChunked(ds, headerStyle);
  pdf.addPage(pw.MultiPage(pageFormat: PdfPageFormat.a4, margin: const pw.EdgeInsets.all(40), build: (pw.Context context) => page2));
  await Future.delayed(Duration.zero);

  final page3 = await _buildPage3WidgetsChunked(ds, headerStyle);
  pdf.addPage(pw.MultiPage(pageFormat: PdfPageFormat.a4, margin: const pw.EdgeInsets.all(40), build: (pw.Context context) => page3));
  await Future.delayed(Duration.zero);

  final page4 = await _buildPage4WidgetsChunked(ds, headerStyle);
  pdf.addPage(pw.MultiPage(pageFormat: PdfPageFormat.a4, margin: const pw.EdgeInsets.all(40), build: (pw.Context context) => page4));
  await Future.delayed(Duration.zero);

  final page5 = await _buildPage5WidgetsChunked(ds, headerStyle);
  pdf.addPage(pw.MultiPage(pageFormat: PdfPageFormat.a4, margin: const pw.EdgeInsets.all(40), build: (pw.Context context) => page5));

  return pdf;
}

Future<List<pw.Widget>> _buildPage1WidgetsChunked(models.DesignSystem ds, pw.TextStyle titleStyle, pw.TextStyle headerStyle) async {
  final list = <pw.Widget>[
    pw.Header(level: 0, child: pw.Text(ds.name, style: titleStyle)),
    if (ds.description.isNotEmpty) pw.Padding(padding: const pw.EdgeInsets.only(bottom: 12), child: pw.Text(ds.description, style: pw.TextStyle(fontSize: 11, color: PdfColors.grey700))),
    pw.Text('Version ${ds.version}', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
    pw.SizedBox(height: 20),
    pw.Text('1. Colors', style: headerStyle),
    pw.SizedBox(height: 10),
  ];
  await Future.delayed(Duration.zero);
  list.add(_buildPdfColorsFull(ds));
  return list;
}

Future<List<pw.Widget>> _buildPage2WidgetsChunked(models.DesignSystem ds, pw.TextStyle headerStyle) async {
  final list = <pw.Widget>[
    pw.Text('2. Typography', style: headerStyle),
    pw.SizedBox(height: 10),
  ];
  await Future.delayed(Duration.zero);
  list.add(_buildPdfTypographyFull(ds));
  list.add(pw.SizedBox(height: 24));
  list.add(pw.Text('3. Spacing & Grid', style: headerStyle));
  list.add(pw.SizedBox(height: 10));
  await Future.delayed(Duration.zero);
  list.add(_buildPdfSpacingDetailed(ds));
  list.add(pw.SizedBox(height: 10));
  list.add(_buildPdfGridDetailed(ds));
  return list;
}

Future<List<pw.Widget>> _buildPage3WidgetsChunked(models.DesignSystem ds, pw.TextStyle headerStyle) async {
  final list = <pw.Widget>[
    pw.Text('4. Border Radius', style: headerStyle),
    pw.SizedBox(height: 8),
  ];
  await Future.delayed(Duration.zero);
  list.add(_buildPdfBorderRadiusFull(ds));
  list.add(pw.SizedBox(height: 20));
  list.add(pw.Text('5. Shadows', style: headerStyle));
  list.add(pw.SizedBox(height: 8));
  list.add(_buildPdfShadowsDetailed(ds));
  list.add(pw.SizedBox(height: 20));
  list.add(pw.Text('6. Effects', style: headerStyle));
  list.add(pw.SizedBox(height: 8));
  list.add(_buildPdfEffectsDetailed(ds));
  return list;
}

Future<List<pw.Widget>> _buildPage4WidgetsChunked(models.DesignSystem ds, pw.TextStyle headerStyle) async {
  final list = <pw.Widget>[
    pw.Text('7. Component Library', style: headerStyle),
    pw.SizedBox(height: 10),
  ];
  await Future.delayed(Duration.zero);
  list.add(_buildPdfComponentsFull(ds));
  list.add(pw.SizedBox(height: 24));
  list.add(pw.Text('8. Iconography', style: headerStyle));
  list.add(pw.SizedBox(height: 10));
  list.add(_buildPdfIconsDetailed(ds));
  return list;
}

Future<List<pw.Widget>> _buildPage5WidgetsChunked(models.DesignSystem ds, pw.TextStyle headerStyle) async {
  final list = <pw.Widget>[
    pw.Text('9. Gradients', style: headerStyle),
    pw.SizedBox(height: 8),
  ];
  await Future.delayed(Duration.zero);
  list.add(_buildPdfGradientsDetailed(ds));
  list.add(pw.SizedBox(height: 20));
  list.add(pw.Text('10. Roles', style: headerStyle));
  list.add(pw.SizedBox(height: 8));
  list.add(_buildPdfRolesDetailed(ds));
  list.add(pw.SizedBox(height: 20));
  list.add(pw.Text('11. Semantic Tokens', style: headerStyle));
  list.add(pw.SizedBox(height: 8));
  list.add(_buildPdfSemanticTokensFull(ds));
  list.add(pw.SizedBox(height: 20));
  list.add(pw.Text('12. Motion Tokens', style: headerStyle));
  list.add(pw.SizedBox(height: 8));
  list.add(_buildPdfMotionTokensFull(ds));
  list.add(pw.SizedBox(height: 20));
  list.add(pw.Text('13. Version History', style: headerStyle));
  list.add(pw.SizedBox(height: 8));
  list.add(_buildPdfVersionHistory(ds));
  return list;
}

pw.Document _buildDocument(models.DesignSystem ds) {
  final pdf = pw.Document();
  final titleStyle = pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold);
  final headerStyle = pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900);

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

double _parsePx(String s) => double.tryParse(s.replaceAll('px', '')) ?? 14.0;

PdfColor _parsePdfColor(String hex) {
  try {
    final h = hex.toString().replaceAll('#', '').trim();
    final normalized = h.length == 6 ? 'FF$h' : h;
    return PdfColor.fromInt(int.parse(normalized, radix: 16));
  } catch (_) {
    return PdfColors.black;
  }
}

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
        pw.Container(width: 40, height: 40, decoration: pw.BoxDecoration(color: _parsePdfColor(val.toString()), border: pw.Border.all(width: 0.5))),
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
  return pw.Wrap(spacing: 15, children: ds.icons.sizes.entries.map((e) => pw.Text('${e.key}: ${e.value}', style: pw.TextStyle(fontSize: 10))).toList());
}

pw.Widget _buildPdfGradientsDetailed(models.DesignSystem ds) {
  return pw.Column(children: ds.gradients.values.entries.map((e) => pw.Text('${e.key}: ${e.value.colors.join(' -> ')}', style: pw.TextStyle(fontSize: 10))).toList());
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
