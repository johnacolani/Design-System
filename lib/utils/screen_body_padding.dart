import 'package:flutter/material.dart';

import 'responsive.dart';

/// Wraps screen body content with the same horizontal padding as the dashboard.
/// On **mobile** (< 600px) uses fixed 16px sides so token tables and forms keep
/// more usable width; on larger screens uses 15% clamped 24–80.
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
    if (width < Breakpoints.mobile) {
      return 16.0;
    }
    return (width * 0.15).clamp(24.0, 80.0);
  }

  @override
  Widget build(BuildContext context) {
    final horizontal = horizontalPaddingFor(context);
    
    // Default vertical padding doubled from 16 to 32
    final vertical = verticalPadding ?? 16.0;
    
    return Padding(
      padding: EdgeInsets.fromLTRB(
        horizontal,
        vertical,
        horizontal,
        vertical * 2, // Doubled bottom padding specifically
      ),
      child: child,
    );
  }
}
