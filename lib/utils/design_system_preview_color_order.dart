import '../models/design_system.dart' as models;
import '../services/color_palette_service.dart';
import 'token_display_order.dart';

/// Groups color tokens in the same order as [PreviewScreen] color documentation.
class PreviewColorSection {
  PreviewColorSection({required this.title, required this.entries});
  final String title;
  final List<(String name, String hex)> entries;
}

/// Normalizes hex for display/sorting (matches Preview / HTML export).
String previewColorHex(String raw) {
  final h = raw.replaceAll('#', '').trim().toUpperCase();
  if (h.length == 6) return '#$h';
  if (h.length == 8) return '#${h.substring(2)}';
  return raw;
}

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

Map<String, String> collectAllColorTokens(models.DesignSystem ds) {
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
      out[e.$1] = previewColorHex(e.$2);
    }
  }
  return out;
}

List<(String name, String hex)> _coreSurfaceEntries(Map<String, String> allTokens) {
  const preferred = <String>[
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

int _comparePreviewSwatchesByLuminance((String, String) a, (String, String) b) {
  final la = ColorPaletteService.luminanceFromHexString(previewColorHex(a.$2));
  final lb = ColorPaletteService.luminanceFromHexString(previewColorHex(b.$2));
  if (la != null && lb != null) {
    final c = la.compareTo(lb);
    if (c != 0) return c;
  } else if (la != null) {
    return -1;
  } else if (lb != null) {
    return 1;
  }
  return TokenDisplayOrder.naturalCompare(a.$1, b.$1);
}

int _compareSemanticPreviewEntries((String, String) a, (String, String) b) {
  final ra = TokenDisplayOrder.semanticColorFamilyRank(a.$1);
  final rb = TokenDisplayOrder.semanticColorFamilyRank(b.$1);
  if (ra != rb) return ra.compareTo(rb);
  return _comparePreviewSwatchesByLuminance(a, b);
}

List<(String name, String hex)> _rampEntries(Map<String, String> allTokens, String prefix) {
  final list = <(String name, String hex)>[];
  for (final e in allTokens.entries) {
    final darkMatch = RegExp('^${RegExp.escape(prefix)}_dark(\\d+)\$').firstMatch(e.key);
    if (darkMatch != null) {
      list.add((e.key, e.value));
      continue;
    }
    final lightMatch = RegExp('^${RegExp.escape(prefix)}_light(\\d+)\$').firstMatch(e.key);
    if (lightMatch != null) {
      list.add((e.key, e.value));
      continue;
    }
    if (e.key == prefix) {
      list.add((e.key, e.value));
    }
  }
  list.sort((a, b) {
    final la = ColorPaletteService.luminanceFromHexString(previewColorHex(a.$2));
    final lb = ColorPaletteService.luminanceFromHexString(previewColorHex(b.$2));
    if (la != null && lb != null) {
      final c = la.compareTo(lb);
      if (c != 0) return c;
    } else if (la != null) {
      return -1;
    } else if (lb != null) {
      return 1;
    }
    return TokenDisplayOrder.naturalCompare(a.$1, b.$1);
  });
  return list;
}

/// Same sections and ordering as the Preview "Colors" doc (Core → ramps → semantic).
List<PreviewColorSection> buildPreviewOrderedColorSections(models.DesignSystem ds) {
  final allTokens = collectAllColorTokens(ds);
  if (allTokens.isEmpty) return [];

  final semanticEntries = _colorMapToEntries(ds.colors.semantic);
  final semanticKeySet = ds.colors.semantic.keys.map((k) => k.toString()).toSet();

  final coreEntries = _coreSurfaceEntries(allTokens);
  final primaryRamp = _rampEntries(allTokens, 'primary');
  final t1Ramp = _rampEntries(allTokens, 'tetradic_1');
  final t2Ramp = _rampEntries(allTokens, 'tetradic_2');
  final t4Ramp = _rampEntries(allTokens, 'tetradic_4');
  final triadic3Ramp = _rampEntries(allTokens, 'triadic_3');

  bool fallbackKey(String key) {
    final k = key.toLowerCase();
    return k.startsWith('triadic_') ||
        k.startsWith('analogous') ||
        k.startsWith('secondary') ||
        k.startsWith('success') ||
        k.startsWith('warning') ||
        k.startsWith('error') ||
        k.startsWith('info');
  }

  final fallback = allTokens.entries
      .where((e) => !semanticKeySet.contains(e.key) && fallbackKey(e.key))
      .map((e) => (e.key, e.value))
      .toList()
    ..sort(_comparePreviewSwatchesByLuminance);

  final out = <PreviewColorSection>[];

  out.add(
    PreviewColorSection(
      title: 'Core & surfaces',
      entries: coreEntries.isEmpty
          ? allTokens.entries.take(7).map((e) => (e.key, e.value)).toList()
          : coreEntries,
    ),
  );

  if (primaryRamp.isNotEmpty) {
    out.add(
      PreviewColorSection(
        title: 'Primary (teal) ramp — primary_dark1...10 / primary_light1...10',
        entries: primaryRamp,
      ),
    );
  }
  if (t1Ramp.isNotEmpty) {
    out.add(PreviewColorSection(title: 'Coral — teal complement (CTA / highlights)', entries: t1Ramp));
  }
  if (t2Ramp.isNotEmpty) {
    out.add(PreviewColorSection(title: 'Purple — secondary', entries: t2Ramp));
  }
  if (t4Ramp.isNotEmpty) {
    out.add(PreviewColorSection(title: 'Gold — purple complement (soft accent)', entries: t4Ramp));
  }
  if (triadic3Ramp.isNotEmpty) {
    out.add(PreviewColorSection(title: 'Triadic 3 ramp', entries: triadic3Ramp));
  }
  if (fallback.isNotEmpty) {
    out.add(PreviewColorSection(title: 'Additional ramps', entries: fallback.take(22).toList()));
  }
  if (semanticEntries.isNotEmpty) {
    final sortedSemantic = List<(String, String)>.from(semanticEntries)..sort(_compareSemanticPreviewEntries);
    out.add(PreviewColorSection(title: 'Semantic colors', entries: sortedSemantic));
  }

  return out;
}

/// Same ordering as Preview → Components → Alerts (info → success → warning → error).
int alertVariantRankForExport(dynamic componentData) {
  if (componentData is! Map) return 4;
  final m = Map<String, dynamic>.from(componentData);
  final v = (m['alertVariant'] ?? m['variant'] ?? 'info').toString().toLowerCase().trim();
  switch (v) {
    case 'info':
      return 0;
    case 'success':
      return 1;
    case 'warning':
      return 2;
    case 'error':
    case 'danger':
      return 3;
    default:
      return 4;
  }
}
