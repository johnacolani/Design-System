// ServiceFlow-style PDF matching assets/docs/serviceflow-design-system.html layout:
// cream page, hero, section titles with accent underline, cards, swatch grids, tables.

import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/design_system.dart' as models;
import '../models/design_system_wrapper.dart';

PdfColor _hex(String hex) {
  try {
    var h = hex.replaceAll('#', '').trim();
    if (h.length == 6) h = 'FF$h';
    return PdfColor.fromInt(int.parse(h, radix: 16));
  } catch (_) {
    return PdfColors.grey800;
  }
}

PdfColor get _pageBg => PdfColor.fromInt(0xFFF5F2EB);
PdfColor get _pageFg => PdfColor.fromInt(0xFF1A1917);
PdfColor get _textSecondary => PdfColor.fromInt(0xFF5C5A56);
PdfColor get _card => PdfColor.fromInt(0xFFFFFCF7);
PdfColor get _divider => PdfColor.fromInt(0xFFE8E4DC);

PdfColor _accentFromDs(models.DesignSystem ds) {
  final p = ds.colors.primary;
  String? hex;
  if (p['primary'] is Map && (p['primary'] as Map)['value'] != null) {
    hex = (p['primary'] as Map)['value']?.toString();
  } else if (p.isNotEmpty) {
    final first = p.values.first;
    if (first is Map && first['value'] != null) hex = first['value']?.toString();
  }
  if (hex != null && hex.isNotEmpty) return _hex(hex);
  return PdfColor.fromInt(0xFF6FA8A1);
}

/// Public entry for [compute] / chunked export from preview.
Future<Uint8List> generateServiceflowPdfBytesFromJson(Map<String, dynamic> json) async {
  final ds = DesignSystemWrapper.fromJson(json).designSystem;
  final pdf = _buildServiceflowPdf(ds);
  return pdf.save();
}

Future<Uint8List> generateServiceflowPdfBytesFromJsonChunked(Map<String, dynamic> json) async {
  final ds = DesignSystemWrapper.fromJson(json).designSystem;
  final pdf = await _buildServiceflowPdfChunked(ds);
  return pdf.save();
}

pw.Document _buildServiceflowPdf(models.DesignSystem ds) {
  final pdf = pw.Document();
  final accent = _accentFromDs(ds);
  final titleStyle = pw.TextStyle(fontSize: 26, fontWeight: pw.FontWeight.bold, color: _pageFg);
  final h2Style = pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: _pageFg);
  final leadStyle = pw.TextStyle(fontSize: 11, color: _textSecondary);

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(28),
      pageTheme: pw.PageTheme(
        buildBackground: (ctx) => pw.FullPage(ignoreMargins: true, child: pw.Container(color: _pageBg)),
      ),
      build: (ctx) => [
        _sfHero(ds, titleStyle, leadStyle, accent),
        pw.SizedBox(height: 28),
        _sfSectionTitle('Color', accent, h2Style, leadStyle, 'Token swatches from your palettes.'),
        pw.SizedBox(height: 10),
        _sfCard(_sfColorsContent(ds, accent)),
        pw.SizedBox(height: 28),
        _sfSectionTitle('Typography', accent, h2Style, leadStyle, ds.typography.fontFamily.primary),
        pw.SizedBox(height: 10),
        _sfCard(_sfTypographyContent(ds)),
        pw.SizedBox(height: 28),
        _sfSectionTitle('Layout & spacing', accent, h2Style, leadStyle, '${ds.grid.columns} columns · ${ds.grid.gutter} gutter'),
        pw.SizedBox(height: 10),
        _sfCard(_sfSpacingTable(ds)),
      ],
    ),
  );

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(28),
      pageTheme: pw.PageTheme(
        buildBackground: (ctx) => pw.FullPage(ignoreMargins: true, child: pw.Container(color: _pageBg)),
      ),
      build: (ctx) => [
        _sfSectionTitle('Border radius', accent, h2Style, leadStyle, null),
        pw.SizedBox(height: 10),
        _sfCard(_sfRadiusTable(ds)),
        pw.SizedBox(height: 24),
        _sfSectionTitle('Icons & elevation', accent, h2Style, leadStyle, null),
        pw.SizedBox(height: 10),
        _sfCard(_sfIconsAndShadows(ds)),
        pw.SizedBox(height: 24),
        _sfSectionTitle('Motion', accent, h2Style, leadStyle, null),
        pw.SizedBox(height: 10),
        _sfCard(_sfMotionTable(ds)),
        pw.SizedBox(height: 24),
        _sfSectionTitle('Gradients', accent, h2Style, leadStyle, null),
        pw.SizedBox(height: 10),
        _sfCard(_sfGradientsText(ds)),
      ],
    ),
  );

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(28),
      pageTheme: pw.PageTheme(
        buildBackground: (ctx) => pw.FullPage(ignoreMargins: true, child: pw.Container(color: _pageBg)),
      ),
      build: (ctx) => [
        _sfSectionTitle('Roles', accent, h2Style, leadStyle, 'Role chrome colors'),
        pw.SizedBox(height: 10),
        _sfCard(_sfRoles(ds)),
        pw.SizedBox(height: 24),
        _sfSectionTitle('Semantic tokens', accent, h2Style, leadStyle, null),
        pw.SizedBox(height: 10),
        _sfCard(_sfSemantic(ds)),
        pw.SizedBox(height: 24),
        _sfSectionTitle('Components', accent, h2Style, leadStyle, 'Library entries'),
        pw.SizedBox(height: 10),
        _sfCard(_sfComponents(ds)),
        pw.SizedBox(height: 24),
        _sfSectionTitle('Version history', accent, h2Style, leadStyle, null),
        pw.SizedBox(height: 10),
        _sfCard(_sfVersionHistory(ds)),
      ],
    ),
  );

  return pdf;
}

