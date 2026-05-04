import '../models/design_system.dart' as models;
import 'design_system_preview_color_order.dart';
import 'token_display_order.dart';

double _px(dynamic v) {
  if (v == null) return 8;
  if (v is num) return v.toDouble();
  final s = v.toString().trim().toLowerCase();
  if (s.endsWith('px')) return double.tryParse(s.replaceAll('px', '')) ?? 8;
  return double.tryParse(s) ?? 8;
}

/// Safe for embedding inside double-quoted HTML attributes (style="...").
String _cssAttr(String s) {
  return s.replaceAll('"', '\'').replaceAll('\n', ' ').trim();
}

Map<String, dynamic> _mapOf(dynamic data) {
  if (data is! Map) return {};
  return Map<String, dynamic>.from(data);
}

/// Mini HTML thumbnail aligned with [ComponentPreviewThumbnail] behavior.
String htmlComponentThumbnail(String category, String name, dynamic data, String Function(String) esc) {
  final m = _mapOf(data);
  switch (category) {
    case 'buttons':
      final h = _px(m['height'] ?? 36);
      final br = _px(m['borderRadius'] ?? 16);
      final p = _px(m['padding'] ?? 16);
      final fs = _px(m['fontSize'] ?? 14);
      final fw = (int.tryParse(m['fontWeight']?.toString() ?? '600') ?? 600).clamp(100, 900);
      final label = esc(m['label']?.toString() ?? m['text']?.toString() ?? name);
      return '<button type="button" style="min-height:${h}px;padding:0 ${p}px;border-radius:${br}px;font-size:${fs}px;font-weight:$fw;border:none;background:#6750A4;color:#fff;cursor:default;font-family:inherit;">$label</button>';
    case 'inputs':
      final r = _px(m['borderRadius'] ?? 8);
      final nm = esc(name);
      return '<div style="width:160px;text-align:left;"><span style="font-size:11px;color:#666;display:block;margin-bottom:4px;">$nm</span><div style="border:1px solid #ccc;border-radius:${r}px;padding:8px 12px;font-size:14px;color:#999;">…</div></div>';
    case 'cards':
      final r = _px(m['borderRadius'] ?? 8);
      final pad = _px(m['padding'] ?? 12);
      final nm = esc(name);
      return '<div style="padding:${pad}px;border:1px solid #ddd;border-radius:${r}px;background:#fff;font-weight:600;font-size:12px;">$nm</div>';
    case 'avatars':
      final size = _px(m['size'] ?? m['height'] ?? 40).clamp(24.0, 72.0);
      final initial = name.isNotEmpty ? esc(name.substring(0, 1).toUpperCase()) : '?';
      return '<div style="width:${size}px;height:${size}px;border-radius:50%;background:#E8DEF8;color:#4A4459;display:flex;align-items:center;justify-content:center;font-weight:600;font-size:${(size * 0.45).round()}px;">$initial</div>';
    case 'navigation':
      final nm = esc(name);
      return '<div style="display:flex;align-items:center;gap:4px;font-size:10px;"><span style="font-size:18px;color:#6750A4;">⌂</span><span>$nm</span></div>';
    case 'modals':
      final r = _px(m['borderRadius'] ?? m['modalCornerRadius'] ?? 12);
      final title = esc((m['modalTitle'] ?? m['title'] ?? name).toString());
      final body = esc((m['bodyText'] ?? m['body'] ?? 'Modal body').toString());
      final cancel = esc((m['cancelLabel'] ?? 'Cancel').toString());
      final confirm = esc((m['confirmLabel'] ?? m['primaryLabel'] ?? 'OK').toString());
      return '<div style="max-width:168px;padding:8px;border:1px solid #ddd;border-radius:${r}px;background:#fff;box-shadow:0 2px 8px rgba(0,0,0,0.12);font-size:9px;"><div style="font-weight:bold;margin-bottom:4px;">$title</div><div style="color:#666;margin-bottom:6px;">$body</div><div style="display:flex;justify-content:flex-end;gap:6px;"><span style="color:#6750A4;">$cancel</span><span style="background:#6750A4;color:#fff;padding:2px 8px;border-radius:4px;">$confirm</span></div></div>';
    case 'tables':
      final h1 = esc((m['col1Header'] ?? m['header1'] ?? 'Name').toString());
      final h2 = esc((m['col2Header'] ?? m['header2'] ?? 'Status').toString());
      final c11 = esc((m['cell11'] ?? m['sample1a'] ?? '—').toString());
      final c12 = esc((m['cell12'] ?? m['sample1b'] ?? '—').toString());
      final c21 = esc((m['cell21'] ?? m['sample2a'] ?? '—').toString());
      final c22 = esc((m['cell22'] ?? m['sample2b'] ?? '—').toString());
      return '<table style="border-collapse:collapse;font-size:9px;border:0.5px solid #bbb;"><tr style="background:#eee;"><th style="padding:4px;border:0.5px solid #bbb;">$h1</th><th style="padding:4px;border:0.5px solid #bbb;">$h2</th></tr><tr><td style="padding:4px;border:0.5px solid #bbb;">$c11</td><td style="padding:4px;border:0.5px solid #bbb;">$c12</td></tr><tr><td style="padding:4px;border:0.5px solid #bbb;">$c21</td><td style="padding:4px;border:0.5px solid #bbb;">$c22</td></tr></table>';
    case 'progress':
      final indeterminate = m['progressIndeterminate'] == true || m['indeterminate'] == true;
      double? pctVal;
      if (!indeterminate) {
        final raw = m['progressValue'] ?? m['value'];
        if (raw != null && raw.toString().isNotEmpty) {
          final n = double.tryParse(raw.toString());
          if (n != null) {
            pctVal = n > 1 ? (n / 100).clamp(0.0, 1.0) : n.clamp(0.0, 1.0);
          }
        }
      }
      final cap = esc((m['progressCaption'] ?? m['caption'] ?? name).toString());
      final pct = pctVal ?? 0.6;
      final bar = indeterminate
          ? '<div style="height:6px;background:repeating-linear-gradient(90deg,#6750A4 0,#6750A4 8px,#eee 8px,#eee 16px);border-radius:3px;"></div>'
          : '<div style="height:6px;background:#eee;border-radius:3px;overflow:hidden;"><div style="height:100%;width:${(pct * 100).round()}%;background:#6750A4;border-radius:3px;"></div></div>';
      return '<div style="width:140px;">$bar<div style="font-size:9px;color:#666;margin-top:4px;">$cap</div></div>';
    case 'alerts':
      final r = _px(m['borderRadius'] ?? 8);
      final variant = (m['alertVariant'] ?? m['variant'] ?? 'info').toString().toLowerCase();
      late final String bg;
      late final String border;
      late final String fg;
      late final String icon;
      if (variant == 'error' || variant == 'danger') {
        bg = '#FFEBEE';
        border = '#C62828';
        fg = '#B71C1C';
        icon = '✕';
      } else if (variant == 'success') {
        bg = '#E8F5E9';
        border = '#2E7D32';
        fg = '#1B5E20';
        icon = '✓';
      } else if (variant == 'warning') {
        bg = '#FFF8E1';
        border = '#F57F17';
        fg = '#E65100';
        icon = '!';
      } else {
        bg = '#E3F2FD';
        border = '#1565C0';
        fg = '#0D47A1';
        icon = 'i';
      }
      final title = esc((m['alertTitle'] ?? '').toString());
      final message = esc((m['alertMessage'] ?? m['message'] ?? name).toString());
      final titleHtml = title.isNotEmpty ? '<strong style="display:block;font-size:10px;margin-bottom:2px;">$title</strong>' : '';
      return '<div style="max-width:170px;padding:6px 8px;background:$bg;border-left:3px solid $border;border-radius:${r}px;font-size:10px;color:$fg;"><div style="display:flex;gap:6px;align-items:flex-start;"><span style="flex-shrink:0;">$icon</span><div>$titleHtml$message</div></div></div>';
    default:
      return '<span style="font-size:12px;color:#888;">${esc(name)}</span>';
  }
}

