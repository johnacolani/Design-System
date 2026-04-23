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
