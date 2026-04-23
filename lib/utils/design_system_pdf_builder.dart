// PDF generation for design system. Top-level entry so it can run in a background isolate
// and avoid freezing the UI (especially on web).

import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/design_system.dart' as models;
import '../models/design_system_wrapper.dart';

final PdfColor _pdfPageFg = PdfColor.fromInt(0xFF1A1917);
final PdfColor _pdfTextSecondary = PdfColor.fromInt(0xFF5C5A56);
final PdfColor _pdfAccent = PdfColor.fromInt(0xFF6FA8A1);
final PdfColor _pdfCardBorder = PdfColor.fromInt(0xFFE8E4DC);
final PdfColor _pdfAccentSoft = PdfColor.fromInt(0xFFA5D4CC);

pw.TextStyle _pdfHeaderStyle() => pw.TextStyle(
  fontSize: 18,
  fontWeight: pw.FontWeight.bold,
  color: _pdfAccent,
);

pw.TextStyle _pdfSubHeaderStyle() => pw.TextStyle(
  fontWeight: pw.FontWeight.bold,
  fontSize: 12,
  color: _pdfPageFg,
);

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
  await Future.delayed(Duration.zero);
  return pdf.save();
}

Future<pw.Document> _buildDocumentChunked(models.DesignSystem ds) async {
  final pdf = pw.Document();
  final titleStyle = pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: _pdfPageFg);
  final headerStyle = _pdfHeaderStyle();
  const safeMaxPages = 99999;

  final allSwatches = <(String groupTitle, MapEntry<String, dynamic>)>[];
  for (final g in _getPdfColorGroups(ds)) {
    for (final e in g.$2.entries) {
      allSwatches.add((g.$1, e));
    }
  }
  final totalColorPages = (allSwatches.length / _swatchesPerPage).ceil();
  final firstColorChunk = allSwatches.isEmpty
      ? <(String groupTitle, MapEntry<String, dynamic>)>[]
      : allSwatches.sublist(0, allSwatches.length < _swatchesPerPage ? allSwatches.length : _swatchesPerPage);

  final introPage = await _buildColorsIntroChunked(ds, titleStyle, headerStyle, firstColorChunk, totalColorPages);
  pdf.addPage(pw.MultiPage(pageFormat: PdfPageFormat.a4, margin: const pw.EdgeInsets.all(40), maxPages: 5, build: (pw.Context context) => introPage));
  await Future.delayed(const Duration(milliseconds: 10));

  for (var i = _swatchesPerPage; i < allSwatches.length; i += _swatchesPerPage) {
    final end = (i + _swatchesPerPage < allSwatches.length) ? i + _swatchesPerPage : allSwatches.length;
    final chunk = allSwatches.sublist(i, end);
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) => _buildPdfColorGridPageFlat(
          chunk,
          headerStyle,
          pageIndex: i ~/ _swatchesPerPage,
          totalPages: totalColorPages,
        ),
      ),
    );
    await Future.delayed(const Duration(milliseconds: 3));
  }

  final page2 = await _buildPage2TypographyChunked(ds, headerStyle);
  pdf.addPage(pw.MultiPage(pageFormat: PdfPageFormat.a4, margin: const pw.EdgeInsets.all(40), maxPages: safeMaxPages, build: (pw.Context context) => page2));
  await Future.delayed(const Duration(milliseconds: 10));

  final page3 = await _buildPage3LayoutAndShapeChunked(ds, headerStyle);
  pdf.addPage(pw.MultiPage(pageFormat: PdfPageFormat.a4, margin: const pw.EdgeInsets.all(40), maxPages: safeMaxPages, build: (pw.Context context) => page3));
  await Future.delayed(const Duration(milliseconds: 10));

  final page4 = await _buildPage4ShadowsChunked(ds, headerStyle);
  pdf.addPage(pw.MultiPage(pageFormat: PdfPageFormat.a4, margin: const pw.EdgeInsets.all(40), maxPages: safeMaxPages, build: (pw.Context context) => page4));
  await Future.delayed(const Duration(milliseconds: 10));

  final page5 = await _buildPage5VisualEffectsChunked(ds, headerStyle);
  pdf.addPage(pw.MultiPage(pageFormat: PdfPageFormat.a4, margin: const pw.EdgeInsets.all(40), maxPages: safeMaxPages, build: (pw.Context context) => page5));
  await Future.delayed(const Duration(milliseconds: 10));

  final page6 = await _buildPage6ComponentsChunked(ds, headerStyle);
  pdf.addPage(pw.MultiPage(pageFormat: PdfPageFormat.a4, margin: const pw.EdgeInsets.all(40), maxPages: safeMaxPages, build: (pw.Context context) => page6));
  await Future.delayed(const Duration(milliseconds: 10));

  final page7 = await _buildPage7AdvancedTokensChunked(ds, headerStyle);
  pdf.addPage(pw.MultiPage(pageFormat: PdfPageFormat.a4, margin: const pw.EdgeInsets.all(40), maxPages: safeMaxPages, build: (pw.Context context) => page7));
  await Future.delayed(const Duration(milliseconds: 10));

  return pdf;
}

