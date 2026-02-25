import 'package:flutter/material.dart';

/// User attitude quadrants
enum UserAttitude {
  youthfulExpressive,
  youthfulUnderstated,
  matureExpressive,
  matureUnderstated,
}

/// Service providing color psychology and user attitude mapping
/// Based on Delve's "Four Steps to the Right Color" methodology
class ColorPsychologyService {

  /// Color psychology meanings
  static Map<String, ColorMeaning> getColorMeanings() {
    return {
      'blue': ColorMeaning(
        name: 'Blue',
        meanings: ['Trust', 'Stability', 'Professional', 'Calm'],
        attitudeFit: {
          UserAttitude.matureExpressive: 0.8,
          UserAttitude.matureUnderstated: 0.9,
          UserAttitude.youthfulUnderstated: 0.7,
          UserAttitude.youthfulExpressive: 0.4,
        },
        brandAttributes: ['Reliable', 'Professional', 'Trustworthy'],
      ),
      'green': ColorMeaning(
        name: 'Green',
        meanings: ['Growth', 'Nature', 'Balance', 'Fresh'],
        attitudeFit: {
          UserAttitude.matureExpressive: 0.7,
          UserAttitude.matureUnderstated: 0.6,
          UserAttitude.youthfulUnderstated: 0.8,
          UserAttitude.youthfulExpressive: 0.7,
        },
        brandAttributes: ['Sustainable', 'Natural', 'Balanced'],
      ),
      'red': ColorMeaning(
        name: 'Red',
        meanings: ['Energy', 'Passion', 'Urgency', 'Bold'],
        attitudeFit: {
          UserAttitude.youthfulExpressive: 0.9,
          UserAttitude.matureExpressive: 0.8,
          UserAttitude.youthfulUnderstated: 0.3,
          UserAttitude.matureUnderstated: 0.2,
        },
        brandAttributes: ['Bold', 'Energetic', 'Dynamic'],
      ),
      'orange': ColorMeaning(
        name: 'Orange',
        meanings: ['Creativity', 'Warmth', 'Enthusiasm', 'Friendly'],
        attitudeFit: {
          UserAttitude.youthfulExpressive: 0.9,
          UserAttitude.matureExpressive: 0.7,
          UserAttitude.youthfulUnderstated: 0.5,
          UserAttitude.matureUnderstated: 0.3,
        },
        brandAttributes: ['Creative', 'Approachable', 'Friendly'],
      ),
      'purple': ColorMeaning(
        name: 'Purple',
        meanings: ['Luxury', 'Creativity', 'Wisdom', 'Innovation'],
        attitudeFit: {
          UserAttitude.matureExpressive: 0.8,
          UserAttitude.youthfulExpressive: 0.7,
          UserAttitude.matureUnderstated: 0.5,
          UserAttitude.youthfulUnderstated: 0.4,
        },
        brandAttributes: ['Premium', 'Innovative', 'Creative'],
      ),
      'yellow': ColorMeaning(
        name: 'Yellow',
        meanings: ['Optimism', 'Happiness', 'Energy', 'Attention'],
        attitudeFit: {
          UserAttitude.youthfulExpressive: 0.9,
          UserAttitude.matureExpressive: 0.6,
          UserAttitude.youthfulUnderstated: 0.4,
          UserAttitude.matureUnderstated: 0.2,
        },
        brandAttributes: ['Optimistic', 'Energetic', 'Positive'],
      ),
      'grey': ColorMeaning(
        name: 'Grey',
        meanings: ['Neutral', 'Balance', 'Sophisticated', 'Professional'],
        attitudeFit: {
          UserAttitude.matureUnderstated: 0.9,
          UserAttitude.youthfulUnderstated: 0.8,
          UserAttitude.matureExpressive: 0.5,
          UserAttitude.youthfulExpressive: 0.3,
        },
        brandAttributes: ['Sophisticated', 'Professional', 'Balanced'],
      ),
      'black': ColorMeaning(
        name: 'Black',
        meanings: ['Elegance', 'Power', 'Sophistication', 'Minimal'],
        attitudeFit: {
          UserAttitude.matureUnderstated: 0.95,
          UserAttitude.youthfulUnderstated: 0.9,
          UserAttitude.matureExpressive: 0.6,
          UserAttitude.youthfulExpressive: 0.4,
        },
        brandAttributes: ['Premium', 'Sophisticated', 'Minimal'],
      ),
      'white': ColorMeaning(
        name: 'White',
        meanings: ['Purity', 'Simplicity', 'Clean', 'Modern'],
        attitudeFit: {
          UserAttitude.youthfulUnderstated: 0.95,
          UserAttitude.matureUnderstated: 0.9,
          UserAttitude.matureExpressive: 0.5,
          UserAttitude.youthfulExpressive: 0.4,
        },
        brandAttributes: ['Clean', 'Modern', 'Simple'],
      ),
    };
  }

