import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Service for color theory operations: color schemes, harmony, and relationships
class ColorTheoryService {
  /// Generate monochromatic color scheme (single color, different shades/tints)
  static List<Color> generateMonochromatic(Color baseColor, {int steps = 5}) {
    final colors = <Color>[];
    final hsl = HSLColor.fromColor(baseColor);
    
    // Generate lighter tints
    for (int i = steps; i >= 1; i--) {
      final lightness = hsl.lightness + (i * 0.15);
      colors.add(hsl.withLightness(math.min(lightness, 1.0)).toColor());
    }
    
    // Base color
    colors.add(baseColor);
    
    // Generate darker shades
    for (int i = 1; i <= steps; i++) {
      final lightness = hsl.lightness - (i * 0.15);
      colors.add(hsl.withLightness(math.max(lightness, 0.0)).toColor());
    }
    
    return colors;
  }

  /// Generate analogous color scheme (adjacent colors on color wheel)
  static List<Color> generateAnalogous(Color baseColor, {int steps = 3}) {
    final colors = <Color>[];
    final hsl = HSLColor.fromColor(baseColor);
    final hueStep = 30.0; // 30 degrees on color wheel
    
    // Colors before base
    for (int i = steps; i >= 1; i--) {
      final hue = (hsl.hue - (i * hueStep)) % 360;
      colors.add(hsl.withHue(hue).toColor());
    }
    
    // Base color
    colors.add(baseColor);
    
    // Colors after base
    for (int i = 1; i <= steps; i++) {
      final hue = (hsl.hue + (i * hueStep)) % 360;
      colors.add(hsl.withHue(hue).toColor());
    }
    
    return colors;
  }

  /// Generate complementary color scheme (opposite colors on color wheel)
  static List<Color> generateComplementary(Color baseColor) {
    final hsl = HSLColor.fromColor(baseColor);
    final complementaryHue = (hsl.hue + 180) % 360;
    
    return [
      baseColor,
      hsl.withHue(complementaryHue).toColor(),
    ];
  }

  /// Generate triadic color scheme (three evenly spaced colors)
  static List<Color> generateTriadic(Color baseColor) {
    final hsl = HSLColor.fromColor(baseColor);
    final hue1 = (hsl.hue + 120) % 360;
    final hue2 = (hsl.hue + 240) % 360;
    
    return [
      baseColor,
      hsl.withHue(hue1).toColor(),
      hsl.withHue(hue2).toColor(),
    ];
  }

  /// Generate split-complementary color scheme
  static List<Color> generateSplitComplementary(Color baseColor) {
    final hsl = HSLColor.fromColor(baseColor);
    final complementaryHue = (hsl.hue + 180) % 360;
    final split1 = (complementaryHue - 30) % 360;
    final split2 = (complementaryHue + 30) % 360;
    
    return [
      baseColor,
      hsl.withHue(split1).toColor(),
      hsl.withHue(split2).toColor(),
    ];
  }

  /// Generate tetradic color scheme (four colors forming a rectangle)
  static List<Color> generateTetradic(Color baseColor) {
    final hsl = HSLColor.fromColor(baseColor);
    final hue1 = (hsl.hue + 60) % 360;
    final hue2 = (hsl.hue + 180) % 360;
    final hue3 = (hsl.hue + 240) % 360;
    
    return [
      baseColor,
      hsl.withHue(hue1).toColor(),
      hsl.withHue(hue2).toColor(),
      hsl.withHue(hue3).toColor(),
    ];
  }

  /// Calculate color harmony score (0.0 to 1.0)
  /// Higher score = more harmonious
  static double calculateHarmonyScore(List<Color> colors) {
    if (colors.length < 2) return 1.0;
    
    double totalScore = 0.0;
    int comparisons = 0;
    
    for (int i = 0; i < colors.length; i++) {
      for (int j = i + 1; j < colors.length; j++) {
        final score = _calculatePairHarmony(colors[i], colors[j]);
        totalScore += score;
        comparisons++;
      }
    }
    
    return comparisons > 0 ? totalScore / comparisons : 0.0;
  }

  /// Calculate harmony between two colors
  static double _calculatePairHarmony(Color color1, Color color2) {
    final hsl1 = HSLColor.fromColor(color1);
    final hsl2 = HSLColor.fromColor(color2);
    
    // Check if colors are complementary (opposite hues)
    final hueDiff = (hsl1.hue - hsl2.hue).abs();
    final complementaryDiff = (hueDiff - 180).abs();
    
    if (complementaryDiff < 15) {
      // Complementary colors - good harmony
      return 0.8;
    }
    
    // Check if colors are analogous (close hues)
    if (hueDiff < 30 || hueDiff > 330) {
      // Analogous colors - good harmony
      return 0.9;
    }
    
    // Check if colors are triadic (120 degrees apart)
    final triadicDiff1 = (hueDiff - 120).abs();
    final triadicDiff2 = (hueDiff - 240).abs();
    if (triadicDiff1 < 15 || triadicDiff2 < 15) {
      return 0.85;
    }
    
    // Check saturation and lightness similarity
    final satDiff = (hsl1.saturation - hsl2.saturation).abs();
    final lightDiff = (hsl1.lightness - hsl2.lightness).abs();
    
    // Similar saturation and lightness = better harmony
    final similarityScore = 1.0 - (satDiff + lightDiff) / 2.0;
    
    return similarityScore * 0.6; // Lower weight for similarity alone
  }

  /// Get color scheme type from a list of colors
  static String? detectColorScheme(List<Color> colors) {
    if (colors.length < 2) return null;
    
    final hslColors = colors.map((c) => HSLColor.fromColor(c)).toList();
    final hues = hslColors.map((hsl) => hsl.hue).toList();
    hues.sort();
    
    // Check for monochromatic
    final hueVariance = hues.map((h) {
      final diffs = hues.map((h2) => (h - h2).abs()).toList();
      return diffs.reduce((a, b) => a + b) / diffs.length;
    }).reduce((a, b) => a + b) / hues.length;
    
    if (hueVariance < 20) {
      return 'Monochromatic';
    }
    
    // Check for complementary
    if (colors.length == 2) {
      final hueDiff = (hues[0] - hues[1]).abs();
      if (hueDiff > 165 && hueDiff < 195) {
        return 'Complementary';
      }
    }
    
    // Check for triadic
    if (colors.length == 3) {
      final diff1 = (hues[1] - hues[0]) % 360;
      final diff2 = (hues[2] - hues[1]) % 360;
      if ((diff1 - 120).abs() < 15 && (diff2 - 120).abs() < 15) {
        return 'Triadic';
      }
    }
    
    // Check for analogous
    final adjacentCount = 0;
    for (int i = 0; i < hues.length - 1; i++) {
      final diff = (hues[i + 1] - hues[i]) % 360;
      if (diff < 45 || diff > 315) {
        return 'Analogous';
      }
    }
    
    return 'Custom';
  }

  /// Get color from hue, saturation, lightness values
  static Color colorFromHSL(double hue, double saturation, double lightness) {
    return HSLColor.fromAHSL(1.0, hue, saturation, lightness).toColor();
  }

  /// Get hue, saturation, lightness from color
  static Map<String, double> colorToHSL(Color color) {
    final hsl = HSLColor.fromColor(color);
    return {
      'hue': hsl.hue,
      'saturation': hsl.saturation,
      'lightness': hsl.lightness,
    };
  }

  /// Convert color to hex string
  static String colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  /// Convert hex string to color
  static Color hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex'; // Add alpha
    }
    return Color(int.parse(hex, radix: 16));
  }
}
