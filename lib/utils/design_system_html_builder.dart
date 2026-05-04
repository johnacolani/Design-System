import '../models/design_system.dart' as models;
import 'design_system_html_visuals.dart';
import 'design_system_preview_color_order.dart';
import 'token_display_order.dart';

String buildDesignSystemHtml(models.DesignSystem ds) {
  final colorSections = buildPreviewOrderedColorSections(ds);
  final colorCards = colorSections.isEmpty
      ? '<p class="lead">No color tokens found.</p>'
      : colorSections
          .map((section) {
            final swatches = section.entries
                .map((e) {
                  final hex = previewColorHex(e.$2);
                  return '''
<div class="swatch" data-hex="${_escapeHtml(hex)}" title="Click to copy ${_escapeHtml(hex)}">
  <div class="chip" style="background:${_escapeHtml(hex)}"></div>
  <div class="lbl">
    <strong>${_escapeHtml(e.$1)}</strong>
    ${_escapeHtml(hex)}
  </div>
</div>''';
                })
                .join('\n');
            return '''
<div class="card color-group">
  <h3>${_escapeHtml(section.title)}</h3>
  <div class="grid-swatches">$swatches</div>
</div>''';
          })
          .join('\n');
  final typographyHtml = _buildTypographyHtml(ds);
  final layoutHtml = _buildLayoutHtml(ds);
  final radiusHtml = _buildRadiusHtml(ds);
  final shadowsHtml = _buildShadowsHtml(ds);
  final effectsHtml = _buildEffectsHtml(ds);
  final componentsHtml = _buildComponentsHtml(ds);
  final advancedHtml = _buildAdvancedHtml(ds);

  return '''
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>${_escapeHtml(ds.name.isEmpty ? 'Design System' : ds.name)}</title>
  <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet" />
  <style>
    :root {
      --page-bg: #F5F2EB;
      --page-fg: #1A1917;
      --card: #FFFCF7;
      --card-border: rgba(26, 25, 23, 0.08);
      --text-secondary: #5C5A56;
      --accent: #6FA8A1;
      --mono: ui-monospace, SFMono-Regular, Menlo, Consolas, monospace;
    }
    * { box-sizing: border-box; }
    body {
      margin: 0;
      padding: 24px;
      background: var(--page-bg);
      color: var(--page-fg);
      font-family: Roboto, system-ui, -apple-system, Segoe UI, sans-serif;
    }
    .wrap { max-width: 1120px; margin: 0 auto; }
    h1 { margin: 0 0 8px; font-size: 34px; }
    .meta { margin: 0 0 24px; color: var(--text-secondary); }
    section { margin-bottom: 24px; }
    h2 {
      margin: 0 0 8px;
      font-size: 28px;
      border-bottom: 2px solid var(--accent);
      padding-bottom: 8px;
    }
    .lead { color: var(--text-secondary); margin: 0 0 16px; }
    .card {
      background: var(--card);
      border: 1px solid var(--card-border);
      border-radius: 16px;
      padding: 16px;
    }
    .card + .card { margin-top: 12px; }
    .color-group h3 {
      margin: 0 0 12px;
      font-size: 16px;
      font-weight: 600;
      color: var(--text-secondary);
    }
    .grid-swatches {
      display: grid;
      gap: 12px;
      grid-template-columns: repeat(auto-fill, minmax(160px, 1fr));
    }
    .swatch {
      border-radius: 12px;
      overflow: hidden;
      border: 1px solid rgba(0,0,0,0.08);
      background: #fff;
      cursor: pointer;
    }
    .swatch:hover { box-shadow: 0 6px 18px rgba(0,0,0,0.12); transform: translateY(-1px); }
    .chip { height: 72px; }
    .lbl {
      padding: 10px 12px;
      font-family: var(--mono);
      font-size: 13px;
    }
    .lbl strong {
      display: block;
      margin-bottom: 4px;
      font-family: Roboto, sans-serif;
      font-size: 11px;
      color: var(--text-secondary);
      font-weight: 600;
    }
    .toast {
      position: fixed;
      left: 50%;
      bottom: 24px;
      transform: translateX(-50%);
      background: #1A1917;
      color: #fff;
      padding: 10px 14px;
      border-radius: 10px;
      font-size: 13px;
      opacity: 0;
      transition: opacity 160ms ease;
      pointer-events: none;
    }
    .toast.show { opacity: 1; }
    table {
      width: 100%;
      border-collapse: collapse;
      font-size: 14px;
    }
    th, td {
      text-align: left;
      padding: 8px 10px;
      border-bottom: 1px solid var(--card-border);
      vertical-align: top;
    }
    th { color: var(--text-secondary); font-size: 12px; text-transform: uppercase; }
    code { font-family: var(--mono); }
    .chips { display: flex; flex-wrap: wrap; gap: 8px; }
    .chip-pill {
      border: 1px solid var(--card-border);
      border-radius: 999px;
      padding: 6px 10px;
      font-size: 12px;
      background: #fff;
    }
    .doc-data-h { margin: 20px 0 8px; font-size: 13px; font-weight: 600; color: var(--text-secondary); text-transform: uppercase; letter-spacing: 0.04em; }
    .doc-vis-h { margin: 20px 0 10px; font-size: 14px; font-weight: 600; color: var(--text-secondary); }
    .doc-preview-visuals { margin-top: 8px; }
    .doc-visual-canvas {
      background: #fafafa;
      border: 1px solid rgba(0,0,0,0.12);
      border-radius: 8px;
      padding: 16px;
      min-height: 80px;
      display: flex;
      align-items: center;
      justify-content: center;
    }
    .doc-visual-canvas--wide { justify-content: flex-start; align-items: stretch; flex-wrap: wrap; }
    .doc-visual-canvas--component { min-height: 120px; min-width: 200px; max-width: 320px; margin-left: auto; }
    .doc-mini-row { display: flex; justify-content: space-between; align-items: center; gap: 16px; padding: 8px 0; border-bottom: 1px solid var(--card-border); flex-wrap: wrap; }
    .doc-mini-row:last-child { border-bottom: none; }
    .doc-mini-label { font-size: 12px; color: var(--text-secondary); }
    .doc-spacing-grid { display: grid; gap: 12px; grid-template-columns: repeat(auto-fill, minmax(200px, 1fr)); }
    .doc-spacing-tile { border: 1px solid var(--card-border); border-radius: 10px; padding: 10px; background: #fff; }
    .doc-spacing-name { display: flex; justify-content: space-between; gap: 8px; font-size: 12px; margin-bottom: 8px; }
    .doc-spacing-bar-wrap { height: 24px; display: flex; align-items: center; background: #eee; border-radius: 4px; padding: 0 6px; }
    .doc-spacing-bar { height: 12px; background: var(--accent); border-radius: 3px; max-width: 100%; }
    .doc-grid-strip { display: flex; gap: 4px; height: 48px; width: 100%; border: 1px solid var(--card-border); border-radius: 8px; padding: 4px; background: #fff; }
    .doc-grid-cell { flex: 1; background: rgba(123, 111, 157, 0.12); border-radius: 6px; }
    .doc-grid-caption { margin: 10px 0 0; font-size: 12px; color: var(--text-secondary); }
    .doc-radius-grid { display: flex; flex-wrap: wrap; gap: 16px; align-items: flex-end; }
    .doc-radius-item { text-align: center; font-size: 11px; color: var(--text-secondary); }
    .doc-radius-box { width: 36px; height: 36px; border: 2px solid var(--accent); background: #fff; margin: 0 auto 6px; }
    .doc-shadow-visuals { display: flex; flex-direction: column; gap: 16px; }
    .doc-shadow-row { display: flex; flex-wrap: wrap; gap: 16px; align-items: center; justify-content: space-between; }
    .doc-shadow-sample { width: 72px; height: 72px; background: #fff; border-radius: 8px; }
    .doc-effect-stage { position: relative; height: 120px; border-radius: 12px; overflow: hidden; }
    .doc-effect-bg { position: absolute; inset: 0; background: linear-gradient(135deg, #90CAF9 0%, #CE93D8 100%); }
    .doc-effect-glass-wrap { position: absolute; inset: 0; display: flex; align-items: center; justify-content: center; }
    .doc-effect-glass { padding: 12px 16px; border-radius: 12px; border: 1px solid rgba(255,255,255,0.35); color: #fff; font-size: 13px; font-weight: 500; }
    .doc-overlay-stage { position: relative; height: 120px; border-radius: 12px; overflow: hidden; }
    .doc-overlay-bg { height: 100%; display: flex; align-items: center; justify-content: center; background: #f0f0f0; color: #888; font-size: 12px; }
    .doc-overlay-top { position: absolute; inset: 0; display: flex; align-items: center; justify-content: center; }
    .doc-overlay-card { background: rgba(255,255,255,0.92); padding: 10px 14px; border-radius: 8px; font-size: 12px; font-weight: 500; box-shadow: 0 2px 8px rgba(0,0,0,0.08); }
    .doc-gradient-visuals { display: flex; flex-direction: column; gap: 12px; }
    .doc-gradient-row { display: flex; flex-direction: column; gap: 6px; }
    .doc-gradient-bar { height: 28px; border-radius: 8px; border: 1px solid var(--card-border); }
    .doc-role-visuals { display: flex; flex-direction: column; gap: 10px; }
    .doc-role-row { display: flex; align-items: center; gap: 12px; flex-wrap: wrap; }
    .doc-role-swatch { width: 36px; height: 36px; border-radius: 8px; border: 1px solid rgba(0,0,0,0.12); }
    .doc-component-row { display: flex; flex-wrap: wrap; gap: 16px; align-items: flex-start; padding: 14px 0; border-bottom: 1px solid var(--card-border); }
    .doc-component-row:last-child { border-bottom: none; }
    .doc-component-meta { flex: 1 1 200px; }
    .doc-component-desc { margin: 6px 0 0; font-size: 12px; color: var(--text-secondary); }
    .doc-project-icons { display: flex; flex-wrap: wrap; gap: 20px; align-items: center; }
    .doc-icon-project { display: flex; flex-direction: column; align-items: center; gap: 6px; font-size: 11px; color: var(--text-secondary); }
    .doc-icon-size-visuals { display: flex; flex-direction: column; gap: 8px; }
    .doc-icon-size-row { display: flex; justify-content: space-between; align-items: center; gap: 12px; flex-wrap: wrap; }
    .doc-icon-star { color: var(--text-secondary); line-height: 1; }
  </style>
</head>
<body>
  <div class="wrap">
    <header>
      <h1>${_escapeHtml(ds.name.isEmpty ? 'Design System' : ds.name)}</h1>
      <p class="meta">Version ${_escapeHtml(ds.version)}${ds.description.isNotEmpty ? ' | ${_escapeHtml(ds.description)}' : ''}</p>
    </header>
    <section>
      <h2>Color</h2>
      <p class="lead">Same groups and order as the in-app Preview (Core → ramps → semantic). Click a swatch to copy hex.</p>
      $colorCards
    </section>
    <section>
      <h2>Typography</h2>
      <div class="card">$typographyHtml</div>
    </section>
    <section>
      <h2>Layout & Shape</h2>
      <div class="card">$layoutHtml</div>
      <div class="card">$radiusHtml</div>
    </section>
    <section>
      <h2>Shadows</h2>
      <div class="card">$shadowsHtml</div>
    </section>
    <section>
      <h2>Visual Effects</h2>
      <div class="card">$effectsHtml</div>
    </section>
    <section>
      <h2>Components & Assets</h2>
      <div class="card">$componentsHtml</div>
    </section>
    <section>
      <h2>Advanced Tokens</h2>
      <div class="card">$advancedHtml</div>
    </section>
  </div>
  <div id="toast" class="toast" aria-live="polite"></div>
  <script>
    (function () {
      const toast = document.getElementById('toast');
      let timer = null;
      function showToast(msg) {
        toast.textContent = msg;
        toast.classList.add('show');
        clearTimeout(timer);
        timer = setTimeout(() => toast.classList.remove('show'), 1400);
      }
      document.querySelectorAll('.swatch[data-hex]').forEach((el) => {
        el.addEventListener('click', async () => {
          const hex = el.getAttribute('data-hex');
          if (!hex) return;
          try {
            await navigator.clipboard.writeText(hex);
            showToast('Copied ' + hex);
          } catch (_) {
            showToast('Copy failed');
          }
        });
      });
    })();
  </script>
</body>
</html>
''';
}