Future<List<pw.Widget>> _buildColorsIntroChunked(
  models.DesignSystem ds,
  pw.TextStyle titleStyle,
  pw.TextStyle headerStyle,
  List<(String groupTitle, MapEntry<String, dynamic>)> firstColorChunk,
  int totalColorPages,
) async {
  await Future.delayed(const Duration(milliseconds: 5));
  final widgets = <pw.Widget>[
    pw.Header(level: 0, child: pw.Text(ds.name, style: titleStyle)),
    if (ds.description.isNotEmpty) pw.Padding(padding: const pw.EdgeInsets.only(bottom: 12), child: pw.Text(ds.description, style: pw.TextStyle(fontSize: 11, color: _pdfTextSecondary))),
    pw.Text('Version ${ds.version}', style: pw.TextStyle(fontSize: 10, color: _pdfTextSecondary)),
    pw.SizedBox(height: 20),
  ];
  if (firstColorChunk.isEmpty) {
    widgets.addAll([
      pw.Text('1. Core Colors', style: headerStyle),
      pw.SizedBox(height: 10),
      pw.Text('No color tokens found.', style: pw.TextStyle(fontSize: 10, color: _pdfTextSecondary)),
    ]);
  } else {
    widgets.add(
      _buildPdfColorGridPageFlat(
        firstColorChunk,
        headerStyle,
        pageIndex: 0,
        totalPages: totalColorPages,
      ),
    );
  }
  return widgets;
}

// Order matches Design System Preview: 1 Core Colors, 2 Typography, 3 Layout & Shape, 4 Shadows, 5 Visual Effects, 6 Components & Assets, 7 Advanced Tokens.

Future<List<pw.Widget>> _buildPage2TypographyChunked(models.DesignSystem ds, pw.TextStyle headerStyle) async {
  await Future.delayed(Duration.zero);
  return [
    pw.Text('2. Typography', style: headerStyle),
    pw.SizedBox(height: 10),
    _buildPdfTypographyFull(ds),
  ];
}

Future<List<pw.Widget>> _buildPage3LayoutAndShapeChunked(models.DesignSystem ds, pw.TextStyle headerStyle) async {
  await Future.delayed(Duration.zero);
  return [
    pw.Text('3. Layout & Shape', style: headerStyle),
    pw.SizedBox(height: 10),
    pw.Text('Spacing & Grid', style: _pdfSubHeaderStyle()),
    pw.SizedBox(height: 6),
    _buildPdfSpacingDetailed(ds),
    pw.SizedBox(height: 10),
    _buildPdfGridDetailed(ds),
    pw.SizedBox(height: 20),
    pw.Text('Border Radius', style: _pdfSubHeaderStyle()),
    pw.SizedBox(height: 6),
    _buildPdfBorderRadiusFull(ds),
  ];
}

Future<List<pw.Widget>> _buildPage4ShadowsChunked(models.DesignSystem ds, pw.TextStyle headerStyle) async {
  await Future.delayed(Duration.zero);
  return [
    pw.Text('4. Shadows', style: headerStyle),
    pw.SizedBox(height: 10),
    _buildPdfShadowsDetailed(ds),
  ];
}

Future<List<pw.Widget>> _buildPage5VisualEffectsChunked(models.DesignSystem ds, pw.TextStyle headerStyle) async {
  await Future.delayed(Duration.zero);
  return [
    pw.Text('5. Visual Effects', style: headerStyle),
    pw.SizedBox(height: 10),
    _buildPdfEffectsDetailed(ds),
  ];
}

