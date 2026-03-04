import 'dart:convert';

import '../models/design_system.dart' as models;

/// Single source of truth for design values as tokens.
/// All design values are exposed as dot-notation tokens (e.g. color.primary.500, spacing.md).
/// Used by Material Design–style systems and for multi-platform export.
class TokenEngine {
  /// Build a flat map of token key → value from the design system.
  /// Keys use dot notation: color.primary.500, spacing.md, radius.sm, font.heading, etc.
  static Map<String, dynamic> buildTokenMap(models.DesignSystem ds) {
    final tokens = <String, dynamic>{};

    // color.*
    _addColorTokens(tokens, 'color.primary', ds.colors.primary);
    _addColorTokens(tokens, 'color.semantic', ds.colors.semantic);
    if (ds.colors.blue != null) _addColorTokens(tokens, 'color.blue', ds.colors.blue!);
    if (ds.colors.green != null) _addColorTokens(tokens, 'color.green', ds.colors.green!);
    if (ds.colors.red != null) _addColorTokens(tokens, 'color.red', ds.colors.red!);
    if (ds.colors.grey != null) _addColorTokens(tokens, 'color.grey', ds.colors.grey!);

    // spacing.*
    for (final e in ds.spacing.values.entries) {
      tokens['spacing.${e.key}'] = e.value;
    }

    // radius.* (alias for borderRadius)
    tokens['radius.none'] = ds.borderRadius.none;
    tokens['radius.sm'] = ds.borderRadius.sm;
    tokens['radius.base'] = ds.borderRadius.base;
    tokens['radius.md'] = ds.borderRadius.md;
    tokens['radius.lg'] = ds.borderRadius.lg;
    tokens['radius.xl'] = ds.borderRadius.xl;
    tokens['radius.full'] = ds.borderRadius.full;

    // font.* (typography)
    tokens['font.family.primary'] = ds.typography.fontFamily.primary;
    tokens['font.family.fallback'] = ds.typography.fontFamily.fallback;
    for (final e in ds.typography.fontWeights.entries) {
      tokens['font.weight.${e.key}'] = e.value;
    }
    for (final e in ds.typography.fontSizes.entries) {
      tokens['font.size.${e.key}'] = e.value.value;
      tokens['font.lineHeight.${e.key}'] = e.value.lineHeight;
    }
    for (final e in ds.typography.textStyles.entries) {
      final s = e.value;
      tokens['font.heading.${e.key}'] = {
        'fontFamily': s.fontFamily,
        'fontSize': s.fontSize,
        'fontWeight': s.fontWeight,
        'lineHeight': s.lineHeight,
        if (s.color != null) 'color': s.color,
      };
    }

    // shadow.*
    for (final e in ds.shadows.values.entries) {
      tokens['shadow.${e.key}'] = e.value.value;
    }

    // motion.*
    for (final e in ds.motionTokens.duration.entries) {
      tokens['motion.duration.${e.key}'] = e.value;
    }
    for (final e in ds.motionTokens.easing.entries) {
      tokens['motion.easing.${e.key}'] = e.value;
    }

    // grid.*
    tokens['grid.columns'] = ds.grid.columns;
    tokens['grid.gutter'] = ds.grid.gutter;
    tokens['grid.margin'] = ds.grid.margin;

    // icon.size.*
    for (final e in ds.icons.sizes.entries) {
      tokens['icon.size.${e.key}'] = e.value;
    }

    return tokens;
  }

  static void _addColorTokens(Map<String, dynamic> tokens, String prefix, Map<String, dynamic> colors) {
    if (colors.isEmpty) return;
    for (final e in colors.entries) {
      final v = e.value;
      final value = v is Map ? (v['value'] ?? v['hex'] ?? v) : v;
      tokens['$prefix.${e.key}'] = value is String ? value : value?.toString();
    }
  }

  /// Export tokens as a JSON object (single source of truth format).
  static String exportTokensAsJson(models.DesignSystem ds) {
    final map = buildTokenMap(ds);
    return const JsonEncoder.withIndent('  ').convert(map);
  }
}
