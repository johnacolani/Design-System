import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../data/demo_design_systems.dart';
import '../models/design_system.dart' as models;
import '../services/project_service.dart';

class DesignSystemProvider extends ChangeNotifier {
  models.DesignSystem _designSystem = models.DesignSystem.empty();
  bool _hasProject = false;
  /// When set, saveProject() writes to this path instead of default location (desktop/mobile only).
  String? _currentProjectPath;
  /// When multi-platform, which platform section is being viewed/edited ('ios'|'android'|'web').
  String? _currentPlatform;

  /// Raw design system (base + platform overrides map). Use for save/load.
  models.DesignSystem get rawDesignSystem => _designSystem;
  /// Design system for the current platform (base merged with platform override when multi-platform). All screens use this.
  models.DesignSystem get effectiveDesignSystem =>
      _currentPlatform != null &&
              _designSystem.platformOverrides != null &&
              _designSystem.platformOverrides!.containsKey(_currentPlatform)
          ? _designSystem.withPlatformOverride(_currentPlatform!)
          : _designSystem;
  bool get hasProject => _hasProject;
  String? get currentProjectPath => _currentProjectPath;
  List<String> get targetPlatforms => _designSystem.targetPlatforms;
  String? get currentPlatform => _currentPlatform;
  bool get isMultiPlatform => _designSystem.isMultiPlatform;
  /// Same as [effectiveDesignSystem] — use for all read/edit flows so platform section is correct.
  models.DesignSystem get designSystem => effectiveDesignSystem;

  /// Design system merged for a specific platform (for token screens that show one section per platform).
  models.DesignSystem designSystemForPlatform(String platform) =>
      _designSystem.platformOverrides != null && _designSystem.platformOverrides!.containsKey(platform)
          ? _designSystem.withPlatformOverride(platform)
          : _designSystem;

  void _setPlatformOverride(String platform, models.PlatformOverride override) {
    _designSystem = _designSystem.copyWith(
      platformOverrides: {...?_designSystem.platformOverrides, platform: override},
      lastModified: DateTime.now().toIso8601String(),
    );
  }

  void updateColorsForPlatform(String platform, models.Colors colors) {
    final o = _designSystem.platformOverrides?[platform] ?? const models.PlatformOverride();
    _setPlatformOverride(platform, o.copyWith(colors: colors));
    notifyListeners();
  }

  void updateTypographyForPlatform(String platform, models.Typography typography) {
    final o = _designSystem.platformOverrides?[platform] ?? const models.PlatformOverride();
    _setPlatformOverride(platform, o.copyWith(typography: typography));
    notifyListeners();
  }

  void updateIconsForPlatform(String platform, models.Icons icons) {
    final o = _designSystem.platformOverrides?[platform] ?? const models.PlatformOverride();
    _setPlatformOverride(platform, o.copyWith(icons: icons));
    notifyListeners();
  }

  void setCurrentProjectPath(String? path) {
    _currentProjectPath = path;
    notifyListeners();
  }

  void setCurrentPlatform(String? platform) {
    if (_currentPlatform == platform) return;
    _currentPlatform = platform;
    notifyListeners();
  }

  void createNewProject({
    required String name,
    required String description,
    Color? primaryColor,
    List<String>? targetPlatforms,
  }) {
    final platforms = targetPlatforms ?? const ['web'];
    _designSystem = models.DesignSystem(
      name: name,
      version: '1.0.0',
      description: description,
      created: DateTime.now().toIso8601String().split('T')[0],
      colors: models.Colors.empty(),
      typography: models.Typography.empty(),
      spacing: models.Spacing.empty(),
      borderRadius: models.BorderRadius.empty(),
      shadows: models.Shadows.empty(),
      effects: models.Effects.empty(),
      components: models.Components.empty(),
      grid: models.Grid.empty(),
      icons: models.Icons.empty(),
      gradients: models.Gradients.empty(),
      roles: models.Roles.empty(),
      semanticTokens: models.SemanticTokens.empty(),
      motionTokens: models.MotionTokens.empty(),
      lastModified: DateTime.now().toIso8601String(),
      versionHistory: [
        models.VersionHistory(
          version: '1.0.0',
          date: DateTime.now().toIso8601String(),
          changes: ['Initial project creation'],
        ),
      ],
      componentVersions: {},
      targetPlatforms: platforms,
      platformOverrides: platforms.length > 1 ? {} : null,
    );

    _currentPlatform = platforms.length > 1 ? platforms.first : null;

    // Set primary color if provided
    if (primaryColor != null) {
      final colorHex = '#${primaryColor.value.toRadixString(16).substring(2).toUpperCase()}';
      _designSystem.colors.primary['primary'] = {
        'value': colorHex,
        'type': 'color',
        'description': 'Primary brand color',
      };
    }

    _hasProject = true;
    notifyListeners();
  }

  void _applyToCurrentPlatform(models.PlatformOverride Function(models.PlatformOverride? o) update) {
    if (_currentPlatform == null) return;
    final o = _designSystem.platformOverrides?[_currentPlatform];
    final next = update(o);
    _designSystem = _designSystem.copyWith(
      platformOverrides: {...?_designSystem.platformOverrides, _currentPlatform!: next},
    );
  }

