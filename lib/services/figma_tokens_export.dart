import 'dart:convert';

import '../models/design_system.dart' as models;
import 'token_engine.dart';

/// Export design tokens in formats usable with **Figma** workflows:
/// - **Tokens Studio** (`exportTokensStudio`) — import JSON in [Tokens Studio for Figma](https://tokens.studio/).
/// - **W3C DTCG-style** (`exportW3cDtcg`) — `$value` / `$type` for tools that consume the design-token format.
class FigmaTokensExport {
  FigmaTokensExport._();

  /// Tokens Studio–compatible nested JSON (`global` set + metadata).
  /// In Figma: Plugins → Tokens Studio → Load from file / JSON, or sync via Git.
  static String exportTokensStudio(models.DesignSystem ds) {
    final global = <String, dynamic>{};
    final flat = TokenEngine.buildTokenMap(ds);

    for (final e in flat.entries) {
      final parts = e.key.split('.');
      if (parts.length < 2) continue;
      final tokenType = _tokensStudioType(parts, e.value);
      final leaf = <String, dynamic>{
        'value': _stringifyValue(e.value),
        'type': tokenType,
      };
      _insertNested(global, parts.sublist(1), leaf);
    }

    // Named gradients as composite (reference string; TS may treat as other)
    for (final e in ds.gradients.values.entries) {
      final g = e.value;
      final desc =
          '${g.type} ${g.direction} [${g.colors.join(', ')}] stops=${g.stops.join(',')}';
      _insertNested(global, ['gradient', _safeKey(e.key)], {
        'value': desc,
        'type': 'other',
      });
    }

    final doc = <String, dynamic>{
      '\$metadata': {
        'tokenSetOrder': ['global'],
        'version': '1.0',
        'source': 'Design System Builder export',
        'designSystem': ds.name,
      },
      '\$themes': <dynamic>[],
      'global': global,
    };

    return const JsonEncoder.withIndent('  ').convert(doc);
  }

  /// W3C Design Tokens Community Group style (flat groups, `$value` / `$type`).
  static String exportW3cDtcg(models.DesignSystem ds) {
    final groups = <String, dynamic>{};
    final flat = TokenEngine.buildTokenMap(ds);

    for (final e in flat.entries) {
      final group = e.key.split('.').first;
      groups.putIfAbsent(group, () => <String, dynamic>{});
      final path = e.key.split('.').skip(1).join('/');
      final w3cType = _w3cType(e.key, e.value);
      (groups[group] as Map<String, dynamic>)[path.replaceAll('.', '/')] = {
        '\$value': _stringifyValue(e.value),
        '\$type': w3cType,
      };
    }

    final doc = {
      '\$schema': 'https://design-tokens.github.io/format/v1/',
      'name': ds.name,
      'description': ds.description,
      'tokens': groups,
    };
    return const JsonEncoder.withIndent('  ').convert(doc);
  }

  static String _safeKey(String k) =>
      k.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');

  static String _stringifyValue(dynamic v) {
    if (v is Map) {
      return const JsonEncoder().convert(v);
    }
    return v?.toString() ?? '';
  }

  static void _insertNested(
    Map<String, dynamic> root,
    List<String> path,
    Map<String, dynamic> leaf,
  ) {
    if (path.isEmpty) return;
    dynamic cur = root;
    for (var i = 0; i < path.length; i++) {
      final p = path[i];
      if (i == path.length - 1) {
        if (cur is Map<String, dynamic>) {
          cur[p] = leaf;
        }
      } else {
        cur.putIfAbsent(p, () => <String, dynamic>{});
        cur = cur[p];
        if (cur is! Map<String, dynamic>) {
          return;
        }
      }
    }
  }

  /// Tokens Studio [type](https://docs.tokens.studio/technical/token-types) values.
  static String _tokensStudioType(List<String> parts, dynamic value) {
    final head = parts.isNotEmpty ? parts[0] : '';
    switch (head) {
      case 'color':
        return 'color';
      case 'spacing':
        return 'spacing';
      case 'radius':
        return 'borderRadius';
      case 'font':
        if (parts.length > 1) {
          switch (parts[1]) {
            case 'size':
              return 'fontSizes';
            case 'weight':
              return 'fontWeights';
            case 'lineHeight':
              return 'lineHeights';
            case 'family':
              return 'fontFamilies';
            case 'heading':
              return 'typography';
          }
        }
        return 'other';
      case 'shadow':
        return 'boxShadow';
      case 'motion':
        return 'other';
      case 'grid':
      case 'icon':
        return 'sizing';
      default:
        return 'other';
    }
  }

  static String _w3cType(String key, dynamic value) {
    if (key.startsWith('color.')) return 'color';
    if (key.startsWith('spacing.')) return 'dimension';
    if (key.startsWith('radius.')) return 'dimension';
    if (key.startsWith('font.size.') || key.startsWith('font.lineHeight.')) {
      return 'dimension';
    }
    if (key.startsWith('font.weight.')) return 'fontWeight';
    if (key.startsWith('font.family.')) return 'fontFamily';
    if (key.startsWith('shadow.')) return 'shadow';
    if (key.startsWith('motion.')) return 'duration';
    return 'other';
  }
}
