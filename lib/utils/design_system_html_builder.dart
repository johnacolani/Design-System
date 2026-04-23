import '../models/design_system.dart' as models;

String buildDesignSystemHtml(models.DesignSystem ds) {
  final colors = _collectColorEntries(ds);
  final colorCards = colors.isEmpty
      ? '<p class="lead">No color tokens found.</p>'
      : colors
          .map((e) => '''
<div class="swatch" data-hex="${_escapeHtml(e.$2)}" title="Click to copy ${_escapeHtml(e.$2)}">
  <div class="chip" style="background:${_escapeHtml(e.$2)}"></div>
  <div class="lbl">
    <strong>${_escapeHtml(e.$1)}</strong>
    ${_escapeHtml(e.$2)}
  </div>
</div>''')
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
      <p class="lead">Click any color in app preview to copy hex. This exported HTML is a shareable snapshot.</p>
      <div class="card">
        <div class="grid-swatches">
          $colorCards
        </div>
      </div>
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
  final weights = t.fontWeights.entries
      .map((e) => '<span class="chip-pill">${_escapeHtml(e.key)}: ${_escapeHtml(e.value.toString())}</span>')
      .join('');
  final sizesRows = t.fontSizes.entries
      .map((e) => '<tr><td><code>${_escapeHtml(e.key)}</code></td><td>${_escapeHtml(e.value.value.toString())}</td><td>${_escapeHtml(e.value.lineHeight.toString())}</td></tr>')
      .join('');
  final stylesRows = t.textStyles.entries
      .map((e) => '<tr><td><code>${_escapeHtml(e.key)}</code></td><td>Sample in ${_escapeHtml(e.key)}</td></tr>')
      .join('');
  return '''
<p class="lead">Primary: <strong>${_escapeHtml(t.fontFamily.primary)}</strong> · Fallback: ${_escapeHtml(t.fontFamily.fallback)}</p>
${weights.isEmpty ? '<p class="lead">No font weights defined.</p>' : '<div class="chips">$weights</div>'}
<h3>Font Sizes</h3>
${sizesRows.isEmpty ? '<p class="lead">No font sizes defined.</p>' : '<table><thead><tr><th>Token</th><th>Size</th><th>Line Height</th></tr></thead><tbody>$sizesRows</tbody></table>'}
<h3>Text Styles</h3>
${stylesRows.isEmpty ? '<p class="lead">No text styles defined.</p>' : '<table><thead><tr><th>Style</th><th>Preview</th></tr></thead><tbody>$stylesRows</tbody></table>'}
''';
}