  void updateDesignSystem(models.DesignSystem designSystem) {
    if (_currentPlatform == null) {
      _designSystem = designSystem.copyWith(
        targetPlatforms: _designSystem.targetPlatforms,
        platformOverrides: _designSystem.platformOverrides,
        lastModified: DateTime.now().toIso8601String(),
        versionHistory: designSystem.versionHistory ?? _designSystem.versionHistory,
        componentVersions: designSystem.componentVersions ?? _designSystem.componentVersions,
      );
    } else {
      _designSystem = _designSystem.copyWith(
        platformOverrides: {
          ...?_designSystem.platformOverrides,
          _currentPlatform!: models.PlatformOverride(
            colors: designSystem.colors,
            typography: designSystem.typography,
            spacing: designSystem.spacing,
            borderRadius: designSystem.borderRadius,
            shadows: designSystem.shadows,
            effects: designSystem.effects,
            components: designSystem.components,
            grid: designSystem.grid,
            icons: designSystem.icons,
            gradients: designSystem.gradients,
            roles: designSystem.roles,
            semanticTokens: designSystem.semanticTokens,
            motionTokens: designSystem.motionTokens,
            componentVersions: designSystem.componentVersions,
          ),
        },
        lastModified: DateTime.now().toIso8601String(),
      );
    }
    notifyListeners();
  }

  void updateColors(models.Colors colors) {
    if (_currentPlatform == null) {
      _designSystem = _designSystem.copyWith(colors: colors);
    } else {
      _applyToCurrentPlatform((o) => (o ?? const models.PlatformOverride()).copyWith(colors: colors));
    }
    notifyListeners();
  }

  void updateTypography(models.Typography typography) {
    if (_currentPlatform == null) {
      _designSystem = _designSystem.copyWith(typography: typography);
    } else {
      _applyToCurrentPlatform((o) => (o ?? const models.PlatformOverride()).copyWith(typography: typography));
    }
    notifyListeners();
  }

  void updateSpacing(models.Spacing spacing) {
    if (_currentPlatform == null) {
      _designSystem = _designSystem.copyWith(spacing: spacing);
    } else {
      _applyToCurrentPlatform((o) => (o ?? const models.PlatformOverride()).copyWith(spacing: spacing));
    }
    notifyListeners();
  }

  void updateSemanticTokens(models.SemanticTokens semanticTokens) {
    if (_currentPlatform == null) {
      _designSystem = _designSystem.copyWith(semanticTokens: semanticTokens);
    } else {
      _applyToCurrentPlatform((o) => (o ?? const models.PlatformOverride()).copyWith(semanticTokens: semanticTokens));
    }
    notifyListeners();
  }

  void updateMotionTokens(models.MotionTokens motionTokens) {
    if (_currentPlatform == null) {
      _designSystem = _designSystem.copyWith(motionTokens: motionTokens);
    } else {
      _applyToCurrentPlatform((o) => (o ?? const models.PlatformOverride()).copyWith(motionTokens: motionTokens));
    }
    notifyListeners();
  }

  void addVersionHistory(String version, List<String> changes, {String? description}) {
    final history = List<models.VersionHistory>.from(_designSystem.versionHistory ?? []);
    history.insert(0, models.VersionHistory(
      version: version,
      date: DateTime.now().toIso8601String(),
      changes: changes,
      description: description,
    ));
    _designSystem = _designSystem.copyWith(version: version, versionHistory: history, lastModified: DateTime.now().toIso8601String());
    notifyListeners();
  }

  /// Bump component version (e.g. "buttons", "primary" -> v2). Helps teams maintain stability.
  void bumpComponentVersion(String category, String componentName) {
    final key = '$category.$componentName';
    final versions = Map<String, String>.from(_designSystem.componentVersions ?? {});
    final current = int.tryParse(versions[key] ?? '1') ?? 1;
    versions[key] = '${current + 1}';
    if (_currentPlatform == null) {
      _designSystem = _designSystem.copyWith(componentVersions: versions, lastModified: DateTime.now().toIso8601String());
    } else {
      _applyToCurrentPlatform((o) => (o ?? const models.PlatformOverride()).copyWith(componentVersions: versions));
      _designSystem = _designSystem.copyWith(lastModified: DateTime.now().toIso8601String());
    }
    notifyListeners();
  }

  int getComponentVersion(String category, String componentName) {
    final key = '$category.$componentName';
    final v = effectiveDesignSystem.componentVersions?[key];
    return int.tryParse(v ?? '1') ?? 1;
  }

  void loadProject(models.DesignSystem designSystem) {
    _designSystem = designSystem;
    _currentPlatform = designSystem.isMultiPlatform && designSystem.targetPlatforms.isNotEmpty
        ? designSystem.targetPlatforms.first
        : null;
    _hasProject = true;
    notifyListeners();
  }

  /// Save current project to disk (uses [currentProjectPath] when set on desktop/mobile).
  Future<String> saveProject() async {
    if (!kIsWeb && _currentProjectPath != null && _currentProjectPath!.isNotEmpty) {
      return await ProjectService.saveProjectToFile(_designSystem, _currentProjectPath!);
    }
    return await ProjectService.saveProject(_designSystem);
  }

  /// Load project from file path (also sets [currentProjectPath] so future saves go to same file).
  Future<void> loadProjectFromPath(String filePath) async {
    final designSystem = await ProjectService.loadProject(filePath);
    loadProject(designSystem);
    // Track storage key/path on all platforms so delete + reset works on web too.
    setCurrentProjectPath(filePath);
  }

  /// Get list of all saved projects
  Future<List<ProjectInfo>> getProjectList() async {
    return await ProjectService.getProjectList();
  }

  /// Delete a project
  Future<void> deleteProject(String filePath) async {
    await ProjectService.deleteProject(filePath);
    notifyListeners();
  }

  void reset() {
    _designSystem = models.DesignSystem.empty();
    _hasProject = false;
    _currentProjectPath = null;
    _currentPlatform = null;
    notifyListeners();
  }

  /// Load a built-in demo preset ([DemoDesignSystems] ids). Not tied to a file until user saves.
  void loadDemoDesignSystem(String demoId) {
    loadProject(DemoDesignSystems.byId(demoId));
    setCurrentProjectPath(null);
  }
}