String _buildTypographyHtml(models.DesignSystem ds) {
  final t = ds.typography;
  final weights = TokenDisplayOrder.sortedFontWeights(t.fontWeights)
      .map((e) => '<span class="chip-pill">${_escapeHtml(e.key)}: ${_escapeHtml(e.value.toString())}</span>')
      .join('');
  final sizesRows = TokenDisplayOrder.sortedFontSizes(t.fontSizes)
      .map((e) => '<tr><td><code>${_escapeHtml(e.key)}</code></td><td>${_escapeHtml(e.value.value.toString())}</td><td>${_escapeHtml(e.value.lineHeight.toString())}</td></tr>')
      .join('');
  final stylesRows = TokenDisplayOrder.sortedTextStyles(t.textStyles)
      .map((e) => '<tr><td><code>${_escapeHtml(e.key)}</code></td><td>Sample in ${_escapeHtml(e.key)}</td></tr>')
      .join('');
  final typoVisuals = buildTypographyVisualsHtml(t, _escapeHtml);
  return '''
<p class="lead">Primary: <strong>${_escapeHtml(t.fontFamily.primary)}</strong> · Fallback: ${_escapeHtml(t.fontFamily.fallback)}</p>
${weights.isEmpty ? '<p class="lead">No font weights defined.</p>' : '<div class="chips">$weights</div>'}
<h3 class="doc-data-h">Font sizes (data)</h3>
${sizesRows.isEmpty ? '<p class="lead">No font sizes defined.</p>' : '<table><thead><tr><th>Token</th><th>Size</th><th>Line Height</th></tr></thead><tbody>$sizesRows</tbody></table>'}
<h3 class="doc-data-h">Text styles (data)</h3>
${stylesRows.isEmpty ? '<p class="lead">No text styles defined.</p>' : '<table><thead><tr><th>Style</th><th>Sample label</th></tr></thead><tbody>$stylesRows</tbody></table>'}
$typoVisuals
''';
}