Future<pw.Document> _buildServiceflowPdfChunked(models.DesignSystem ds) async {
  await Future.delayed(Duration.zero);
  return _buildServiceflowPdf(ds);
}

pw.Widget _sfHero(
  models.DesignSystem ds,
  pw.TextStyle titleStyle,
  pw.TextStyle leadStyle,
  PdfColor accent,
) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(ds.name, style: titleStyle),
      pw.SizedBox(height: 8),
      if (ds.description.isNotEmpty)
        pw.Text(ds.description, style: leadStyle),
      pw.SizedBox(height: 6),
      pw.Text('Version ${ds.version}', style: pw.TextStyle(fontSize: 10, color: _textSecondary)),
      pw.SizedBox(height: 4),
      pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: pw.BoxDecoration(
          color: PdfColor(accent.red, accent.green, accent.blue, 0.22),
          borderRadius: pw.BorderRadius.circular(4),
        ),
        child: pw.Text(
          ds.name.replaceAll(' ', '_').toLowerCase(),
          style: pw.TextStyle(fontSize: 9, font: pw.Font.courier()),
        ),
      ),
      pw.Container(
        margin: const pw.EdgeInsets.only(top: 16),
        padding: const pw.EdgeInsets.only(bottom: 16),
        decoration: pw.BoxDecoration(
          border: pw.Border(bottom: pw.BorderSide(color: PdfColor(0.1, 0.1, 0.1, 0.08), width: 1)),
        ),
      ),
    ],
  );
}

pw.Widget _sfSectionTitle(
  String title,
  PdfColor accent,
  pw.TextStyle h2,
  pw.TextStyle lead,
  String? leadText,
) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(title, style: h2),
      pw.Container(height: 2, width: double.infinity, color: accent),
      if (leadText != null) ...[
        pw.SizedBox(height: 8),
        pw.Text(leadText, style: lead),
      ],
    ],
  );
}

pw.Widget _sfCard(pw.Widget child) {
  return pw.Container(
    padding: const pw.EdgeInsets.all(16),
    decoration: pw.BoxDecoration(
      color: _card,
      borderRadius: pw.BorderRadius.circular(12),
      border: pw.Border.all(color: PdfColor(0.1, 0.1, 0.1, 0.08)),
      boxShadow: [
        pw.BoxShadow(color: PdfColor(0.1, 0.04, 0.04, 0.06), blurRadius: 8, offset: const PdfPoint(0, 2)),
      ],
    ),
    child: child,
  );
}