Future<List<pw.Widget>> _buildPage6ComponentsChunked(models.DesignSystem ds, pw.TextStyle headerStyle) async {
  await Future.delayed(Duration.zero);
  return [
    pw.Text('6. Components & Assets', style: headerStyle),
    pw.SizedBox(height: 10),
    pw.Text('Component Library', style: _pdfSubHeaderStyle()),
    pw.SizedBox(height: 6),
    _buildPdfComponentsFull(ds),
    pw.SizedBox(height: 20),
    pw.Text('Iconography', style: _pdfSubHeaderStyle()),
    pw.SizedBox(height: 6),
    _buildPdfIconsDetailed(ds),
  ];
}

Future<List<pw.Widget>> _buildPage7AdvancedTokensChunked(models.DesignSystem ds, pw.TextStyle headerStyle) async {
  await Future.delayed(Duration.zero);
  return [
    pw.Text('7. Advanced Tokens', style: headerStyle),
    pw.SizedBox(height: 10),
    pw.Text('Gradients', style: _pdfSubHeaderStyle()),
    pw.SizedBox(height: 6),
    _buildPdfGradientsDetailed(ds),
    pw.SizedBox(height: 16),
    pw.Text('Roles', style: _pdfSubHeaderStyle()),
    pw.SizedBox(height: 6),
    _buildPdfRolesDetailed(ds),
    pw.SizedBox(height: 16),
    pw.Text('Semantic Tokens', style: _pdfSubHeaderStyle()),
    pw.SizedBox(height: 6),
    _buildPdfSemanticTokensFull(ds),
    pw.SizedBox(height: 16),
    pw.Text('Motion Tokens', style: _pdfSubHeaderStyle()),
    pw.SizedBox(height: 6),
    _buildPdfMotionTokensFull(ds),
    pw.SizedBox(height: 16),
    pw.Text('Version History', style: _pdfSubHeaderStyle()),
    pw.SizedBox(height: 6),
    _buildPdfVersionHistory(ds),
  ];
}