String _buildLayoutHtml(models.DesignSystem ds) {
  final spacingRows = ds.spacing.values.entries
      .map((e) => '<tr><td><code>${_escapeHtml(e.key)}</code></td><td>${_escapeHtml(e.value)}</td></tr>')
      .join('');
  return '''
<h3>Spacing</h3>
${spacingRows.isEmpty ? '<p class="lead">No spacing tokens defined.</p>' : '<table><thead><tr><th>Token</th><th>Value</th></tr></thead><tbody>$spacingRows</tbody></table>'}
<h3>Grid</h3>
<p class="lead">Columns: <strong>${_escapeHtml(ds.grid.columns.toString())}</strong> · Gutter: <strong>${_escapeHtml(ds.grid.gutter)}</strong></p>
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
  return '<h3>Border Radius</h3><table><thead><tr><th>Token</th><th>Value</th></tr></thead><tbody>$rows</tbody></table>';
}

String _buildShadowsHtml(models.DesignSystem ds) {
  final rows = ds.shadows.values.entries
      .map((e) => '<tr><td><code>${_escapeHtml(e.key)}</code></td><td>${_escapeHtml(e.value.value.toString())}</td></tr>')
      .join('');
  return rows.isEmpty
      ? '<p class="lead">No shadows defined.</p>'
      : '<table><thead><tr><th>Token</th><th>Value</th></tr></thead><tbody>$rows</tbody></table>';
}

String _buildEffectsHtml(models.DesignSystem ds) {
  final glassRows = (ds.effects.glassMorphism ?? {}).entries
      .map((e) => '<tr><td><code>${_escapeHtml(e.key)}</code></td><td>${_escapeHtml(e.value.toString())}</td></tr>')
      .join('');
  final darkRows = (ds.effects.darkOverlay ?? {}).entries
      .map((e) => '<tr><td><code>${_escapeHtml(e.key)}</code></td><td>${_escapeHtml(e.value.toString())}</td></tr>')
      .join('');
  if (glassRows.isEmpty && darkRows.isEmpty) return '<p class="lead">No effects defined.</p>';
  return '''
<h3>Glass Morphism</h3>
${glassRows.isEmpty ? '<p class="lead">Not defined.</p>' : '<table><thead><tr><th>Key</th><th>Value</th></tr></thead><tbody>$glassRows</tbody></table>'}
<h3>Dark Overlay</h3>
${darkRows.isEmpty ? '<p class="lead">Not defined.</p>' : '<table><thead><tr><th>Key</th><th>Value</th></tr></thead><tbody>$darkRows</tbody></table>'}
''';
}

String _buildComponentsHtml(models.DesignSystem ds) {
  final sections = <String>[];
  void addMapSection(String title, Map<String, dynamic>? map) {
    if (map == null || map.isEmpty) return;
    final rows = map.entries.map((e) {
      final val = e.value;
      final desc = (val is Map && val['description'] != null) ? val['description'].toString() : val.toString();
      return '<tr><td><code>${_escapeHtml(e.key)}</code></td><td>${_escapeHtml(desc)}</td></tr>';
    }).join('');
    sections.add('<h3>${_escapeHtml(title)}</h3><table><thead><tr><th>Component</th><th>Description</th></tr></thead><tbody>$rows</tbody></table>');
  }

  addMapSection('Buttons', ds.components.buttons);
  addMapSection('Cards', ds.components.cards);
  addMapSection('Inputs', ds.components.inputs);
  addMapSection('Navigation', ds.components.navigation);
  addMapSection('Avatars', ds.components.avatars);
  addMapSection('Modals', ds.components.modals);
  addMapSection('Tables', ds.components.tables);
  addMapSection('Progress', ds.components.progress);
  addMapSection('Alerts', ds.components.alerts);

  final iconRows = ds.icons.sizes.entries
      .map((e) => '<tr><td><code>${_escapeHtml(e.key)}</code></td><td>${_escapeHtml(e.value.toString())}</td></tr>')
      .join('');
  if (iconRows.isNotEmpty) {
    sections.add('<h3>Icon Sizes</h3><table><thead><tr><th>Token</th><th>Size</th></tr></thead><tbody>$iconRows</tbody></table>');
  }
  return sections.isEmpty ? '<p class="lead">No components or icon sizes defined.</p>' : sections.join('\n');
}

String _buildAdvancedHtml(models.DesignSystem ds) {
  final gradientRows = ds.gradients.values.entries
      .map((e) => '<tr><td><code>${_escapeHtml(e.key)}</code></td><td>${_escapeHtml(e.value.colors.join(' → '))}</td></tr>')
      .join('');
  final roleRows = ds.roles.values.entries
      .map((e) => '<tr><td><code>${_escapeHtml(e.key)}</code></td><td>${_escapeHtml(e.value.primaryColor)}</td></tr>')
      .join('');
  final semanticRows = _flattenMaps({
    'color': ds.semanticTokens.color,
    'typography': ds.semanticTokens.typography,
    'spacing': ds.semanticTokens.spacing,
    'shadow': ds.semanticTokens.shadow,
    'borderRadius': ds.semanticTokens.borderRadius,
  });
  final motionRows = _flattenMaps({
    'duration': ds.motionTokens.duration,
    'easing': ds.motionTokens.easing,
  });

  return '''
<h3>Gradients</h3>
${gradientRows.isEmpty ? '<p class="lead">No gradients defined.</p>' : '<table><thead><tr><th>Name</th><th>Colors</th></tr></thead><tbody>$gradientRows</tbody></table>'}
<h3>Roles</h3>
${roleRows.isEmpty ? '<p class="lead">No roles defined.</p>' : '<table><thead><tr><th>Role</th><th>Primary Color</th></tr></thead><tbody>$roleRows</tbody></table>'}
<h3>Semantic Tokens</h3>
${semanticRows.isEmpty ? '<p class="lead">No semantic tokens defined.</p>' : '<table><thead><tr><th>Group</th><th>Token</th><th>Reference</th></tr></thead><tbody>$semanticRows</tbody></table>'}
<h3>Motion Tokens</h3>
${motionRows.isEmpty ? '<p class="lead">No motion tokens defined.</p>' : '<table><thead><tr><th>Group</th><th>Token</th><th>Value</th></tr></thead><tbody>$motionRows</tbody></table>'}
''';
}

String _flattenMaps(Map<String, Map<String, dynamic>> grouped) {
  final rows = <String>[];
  for (final g in grouped.entries) {
    for (final e in g.value.entries) {
      final value = e.value;
      String rendered;
      if (value is Map) {
        rendered = value['baseTokenReference']?.toString() ?? value['reference']?.toString() ?? value.toString();
      } else {
        rendered = value.toString();
      }
      rows.add('<tr><td>${_escapeHtml(g.key)}</td><td><code>${_escapeHtml(e.key)}</code></td><td>${_escapeHtml(rendered)}</td></tr>');
    }
  }
  return rows.join('');
}

List<(String, String)> _collectColorEntries(models.DesignSystem ds) {
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
  final out = <(String, String)>[];
  for (final m in maps) {
    if (m == null) continue;
    for (final e in m.entries) {
      final val = e.value;
      if (val is Map && val['value'] != null) {
        out.add((e.key, _toHex(val['value'].toString())));
      } else if (val is! Map) {
        out.add((e.key, _toHex(val.toString())));
      }
    }
  }
  return out;
}

String _toHex(String raw) {
  final h = raw.replaceAll('#', '').trim().toUpperCase();
  if (h.length == 6) return '#$h';
  if (h.length == 8) return '#${h.substring(2)}';
  return raw;
}

String _escapeHtml(String input) {
  return input
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&#39;');
}