String _gradientCss(models.GradientValue g) {
  final colors = g.colors.map(previewColorHex).join(', ');
  var angle = '180deg';
  final d = g.direction.toLowerCase().trim();
  if (d.contains('right') || d.contains('90')) angle = '90deg';
  if (d.contains('left')) angle = '270deg';
  if (d.contains('top') && !d.contains('bottom')) angle = '0deg';
  if (g.type.toLowerCase() == 'radial') {
    return 'radial-gradient(circle, $colors)';
  }
  return 'linear-gradient($angle, $colors)';
}

/// Typography: live samples (family, weights, sizes, text styles).
String buildTypographyVisualsHtml(models.Typography t, String Function(String) esc) {
  final primary = esc(t.fontFamily.primary);
  final parts = <String>[];

  parts.add('''<h4 class="doc-vis-h">Font family</h4>
<div class="doc-visual-canvas doc-visual-canvas--wide">
  <div style="font-family:'$primary',system-ui,sans-serif;font-size:22px;line-height:1.3;color:#1A1917;">The quick brown fox jumps over the lazy dog</div>
</div>''');

  if (t.fontWeights.isNotEmpty) {
    final wRows = StringBuffer();
    for (final e in TokenDisplayOrder.sortedFontWeights(t.fontWeights)) {
      wRows.write(
        '<div class="doc-mini-row"><span class="doc-mini-label"><code>${esc(e.key)}</code> · ${e.value}</span>'
        '<span style="font-weight:${e.value};font-size:26px;font-family:\'$primary\',sans-serif;">Ag</span></div>',
      );
    }
    parts.add('<h4 class="doc-vis-h">Weights</h4><div class="doc-visual-canvas doc-visual-canvas--wide">$wRows</div>');
  }

  if (t.fontSizes.isNotEmpty) {
    final sRows = StringBuffer();
    for (final e in TokenDisplayOrder.sortedFontSizes(t.fontSizes)) {
      final fs = _cssAttr(e.value.value.toString());
      sRows.write(
        '<div class="doc-mini-row"><span class="doc-mini-label"><code>${esc(e.key)}</code></span>'
        '<span style="font-size:$fs;font-family:\'$primary\',sans-serif;line-height:1.2;">${esc(e.key)} sample</span></div>',
      );
    }
    parts.add('<h4 class="doc-vis-h">Font sizes</h4><div class="doc-visual-canvas doc-visual-canvas--wide">$sRows</div>');
  }

  if (t.textStyles.isNotEmpty) {
    final stRows = StringBuffer();
    for (final e in TokenDisplayOrder.sortedTextStyles(t.textStyles)) {
      final ts = e.value;
      final ff = esc(ts.fontFamily);
      final fs = _cssAttr(ts.fontSize.toString());
      final fw = ts.fontWeight;
      stRows.write(
        '<div class="doc-mini-row" style="display:block;margin-bottom:12px;">'
        '<div class="doc-mini-label" style="margin-bottom:6px;"><code>${esc(e.key)}</code> · $fs · $fw</div>'
        '<div style="font-family:\'$ff\',sans-serif;font-size:$fs;font-weight:$fw;line-height:${_cssAttr(ts.lineHeight)};">The quick brown fox jumps over the lazy dog</div>'
        '</div>',
      );
    }
    parts.add('<h4 class="doc-vis-h">Text styles</h4><div class="doc-visual-canvas doc-visual-canvas--wide">$stRows</div>');
  }

  return '<div class="doc-preview-visuals">${parts.join('\n')}</div>';
}

