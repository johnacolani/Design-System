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
      'icons': {
        'sizes': ds.icons.sizes,
        'projectIcons': ds.icons.projectIcons.map((e) => e.toJson()).toList(),
      },
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
      'semanticTokens': {
        'color': ds.semanticTokens.color,
        'typography': ds.semanticTokens.typography,
        'spacing': ds.semanticTokens.spacing,
        'shadow': ds.semanticTokens.shadow,
        'borderRadius': ds.semanticTokens.borderRadius,
      },
      'motionTokens': {
        'duration': ds.motionTokens.duration,
        'easing': ds.motionTokens.easing,
      },
      if (ds.lastModified != null) 'lastModified': ds.lastModified,
      if (ds.versionHistory != null) 'versionHistory': ds.versionHistory!.map((v) => v.toJson()).toList(),
      if (ds.componentVersions != null && ds.componentVersions!.isNotEmpty) 'componentVersions': ds.componentVersions,
      'targetPlatforms': ds.targetPlatforms,
      if (ds.platformOverrides != null && ds.platformOverrides!.isNotEmpty)
        'platformOverrides': ds.platformOverrides!.map((k, v) => MapEntry(k, _platformOverrideToJson(v))),
    };
  }

  static Map<String, dynamic> _platformOverrideToJson(PlatformOverride o) {
    return {
      if (o.colors != null) 'colors': _colorsToJson(o.colors!),
      if (o.typography != null) 'typography': _typographyToJson(o.typography!),
      if (o.spacing != null) 'spacing': {'scale': o.spacing!.scale, 'values': o.spacing!.values},
      if (o.borderRadius != null) 'borderRadius': {'none': o.borderRadius!.none, 'sm': o.borderRadius!.sm, 'base': o.borderRadius!.base, 'md': o.borderRadius!.md, 'lg': o.borderRadius!.lg, 'xl': o.borderRadius!.xl, 'full': o.borderRadius!.full},
      if (o.shadows != null) 'shadows': o.shadows!.values.map((key, s) => MapEntry(key, {'value': s.value, if (s.description != null) 'description': s.description})),
      if (o.effects != null) 'effects': {
        if (o.effects!.glassMorphism != null) 'glassMorphism': o.effects!.glassMorphism,
        if (o.effects!.darkOverlay != null) 'darkOverlay': o.effects!.darkOverlay,
      },
      if (o.components != null) 'components': {
        'buttons': o.components!.buttons,
        'cards': o.components!.cards,
        'inputs': o.components!.inputs,
        'navigation': o.components!.navigation,
        'avatars': o.components!.avatars,
        if (o.components!.modals != null) 'modals': o.components!.modals,
        if (o.components!.tables != null) 'tables': o.components!.tables,
        if (o.components!.progress != null) 'progress': o.components!.progress,
        if (o.components!.alerts != null) 'alerts': o.components!.alerts,
      },
      if (o.grid != null) 'grid': {'columns': o.grid!.columns, 'gutter': o.grid!.gutter, 'margin': o.grid!.margin, 'breakpoints': o.grid!.breakpoints},
      if (o.icons != null) 'icons': {'sizes': o.icons!.sizes, 'projectIcons': o.icons!.projectIcons.map((e) => e.toJson()).toList()},
      if (o.gradients != null) 'gradients': o.gradients!.values.map((key, g) => MapEntry(key, {'type': g.type, 'direction': g.direction, 'colors': g.colors, 'stops': g.stops})),
      if (o.roles != null) 'roles': o.roles!.values.map((key, r) => MapEntry(key, {'primaryColor': r.primaryColor, 'accentColor': r.accentColor, 'background': r.background})),
      if (o.semanticTokens != null) 'semanticTokens': {'color': o.semanticTokens!.color, 'typography': o.semanticTokens!.typography, 'spacing': o.semanticTokens!.spacing, 'shadow': o.semanticTokens!.shadow, 'borderRadius': o.semanticTokens!.borderRadius},
      if (o.motionTokens != null) 'motionTokens': {'duration': o.motionTokens!.duration, 'easing': o.motionTokens!.easing},
      if (o.componentVersions != null && o.componentVersions!.isNotEmpty) 'componentVersions': o.componentVersions,
    };
  }

  static PlatformOverride _platformOverrideFromJson(Map<String, dynamic>? j) {
    if (j == null || j.isEmpty) return const PlatformOverride();
    return PlatformOverride(
      colors: j.containsKey('colors') ? _colorsFromJson(Map<String, dynamic>.from(j['colors'] as Map)) : null,
      typography: j.containsKey('typography') ? _typographyFromJson(Map<String, dynamic>.from(j['typography'] as Map)) : null,
      spacing: j.containsKey('spacing') ? Spacing(scale: List<int>.from(j['spacing']['scale'] as List), values: Map<String, String>.from(j['spacing']['values'] as Map<String, dynamic>)) : null,
      borderRadius: j.containsKey('borderRadius') ? BorderRadius(none: j['borderRadius']['none'] as String, sm: j['borderRadius']['sm'] as String, base: j['borderRadius']['base'] as String, md: j['borderRadius']['md'] as String, lg: j['borderRadius']['lg'] as String, xl: j['borderRadius']['xl'] as String, full: j['borderRadius']['full'] as String) : null,
      shadows: j.containsKey('shadows') ? Shadows(values: (j['shadows'] as Map<String, dynamic>).map((key, s) => MapEntry(key, ShadowValue(value: s['value'] as String, description: s['description'] as String?)))) : null,
      effects: j.containsKey('effects') ? Effects(glassMorphism: j['effects']['glassMorphism'] as Map<String, dynamic>?, darkOverlay: j['effects']['darkOverlay'] as Map<String, dynamic>?) : null,
      components: j.containsKey('components')
          ? Components(
              buttons: Map<String, dynamic>.from(j['components']['buttons'] as Map),
              cards: Map<String, dynamic>.from(j['components']['cards'] as Map),
              inputs: Map<String, dynamic>.from(j['components']['inputs'] as Map),
              navigation: Map<String, dynamic>.from(j['components']['navigation'] as Map),
              avatars: Map<String, dynamic>.from(j['components']['avatars'] as Map),
              modals: j['components']['modals'] != null ? Map<String, dynamic>.from(j['components']['modals'] as Map) : null,
              tables: j['components']['tables'] != null ? Map<String, dynamic>.from(j['components']['tables'] as Map) : null,
              progress: j['components']['progress'] != null ? Map<String, dynamic>.from(j['components']['progress'] as Map) : null,
              alerts: j['components']['alerts'] != null ? Map<String, dynamic>.from(j['components']['alerts'] as Map) : null,
            )
          : null,
      grid: j.containsKey('grid')
          ? Grid(
              columns: j['grid']['columns'] as int,
              gutter: j['grid']['gutter'] as String,
              margin: j['grid']['margin'] as String,
              breakpoints: Map<String, String>.from(j['grid']['breakpoints'] as Map<String, dynamic>),
            )
          : null,
      icons: j.containsKey('icons') ? _iconsFromJson(j['icons']) : null,
      gradients: j.containsKey('gradients')
          ? Gradients(
              values: (j['gradients'] as Map<String, dynamic>).map((key, g) => MapEntry(
                key,
                GradientValue(
                  type: g['type'] as String,
                  direction: g['direction'] as String,
                  colors: List<String>.from(g['colors'] as List),
                  stops: List<int>.from(g['stops'] as List),
                ),
              )),
            )
          : null,
      roles: j.containsKey('roles')
          ? Roles(
              values: (j['roles'] as Map<String, dynamic>).map((key, r) => MapEntry(
                key,
                RoleValue(
                  primaryColor: r['primaryColor'] as String,
                  accentColor: r['accentColor'] as String,
                  background: r['background'] as String,
                ),
              )),
            )
          : null,
      semanticTokens: j.containsKey('semanticTokens')
          ? SemanticTokens(
              color: Map<String, dynamic>.from(j['semanticTokens']['color'] as Map? ?? {}),
              typography: Map<String, dynamic>.from(j['semanticTokens']['typography'] as Map? ?? {}),
              spacing: Map<String, dynamic>.from(j['semanticTokens']['spacing'] as Map? ?? {}),
              shadow: Map<String, dynamic>.from(j['semanticTokens']['shadow'] as Map? ?? {}),
              borderRadius: Map<String, dynamic>.from(j['semanticTokens']['borderRadius'] as Map? ?? {}),
            )
          : null,
      motionTokens: j.containsKey('motionTokens')
          ? MotionTokens(
              duration: Map<String, String>.from(j['motionTokens']['duration'] as Map? ?? {}),
              easing: Map<String, String>.from(j['motionTokens']['easing'] as Map? ?? {}),
            )
          : null,
      componentVersions: j['componentVersions'] != null ? Map<String, String>.from(j['componentVersions'] as Map<String, dynamic>) : null,
    );
  }

  static Map<String, PlatformOverride>? _platformOverridesFromJson(dynamic raw) {
    if (raw == null || raw is! Map) return null;
    final map = <String, PlatformOverride>{};
    for (final e in raw.entries) {
      if (e.value is Map) map[e.key as String] = _platformOverrideFromJson(Map<String, dynamic>.from(e.value as Map));
    }
    return map.isEmpty ? null : map;
  }

  /// New format: `{ sizes, projectIcons }`. Legacy: flat map of size tokens only.
  static Icons _iconsFromJson(dynamic raw) {
    if (raw == null) return Icons.empty();
    if (raw is! Map) return Icons.empty();
    final m = Map<String, dynamic>.from(raw);
    if (m.containsKey('sizes')) {
      return Icons(
        sizes: Map<String, String>.from(m['sizes'] as Map),
        projectIcons: (m['projectIcons'] as List<dynamic>? ?? [])
            .map((e) => ProjectIconEntry.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
      );
    }
    return Icons(
      sizes: Map<String, String>.from(m),
      projectIcons: const [],
    );
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
        modals: json['components']['modals'] != null ? Map<String, dynamic>.from(json['components']['modals'] as Map) : null,
        tables: json['components']['tables'] != null ? Map<String, dynamic>.from(json['components']['tables'] as Map) : null,
        progress: json['components']['progress'] != null ? Map<String, dynamic>.from(json['components']['progress'] as Map) : null,
        alerts: json['components']['alerts'] != null ? Map<String, dynamic>.from(json['components']['alerts'] as Map) : null,
      ),
      grid: Grid(
        columns: json['grid']['columns'] as int,
        gutter: json['grid']['gutter'] as String,
        margin: json['grid']['margin'] as String,
        breakpoints: Map<String, String>.from(json['grid']['breakpoints'] as Map<String, dynamic>),
      ),
      icons: _iconsFromJson(json['icons']),
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
      semanticTokens: json['semanticTokens'] != null
          ? SemanticTokens(
              color: Map<String, dynamic>.from(json['semanticTokens']['color'] as Map? ?? {}),
              typography: Map<String, dynamic>.from(json['semanticTokens']['typography'] as Map? ?? {}),
              spacing: Map<String, dynamic>.from(json['semanticTokens']['spacing'] as Map? ?? {}),
              shadow: Map<String, dynamic>.from(json['semanticTokens']['shadow'] as Map? ?? {}),
              borderRadius: Map<String, dynamic>.from(json['semanticTokens']['borderRadius'] as Map? ?? {}),
            )
          : SemanticTokens.empty(),
      motionTokens: json['motionTokens'] != null
          ? MotionTokens(
              duration: Map<String, String>.from(json['motionTokens']['duration'] as Map? ?? {}),
              easing: Map<String, String>.from(json['motionTokens']['easing'] as Map? ?? {}),
            )
          : MotionTokens.empty(),
      lastModified: json['lastModified'] as String?,
      versionHistory: json['versionHistory'] != null
          ? (json['versionHistory'] as List).map((v) => VersionHistory(
                version: v['version'] as String,
                date: v['date'] as String,
                changes: List<String>.from(v['changes'] as List),
                description: v['description'] as String?,
              )).toList()
          : null,
      componentVersions: json['componentVersions'] != null
          ? Map<String, String>.from(json['componentVersions'] as Map<String, dynamic>)
          : null,
      targetPlatforms: json['targetPlatforms'] != null
          ? List<String>.from(json['targetPlatforms'] as List)
          : const ['web'],
      platformOverrides: _platformOverridesFromJson(json['platformOverrides']),
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
