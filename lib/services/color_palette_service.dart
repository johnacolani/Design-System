import 'package:flutter/material.dart';

class ColorPaletteService {
  /// Generate color scale from a base color (light to dark)
  /// Returns a map with keys like '50', '100', '200', ..., '900', '950'
  static Map<String, String> generateColorScale(Color baseColor, {int steps = 10}) {
    final scale = <String, String>{};
    
    // Generate lighter shades (50-400)
    for (int i = 0; i <= 4; i++) {
      final lightness = 0.95 - (i * 0.1);
      final color = _lightenColor(baseColor, lightness);
      scale['${i * 100}'] = colorToHex(color);
    }
    
    // Base color (500)
    scale['500'] = colorToHex(baseColor);
    
    // Generate darker shades (600-950)
    for (int i = 6; i <= 9; i++) {
      final darkness = (i - 5) * 0.15;
      final color = _darkenColor(baseColor, darkness);
      scale['${i * 100}'] = colorToHex(color);
    }
    
    // Extra dark shade
    scale['950'] = _colorToHex(_darkenColor(baseColor, 0.7));
    
    return scale;
  }

  /// Generate color scale from primary to dark
  static Map<String, String> generatePrimaryToDark(Color primaryColor, {int steps = 10}) {
    final scale = <String, String>{};
    scale['primary'] = _colorToHex(primaryColor);
    
    for (int i = 1; i <= steps; i++) {
      final darkness = i / steps;
      final color = _darkenColor(primaryColor, darkness * 0.6);
      scale['dark$i'] = colorToHex(color);
    }
    
    return scale;
  }

  /// Generate color scale from primary to light
  static Map<String, String> generatePrimaryToLight(Color primaryColor, {int steps = 10}) {
    final scale = <String, String>{};
    scale['primary'] = _colorToHex(primaryColor);
    
    for (int i = 1; i <= steps; i++) {
      final lightness = i / steps;
      final color = _lightenColor(primaryColor, lightness * 0.5);
      scale['light$i'] = colorToHex(color);
    }
    
    return scale;
  }

  /// Generate secondary color scales (to white and to dark)
  static Map<String, Map<String, String>> generateSecondaryScales(Color secondaryColor, {int steps = 10}) {
    return {
      'toWhite': generateSecondaryToWhite(secondaryColor, steps: steps),
      'toDark': generateSecondaryToDark(secondaryColor, steps: steps),
    };
  }

  /// Generate color scale from secondary to white
  static Map<String, String> generateSecondaryToWhite(Color secondaryColor, {int steps = 10}) {
    final scale = <String, String>{};
    scale['secondary'] = _colorToHex(secondaryColor);
    
    for (int i = 1; i <= steps; i++) {
      final lightness = i / steps;
      final color = _blendColor(secondaryColor, Colors.white, lightness);
      scale['white$i'] = colorToHex(color);
    }
    
    scale['white'] = colorToHex(Colors.white);
    return scale;
  }

  /// Generate color scale from secondary to dark
  static Map<String, String> generateSecondaryToDark(Color secondaryColor, {int steps = 10}) {
    final scale = <String, String>{};
    scale['secondary'] = _colorToHex(secondaryColor);
    
    for (int i = 1; i <= steps; i++) {
      final darkness = i / steps;
      final color = _darkenColor(secondaryColor, darkness * 0.7);
      scale['dark$i'] = colorToHex(color);
    }
    
    return scale;
  }

  /// Suggest complementary colors
  static List<ColorSuggestion> suggestColors(Color baseColor) {
    final suggestions = <ColorSuggestion>[];
    
    // Complementary color (opposite on color wheel)
    final complementary = _getComplementaryColor(baseColor);
    suggestions.add(ColorSuggestion(
      color: complementary,
      name: 'Complementary',
      description: 'Opposite color on the color wheel',
      matchScore: 0.9,
    ));
    
    // Analogous colors (adjacent on color wheel)
    final analogous = _getAnalogousColors(baseColor);
    suggestions.add(ColorSuggestion(
      color: analogous[0],
      name: 'Analogous 1',
      description: 'Adjacent color (warmer)',
      matchScore: 0.8,
    ));
    suggestions.add(ColorSuggestion(
      color: analogous[1],
      name: 'Analogous 2',
      description: 'Adjacent color (cooler)',
      matchScore: 0.8,
    ));
    
    // Triadic colors
    final triadic = _getTriadicColors(baseColor);
    suggestions.add(ColorSuggestion(
      color: triadic[0],
      name: 'Triadic 1',
      description: 'Triadic color scheme',
      matchScore: 0.7,
    ));
    suggestions.add(ColorSuggestion(
      color: triadic[1],
      name: 'Triadic 2',
      description: 'Triadic color scheme',
      matchScore: 0.7,
    ));
    
    // Split complementary
    final splitComplementary = _getSplitComplementaryColors(baseColor);
    suggestions.add(ColorSuggestion(
      color: splitComplementary[0],
      name: 'Split Complementary 1',
      description: 'Split complementary scheme',
      matchScore: 0.75,
    ));
    suggestions.add(ColorSuggestion(
      color: splitComplementary[1],
      name: 'Split Complementary 2',
      description: 'Split complementary scheme',
      matchScore: 0.75,
    ));
    
    // Monochromatic (lighter and darker)
    suggestions.add(ColorSuggestion(
      color: _lightenColor(baseColor, 0.3),
      name: 'Monochromatic Light',
      description: 'Lighter shade of the same color',
      matchScore: 0.95,
    ));
    suggestions.add(ColorSuggestion(
      color: _darkenColor(baseColor, 0.3),
      name: 'Monochromatic Dark',
      description: 'Darker shade of the same color',
      matchScore: 0.95,
    ));
    
    // Sort by match score (highest first)
    suggestions.sort((a, b) => b.matchScore.compareTo(a.matchScore));
    
    return suggestions;
  }