String buildSpacingVisualHtml(models.DesignSystem ds, String Function(String) esc) {
  if (ds.spacing.values.isEmpty) return '';
  final parts = StringBuffer();
  for (final e in TokenDisplayOrder.sortedStringValuesByPx(ds.spacing.values)) {
    final px = _px(e.value);
    final w = px.clamp(4.0, 120.0);
    parts.write(
      '<div class="doc-spacing-tile"><div class="doc-spacing-name"><code>${esc(e.key)}</code><span>${esc(e.value)}</span></div>'
      '<div class="doc-spacing-bar-wrap"><div class="doc-spacing-bar" style="width:${w}px;"></div></div></div>',
    );
  }
  return '<h4 class="doc-vis-h">Spacing preview</h4><div class="doc-spacing-grid">$parts</div>';
}

String buildGridVisualHtml(models.Grid grid, String Function(String) esc) {
  final cols = grid.columns.clamp(1, 24);
  final cells = List.generate(cols, (_) => '<div class="doc-grid-cell"></div>').join('');
  return '''<h4 class="doc-vis-h">Grid preview</h4>
<div class="doc-visual-canvas doc-visual-canvas--wide">
  <div class="doc-grid-strip">$cells</div>
  <p class="doc-grid-caption">Columns: ${esc(cols.toString())} · Gutter: ${esc(grid.gutter)} · Margin: ${esc(grid.margin)}</p>
</div>''';
}

