import 'package:flutter/material.dart';

/// Renders a Material icon glyph by [codePoint] without using non-const
/// [IconData] (which would block release web icon tree shaking).
///
/// Uses the full `MaterialIconsDynamic` font declared in `pubspec.yaml`, so
/// arbitrary code points from saved project icons render correctly while static
/// [Icon]/[Icons] use the subsetted default `MaterialIcons` font.
class DynamicMaterialIcon extends StatelessWidget {
  const DynamicMaterialIcon({
    super.key,
    required this.codePoint,
    this.size,
    this.color,
    this.semanticLabel,
  });

  final int codePoint;
  final double? size;
  final Color? color;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final double iconSize = size ?? IconTheme.of(context).size ?? 24;
    final Color? effectiveColor = color ?? IconTheme.of(context).color;

    final Widget text = Text(
      String.fromCharCode(codePoint),
      style: TextStyle(
        fontFamily: 'MaterialIconsDynamic',
        fontSize: iconSize,
        color: effectiveColor,
        height: 1.0,
      ),
      textAlign: TextAlign.center,
    );

    final Widget child = semanticLabel == null
        ? text
        : Semantics(label: semanticLabel, child: text);

    return child;
  }
}