pw.Widget _sfColorsContent(models.DesignSystem ds, PdfColor accent) {
  void addPalette(String title, Map<String, dynamic>? m, List<pw.Widget> out) {
    if (m == null || m.isEmpty) return;
    out.add(pw.Text(title, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)));
    out.add(pw.SizedBox(height: 8));
    out.add(
      pw.Wrap(
        spacing: 10,
        runSpacing: 10,
        children: m.entries.map((e) {
          final val = e.value is Map ? (e.value as Map)['value']?.toString() ?? '' : e.value.toString();
          final c = _hex(val);
          return pw.Container(
            width: 120,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(
                  height: 56,
                  decoration: pw.BoxDecoration(
                    color: c,
                    borderRadius: pw.BorderRadius.circular(8),
                    border: pw.Border.all(width: 0.5, color: PdfColors.grey400),
                  ),
                ),
                pw.SizedBox(height: 6),
                pw.Text(e.key, style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700)),
                pw.Text(val.toUpperCase(), style: pw.TextStyle(fontSize: 8, font: pw.Font.courier())),
              ],
            ),
          );
        }).toList(),
      ),
    );
    out.add(pw.SizedBox(height: 14));
  }

  final children = <pw.Widget>[];
  final c = ds.colors;
  addPalette('Primary', c.primary, children);
  addPalette('Semantic', c.semantic, children);
  addPalette('Blue', c.blue, children);
  addPalette('Green', c.green, children);
  addPalette('Orange', c.orange, children);
  addPalette('Purple', c.purple, children);
  addPalette('Red', c.red, children);
  addPalette('Grey', c.grey, children);
  if (children.isEmpty) return pw.Text('No colors defined.', style: pw.TextStyle(fontSize: 10, color: _textSecondary));
  return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: children);
}

pw.Widget _sfTypographyContent(models.DesignSystem ds) {
  final t = ds.typography;
  final lines = <pw.Widget>[
    pw.Text('Primary: ${t.fontFamily.primary}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
    if (t.fontFamily.fallback.isNotEmpty)
      pw.Text('Fallback: ${t.fontFamily.fallback}', style: pw.TextStyle(fontSize: 10, color: _textSecondary)),
  ];
  for (final e in t.fontSizes.entries) {
    lines.add(pw.Padding(
      padding: const pw.EdgeInsets.only(top: 6),
      child: pw.Text('${e.key}: ${e.value.value} (line-height ${e.value.lineHeight})', style: const pw.TextStyle(fontSize: 9)),
    ));
  }
  if (lines.length <= 2) lines.add(pw.Text('Add font sizes in Typography.', style: pw.TextStyle(fontSize: 9, color: _textSecondary)));
  return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: lines);
}

pw.Widget _sfSpacingTable(models.DesignSystem ds) {
  final rows = ds.spacing.values.entries.map((e) => [e.key, e.value]).toList();
  return _sfTokenTable(['Token', 'Value'], rows);
}

pw.Widget _sfRadiusTable(models.DesignSystem ds) {
  final r = ds.borderRadius;
  final data = [
    ['none', r.none],
    ['sm', r.sm],
    ['base', r.base],
    ['md', r.md],
    ['lg', r.lg],
    ['xl', r.xl],
    ['full', r.full],
  ];
  return _sfTokenTable(['Token', 'Value'], data);
}

pw.Widget _sfTokenTable(List<String> headers, List<List<String>> rows) {
  return pw.Table(
    border: pw.TableBorder(horizontalInside: pw.BorderSide(color: _divider)),
    columnWidths: {0: const pw.FlexColumnWidth(1.2), 1: const pw.FlexColumnWidth(2)},
    children: [
      pw.TableRow(
        children: headers
            .map((h) => pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  child: pw.Text(
                    h,
                    style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: _textSecondary),
                  ),
                ))
            .toList(),
      ),
      ...rows.map(
        (r) => pw.TableRow(
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              child: pw.Text(r[0], style: const pw.TextStyle(fontSize: 10)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              child: pw.Text(r[1], style: pw.TextStyle(fontSize: 9, font: pw.Font.courier())),
            ),
          ],
        ),
      ),
    ],
  );
}

pw.Widget _sfIconsAndShadows(models.DesignSystem ds) {
  final iconLines = ds.icons.sizes.entries.map((e) => pw.Text('${e.key}: ${e.value}', style: const pw.TextStyle(fontSize: 9))).toList();
  final shadowLines = ds.shadows.values.entries.map((e) => pw.Text('${e.key}: ${e.value.value}', style: const pw.TextStyle(fontSize: 9))).toList();
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text('Icon sizes', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
      pw.SizedBox(height: 6),
      if (iconLines.isEmpty) pw.Text('None', style: pw.TextStyle(fontSize: 9, color: _textSecondary)) else ...iconLines,
      pw.SizedBox(height: 12),
      pw.Text('Shadows', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
      pw.SizedBox(height: 6),
      if (shadowLines.isEmpty) pw.Text('None', style: pw.TextStyle(fontSize: 9, color: _textSecondary)) else ...shadowLines,
    ],
  );
}