String buildRadiusVisualHtml(models.BorderRadius br, String Function(String) esc) {
  final entries = [
    ('none', br.none),
    ('sm', br.sm),
    ('base', br.base),
    ('md', br.md),
    ('lg', br.lg),
    ('xl', br.xl),
    ('full', br.full),
  ];
  final chips = entries.map((e) {
    final px = e.$2 == '9999px' || e.$2.toLowerCase() == 'full' ? 9999.0 : _px(e.$2);
    final r = px >= 500 ? 18.0 : (px / 2).clamp(0.0, 18.0);
    return '<div class="doc-radius-item"><div class="doc-radius-box" style="border-radius:${r}px;"></div><span><code>${esc(e.$1)}</code> ${esc(e.$2)}</span></div>';
  }).join('');
  return '<h4 class="doc-vis-h">Radius preview</h4><div class="doc-radius-grid">$chips</div>';
}

String buildShadowsVisualHtml(models.Shadows shadows, String Function(String) esc) {
  if (shadows.values.isEmpty) return '';
  final parts = StringBuffer();
  for (final e in TokenDisplayOrder.sortedShadows(shadows.values)) {
    final raw = _cssAttr(e.value.value.toString());
    parts.write(
      '<div class="doc-shadow-row"><div><code>${esc(e.key)}</code></div>'
      '<div class="doc-shadow-sample" style="box-shadow:$raw;"></div></div>',
    );
  }
  return '<h4 class="doc-vis-h">Shadow preview</h4><div class="doc-shadow-visuals">$parts</div>';
}

double? _extractBlurPx(String s) {
  final m = RegExp(r'blur\s*\(\s*(\d+(?:\.\d+)?)\s*px\s*\)', caseSensitive: false).firstMatch(s);
  if (m != null) return double.tryParse(m.group(1)!);
  return null;
}

String buildEffectsVisualHtml(models.Effects fx, String Function(String) esc) {
  final glass = fx.glassMorphism;
  final dark = fx.darkOverlay;
  if ((glass == null || glass.isEmpty) && (dark == null || dark.isEmpty)) return '';

  final buf = StringBuffer();
  if (glass != null && glass.isNotEmpty) {
    final bg = _cssAttr(glass['background']?.toString() ?? 'rgba(255,255,255,0.15)');
    final blur = _extractBlurPx(glass['backdrop']?.toString() ?? 'blur(10px)') ?? 10.0;
    buf.write('''<h4 class="doc-vis-h">Glass morphism</h4>
<div class="doc-effect-stage">
  <div class="doc-effect-bg"></div>
  <div class="doc-effect-glass-wrap">
    <div class="doc-effect-glass" style="backdrop-filter:blur(${blur}px);-webkit-backdrop-filter:blur(${blur}px);background:$bg;">Glass panel</div>
  </div>
</div>''');
  }
  if (dark != null && dark.isNotEmpty) {
    final ov = _cssAttr(dark['background']?.toString() ?? 'rgba(26,26,46,0.75)');
    buf.write('''<h4 class="doc-vis-h">Dark overlay</h4>
<div class="doc-overlay-stage">
  <div class="doc-overlay-bg">Content behind</div>
  <div class="doc-overlay-top" style="background:$ov;"><span class="doc-overlay-card">Overlay on top</span></div>
</div>''');
  }
  return '<div class="doc-preview-visuals">${buf.toString()}</div>';
}