  /// Get attitude description
  static String getAttitudeDescription(UserAttitude attitude) {
    switch (attitude) {
      case UserAttitude.youthfulExpressive:
        return 'Bold, adventurous, progressive use of colors. More distinct and vibrant color choices.';
      case UserAttitude.youthfulUnderstated:
        return 'Apple-like aesthetic: black/white contrasts, pale greys, minimal color accents. Small, controlled pops of color.';
      case UserAttitude.matureExpressive:
        return 'Adventurous but sophisticated. Mature colors with progressive, distinct attitude. Mass-market appeal with brand statement.';
      case UserAttitude.matureUnderstated:
        return 'Serious, businesslike tone. Professional and sophisticated color choices.';
    }
  }

  /// Get attitude name
  static String getAttitudeName(UserAttitude attitude) {
    switch (attitude) {
      case UserAttitude.youthfulExpressive:
        return 'Youthful / Expressive';
      case UserAttitude.youthfulUnderstated:
        return 'Youthful / Understated';
      case UserAttitude.matureExpressive:
        return 'Mature / Expressive';
      case UserAttitude.matureUnderstated:
        return 'Mature / Understated';
    }
  }

  /// Analyze color fit for attitude
  static double getColorAttitudeFit(Color color, UserAttitude attitude) {
    final meanings = getColorMeanings();
    final colorName = getColorName(color);
    
    if (colorName == null) return 0.5;
    
    final meaning = meanings[colorName];
    if (meaning == null) return 0.5;
    
    return meaning.attitudeFit[attitude] ?? 0.5;
  }

  /// Get color meaning for a color
  static ColorMeaning? getColorMeaning(Color color) {
    final colorName = getColorName(color);
    if (colorName == null) return null;
    return getColorMeanings()[colorName];
  }

  /// Determine color name from Color object
  static String? getColorName(Color color) {
    // Simple hue-based color detection
    final hsl = HSLColor.fromColor(color);
    final hue = hsl.hue;
    final saturation = hsl.saturation;
    final lightness = hsl.lightness;

    if (lightness < 0.2) return 'black';
    if (lightness > 0.9 && saturation < 0.1) return 'white';
    if (saturation < 0.2) return 'grey';

    if (hue >= 0 && hue < 30) return 'red';
    if (hue >= 30 && hue < 60) return 'orange';
    if (hue >= 60 && hue < 90) return 'yellow';
    if (hue >= 90 && hue < 150) return 'green';
    if (hue >= 150 && hue < 210) return 'blue';
    if (hue >= 210 && hue < 270) return 'purple';
    if (hue >= 270 && hue < 330) return 'purple';
    return 'red';
  }

  /// Get recommended colors for an attitude
  static List<ColorRecommendation> getRecommendedColors(UserAttitude attitude) {
    final meanings = getColorMeanings();
    final recommendations = <ColorRecommendation>[];

    meanings.forEach((name, meaning) {
      final fit = meaning.attitudeFit[attitude] ?? 0.0;
      if (fit >= 0.7) {
        recommendations.add(ColorRecommendation(
          colorName: name,
          fitScore: fit,
          meaning: meaning,
        ));
      }
    });

    recommendations.sort((a, b) => b.fitScore.compareTo(a.fitScore));
    return recommendations;
  }