pw.Document _buildDocument(models.DesignSystem ds) {
  final pdf = pw.Document();
  final titleStyle = pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: _pdfPageFg);
  final headerStyle = _pdfHeaderStyle();
  const safeMaxPages = 99999;

  final allSwatches = <(String groupTitle, MapEntry<String, dynamic>)>[];
  for (final g in _getPdfColorGroups(ds)) {
    for (final e in g.$2.entries) {
      allSwatches.add((g.$1, e));
    }
  }
  final totalColorPages = (allSwatches.length / _swatchesPerPage).ceil();
  final firstColorChunk = allSwatches.isEmpty
      ? <(String groupTitle, MapEntry<String, dynamic>)>[]
      : allSwatches.sublist(0, allSwatches.length < _swatchesPerPage ? allSwatches.length : _swatchesPerPage);

  pdf.addPage(pw.MultiPage(
    pageFormat: PdfPageFormat.a4,
    margin: const pw.EdgeInsets.all(40),
    maxPages: 5,
    build: (pw.Context context) => [
      pw.Header(level: 0, child: pw.Text(ds.name, style: titleStyle)),
      if (ds.description.isNotEmpty) pw.Padding(padding: const pw.EdgeInsets.only(bottom: 12), child: pw.Text(ds.description, style: pw.TextStyle(fontSize: 11, color: _pdfTextSecondary))),
      pw.Text('Version ${ds.version}', style: pw.TextStyle(fontSize: 10, color: _pdfTextSecondary)),
      pw.SizedBox(height: 20),
      if (firstColorChunk.isEmpty) ...[
        pw.Text('1. Core Colors', style: headerStyle),
        pw.SizedBox(height: 10),
        pw.Text('No color tokens found.', style: pw.TextStyle(fontSize: 10, color: _pdfTextSecondary)),
      ] else ...[
        _buildPdfColorGridPageFlat(firstColorChunk, headerStyle, pageIndex: 0, totalPages: totalColorPages),
      ],
    ],
  ));
  for (var i = _swatchesPerPage; i < allSwatches.length; i += _swatchesPerPage) {
    final end = (i + _swatchesPerPage < allSwatches.length) ? i + _swatchesPerPage : allSwatches.length;
    final chunk = allSwatches.sublist(i, end);
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) => _buildPdfColorGridPageFlat(chunk, headerStyle, pageIndex: i ~/ _swatchesPerPage, totalPages: totalColorPages),
      ),
    );
  }
  pdf.addPage(pw.MultiPage(
    pageFormat: PdfPageFormat.a4,
    margin: const pw.EdgeInsets.all(40),
    maxPages: safeMaxPages,
    build: (pw.Context context) => [
      pw.Text('2. Typography', style: headerStyle),
      pw.SizedBox(height: 10),
      _buildPdfTypographyFull(ds),
    ],
  ));
  pdf.addPage(pw.MultiPage(
    pageFormat: PdfPageFormat.a4,
    margin: const pw.EdgeInsets.all(40),
    maxPages: safeMaxPages,
    build: (pw.Context context) => [
      pw.Text('3. Layout & Shape', style: headerStyle),
      pw.SizedBox(height: 10),
      pw.Text('Spacing & Grid', style: _pdfSubHeaderStyle()),
      pw.SizedBox(height: 6),
      _buildPdfSpacingDetailed(ds),
      pw.SizedBox(height: 10),
      _buildPdfGridDetailed(ds),
      pw.SizedBox(height: 20),
      pw.Text('Border Radius', style: _pdfSubHeaderStyle()),
      pw.SizedBox(height: 6),
      _buildPdfBorderRadiusFull(ds),
    ],
  ));
  pdf.addPage(pw.MultiPage(
    pageFormat: PdfPageFormat.a4,
    margin: const pw.EdgeInsets.all(40),
    maxPages: safeMaxPages,
    build: (pw.Context context) => [
      pw.Text('4. Shadows', style: headerStyle),
      pw.SizedBox(height: 10),
      _buildPdfShadowsDetailed(ds),
    ],
  ));
  pdf.addPage(pw.MultiPage(
    pageFormat: PdfPageFormat.a4,
    margin: const pw.EdgeInsets.all(40),
    maxPages: safeMaxPages,
    build: (pw.Context context) => [
      pw.Text('5. Visual Effects', style: headerStyle),
      pw.SizedBox(height: 10),
      _buildPdfEffectsDetailed(ds),
    ],
  ));
  pdf.addPage(pw.MultiPage(
    pageFormat: PdfPageFormat.a4,
    margin: const pw.EdgeInsets.all(40),
    maxPages: safeMaxPages,
    build: (pw.Context context) => [
      pw.Text('6. Components & Assets', style: headerStyle),
      pw.SizedBox(height: 10),
      pw.Text('Component Library', style: _pdfSubHeaderStyle()),
      pw.SizedBox(height: 6),
      _buildPdfComponentsFull(ds),
      pw.SizedBox(height: 20),
      pw.Text('Iconography', style: _pdfSubHeaderStyle()),
      pw.SizedBox(height: 6),
      _buildPdfIconsDetailed(ds),
    ],
  ));
  pdf.addPage(pw.MultiPage(
    pageFormat: PdfPageFormat.a4,
    margin: const pw.EdgeInsets.all(40),
    maxPages: safeMaxPages,
    build: (pw.Context context) => [
      pw.Text('7. Advanced Tokens', style: headerStyle),
      pw.SizedBox(height: 10),
      pw.Text('Gradients', style: _pdfSubHeaderStyle()),
      pw.SizedBox(height: 6),
      _buildPdfGradientsDetailed(ds),
      pw.SizedBox(height: 16),
      pw.Text('Roles', style: _pdfSubHeaderStyle()),
      pw.SizedBox(height: 6),
      _buildPdfRolesDetailed(ds),
      pw.SizedBox(height: 16),
      pw.Text('Semantic Tokens', style: _pdfSubHeaderStyle()),
      pw.SizedBox(height: 6),
      _buildPdfSemanticTokensFull(ds),
      pw.SizedBox(height: 16),
      pw.Text('Motion Tokens', style: _pdfSubHeaderStyle()),
      pw.SizedBox(height: 6),
      _buildPdfMotionTokensFull(ds),
      pw.SizedBox(height: 16),
      pw.Text('Version History', style: _pdfSubHeaderStyle()),
      pw.SizedBox(height: 6),
      _buildPdfVersionHistory(ds),
    ],
  ));
  return pdf;
}

double _parsePx(String s) => double.tryParse(s.replaceAll('px', '')) ?? 14.0;

String _pdfHex(String raw) {
  final h = raw.replaceAll('#', '').trim().toUpperCase();
  if (h.length == 6) return '#$h';
  if (h.length == 8) return '#${h.substring(2)}';
  return raw;
}

