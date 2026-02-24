// import 'package:json_annotation/json_annotation.dart';
import 'design_system.dart';

// part 'design_system_wrapper.g.dart';

// @JsonSerializable()
class DesignSystemWrapper {
  // @JsonKey(name: 'designSystem')
  final DesignSystem designSystem;

  DesignSystemWrapper({required this.designSystem});

  // factory DesignSystemWrapper.fromJson(Map<String, dynamic> json) =>
  //     _$DesignSystemWrapperFromJson(json);

  // Map<String, dynamic> toJson() => _$DesignSystemWrapperToJson(this);

  /// Manual JSON conversion (since serialization is commented out)
  Map<String, dynamic> toJson() {
    return {
      'designSystem': _designSystemToJson(designSystem),
    };
  }

  factory DesignSystemWrapper.fromJson(Map<String, dynamic> json) {
    return DesignSystemWrapper(
      designSystem: _designSystemFromJson(json['designSystem'] as Map<String, dynamic>),
    );
  }

  static Map<String, dynamic> _designSystemToJson(DesignSystem ds) {
    return {
      'name': ds.name,
      'version': ds.version,
      'description': ds.description,
      'created': ds.created,
      'colors': _colorsToJson(ds.colors),
      'typography': _typographyToJson(ds.typography),
      'spacing': {
        'scale': ds.spacing.scale,
        'values': ds.spacing.values,
      },
      'borderRadius': {
        'none': ds.borderRadius.none,
        'sm': ds.borderRadius.sm,
        'base': ds.borderRadius.base,
        'md': ds.borderRadius.md,
        'lg': ds.borderRadius.lg,
        'xl': ds.borderRadius.xl,
        'full': ds.borderRadius.full,
      },
      'shadows': ds.shadows.values.map((key, s) => MapEntry(key, {
        'value': s.value,
        if (s.description != null) 'description': s.description,
      })),
      'effects': {
        if (ds.effects.glassMorphism != null) 'glassMorphism': ds.effects.glassMorphism,
        if (ds.effects.darkOverlay != null) 'darkOverlay': ds.effects.darkOverlay,
      },
      'components': {
        'buttons': ds.components.buttons,
        'cards': ds.components.cards,
        'inputs': ds.components.inputs,
        'navigation': ds.components.navigation,
        'avatars': ds.components.avatars,
      },
      'grid': {
        'columns': ds.grid.columns,
        'gutter': ds.grid.gutter,
        'margin': ds.grid.margin,
        'breakpoints': ds.grid.breakpoints,
      },
      'icons': ds.icons.sizes,
      'gradients': ds.gradients.values.map((key, g) => MapEntry(key, {
        'type': g.type,
        'direction': g.direction,
        'colors': g.colors,
        'stops': g.stops,
      })),
      'roles': ds.roles.values.map((key, r) => MapEntry(key, {
        'primaryColor': r.primaryColor,
        'accentColor': r.accentColor,
        'background': r.background,
      })),
    };
  }

  static DesignSystem _designSystemFromJson(Map<String, dynamic> json) {
    return DesignSystem(
      name: json['name'] as String,
      version: json['version'] as String,
      description: json['description'] as String,
      created: json['created'] as String,
      colors: _colorsFromJson(json['colors'] as Map<String, dynamic>),
      typography: _typographyFromJson(json['typography'] as Map<String, dynamic>),
      spacing: Spacing(
        scale: List<int>.from(json['spacing']['scale'] as List),
        values: Map<String, String>.from(json['spacing']['values'] as Map<String, dynamic>),
      ),
      borderRadius: BorderRadius(
        none: json['borderRadius']['none'] as String,
        sm: json['borderRadius']['sm'] as String,
        base: json['borderRadius']['base'] as String,
        md: json['borderRadius']['md'] as String,
        lg: json['borderRadius']['lg'] as String,
        xl: json['borderRadius']['xl'] as String,
        full: json['borderRadius']['full'] as String,
      ),
      shadows: Shadows(
        values: (json['shadows'] as Map<String, dynamic>).map((key, s) => MapEntry(
          key,
          ShadowValue(
            value: s['value'] as String,
            description: s['description'] as String?,
          ),
        )),
      ),
      effects: Effects(
        glassMorphism: json['effects']['glassMorphism'] as Map<String, dynamic>?,
        darkOverlay: json['effects']['darkOverlay'] as Map<String, dynamic>?,
      ),
      components: Components(
        buttons: Map<String, dynamic>.from(json['components']['buttons'] as Map),
        cards: Map<String, dynamic>.from(json['components']['cards'] as Map),
        inputs: Map<String, dynamic>.from(json['components']['inputs'] as Map),
        navigation: Map<String, dynamic>.from(json['components']['navigation'] as Map),
        avatars: Map<String, dynamic>.from(json['components']['avatars'] as Map),
      ),
      grid: Grid(
        columns: json['grid']['columns'] as int,
        gutter: json['grid']['gutter'] as String,
        margin: json['grid']['margin'] as String,
        breakpoints: Map<String, String>.from(json['grid']['breakpoints'] as Map<String, dynamic>),
      ),
      icons: Icons(sizes: Map<String, String>.from(json['icons'] as Map<String, dynamic>)),
      gradients: Gradients(
        values: (json['gradients'] as Map<String, dynamic>).map((key, g) => MapEntry(
          key,
          GradientValue(
            type: g['type'] as String,
            direction: g['direction'] as String,
            colors: List<String>.from(g['colors'] as List),
            stops: List<int>.from(g['stops'] as List),
          ),
        )),
      ),
      roles: Roles(
        values: (json['roles'] as Map<String, dynamic>).map((key, r) => MapEntry(
          key,
          RoleValue(
            primaryColor: r['primaryColor'] as String,
            accentColor: r['accentColor'] as String,
            background: r['background'] as String,
          ),
        )),
      ),
    );
  }