String _buildGridBreakpointsHtml(models.DesignSystem ds) {
  final bp = ds.grid.breakpoints;
  if (bp.isEmpty) return '';
  final sorted = bp.entries.toList()
    ..sort((a, b) => TokenDisplayOrder.naturalCompare(a.key, b.key));
  final rows = sorted
      .map((e) => '<tr><td><code>${_escapeHtml(e.key)}</code></td><td>${_escapeHtml(e.value)}</td></tr>')
      .join('');
  return '<h4>Breakpoints</h4><table><thead><tr><th>Name</th><th>Width</th></tr></thead><tbody>$rows</tbody></table>';
}

String _buildLayoutHtml(models.DesignSystem ds) {
  final spacingRows = TokenDisplayOrder.sortedStringValuesByPx(ds.spacing.values)
      .map((e) => '<tr><td><code>${_escapeHtml(e.key)}</code></td><td>${_escapeHtml(e.value)}</td></tr>')
      .join('');
  final scaleLine = ds.spacing.scale.isEmpty
      ? ''
      : '<p class="lead">Spacing scale (steps): <code>${_escapeHtml(ds.spacing.scale.join(', '))}</code></p>';
  final spacingVis = buildSpacingVisualHtml(ds, _escapeHtml);
  final gridVis = buildGridVisualHtml(ds.grid, _escapeHtml);
  return '''
<h3>Spacing</h3>
$scaleLine
${spacingRows.isEmpty ? '<p class="lead">No spacing tokens defined.</p>' : '<table><thead><tr><th>Token</th><th>Value</th></tr></thead><tbody>$spacingRows</tbody></table>'}
$spacingVis
<h3>Grid</h3>
<p class="lead">Columns: <strong>${_escapeHtml(ds.grid.columns.toString())}</strong> · Gutter: <strong>${_escapeHtml(ds.grid.gutter)}</strong> · Margin: <strong>${_escapeHtml(ds.grid.margin)}</strong></p>
${_buildGridBreakpointsHtml(ds)}
$gridVis
''';
}