PdfColor _parsePdfColor(String hex) {
  try {
    final h = hex.toString().replaceAll('#', '').trim();
    final normalized = h.length == 6 ? 'FF$h' : h;
    return PdfColor.fromInt(int.parse(normalized, radix: 16));
  } catch (_) {
    return PdfColors.black;
  }
}

/// Same grouping as Preview: Primary, Analogous 01 Dark, Analogous 01 Light, etc.
/// Returns ordered (displayTitle, palette map) so we can render one page per group and avoid TooManyPagesException.
List<(String title, Map<String, dynamic> palette)> _getPdfColorGroups(models.DesignSystem ds) {
  final c = ds.colors;
  final List<(String name, Map<String, dynamic> entry)> primarySemantic = [];
  void addEntries(Map<String, dynamic>? m) {
    if (m == null) return;
    for (final e in m.entries) {
      primarySemantic.add((e.key, e.value is Map ? Map<String, dynamic>.from(e.value as Map) : {'value': e.value.toString()}));
    }
  }
  addEntries(c.primary);
  addEntries(c.semantic);

  String groupKey(String name) {
    final parts = name.split('_');
    final first = parts.isNotEmpty ? parts[0].toLowerCase() : '';
    final analogousNum = RegExp(r'^analogous(\d+)$').firstMatch(first);
    if (analogousNum != null && parts.length >= 2) {
      final subPart = parts.length >= 3 ? parts[2] : parts[1];
      final sub = subPart.toLowerCase().replaceAll(RegExp(r'\d+$'), '');
      return 'analogous_${analogousNum.group(1)!}_${sub.isEmpty ? subPart.toLowerCase() : sub}';
    }
    if (analogousNum != null) return 'analogous_${analogousNum.group(1)!}';
    if (first == 'analogous' && parts.length >= 3) {
      final third = parts[2].toLowerCase().replaceAll(RegExp(r'\d+$'), '');
      return 'analogous_${parts[1]}_${third.isEmpty ? parts[2].toLowerCase() : third}';
    }
    if (first == 'analogous' && parts.length >= 2) return '${first}_${parts[1]}';
    if (parts.length >= 2 && int.tryParse(parts[1]) != null) return '${first}_${parts[1]}';
    return first.isEmpty ? name.toLowerCase() : first;
  }

  final groups = <String, Map<String, dynamic>>{};
  for (final e in primarySemantic) {
    final key = groupKey(e.$1);
    groups.putIfAbsent(key, () => {})[e.$1] = e.$2;
  }
  const order = ['primary', 'analogous', 'success', 'error', 'warning', 'info', 'secondary'];
  final ordered = <String>[];
  for (final k in order) {
    if (groups.containsKey(k)) ordered.add(k);
  }
  final analogousKeys = groups.keys.where((k) => k.startsWith('analogous_')).toList()
    ..sort((a, b) => _pdfNaturalCompare(a, b));
  final primaryFirst = <String>[];
  if (groups.containsKey('primary')) primaryFirst.add('primary');
  for (final k in analogousKeys) primaryFirst.add(k);
  for (final k in ordered) {
    if (!primaryFirst.contains(k)) primaryFirst.add(k);
  }
  for (final k in groups.keys) {
    if (!primaryFirst.contains(k)) primaryFirst.add(k);
  }

  String titleFor(String key) {
    final lower = key.toLowerCase();
    final sub = RegExp(r'^analogous_(\d+)_(.+)$').firstMatch(lower);
    if (sub != null) {
      final n = int.tryParse(sub.group(1)!);
      final label = n != null ? n.toString().padLeft(2, '0') : sub.group(1)!;
      final subCap = sub.group(2)!.isEmpty ? '' : sub.group(2)![0].toUpperCase() + sub.group(2)!.substring(1).toLowerCase();
      return 'Analogous $label${subCap.isEmpty ? '' : ' $subCap'}';
    }
    final an = RegExp(r'^analogous_(\d+)$').firstMatch(lower);
    if (an != null) {
      final n = int.tryParse(an.group(1)!);
      return 'Analogous ${n != null ? n.toString().padLeft(2, '0') : an.group(1)!}';
    }
    return key.split('_').map((p) => p.isEmpty ? p : p[0].toUpperCase() + p.substring(1).toLowerCase()).join(' ');
  }

  final result = <(String, Map<String, dynamic>)>[];
  for (final k in primaryFirst) {
    result.add((titleFor(k), groups[k]!));
  }
  final otherPalettes = [
    ('Blue', c.blue),
    ('Green', c.green),
    ('Orange', c.orange),
    ('Purple', c.purple),
    ('Red', c.red),
    ('Grey', c.grey),
    ('White', c.white),
    ('Text', c.text),
    ('Input', c.input),
    ('Role-specific', c.roleSpecific),
  ];
  for (final t in otherPalettes) {
    if (t.$2 != null && (t.$2 as Map).isNotEmpty) {
      result.add((t.$1, Map<String, dynamic>.from(t.$2 as Map)));
    }
  }
  return result;
}

