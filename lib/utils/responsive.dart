import 'package:flutter/material.dart';

/// Responsive breakpoints
class Breakpoints {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
}

/// Responsive utility class
class Responsive {
  final BuildContext context;
  
  Responsive(this.context);
  
  /// Get screen width
  double get width => MediaQuery.of(context).size.width;
  
  /// Get screen height
  double get height => MediaQuery.of(context).size.height;
  
  /// Check if screen is mobile
  bool get isMobile => width < Breakpoints.mobile;
  
  /// Check if screen is tablet
  bool get isTablet => width >= Breakpoints.mobile && width < Breakpoints.desktop;
  
  /// Check if screen is desktop
  bool get isDesktop => width >= Breakpoints.desktop;
  
  /// Get responsive padding
  EdgeInsets get padding => EdgeInsets.symmetric(
    horizontal: isMobile ? 16 : isTablet ? 24 : 32,
    vertical: isMobile ? 12 : 16,
  );
  
  /// Get responsive margin
  EdgeInsets get margin => EdgeInsets.all(isMobile ? 16 : 24);
  
  /// Get responsive font size multiplier
  double get fontSizeMultiplier => isMobile ? 0.9 : isTablet ? 1.0 : 1.1;
  
  /// Get responsive grid columns
  int get gridColumns => isMobile ? 2 : isTablet ? 3 : 4;
}

/// Extension for easy access
extension ResponsiveExtension on BuildContext {
  Responsive get responsive => Responsive(this);
}
