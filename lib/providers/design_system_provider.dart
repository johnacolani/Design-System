import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:flutter/material.dart';
import '../data/demo_design_systems.dart';
import '../models/design_system.dart' as models;
import '../services/project_service.dart';
import '../services/cloud_project_service.dart';
import '../services/admin_design_system_service.dart';
import '../models/design_system_wrapper.dart';

/// Groups platforms for design token UI: single column for one platform, or iOS vs Android & Web (Material).
class TokenDisplayGroup {
  const TokenDisplayGroup({required this.label, required this.platforms});
  final String label;
  final List<String> platforms;
  String get primaryPlatform => platforms.isNotEmpty ? platforms.first : 'web';
}

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

  /// For design token screens: one group = one column; two groups = iOS (Cupertino) + Android & Web (Material).
  List<TokenDisplayGroup> get designTokenDisplayGroups {
    final p = _designSystem.targetPlatforms;
    if (p.isEmpty) return [const TokenDisplayGroup(label: 'Web', platforms: ['web'])];
    if (p.length == 1) {
      final label = p.first == 'ios' ? 'iOS' : p.first == 'android' ? 'Android' : 'Web';
      return [TokenDisplayGroup(label: label, platforms: p)];
    }
    final ios = p.where((e) => e.toLowerCase() == 'ios').toList();
    final material = p.where((e) => e.toLowerCase() == 'android' || e.toLowerCase() == 'web').toList();
    if (ios.isEmpty) {
      final label = material.length > 1 ? 'Android & Web' : (material.first == 'android' ? 'Android' : 'Web');
      return [TokenDisplayGroup(label: label, platforms: material)];
    }
    if (material.isEmpty) return [TokenDisplayGroup(label: 'iOS', platforms: ios)];
    final materialLabel = material.length > 1 ? 'Android & Web (Material)' : (material.first == 'android' ? 'Android (Material)' : 'Web (Material)');
    return [
      const TokenDisplayGroup(label: 'iOS (Cupertino)', platforms: ['ios']),
      TokenDisplayGroup(label: materialLabel, platforms: material),
    ];
  }

  void updateColorsForGroup(TokenDisplayGroup group, models.Colors colors) {
    for (final platform in group.platforms) {
      updateColorsForPlatform(platform, colors);
    }
  }

  void updateTypographyForGroup(TokenDisplayGroup group, models.Typography typography) {
    for (final platform in group.platforms) {
      updateTypographyForPlatform(platform, typography);
    }
  }

  void updateIconsForGroup(TokenDisplayGroup group, models.Icons icons) {
    for (final platform in group.platforms) {
      updateIconsForPlatform(platform, icons);
    }
  }

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

  models.DesignSystem _buildDuplicate(models.DesignSystem source, String trimmedName) {
    final now = DateTime.now();
    final nowIso = now.toIso8601String();
    final createdDate = nowIso.split('T')[0];
    final cloned = DesignSystemWrapper.cloneDesignSystem(source);
    final priorName = source.name;
    final history = List<models.VersionHistory>.from(cloned.versionHistory ?? []);
    history.insert(
      0,
      models.VersionHistory(
        version: cloned.version,
        date: nowIso,
        changes: [
          if (priorName.isNotEmpty) 'Duplicated from "$priorName"' else 'Duplicated project',
        ],
      ),
    );
    return cloned.copyWith(
      name: trimmedName,
      created: createdDate,
      lastModified: nowIso,
      versionHistory: history,
    );
  }

  /// Full copy of the current project (including platform overrides) under a new name.
  /// Clears [currentProjectPath] so the next save creates a new file or cloud document.
  void duplicateProjectAs(String newName) {
    final trimmed = newName.trim();
    if (trimmed.isEmpty) return;
    loadProject(_buildDuplicate(_designSystem, trimmed));
    setCurrentProjectPath(null);
  }

  /// Load a project from [sourcePath], clone it, and save as a new project (local + optional cloud).
  /// Returns the storage path/key for the new copy (same as [saveProject]).
  Future<String> duplicateProjectFromPath(
    String sourcePath,
    String newName, {
    String? firebaseUid,
    void Function(Object? error)? onCloudSyncCompleted,
    /// When true (admin flows), also writes a snapshot under `users/{uid}/design_systems` for auditing.
    bool snapshotToAdminDesignSystems = false,
  }) async {
    final trimmed = newName.trim();
    if (trimmed.isEmpty) throw ArgumentError('newName cannot be empty');

    models.DesignSystem source;
    if (CloudProjectService.isCloudProjectPath(sourcePath)) {
      final uid = firebaseUid;
      if (uid == null || uid.isEmpty || uid.startsWith('guest_')) {
        throw Exception('Sign in to duplicate cloud projects');
      }
      final docId = CloudProjectService.docIdFromCloudPath(sourcePath);
      source = await CloudProjectService.loadProject(uid, docId);
    } else {
      source = await ProjectService.loadProject(sourcePath);
    }

    final next = _buildDuplicate(source, trimmed);
    final path = await ProjectService.saveProject(next);

    final uid = firebaseUid;
    if (uid != null && uid.isNotEmpty && !uid.startsWith('guest_')) {
      try {
        await CloudProjectService.upsertProject(uid, next);
        if (snapshotToAdminDesignSystems) {
          try {
            await AdminDesignSystemService.saveDesignSystemForAdmin(
              adminUserId: uid,
              designSystem: next,
            );
          } catch (e, st) {
            debugPrint('duplicateProjectFromPath admin snapshot failed: $e\n$st');
          }
        }
        onCloudSyncCompleted?.call(null);
      } catch (e, st) {
        debugPrint('duplicateProjectFromPath cloud sync failed: $e\n$st');
        onCloudSyncCompleted?.call(e);
      }
    } else {
      onCloudSyncCompleted?.call(null);
    }

    return path;
  }

  /// Save current project to disk (uses [currentProjectPath] when set on desktop/mobile).
  ///
  /// When [firebaseUid] is a real signed-in user id, also upserts `users/{uid}/projects/{docId}`
  /// in Firestore. Local save always runs first; cloud failures are reported via [onCloudSyncCompleted].
  Future<String> saveProject({
    String? firebaseUid,
    void Function(Object? error)? onCloudSyncCompleted,
  }) async {
    final String path;
    final customLocal = !kIsWeb &&
        _currentProjectPath != null &&
        _currentProjectPath!.isNotEmpty &&
        !CloudProjectService.isCloudProjectPath(_currentProjectPath!);
    if (customLocal) {
      path = await ProjectService.saveProjectToFile(_designSystem, _currentProjectPath!);
    } else {
      path = await ProjectService.saveProject(_designSystem);
    }

    final uid = firebaseUid;
    if (uid != null && uid.isNotEmpty && !uid.startsWith('guest_')) {
      try {
        await CloudProjectService.upsertProject(uid, _designSystem);
        onCloudSyncCompleted?.call(null);
      } catch (e, st) {
        debugPrint('saveProject cloud sync failed: $e\n$st');
        onCloudSyncCompleted?.call(e);
      }
    } else {
      onCloudSyncCompleted?.call(null);
    }
    return path;
  }

  /// Upload current design system to Firestore without touching local storage.
  Future<void> syncToCloud(String firebaseUid) async {
    if (firebaseUid.isEmpty || firebaseUid.startsWith('guest_')) return;
    await CloudProjectService.upsertProject(firebaseUid, _designSystem);
  }

  /// Load project from file path (also sets [currentProjectPath] so future saves go to same file).
  ///
  /// For Firestore paths (`cloud:…`), pass [firebaseUid] of the signed-in user.
  Future<void> loadProjectFromPath(String filePath, {String? firebaseUid}) async {
    final models.DesignSystem designSystem;
    if (CloudProjectService.isCloudProjectPath(filePath)) {
      final uid = firebaseUid;
      if (uid == null || uid.isEmpty || uid.startsWith('guest_')) {
        throw Exception('Sign in to open cloud projects');
      }
      final docId = CloudProjectService.docIdFromCloudPath(filePath);
      designSystem = await CloudProjectService.loadProject(uid, docId);
    } else {
      designSystem = await ProjectService.loadProject(filePath);
    }
    loadProject(designSystem);
    // Track storage key/path on all platforms so delete + reset works on web too.
    setCurrentProjectPath(filePath);
  }

  /// Get list of all saved projects (local + optional Firestore when [firebaseUid] is signed-in).
  ///
  /// Cloud and browser/desktop copies of the **same** project share one canonical stem (`asd_app`);
  /// without deduping, the UI showed duplicate cards for one design system.
  Future<List<ProjectInfo>> getProjectList({String? firebaseUid}) async {
    final local = await ProjectService.getProjectList();
    final uid = firebaseUid;
    if (uid == null || uid.isEmpty || uid.startsWith('guest_')) {
      return local;
    }
    try {
      final cloud = await CloudProjectService.listProjects(uid);
      return _mergeProjectListsPreferCloud(cloud, local);
    } catch (e, st) {
      debugPrint('getProjectList cloud: $e\n$st');
      return local;
    }
  }

  /// One row per logical project: same stem in Firestore and local prefs/files counts once (cloud wins).
  List<ProjectInfo> _mergeProjectListsPreferCloud(
    List<ProjectInfo> cloud,
    List<ProjectInfo> local,
  ) {
    String stem(ProjectInfo p) {
      if (p.fromCloud) {
        return CloudProjectService.docIdFromCloudPath(p.filePath);
      }
      return ProjectService.canonicalStemFromStoragePath(p.filePath);
    }

    final byStem = <String, ProjectInfo>{};
    for (final p in local) {
      byStem[stem(p)] = p;
    }
    for (final p in cloud) {
      byStem[stem(p)] = p;
    }
    final out = byStem.values.toList();
    out.sort((a, b) => b.modified.compareTo(a.modified));
    return out;
  }

  /// Delete a project
  Future<void> deleteProject(String filePath, {String? firebaseUid}) async {
    if (CloudProjectService.isCloudProjectPath(filePath)) {
      final uid = firebaseUid;
      if (uid == null || uid.isEmpty || uid.startsWith('guest_')) {
        throw Exception('Sign in to delete cloud projects');
      }
      final docId = CloudProjectService.docIdFromCloudPath(filePath);
      await CloudProjectService.deleteProject(uid, docId);
    } else {
      await ProjectService.deleteProject(filePath);
    }
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
