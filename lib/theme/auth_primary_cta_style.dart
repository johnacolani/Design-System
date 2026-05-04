import 'package:flutter/material.dart';

/// Shared gold primary CTA (Sign In / Sign Up / Sign up with Email) — visible on white;
/// hover uses [fillHover].
abstract final class AuthPrimaryCtaStyle {
  static const Color fill = Color(0xFFF2CD79);
  static const Color fillHover = Color(0xFFF1BF42);
  static const Color foreground = Color(0xFF1A1A1A);

  static ButtonStyle elevated({double verticalPadding = 16}) {
    return ButtonStyle(
      padding: WidgetStateProperty.all(
        EdgeInsets.symmetric(vertical: verticalPadding),
      ),
      elevation: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) return 0;
        if (states.contains(WidgetState.hovered) ||
            states.contains(WidgetState.pressed)) {
          return 3;
        }
        return 2;
      }),
      foregroundColor: WidgetStateProperty.all(foreground),
      iconColor: WidgetStateProperty.all(foreground),
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return fill.withValues(alpha: 0.5);
        }
        if (states.contains(WidgetState.hovered) ||
            states.contains(WidgetState.pressed)) {
          return fillHover;
        }
        return fill;
      }),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