  static Map<String, dynamic> _colorsToJson(Colors colors) {
    return {
      'primary': colors.primary,
      'semantic': colors.semantic,
      if (colors.blue != null) 'blue': colors.blue,
      if (colors.green != null) 'green': colors.green,
      if (colors.orange != null) 'orange': colors.orange,
      if (colors.purple != null) 'purple': colors.purple,
      if (colors.red != null) 'red': colors.red,
      if (colors.grey != null) 'grey': colors.grey,
      if (colors.white != null) 'white': colors.white,
      if (colors.text != null) 'text': colors.text,
      if (colors.input != null) 'input': colors.input,
      if (colors.roleSpecific != null) 'roleSpecific': colors.roleSpecific,
    };
  }

  static Colors _colorsFromJson(Map<String, dynamic> json) {
    return Colors(
      primary: Map<String, dynamic>.from(json['primary'] as Map),
      semantic: Map<String, dynamic>.from(json['semantic'] as Map),
      blue: json['blue'] != null ? Map<String, dynamic>.from(json['blue'] as Map) : null,
      green: json['green'] != null ? Map<String, dynamic>.from(json['green'] as Map) : null,
      orange: json['orange'] != null ? Map<String, dynamic>.from(json['orange'] as Map) : null,
      purple: json['purple'] != null ? Map<String, dynamic>.from(json['purple'] as Map) : null,
      red: json['red'] != null ? Map<String, dynamic>.from(json['red'] as Map) : null,
      grey: json['grey'] != null ? Map<String, dynamic>.from(json['grey'] as Map) : null,
      white: json['white'] != null ? Map<String, dynamic>.from(json['white'] as Map) : null,
      text: json['text'] != null ? Map<String, dynamic>.from(json['text'] as Map) : null,
      input: json['input'] != null ? Map<String, dynamic>.from(json['input'] as Map) : null,
      roleSpecific: json['roleSpecific'] != null ? Map<String, dynamic>.from(json['roleSpecific'] as Map) : null,
    );
  }

  static Map<String, dynamic> _typographyToJson(Typography typography) {
    return {
      'fontFamily': {
        'primary': typography.fontFamily.primary,
        'fallback': typography.fontFamily.fallback,
      },
      'fontWeights': typography.fontWeights,
      'fontSizes': typography.fontSizes.map((key, size) => MapEntry(key, {
        'value': size.value,
        'lineHeight': size.lineHeight,
        if (size.description != null) 'description': size.description,
      })),
      'textStyles': typography.textStyles.map((key, style) => MapEntry(key, {
        'fontFamily': style.fontFamily,
        'fontSize': style.fontSize,
        'fontWeight': style.fontWeight,
        'lineHeight': style.lineHeight,
        if (style.color != null) 'color': style.color,
        if (style.textDecoration != null) 'textDecoration': style.textDecoration,
      })),
    };
  }

  static Typography _typographyFromJson(Map<String, dynamic> json) {
    final fontFamilyJson = json['fontFamily'] as Map<String, dynamic>;
    return Typography(
      fontFamily: FontFamily(
        primary: fontFamilyJson['primary'] as String,
        fallback: fontFamilyJson['fallback'] as String,
      ),
      fontWeights: Map<String, int>.from(json['fontWeights'] as Map<String, dynamic>),
      fontSizes: (json['fontSizes'] as Map<String, dynamic>).map((key, s) => MapEntry(
        key,
        FontSize(
          value: s['value'] as String,
          lineHeight: s['lineHeight'] as String,
          description: s['description'] as String?,
        ),
      )),
      textStyles: (json['textStyles'] as Map<String, dynamic>).map((key, ts) => MapEntry(
        key,
        TextStyle(
          fontFamily: ts['fontFamily'] as String,
          fontSize: ts['fontSize'] as String,
          fontWeight: ts['fontWeight'] as int,
          lineHeight: ts['lineHeight'] as String,
          color: ts['color'] as String?,
          textDecoration: ts['textDecoration'] as String?,
        ),
      )),
    );
  }
}