  /// Cultural associations for colors
  static Map<String, CulturalAssociation> getCulturalAssociations() {
    return {
      'red': CulturalAssociation(
        western: ['Love', 'Passion', 'Danger', 'Energy'],
        eastern: ['Luck', 'Prosperity', 'Happiness'],
        middleEastern: ['Danger', 'Evil'],
        african: ['Death', 'Mourning'],
        latinAmerican: ['Passion', 'Love'],
        warnings: ['Can symbolize danger or warning in some cultures'],
      ),
      'blue': CulturalAssociation(
        western: ['Trust', 'Stability', 'Calm'],
        eastern: ['Immortality', 'Spirituality'],
        middleEastern: ['Protection', 'Heaven'],
        african: ['Harmony', 'Love'],
        latinAmerican: ['Trust', 'Reliability'],
        warnings: [],
      ),
      'green': CulturalAssociation(
        western: ['Nature', 'Growth', 'Freshness'],
        eastern: ['New Life', 'Fertility', 'Youth'],
        middleEastern: ['Islam', 'Paradise'],
        african: ['Fertility', 'Agriculture'],
        latinAmerican: ['Nature', 'Hope'],
        warnings: [],
      ),
      'yellow': CulturalAssociation(
        western: ['Happiness', 'Optimism', 'Caution'],
        eastern: ['Royalty', 'Sacred'],
        middleEastern: ['Happiness', 'Prosperity'],
        african: ['Wealth', 'Status'],
        latinAmerican: ['Death', 'Mourning'],
        warnings: ['Can symbolize death or mourning in some Latin American cultures'],
      ),
      'white': CulturalAssociation(
        western: ['Purity', 'Innocence', 'Peace'],
        eastern: ['Death', 'Mourning', 'Funerals'],
        middleEastern: ['Mourning', 'Death'],
        african: ['Purity', 'Spirituality'],
        latinAmerican: ['Purity', 'Peace'],
        warnings: ['Symbolizes death and mourning in many Eastern and Middle Eastern cultures'],
      ),
      'black': CulturalAssociation(
        western: ['Elegance', 'Sophistication', 'Mourning'],
        eastern: ['Mystery', 'Evil', 'Death'],
        middleEastern: ['Mystery', 'Rebirth'],
        african: ['Age', 'Maturity', 'Wisdom'],
        latinAmerican: ['Elegance', 'Mourning'],
        warnings: [],
      ),
      'purple': CulturalAssociation(
        western: ['Royalty', 'Luxury', 'Creativity'],
        eastern: ['Wealth', 'Prosperity'],
        middleEastern: ['Mystery', 'Spirituality'],
        african: ['Royalty', 'Wealth'],
        latinAmerican: ['Luxury', 'Spirituality'],
        warnings: [],
      ),
      'orange': CulturalAssociation(
        western: ['Energy', 'Creativity', 'Warmth'],
        eastern: ['Sacred', 'Spirituality'],
        middleEastern: ['Courage', 'Sacrifice'],
        african: ['Earth', 'Harvest'],
        latinAmerican: ['Energy', 'Sunset'],
        warnings: [],
      ),
    };
  }

  /// Get cultural warnings for a color
  static List<String> getCulturalWarnings(String colorName) {
    final associations = getCulturalAssociations();
    return associations[colorName]?.warnings ?? [];
  }

  /// Demographic color preferences
  static DemographicPreferences getDemographicPreferences() {
    return DemographicPreferences(
      male: ['Blue', 'Green', 'Black', 'Gray', 'Red'],
      female: ['Purple', 'Pink', 'Blue', 'Green', 'Lavender'],
      young: ['Bright', 'Bold', 'Vibrant', 'Energetic'],
      mature: ['Muted', 'Classic', 'Sophisticated', 'Professional'],
      professional: ['Blue', 'Gray', 'Black', 'Navy'],
      creative: ['Purple', 'Orange', 'Pink', 'Vibrant'],
      luxury: ['Black', 'Gold', 'Purple', 'Deep Blue'],
      ecoFriendly: ['Green', 'Brown', 'Earth Tones'],
    );
  }

  /// Get color recommendations based on demographics
  static List<String> getColorsForDemographic({
    String? gender,
    String? ageGroup,
    String? profession,
  }) {
    final prefs = getDemographicPreferences();
    final recommendations = <String>[];

    if (gender == 'male') {
      recommendations.addAll(prefs.male);
    } else if (gender == 'female') {
      recommendations.addAll(prefs.female);
    }

    if (ageGroup == 'young') {
      recommendations.addAll(prefs.young);
    } else if (ageGroup == 'mature') {
      recommendations.addAll(prefs.mature);
    }

    if (profession == 'professional') {
      recommendations.addAll(prefs.professional);
    } else if (profession == 'creative') {
      recommendations.addAll(prefs.creative);
    }

    return recommendations.toSet().toList();
  }
}

class CulturalAssociation {
  final List<String> western;
  final List<String> eastern;
  final List<String> middleEastern;
  final List<String> african;
  final List<String> latinAmerican;
  final List<String> warnings;

  CulturalAssociation({
    required this.western,
    required this.eastern,
    required this.middleEastern,
    required this.african,
    required this.latinAmerican,
    required this.warnings,
  });
}

class DemographicPreferences {
  final List<String> male;
  final List<String> female;
  final List<String> young;
  final List<String> mature;
  final List<String> professional;
  final List<String> creative;
  final List<String> luxury;
  final List<String> ecoFriendly;

  DemographicPreferences({
    required this.male,
    required this.female,
    required this.young,
    required this.mature,
    required this.professional,
    required this.creative,
    required this.luxury,
    required this.ecoFriendly,
  });
}

class ColorMeaning {
  final String name;
  final List<String> meanings;
  final Map<UserAttitude, double> attitudeFit;
  final List<String> brandAttributes;

  ColorMeaning({
    required this.name,
    required this.meanings,
    required this.attitudeFit,
    required this.brandAttributes,
  });
}

class ColorRecommendation {
  final String colorName;
  final double fitScore;
  final ColorMeaning meaning;

  ColorRecommendation({
    required this.colorName,
    required this.fitScore,
    required this.meaning,
  });
}