  /// Lighten a color
  static Color _lightenColor(Color color, double amount) {
    assert(amount >= 0 && amount <= 1);
    return Color.fromARGB(
      color.alpha,
      ((color.red + (255 - color.red) * amount)).round().clamp(0, 255),
      ((color.green + (255 - color.green) * amount)).round().clamp(0, 255),
      ((color.blue + (255 - color.blue) * amount)).round().clamp(0, 255),
    );
  }

  /// Darken a color
  static Color _darkenColor(Color color, double amount) {
    assert(amount >= 0 && amount <= 1);
    return Color.fromARGB(
      color.alpha,
      (color.red * (1 - amount)).round().clamp(0, 255),
      (color.green * (1 - amount)).round().clamp(0, 255),
      (color.blue * (1 - amount)).round().clamp(0, 255),
    );
  }

  /// Blend two colors
  static Color _blendColor(Color color1, Color color2, double ratio) {
    assert(ratio >= 0 && ratio <= 1);
    return Color.fromARGB(
      ((color1.alpha * (1 - ratio) + color2.alpha * ratio)).round().clamp(0, 255),
      ((color1.red * (1 - ratio) + color2.red * ratio)).round().clamp(0, 255),
      ((color1.green * (1 - ratio) + color2.green * ratio)).round().clamp(0, 255),
      ((color1.blue * (1 - ratio) + color2.blue * ratio)).round().clamp(0, 255),
    );
  }

  /// Get complementary color
  static Color _getComplementaryColor(Color color) {
    return Color.fromARGB(
      color.alpha,
      255 - color.red,
      255 - color.green,
      255 - color.blue,
    );
  }

  /// Get analogous colors (30 degrees apart)
  static List<Color> _getAnalogousColors(Color color) {
    final hsl = _rgbToHsl(color.red, color.green, color.blue);
    return [
      _hslToRgb((hsl[0] + 30) % 360, hsl[1], hsl[2]),
      _hslToRgb((hsl[0] - 30 + 360) % 360, hsl[1], hsl[2]),
    ];
  }

  /// Get triadic colors (120 degrees apart)
  static List<Color> _getTriadicColors(Color color) {
    final hsl = _rgbToHsl(color.red, color.green, color.blue);
    return [
      _hslToRgb((hsl[0] + 120) % 360, hsl[1], hsl[2]),
      _hslToRgb((hsl[0] + 240) % 360, hsl[1], hsl[2]),
    ];
  }

  /// Get split complementary colors
  static List<Color> _getSplitComplementaryColors(Color color) {
    final hsl = _rgbToHsl(color.red, color.green, color.blue);
    return [
      _hslToRgb((hsl[0] + 150) % 360, hsl[1], hsl[2]),
      _hslToRgb((hsl[0] + 210) % 360, hsl[1], hsl[2]),
    ];
  }

  /// Convert RGB to HSL
  static List<double> _rgbToHsl(int r, int g, int b) {
    r = r.clamp(0, 255);
    g = g.clamp(0, 255);
    b = b.clamp(0, 255);
    
    final rNorm = r / 255.0;
    final gNorm = g / 255.0;
    final bNorm = b / 255.0;
    
    final max = [rNorm, gNorm, bNorm].reduce((a, b) => a > b ? a : b);
    final min = [rNorm, gNorm, bNorm].reduce((a, b) => a < b ? a : b);
    final delta = max - min;
    
    double h = 0.0;
    if (delta != 0) {
      if (max == rNorm) {
        h = (((gNorm - bNorm) / delta) % 6).toDouble();
      } else if (max == gNorm) {
        h = ((bNorm - rNorm) / delta + 2).toDouble();
      } else {
        h = ((rNorm - gNorm) / delta + 4).toDouble();
      }
    }
    h = (h * 60).roundToDouble();
    if (h < 0) h += 360.0;
    
    final double l = (max + min) / 2.0;
    final double s = delta == 0 ? 0.0 : (delta / (1 - (2 * l - 1).abs())).toDouble();
    
    return [h, s, l];
  }

  /// Convert HSL to RGB
  static Color _hslToRgb(double h, double s, double l) {
    h = h % 360;
    s = s.clamp(0, 1);
    l = l.clamp(0, 1);
    
    final c = (1 - (2 * l - 1).abs()) * s;
    final x = c * (1 - ((h / 60) % 2 - 1).abs());
    final m = l - c / 2;
    
    double r = 0, g = 0, b = 0;
    
    if (h < 60) {
      r = c; g = x; b = 0;
    } else if (h < 120) {
      r = x; g = c; b = 0;
    } else if (h < 180) {
      r = 0; g = c; b = x;
    } else if (h < 240) {
      r = 0; g = x; b = c;
    } else if (h < 300) {
      r = x; g = 0; b = c;
    } else {
      r = c; g = 0; b = x;
    }
    
    return Color.fromARGB(
      255,
      ((r + m) * 255).round().clamp(0, 255),
      ((g + m) * 255).round().clamp(0, 255),
      ((b + m) * 255).round().clamp(0, 255),
    );
  }

  /// Convert Color to hex string
  static String colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase().padLeft(6, '0')}';
  }

  /// Convert Color to hex string (private alias for internal use)
  static String _colorToHex(Color color) => colorToHex(color);

  /// Parse hex string to Color
  static Color hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex'; // Add alpha
    }
    return Color(int.parse(hex, radix: 16));
  }
}

class ColorSuggestion {
  final Color color;
  final String name;
  final String description;
  final double matchScore; // 0.0 to 1.0

  ColorSuggestion({
    required this.color,
    required this.name,
    required this.description,
    required this.matchScore,
  });
}
