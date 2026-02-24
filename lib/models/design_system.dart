import 'package:json_annotation/json_annotation.dart';

part 'design_system.g.dart';

@JsonSerializable()
class DesignSystem {
  final String name;
  final String version;
  final String description;
  final String created;
  final Colors colors;
  final Typography typography;
  final Spacing spacing;
  final BorderRadius borderRadius;
  final Shadows shadows;
  final Effects effects;
  final Components components;
  final Grid grid;
  final Icons icons;
  final Gradients gradients;
  final Roles roles;

  DesignSystem({
    required this.name,
    required this.version,
    required this.description,
    required this.created,
    required this.colors,
    required this.typography,
    required this.spacing,
    required this.borderRadius,
    required this.shadows,
    required this.effects,
    required this.components,
    required this.grid,
    required this.icons,
    required this.gradients,
    required this.roles,
  });

  factory DesignSystem.fromJson(Map<String, dynamic> json) =>
      _$DesignSystemFromJson(json);

  Map<String, dynamic> toJson() => _$DesignSystemToJson(this);

  factory DesignSystem.empty() => DesignSystem(
        name: '',
        version: '1.0.0',
        description: '',
        created: DateTime.now().toIso8601String().split('T')[0],
        colors: Colors.empty(),
        typography: Typography.empty(),
        spacing: Spacing.empty(),
        borderRadius: BorderRadius.empty(),
        shadows: Shadows.empty(),
        effects: Effects.empty(),
        components: Components.empty(),
        grid: Grid.empty(),
        icons: Icons.empty(),
        gradients: Gradients.empty(),
        roles: Roles.empty(),
      );
}

@JsonSerializable()
class Colors {
  final Map<String, dynamic> primary;
  final Map<String, dynamic> semantic;
  final Map<String, dynamic>? blue;
  final Map<String, dynamic>? green;
  final Map<String, dynamic>? orange;
  final Map<String, dynamic>? purple;
  final Map<String, dynamic>? red;
  final Map<String, dynamic>? grey;
  final Map<String, dynamic>? white;
  final Map<String, dynamic>? text;
  final Map<String, dynamic>? input;
  final Map<String, dynamic>? roleSpecific;

  Colors({
    required this.primary,
    required this.semantic,
    this.blue,
    this.green,
    this.orange,
    this.purple,
    this.red,
    this.grey,
    this.white,
    this.text,
    this.input,
    this.roleSpecific,
  });

  factory Colors.fromJson(Map<String, dynamic> json) => _$ColorsFromJson(json);

  Map<String, dynamic> toJson() => _$ColorsToJson(this);

  factory Colors.empty() => Colors(
        primary: {},
        semantic: {},
      );
}

@JsonSerializable()
class Typography {
  final FontFamily fontFamily;
  final Map<String, int> fontWeights;
  final Map<String, FontSize> fontSizes;
  final Map<String, TextStyle> textStyles;

  Typography({
    required this.fontFamily,
    required this.fontWeights,
    required this.fontSizes,
    required this.textStyles,
  });

  factory Typography.fromJson(Map<String, dynamic> json) =>
      _$TypographyFromJson(json);

  Map<String, dynamic> toJson() => _$TypographyToJson(this);

  factory Typography.empty() => Typography(
        fontFamily: FontFamily(primary: 'Roboto', fallback: 'system-ui'),
        fontWeights: {
          'light': 300,
          'regular': 400,
          'medium': 500,
          'semibold': 600,
          'bold': 700,
        },
        fontSizes: {},
        textStyles: {},
      );
}

@JsonSerializable()
class FontFamily {
  final String primary;
  final String fallback;

  FontFamily({required this.primary, required this.fallback});

  factory FontFamily.fromJson(Map<String, dynamic> json) =>
      _$FontFamilyFromJson(json);

  Map<String, dynamic> toJson() => _$FontFamilyToJson(this);
}

@JsonSerializable()
class FontSize {
  final String value;
  final String lineHeight;
  final String? description;

  FontSize({
    required this.value,
    required this.lineHeight,
    this.description,
  });

  factory FontSize.fromJson(Map<String, dynamic> json) =>
      _$FontSizeFromJson(json);

  Map<String, dynamic> toJson() => _$FontSizeToJson(this);
}

@JsonSerializable()
class TextStyle {
  final String fontFamily;
  final String fontSize;
  final int fontWeight;
  final String lineHeight;
  final String? color;
  final String? textDecoration;

  TextStyle({
    required this.fontFamily,
    required this.fontSize,
    required this.fontWeight,
    required this.lineHeight,
    this.color,
    this.textDecoration,
  });

  factory TextStyle.fromJson(Map<String, dynamic> json) =>
      _$TextStyleFromJson(json);

  Map<String, dynamic> toJson() => _$TextStyleToJson(this);
}

@JsonSerializable()
class Spacing {
  final List<int> scale;
  final Map<String, String> values;

  Spacing({required this.scale, required this.values});

  factory Spacing.fromJson(Map<String, dynamic> json) =>
      _$SpacingFromJson(json);

  Map<String, dynamic> toJson() => _$SpacingToJson(this);

  factory Spacing.empty() => Spacing(
        scale: [0, 4, 8, 12, 16, 20, 24, 32, 40, 48, 64, 80, 96],
        values: {
          '0': '0px',
          '1': '4px',
          '2': '8px',
          '3': '12px',
          '4': '16px',
          '5': '20px',
          '6': '24px',
          '8': '32px',
          '10': '40px',
          '12': '48px',
          '16': '64px',
          '20': '80px',
          '24': '96px',
        },
      );
}