String _buildRadiusHtml(models.DesignSystem ds) {
  final rows = [
    ('none', ds.borderRadius.none),
    ('sm', ds.borderRadius.sm),
    ('base', ds.borderRadius.base),
    ('md', ds.borderRadius.md),
    ('lg', ds.borderRadius.lg),
    ('xl', ds.borderRadius.xl),
    ('full', ds.borderRadius.full),
  ]
      .map((e) => '<tr><td><code>${_escapeHtml(e.$1)}</code></td><td>${_escapeHtml(e.$2)}</td></tr>')
      .join('');
  final radiusVis = buildRadiusVisualHtml(ds.borderRadius, _escapeHtml);
  return '<h3>Border Radius</h3><table><thead><tr><th>Token</th><th>Value</th></tr></thead><tbody>$rows</tbody></table>$radiusVis';
}

String _buildShadowsHtml(models.DesignSystem ds) {
  final rows = TokenDisplayOrder.sortedShadows(ds.shadows.values)
      .map((e) => '<tr><td><code>${_escapeHtml(e.key)}</code></td><td>${_escapeHtml(e.value.value.toString())}</td></tr>')
      .join('');
  final vis = buildShadowsVisualHtml(ds.shadows, _escapeHtml);
  if (rows.isEmpty) return '<p class="lead">No shadows defined.</p>';
  return '<table><thead><tr><th>Token</th><th>Value</th></tr></thead><tbody>$rows</tbody></table>$vis';
}

