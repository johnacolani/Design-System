import '../models/design_system.dart' as models;

/// Stable ordering for design-token lists: numeric / px ordering where it matters,
/// then [naturalCompare] on keys so `dark2` sorts before `dark10`.
class TokenDisplayOrder {
  TokenDisplayOrder._();

  /// Flat keys from [TokenEngine.buildTokenMap]: natural sort so exports match UI grouping.
  static List<MapEntry<String, dynamic>> sortedFlatTokenEntries(Map<String, dynamic> map) {
    final list = map.entries.toList()
      ..sort((a, b) => naturalCompare(a.key, b.key));
    return list;
  }

  /// Spacing values, grid breakpoints, icon sizes — sort by pixel magnitude, then key.
  static List<MapEntry<String, String>> sortedStringValuesByPx(Map<String, String> map) {
    final list = map.entries.toList()
      ..sort((a, b) {
        final c = _parsePxLoose(a.value).compareTo(_parsePxLoose(b.value));
        if (c != 0) return c;
        return naturalCompare(a.key, b.key);
      });
    return list;
  }

  static List<MapEntry<String, int>> sortedFontWeights(Map<String, int> map) {
    final list = map.entries.toList()
      ..sort((a, b) {
        final c = a.value.compareTo(b.value);
        if (c != 0) return c;
        return naturalCompare(a.key, b.key);
      });
    return list;
  }

  static List<MapEntry<String, models.FontSize>> sortedFontSizes(Map<String, models.FontSize> map) {
    final list = map.entries.toList()
      ..sort((a, b) {
        final c = _parsePxLoose(a.value.value).compareTo(_parsePxLoose(b.value.value));
        if (c != 0) return c;
        return naturalCompare(a.key, b.key);
      });
    return list;
  }

  static List<MapEntry<String, models.TextStyle>> sortedTextStyles(Map<String, models.TextStyle> map) {
    final list = map.entries.toList()
      ..sort((a, b) {
        final c = _parsePxLoose(a.value.fontSize).compareTo(_parsePxLoose(b.value.fontSize));
        if (c != 0) return c;
        final w = a.value.fontWeight.compareTo(b.value.fontWeight);
        if (w != 0) return w;
        return naturalCompare(a.key, b.key);
      });
    return list;
  }

  static List<MapEntry<String, String>> sortedMotionDurations(Map<String, String> map) {
    final list = map.entries.toList()
      ..sort((a, b) {
        final c = _parseDurationMs(a.value).compareTo(_parseDurationMs(b.value));
        if (c != 0) return c;
        return naturalCompare(a.key, b.key);
      });
    return list;
  }

  static List<MapEntry<String, String>> sortedMotionEasing(Map<String, String> map) {
    final list = map.entries.toList()
      ..sort((a, b) => naturalCompare(a.key, b.key));
    return list;
  }

  /// Nested maps (component props, effect fields): alphabetical keys with numeric chunks as numbers.
  static List<MapEntry<String, dynamic>> sortedDynamicMap(Map<String, dynamic> map) {
    final list = map.entries.toList()
      ..sort((a, b) => naturalCompare(a.key, b.key));
    return list;
  }

  static List<MapEntry<String, models.GradientValue>> sortedGradients(Map<String, models.GradientValue> map) {
    final list = map.entries.toList()
      ..sort((a, b) => naturalCompare(a.key, b.key));
    return list;
  }

  static List<MapEntry<String, models.ShadowValue>> sortedShadows(Map<String, models.ShadowValue> map) {
    final list = map.entries.toList()
      ..sort((a, b) => naturalCompare(a.key, b.key));
    return list;
  }

  static List<MapEntry<String, models.RoleValue>> sortedRoles(Map<String, models.RoleValue> map) {
    final list = map.entries.toList()
      ..sort((a, b) => naturalCompare(a.key, b.key));
    return list;
  }

  /// Semantic token maps: order mostly by key; spacing / radius try to follow referenced px when obvious.
  static List<MapEntry<String, dynamic>> sortedSemanticTokens(
    Map<String, dynamic> map,
    String category,
  ) {
    final list = map.entries.toList();
    switch (category) {
      case 'spacing':
      case 'borderRadius':
        list.sort((a, b) {
          final c = _semanticSortHint(a.value).compareTo(_semanticSortHint(b.value));
          if (c != 0) return c;
          return naturalCompare(a.key, b.key);
        });
        break;
      default:
        list.sort((a, b) => naturalCompare(a.key, b.key));
    }
    return list;
  }

  static double _semanticSortHint(dynamic v) {
    if (v is Map) {
      final ref = v['baseTokenReference']?.toString() ?? '';
      final tail = RegExp(r'(\d+)$').firstMatch(ref);
      if (tail != null) {
        final n = double.tryParse(tail.group(1)!);
        if (n != null) return n;
      }
      final fromPx = _parsePxLoose(ref);
      if (fromPx != 0) return fromPx;
    }
    return _parsePxLoose(v.toString());
  }

  static int naturalCompare(String a, String b) {
    final aParts = _splitForNaturalSort(a.toLowerCase());
    final bParts = _splitForNaturalSort(b.toLowerCase());
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

  static List<String> _splitForNaturalSort(String s) {
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

  static double _parsePxLoose(String s) {
    final t = s.trim().toLowerCase();
    if (t.isEmpty) return 0;
    final n = double.tryParse(t.replaceAll('px', '').replaceAll('rem', '').trim());
    return n ?? 0;
  }

  static double _parseDurationMs(String s) {
    var t = s.trim().toLowerCase();
    if (t.endsWith('ms')) {
      return double.tryParse(t.replaceAll('ms', '').trim()) ?? 0;
    }
    if (t.endsWith('s')) {
      final sec = double.tryParse(t.replaceAll('s', '').trim());
      return (sec ?? 0) * 1000;
    }
    return double.tryParse(t) ?? 0;
  }
}