@JsonSerializable()
class BorderRadius {
  final String none;
  final String sm;
  final String base;
  final String md;
  final String lg;
  final String xl;
  final String full;

  BorderRadius({
    required this.none,
    required this.sm,
    required this.base,
    required this.md,
    required this.lg,
    required this.xl,
    required this.full,
  });

  factory BorderRadius.fromJson(Map<String, dynamic> json) =>
      _$BorderRadiusFromJson(json);

  Map<String, dynamic> toJson() => _$BorderRadiusToJson(this);

  factory BorderRadius.empty() => BorderRadius(
        none: '0px',
        sm: '8px',
        base: '12px',
        md: '16px',
        lg: '24px',
        xl: '30px',
        full: '9999px',
      );
}

@JsonSerializable()
class Shadows {
  final Map<String, ShadowValue> values;

  Shadows({required this.values});

  factory Shadows.fromJson(Map<String, dynamic> json) =>
      _$ShadowsFromJson(json);

  Map<String, dynamic> toJson() => _$ShadowsToJson(this);

  factory Shadows.empty() => Shadows(values: {});
}

@JsonSerializable()
class ShadowValue {
  final String value;
  final String? description;

  ShadowValue({required this.value, this.description});

  factory ShadowValue.fromJson(Map<String, dynamic> json) =>
      _$ShadowValueFromJson(json);

  Map<String, dynamic> toJson() => _$ShadowValueToJson(this);
}

@JsonSerializable()
class Effects {
  final Map<String, dynamic>? glassMorphism;
  final Map<String, dynamic>? darkOverlay;

  Effects({this.glassMorphism, this.darkOverlay});

  factory Effects.fromJson(Map<String, dynamic> json) =>
      _$EffectsFromJson(json);

  Map<String, dynamic> toJson() => _$EffectsToJson(this);

  factory Effects.empty() => Effects();
}

@JsonSerializable()
class Components {
  final Map<String, dynamic> buttons;
  final Map<String, dynamic> cards;
  final Map<String, dynamic> inputs;
  final Map<String, dynamic> navigation;
  final Map<String, dynamic> avatars;

  Components({
    required this.buttons,
    required this.cards,
    required this.inputs,
    required this.navigation,
    required this.avatars,
  });

  factory Components.fromJson(Map<String, dynamic> json) =>
      _$ComponentsFromJson(json);

  Map<String, dynamic> toJson() => _$ComponentsToJson(this);

  factory Components.empty() => Components(
        buttons: {},
        cards: {},
        inputs: {},
        navigation: {},
        avatars: {},
      );
}

@JsonSerializable()
class Grid {
  final int columns;
  final String gutter;
  final String margin;
  final Map<String, String> breakpoints;

  Grid({
    required this.columns,
    required this.gutter,
    required this.margin,
    required this.breakpoints,
  });

  factory Grid.fromJson(Map<String, dynamic> json) => _$GridFromJson(json);

  Map<String, dynamic> toJson() => _$GridToJson(this);

  factory Grid.empty() => Grid(
        columns: 12,
        gutter: '16px',
        margin: '16px',
        breakpoints: {
          'mobile': '360px',
          'tablet': '768px',
          'desktop': '1200px',
        },
      );
}

@JsonSerializable()
class Icons {
  final Map<String, String> sizes;

  Icons({required this.sizes});

  factory Icons.fromJson(Map<String, dynamic> json) => _$IconsFromJson(json);

  Map<String, dynamic> toJson() => _$IconsToJson(this);

  factory Icons.empty() => Icons(
        sizes: {
          'xs': '16px',
          'sm': '20px',
          'md': '24px',
          'lg': '28px',
          'xl': '32px',
          '2xl': '40px',
        },
      );
}

@JsonSerializable()
class Gradients {
  final Map<String, GradientValue> values;

  Gradients({required this.values});

  factory Gradients.fromJson(Map<String, dynamic> json) =>
      _$GradientsFromJson(json);

  Map<String, dynamic> toJson() => _$GradientsToJson(this);

  factory Gradients.empty() => Gradients(values: {});
}

@JsonSerializable()
class GradientValue {
  final String type;
  final String direction;
  final List<String> colors;
  final List<int> stops;

  GradientValue({
    required this.type,
    required this.direction,
    required this.colors,
    required this.stops,
  });

  factory GradientValue.fromJson(Map<String, dynamic> json) =>
      _$GradientValueFromJson(json);

  Map<String, dynamic> toJson() => _$GradientValueToJson(this);
}

@JsonSerializable()
class Roles {
  final Map<String, RoleValue> values;

  Roles({required this.values});

  factory Roles.fromJson(Map<String, dynamic> json) => _$RolesFromJson(json);

  Map<String, dynamic> toJson() => _$RolesToJson(this);

  factory Roles.empty() => Roles(values: {});
}

@JsonSerializable()
class RoleValue {
  final String primaryColor;
  final String accentColor;
  final String background;

  RoleValue({
    required this.primaryColor,
    required this.accentColor,
    required this.background,
  });

  factory RoleValue.fromJson(Map<String, dynamic> json) =>
      _$RoleValueFromJson(json);

  Map<String, dynamic> toJson() => _$RoleValueToJson(this);
}