String _buildEffectsHtml(models.DesignSystem ds) {
  final glassRows = TokenDisplayOrder.sortedDynamicMap(ds.effects.glassMorphism ?? {})
      .map((e) => '<tr><td><code>${_escapeHtml(e.key)}</code></td><td>${_escapeHtml(e.value.toString())}</td></tr>')
      .join('');
  final darkRows = TokenDisplayOrder.sortedDynamicMap(ds.effects.darkOverlay ?? {})
      .map((e) => '<tr><td><code>${_escapeHtml(e.key)}</code></td><td>${_escapeHtml(e.value.toString())}</td></tr>')
      .join('');
  final vis = buildEffectsVisualHtml(ds.effects, _escapeHtml);
  if (glassRows.isEmpty && darkRows.isEmpty) return '<p class="lead">No effects defined.</p>';
  return '''
<h3>Glass Morphism</h3>
${glassRows.isEmpty ? '<p class="lead">Not defined.</p>' : '<table><thead><tr><th>Key</th><th>Value</th></tr></thead><tbody>$glassRows</tbody></table>'}
<h3>Dark Overlay</h3>
${darkRows.isEmpty ? '<p class="lead">Not defined.</p>' : '<table><thead><tr><th>Key</th><th>Value</th></tr></thead><tbody>$darkRows</tbody></table>'}
$vis
''';
}

String _buildComponentsHtml(models.DesignSystem ds) {
  final sections = <String>[];
  void addMapSection(String title, String categoryKey, Map<String, dynamic>? map, {required bool alerts}) {
    if (map == null || map.isEmpty) return;
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
    final rows = entries.map((e) {
      final val = e.value;
      final desc = (val is Map && val['description'] != null) ? val['description'].toString() : val.toString();
      return '<tr><td><code>${_escapeHtml(e.key)}</code></td><td>${_escapeHtml(desc)}</td></tr>';
    }).join('');
    final visuals = buildComponentRowsHtml(categoryKey, map, alerts: alerts, esc: _escapeHtml);
    sections.add(
      '<h3>${_escapeHtml(title)}</h3>'
      '<p class="lead doc-data-h" style="margin-top:0;">Data</p>'
      '<table><thead><tr><th>Component</th><th>Description / value</th></tr></thead><tbody>$rows</tbody></table>'
      '<p class="lead doc-data-h">Visual preview</p>$visuals',
    );
  }

  addMapSection('Buttons', 'buttons', ds.components.buttons, alerts: false);
  addMapSection('Cards', 'cards', ds.components.cards, alerts: false);
  addMapSection('Inputs', 'inputs', ds.components.inputs, alerts: false);
  addMapSection('Navigation', 'navigation', ds.components.navigation, alerts: false);
  addMapSection('Avatars', 'avatars', ds.components.avatars, alerts: false);
  addMapSection('Modals', 'modals', ds.components.modals, alerts: false);
  addMapSection('Tables', 'tables', ds.components.tables, alerts: false);
  addMapSection('Progress', 'progress', ds.components.progress, alerts: false);
  addMapSection('Alerts', 'alerts', ds.components.alerts, alerts: true);

  final sortedIcons = List.of(ds.icons.projectIcons)
    ..sort((a, b) => TokenDisplayOrder.naturalCompare(a.label, b.label));
  final projectIconRows = sortedIcons
      .map((e) => '<tr><td><code>${_escapeHtml(e.label)}</code></td><td>0x${_escapeHtml(e.codePoint.toRadixString(16))}</td></tr>')
      .join('');
  final projectVis = buildProjectIconsVisualHtml(ds, _escapeHtml);
  if (projectIconRows.isNotEmpty) {
    sections.add(
      '<h3>Project Icons</h3><p class="lead">Material icons (requires Material Icons webfont).</p>'
      '<table><thead><tr><th>Label</th><th>Code point</th></tr></thead><tbody>$projectIconRows</tbody></table>$projectVis',
    );
  }
  final iconRows = TokenDisplayOrder.sortedStringValuesByPx(ds.icons.sizes)
      .map((e) => '<tr><td><code>${_escapeHtml(e.key)}</code></td><td>${_escapeHtml(e.value.toString())}</td></tr>')
      .join('');
  final iconSzVis = buildIconSizesVisualHtml(ds, _escapeHtml);
  if (iconRows.isNotEmpty) {
    sections.add('<h3>Icon Sizes</h3><table><thead><tr><th>Token</th><th>Size</th></tr></thead><tbody>$iconRows</tbody></table>$iconSzVis');
  }
  return sections.isEmpty ? '<p class="lead">No components or icon sizes defined.</p>' : sections.join('\n');
}