int _pdfNaturalCompare(String a, String b) {
  final ap = a.split(RegExp(r'(\d+)'));
  final bp = b.split(RegExp(r'(\d+)'));
  for (var i = 0; i < ap.length && i < bp.length; i++) {
    final an = int.tryParse(ap[i]);
    final bn = int.tryParse(bp[i]);
    if (an != null && bn != null) {
      final c = an.compareTo(bn);
      if (c != 0) return c;
    } else {
      final c = ap[i].compareTo(bp[i]);
      if (c != 0) return c;
    }
  }
  return ap.length.compareTo(bp.length);
}

pw.Widget _buildPdfColorsFull(models.DesignSystem ds) {
  final groups = _getPdfColorGroups(ds);
  if (groups.isEmpty) return pw.Text('No colors defined.', style: pw.TextStyle(fontSize: 10, color: _pdfTextSecondary));
  final sections = <pw.Widget>[];
  for (final g in groups) {
    sections.add(pw.Text(g.$1, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12, color: _pdfPageFg)));
    sections.add(pw.SizedBox(height: 6));
    sections.add(_buildPdfSwatchGroup(g.$2));
    sections.add(pw.SizedBox(height: 16));
  }
  return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: sections);
}

/// Number of color swatches per PDF page (3 columns x 4 rows).
const int _swatchesPerPage = 12;
const int _swatchColumns = 3;

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

/// One fixed-size page with a grid of swatches (no MultiPage = no one-swatch-per-page).
pw.Widget _buildPdfColorGridPage(String groupTitle, List<MapEntry<String, dynamic>> entries, pw.TextStyle headerStyle, {bool isContinuation = false}) {
  final title = isContinuation ? '$groupTitle (cont.)' : groupTitle;
  final rows = _buildPdfColorGridRows(entries);
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
    children: [
      pw.Text('1. Core Colors — $title', style: headerStyle),
      pw.SizedBox(height: 12),
      ...rows,
    ],
  );
}

/// Flattened list: one page per 32 swatches across all groups (avoids 1-color-per-page).
pw.Widget _buildPdfColorGridPageFlat(List<(String groupTitle, MapEntry<String, dynamic>)> chunk, pw.TextStyle headerStyle, {required int pageIndex, required int totalPages}) {
  final entries = chunk.map((e) => e.$2).toList();
  final rows = _buildPdfColorGridRows(entries);
  final pageLabel = totalPages <= 1 ? '1. Core Colors' : '1. Core Colors (page ${pageIndex + 1} of $totalPages)';
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
    children: [
      pw.Text(pageLabel, style: headerStyle),
      pw.SizedBox(height: 12),
      ...rows,
    ],
  );
}

