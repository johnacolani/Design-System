import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Service for checking color contrast and accessibility compliance
class ContrastCheckerService {
  /// Calculate relative luminance of a color (0.0 to 1.0)
  /// Based on WCAG 2.1 formula
  static double getRelativeLuminance(Color color) {
    final r = _linearizeColorComponent(color.red / 255.0);
    final g = _linearizeColorComponent(color.green / 255.0);
    final b = _linearizeColorComponent(color.blue / 255.0);
    
    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }

  /// Linearize color component for luminance calculation
  static double _linearizeColorComponent(double component) {
    if (component <= 0.03928) {
      return component / 12.92;
    } else {
      return math.pow((component + 0.055) / 1.055, 2.4).toDouble();
    }
  }

  /// Calculate contrast ratio between two colors
  /// Returns value between 1.0 (no contrast) and 21.0 (maximum contrast)
  static double calculateContrastRatio(Color color1, Color color2) {
    final lum1 = getRelativeLuminance(color1);
    final lum2 = getRelativeLuminance(color2);
    
    final lighter = lum1 > lum2 ? lum1 : lum2;
    final darker = lum1 > lum2 ? lum2 : lum1;
    
    return (lighter + 0.05) / (darker + 0.05);
  }

  /// Check if contrast meets WCAG AA standard for normal text (4.5:1)
  static bool meetsWCAGAA(Color foreground, Color background) {
    return calculateContrastRatio(foreground, background) >= 4.5;
  }

  /// Check if contrast meets WCAG AA standard for large text (3:1)
  static bool meetsWCAGAA_Large(Color foreground, Color background) {
    return calculateContrastRatio(foreground, background) >= 3.0;
  }

  /// Check if contrast meets WCAG AAA standard for normal text (7:1)
  static bool meetsWCAGAAA(Color foreground, Color background) {
    return calculateContrastRatio(foreground, background) >= 7.0;
  }

  /// Check if contrast meets WCAG AAA standard for large text (4.5:1)
  static bool meetsWCAGAAA_Large(Color foreground, Color background) {
    return calculateContrastRatio(foreground, background) >= 4.5;
  }

  /// Get WCAG compliance level
  /// Returns: 'AAA', 'AA', 'AA Large', or 'Fail'
  static String getWCAGLevel(Color foreground, Color background, {bool isLargeText = false}) {
    final ratio = calculateContrastRatio(foreground, background);
    
    if (isLargeText) {
      if (ratio >= 4.5) return 'AAA';
      if (ratio >= 3.0) return 'AA';
    } else {
      if (ratio >= 7.0) return 'AAA';
      if (ratio >= 4.5) return 'AA';
    }
    
    return 'Fail';
  }

  /// Get accessibility score (0.0 to 1.0)
  static double getAccessibilityScore(Color foreground, Color background) {
    final ratio = calculateContrastRatio(foreground, background);
    
    // Normalize to 0-1 scale (4.5:1 = 0.5, 7:1 = 1.0)
    if (ratio >= 7.0) return 1.0;
    if (ratio >= 4.5) return 0.5 + ((ratio - 4.5) / 5.0);
    if (ratio >= 3.0) return 0.3 + ((ratio - 3.0) / 7.5);
    return ratio / 10.0; // Below 3:1 gets very low score
  }

  /// Suggest better foreground color for given background
  static Color suggestForegroundColor(Color background, {bool preferDark = true}) {
    final bgLum = getRelativeLuminance(background);
    
    if (bgLum > 0.5) {
      // Light background - suggest dark foreground
      return preferDark ? Colors.black : const Color(0xFF1A1A1A);
    } else {
      // Dark background - suggest light foreground
      return preferDark ? Colors.white : const Color(0xFFF5F5F5);
    }
  }

  /// Suggest better background color for given foreground
  static Color suggestBackgroundColor(Color foreground, {bool preferLight = true}) {
    final fgLum = getRelativeLuminance(foreground);
    
    if (fgLum > 0.5) {
      // Light foreground - suggest dark background
      return preferLight ? Colors.black : const Color(0xFF1A1A1A);
    } else {
      // Dark foreground - suggest light background
      return preferLight ? Colors.white : const Color(0xFFF5F5F5);
    }
  }

  /// Check if color combination is readable
  static bool isReadable(Color foreground, Color background) {
    return calculateContrastRatio(foreground, background) >= 3.0;
  }

  /// Get detailed contrast information
  static ContrastInfo getContrastInfo(Color foreground, Color background) {
    final ratio = calculateContrastRatio(foreground, background);
    final wcagAA = meetsWCAGAA(foreground, background);
    final wcagaaLarge = meetsWCAGAA_Large(foreground, background);
    final wcagAAA = meetsWCAGAAA(foreground, background);
    final wcagaaaLarge = meetsWCAGAAA_Large(foreground, background);
    final level = getWCAGLevel(foreground, background);
    final score = getAccessibilityScore(foreground, background);
    
    return ContrastInfo(
      ratio: ratio,
      wcagAA: wcagAA,
      wcagAA_Large: wcagaaLarge,
      wcagAAA: wcagAAA,
      wcagAAA_Large: wcagaaaLarge,
      level: level,
      score: score,
      readable: isReadable(foreground, background),
    );
  }
}

class ContrastInfo {
  final double ratio;
  final bool wcagAA;
  final bool wcagAA_Large;
  final bool wcagAAA;
  final bool wcagAAA_Large;
  final String level;
  final double score;
  final bool readable;

  ContrastInfo({
    required this.ratio,
    required this.wcagAA,
    required this.wcagAA_Large,
    required this.wcagAAA,
    required this.wcagAAA_Large,
    required this.level,
    required this.score,
    required this.readable,
  });
}