String _buildAdvancedHtml(models.DesignSystem ds) {
  final gradientRows = TokenDisplayOrder.sortedGradients(ds.gradients.values)
      .map((e) => '<tr><td><code>${_escapeHtml(e.key)}</code></td><td>${_escapeHtml(e.value.colors.join(' → '))}</td></tr>')
      .join('');
  final roleRows = TokenDisplayOrder.sortedRoles(ds.roles.values)
      .map((e) => '<tr><td><code>${_escapeHtml(e.key)}</code></td><td>${_escapeHtml(e.value.primaryColor)}</td></tr>')
      .join('');

  final st = ds.semanticTokens;
  final semanticRowParts = <String>[];
  void addSemanticRows(String category, Map<String, dynamic> map) {
    for (final e in TokenDisplayOrder.sortedSemanticTokens(map, category)) {
      final value = e.value;
      final rendered = value is Map
          ? (value['baseTokenReference']?.toString() ?? value['reference']?.toString() ?? value.toString())
          : value.toString();
      semanticRowParts.add(
        '<tr><td>${_escapeHtml(category)}</td><td><code>${_escapeHtml(e.key)}</code></td><td>${_escapeHtml(rendered)}</td></tr>',
      );
    }
  }

  addSemanticRows('color', st.color);
  addSemanticRows('typography', st.typography);
  addSemanticRows('spacing', st.spacing);
  addSemanticRows('shadow', st.shadow);
  addSemanticRows('borderRadius', st.borderRadius);
  final semanticRows = semanticRowParts.join('');

  final durationRows = TokenDisplayOrder.sortedMotionDurations(ds.motionTokens.duration)
      .map((e) => '<tr><td>duration</td><td><code>${_escapeHtml(e.key)}</code></td><td>${_escapeHtml(e.value)}</td></tr>')
      .join('');
  final easingRows = TokenDisplayOrder.sortedMotionEasing(ds.motionTokens.easing)
      .map((e) => '<tr><td>easing</td><td><code>${_escapeHtml(e.key)}</code></td><td>${_escapeHtml(e.value)}</td></tr>')
      .join('');
  final motionRows = '$durationRows$easingRows';

  final gradVis = buildGradientVisualsHtml(ds, _escapeHtml);
  final roleVis = buildRolesVisualHtml(ds, _escapeHtml);

  return '''
<h3>Gradients</h3>
${gradientRows.isEmpty ? '<p class="lead">No gradients defined.</p>' : '<table><thead><tr><th>Name</th><th>Colors</th></tr></thead><tbody>$gradientRows</tbody></table>'}
$gradVis
<h3>Roles</h3>
${roleRows.isEmpty ? '<p class="lead">No roles defined.</p>' : '<table><thead><tr><th>Role</th><th>Primary Color</th></tr></thead><tbody>$roleRows</tbody></table>'}
$roleVis
<h3>Semantic Tokens</h3>
${semanticRows.isEmpty ? '<p class="lead">No semantic tokens defined.</p>' : '<table><thead><tr><th>Group</th><th>Token</th><th>Reference</th></tr></thead><tbody>$semanticRows</tbody></table>'}
<h3>Motion Tokens</h3>
${motionRows.isEmpty ? '<p class="lead">No motion tokens defined.</p>' : '<table><thead><tr><th>Group</th><th>Token</th><th>Value</th></tr></thead><tbody>$motionRows</tbody></table>'}
''';
}

String _escapeHtml(String input) {
  return input
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&#39;');
}
