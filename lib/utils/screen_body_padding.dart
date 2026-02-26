import 'package:flutter/material.dart';

/// Wraps screen body content with the same horizontal padding as the dashboard
/// (15% of width, clamped between 24 and 80).
class ScreenBodyPadding extends StatelessWidget {
  const ScreenBodyPadding({
    super.key,
    required this.child,
    this.verticalPadding,
  });

  final Widget child;
  final double? verticalPadding;

  static double horizontalPaddingFor(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return (width * 0.15).clamp(24.0, 80.0);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final horizontal = (width * 0.15).clamp(24.0, 80.0);
    final vertical = verticalPadding ?? 16.0;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        horizontal,
        vertical > 0 ? vertical : 0,
        horizontal,
        vertical > 0 ? vertical : 0,
      ),
      child: child,
    );
  }
}