pw.Widget _sfMotionTable(models.DesignSystem ds) {
  final rows = <List<String>>[];
  for (final e in ds.motionTokens.duration.entries) {
    rows.add([e.key, e.value]);
  }
  for (final e in ds.motionTokens.easing.entries) {
    rows.add([e.key, e.value]);
  }
  if (rows.isEmpty) return pw.Text('No motion tokens.', style: pw.TextStyle(fontSize: 9, color: _textSecondary));
  return _sfTokenTable(['Token', 'Value'], rows);
}

pw.Widget _sfGradientsText(models.DesignSystem ds) {
  if (ds.gradients.values.isEmpty) {
    return pw.Text('No gradients.', style: pw.TextStyle(fontSize: 9, color: _textSecondary));
  }
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: ds.gradients.values.entries
        .map((e) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 6),
              child: pw.Text('${e.key}: ${e.value.colors.join(' → ')} (${e.value.direction})', style: const pw.TextStyle(fontSize: 9)),
            ))
        .toList(),
  );
}

pw.Widget _sfRoles(models.DesignSystem ds) {
  if (ds.roles.values.isEmpty) return pw.Text('No roles.', style: pw.TextStyle(fontSize: 9, color: _textSecondary));
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: ds.roles.values.entries
        .map((e) => pw.Text('${e.key}: primary ${e.value.primaryColor}, accent ${e.value.accentColor}, bg ${e.value.background}', style: const pw.TextStyle(fontSize: 9)))
        .toList(),
  );
}

pw.Widget _sfSemantic(models.DesignSystem ds) {
  final st = ds.semanticTokens;
  final lines = <pw.Widget>[];
  void add(String title, Map<String, dynamic> m) {
    if (m.isEmpty) return;
    lines.add(pw.Text(title, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)));
    for (final e in m.entries) {
      final v = e.value;
      final ref = v is Map ? v['baseTokenReference'] ?? v['reference'] ?? v.toString() : v.toString();
      lines.add(pw.Text('  ${e.key} → $ref', style: const pw.TextStyle(fontSize: 8)));
    }
    lines.add(pw.SizedBox(height: 6));
  }

  add('Color', st.color);
  add('Typography', st.typography);
  add('Spacing', st.spacing);
  add('Shadow', st.shadow);
  add('Border radius', st.borderRadius);
  if (lines.isEmpty) return pw.Text('No semantic tokens.', style: pw.TextStyle(fontSize: 9, color: _textSecondary));
  return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: lines);
}

pw.Widget _sfComponents(models.DesignSystem ds) {
  final comp = ds.components;
  final cats = [
    ('Buttons', comp.buttons),
    ('Cards', comp.cards),
    ('Inputs', comp.inputs),
    ('Navigation', comp.navigation),
  ];
  final lines = <pw.Widget>[];
  for (final cat in cats) {
    if (cat.$2.isEmpty) continue;
    lines.add(pw.Text(cat.$1, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)));
    for (final e in cat.$2.entries) {
      lines.add(pw.Text('  ${e.key}', style: const pw.TextStyle(fontSize: 8)));
    }
  }
  if (lines.isEmpty) return pw.Text('No components.', style: pw.TextStyle(fontSize: 9, color: _textSecondary));
  return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: lines);
}

pw.Widget _sfVersionHistory(models.DesignSystem ds) {
  final h = ds.versionHistory ?? [];
  if (h.isEmpty) return pw.Text('No version history.', style: pw.TextStyle(fontSize: 9, color: _textSecondary));
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: h.take(12).map((v) {
      return pw.Container(
        margin: const pw.EdgeInsets.only(bottom: 6),
        padding: const pw.EdgeInsets.all(6),
        decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey400), borderRadius: pw.BorderRadius.circular(4)),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('${v.version} — ${v.date}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8)),
            if (v.changes.isNotEmpty) pw.Text(v.changes.join('; '), style: const pw.TextStyle(fontSize: 7)),
          ],
        ),
      );
    }).toList(),
  );
}