List<pw.Widget> _buildPdfColorGridRows(List<MapEntry<String, dynamic>> entries) {
  final rows = <pw.Widget>[];
  for (var i = 0; i < entries.length; i += _swatchColumns) {
    final rowChildren = <pw.Widget>[];
    for (var j = 0; j < _swatchColumns && i + j < entries.length; j++) {
      final e = entries[i + j];
      final val = e.value is Map ? e.value['value'] : e.value.toString();
      rowChildren.add(
        pw.Expanded(
          child: pw.Padding(
            padding: const pw.EdgeInsets.only(right: 10, bottom: 10),
            child: pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: _pdfCardBorder, width: 0.8),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                children: [
                  pw.Container(
                    height: 44,
                    decoration: pw.BoxDecoration(
                      color: _parsePdfColor(val.toString()),
                      borderRadius: const pw.BorderRadius.only(
                        topLeft: pw.Radius.circular(8),
                        topRight: pw.Radius.circular(8),
                      ),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.fromLTRB(6, 5, 6, 6),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          e.key.length > 20 ? '${e.key.substring(0, 17)}...' : e.key,
                          style: pw.TextStyle(fontSize: 7, color: _pdfTextSecondary),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(_pdfHex(val.toString()), style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: _pdfPageFg)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    rows.add(pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: rowChildren));
  }
  return rows;
}

pw.Widget _buildPdfTypographyFull(models.DesignSystem ds) {
  final t = ds.typography;
  final children = <pw.Widget>[
    pw.Text('Font family: ${t.fontFamily.primary}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
    if (t.fontFamily.fallback.isNotEmpty) pw.Text('Fallback: ${t.fontFamily.fallback}', style: pw.TextStyle(fontSize: 10, color: _pdfTextSecondary)),
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
          pw.Text(e.key, style: pw.TextStyle(fontSize: 8, color: _pdfTextSecondary)),
          pw.Text('Sample in ${e.key}', style: pw.TextStyle(fontSize: 10)),
        ],
      ),
    )));
  }
  if (children.length <= 3) children.add(pw.Text('No typography defined.', style: pw.TextStyle(fontSize: 10, color: _pdfTextSecondary)));
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
            color: _pdfAccentSoft,
            border: pw.Border.all(color: _pdfAccent, width: 0.5),
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
            border: pw.Border.all(color: _pdfAccent),
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
        decoration: pw.BoxDecoration(border: pw.Border.all(color: _pdfCardBorder), borderRadius: pw.BorderRadius.circular(radius)),
        child: pw.Text('${e.key}${desc.isNotEmpty ? ': $desc' : ''}', style: const pw.TextStyle(fontSize: 8)),
      );
    }));
    children.add(pw.SizedBox(height: 12));
  }
  if (children.isEmpty) children.add(pw.Text('No components defined.', style: pw.TextStyle(fontSize: 10, color: _pdfTextSecondary)));
  return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: children);
}

pw.Widget _buildPdfIconsDetailed(models.DesignSystem ds) {
  final parts = <pw.Widget>[];
  if (ds.icons.projectIcons.isNotEmpty) {
    parts.add(pw.Text('Project icons', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)));
    for (final e in ds.icons.projectIcons) {
      parts.add(pw.Padding(
        padding: const pw.EdgeInsets.only(left: 8, top: 2),
        child: pw.Text('• ${e.label} (0x${e.codePoint.toRadixString(16)})', style: const pw.TextStyle(fontSize: 9)),
      ));
    }
    parts.add(pw.SizedBox(height: 8));
  }
  parts.add(pw.Wrap(
    spacing: 15,
    children: ds.icons.sizes.entries.map((e) => pw.Text('${e.key}: ${e.value}', style: pw.TextStyle(fontSize: 10))).toList(),
  ));
  return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: parts);
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
  if (lines.isEmpty) lines.add(pw.Text('No effects defined.', style: pw.TextStyle(fontSize: 10, color: _pdfTextSecondary)));
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
  if (children.isEmpty) children.add(pw.Text('No semantic tokens defined.', style: pw.TextStyle(fontSize: 10, color: _pdfTextSecondary)));
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
  if (children.isEmpty) children.add(pw.Text('No motion tokens defined.', style: pw.TextStyle(fontSize: 10, color: _pdfTextSecondary)));
  return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: children);
}

pw.Widget _buildPdfVersionHistory(models.DesignSystem ds) {
  final history = ds.versionHistory ?? [];
  if (history.isEmpty) return pw.Text('No version history.', style: pw.TextStyle(fontSize: 10, color: _pdfTextSecondary));
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: history.take(15).map((v) {
      return pw.Container(
        margin: const pw.EdgeInsets.only(bottom: 6),
        padding: const pw.EdgeInsets.all(6),
        decoration: pw.BoxDecoration(border: pw.Border.all(color: _pdfCardBorder), borderRadius: pw.BorderRadius.circular(4)),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('${v.version} - ${v.date}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
            if (v.changes.isNotEmpty) pw.Text(v.changes.join('; '), style: const pw.TextStyle(fontSize: 8)),
            if (v.description != null && v.description!.isNotEmpty) pw.Text(v.description!, style: pw.TextStyle(fontSize: 8, color: _pdfTextSecondary)),
          ],
        ),
      );
    }).toList(),
  );
}