String buildGradientVisualsHtml(models.DesignSystem ds, String Function(String) esc) {
  if (ds.gradients.values.isEmpty) return '';
  final rows = StringBuffer();
  for (final e in TokenDisplayOrder.sortedGradients(ds.gradients.values)) {
    final css = _gradientCss(e.value);
    rows.write(
      '<div class="doc-gradient-row"><div><code>${esc(e.key)}</code></div>'
      '<div class="doc-gradient-bar" style="background:$css;"></div></div>',
    );
  }
  return '<h4 class="doc-vis-h">Gradient preview</h4><div class="doc-gradient-visuals">$rows</div>';
}

String buildProjectIconsVisualHtml(models.DesignSystem ds, String Function(String) esc) {
  if (ds.icons.projectIcons.isEmpty) return '';
  final sorted = List.of(ds.icons.projectIcons)
    ..sort((a, b) => TokenDisplayOrder.naturalCompare(a.label, b.label));
  final parts = StringBuffer();
  for (final e in sorted) {
    final ch = String.fromCharCode(e.codePoint);
    parts.write(
      '<div class="doc-icon-project"><span class="material-icons" style="font-size:40px;">$ch</span><span>${esc(e.label)}</span></div>',
    );
  }
  return '<h4 class="doc-vis-h">Project icons</h4><div class="doc-project-icons">$parts</div>';
}

String buildRolesVisualHtml(models.DesignSystem ds, String Function(String) esc) {
  if (ds.roles.values.isEmpty) return '';
  final rows = StringBuffer();
  for (final e in TokenDisplayOrder.sortedRoles(ds.roles.values)) {
    final c = previewColorHex(e.value.primaryColor);
    rows.write(
      '<div class="doc-role-row"><div><code>${esc(e.key)}</code></div>'
      '<div class="doc-role-swatch" style="background:${_cssAttr(c)};"></div>'
      '<span>${esc(c)}</span></div>',
    );
  }
  return '<h4 class="doc-vis-h">Roles preview</h4><div class="doc-role-visuals">$rows</div>';
}

String buildIconSizesVisualHtml(models.DesignSystem ds, String Function(String) esc) {
  if (ds.icons.sizes.isEmpty) return '';
  final rows = StringBuffer();
  for (final e in TokenDisplayOrder.sortedStringValuesByPx(ds.icons.sizes)) {
    final sz = _px(e.value).clamp(12.0, 56.0);
    rows.write(
      '<div class="doc-icon-size-row"><span><code>${esc(e.key)}</code> ${esc(e.value)}</span>'
      '<span class="doc-icon-star" style="font-size:${sz}px;">★</span></div>',
    );
  }
  return '<h4 class="doc-vis-h">Icon sizes preview</h4><div class="doc-icon-size-visuals">$rows</div>';
}

/// One component row: metadata + thumbnail (matches Preview layout).
String buildComponentRowsHtml(
  String category,
  Map<String, dynamic>? map, {
  required bool alerts,
  required String Function(String) esc,
}) {
  if (map == null || map.isEmpty) return '';
  var entries = map.entries.toList();
  if (alerts) {
    entries.sort((a, b) {
      final ra = alertVariantRankForExport(a.value);
      final rb = alertVariantRankForExport(b.value);
      if (ra != rb) return ra.compareTo(rb);
      return TokenDisplayOrder.naturalCompare(a.key, b.key);
    });
  } else {
    entries.sort((a, b) => TokenDisplayOrder.naturalCompare(a.key, b.key));
  }

  final buf = StringBuffer();
  for (final e in entries) {
    final val = e.value;
    final desc = (val is Map && val['description'] != null) ? val['description'].toString() : '';
    final thumb = htmlComponentThumbnail(category, e.key, val, esc);
    buf.write(
      '<div class="doc-component-row">'
      '<div class="doc-component-meta"><strong><code>${esc(e.key)}</code></strong>'
      '${desc.isNotEmpty ? '<p class="doc-component-desc">${esc(desc)}</p>' : ''}</div>'
      '<div class="doc-visual-canvas doc-visual-canvas--component">$thumb</div>'
      '</div>',
    );
  }
  return buf.toString();
}
