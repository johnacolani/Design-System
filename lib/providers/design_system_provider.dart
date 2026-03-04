import 'package:flutter/material.dart';
import '../models/design_system.dart' as models;
import '../services/project_service.dart';

class DesignSystemProvider extends ChangeNotifier {
  models.DesignSystem _designSystem = models.DesignSystem.empty();
  bool _hasProject = false;

  models.DesignSystem get designSystem => _designSystem;
  bool get hasProject => _hasProject;

  void createNewProject({
    required String name,
    required String description,
    Color? primaryColor,
  }) {
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
    );

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

  void updateDesignSystem(models.DesignSystem designSystem) {
    // Preserve version history and update lastModified
    _designSystem = models.DesignSystem(
      name: designSystem.name,
      version: designSystem.version,
      description: designSystem.description,
      created: designSystem.created,
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
      lastModified: DateTime.now().toIso8601String(),
      versionHistory: designSystem.versionHistory ?? _designSystem.versionHistory,
      componentVersions: designSystem.componentVersions ?? _designSystem.componentVersions,
    );
    notifyListeners();
  }

  void updateColors(models.Colors colors) {
    _designSystem = models.DesignSystem(
      name: _designSystem.name,
      version: _designSystem.version,
      description: _designSystem.description,
      created: _designSystem.created,
      colors: colors,
      typography: _designSystem.typography,
      spacing: _designSystem.spacing,
      borderRadius: _designSystem.borderRadius,
      shadows: _designSystem.shadows,
      effects: _designSystem.effects,
      components: _designSystem.components,
      grid: _designSystem.grid,
      icons: _designSystem.icons,
      gradients: _designSystem.gradients,
      roles: _designSystem.roles,
      semanticTokens: _designSystem.semanticTokens,
      motionTokens: _designSystem.motionTokens,
      lastModified: _designSystem.lastModified,
      versionHistory: _designSystem.versionHistory,
      componentVersions: _designSystem.componentVersions,
    );
    notifyListeners();
  }

  void updateTypography(models.Typography typography) {
    _designSystem = models.DesignSystem(
      name: _designSystem.name,
      version: _designSystem.version,
      description: _designSystem.description,
      created: _designSystem.created,
      colors: _designSystem.colors,
      typography: typography,
      spacing: _designSystem.spacing,
      borderRadius: _designSystem.borderRadius,
      shadows: _designSystem.shadows,
      effects: _designSystem.effects,
      components: _designSystem.components,
      grid: _designSystem.grid,
      icons: _designSystem.icons,
      gradients: _designSystem.gradients,
      roles: _designSystem.roles,
      semanticTokens: _designSystem.semanticTokens,
      motionTokens: _designSystem.motionTokens,
      lastModified: DateTime.now().toIso8601String(),
      versionHistory: _designSystem.versionHistory,
      componentVersions: _designSystem.componentVersions,
    );
    notifyListeners();
  }

  void updateSpacing(models.Spacing spacing) {
    _designSystem = models.DesignSystem(
      name: _designSystem.name,
      version: _designSystem.version,
      description: _designSystem.description,
      created: _designSystem.created,
      colors: _designSystem.colors,
      typography: _designSystem.typography,
      spacing: spacing,
      borderRadius: _designSystem.borderRadius,
      shadows: _designSystem.shadows,
      effects: _designSystem.effects,
      components: _designSystem.components,
      grid: _designSystem.grid,
      icons: _designSystem.icons,
      gradients: _designSystem.gradients,
      roles: _designSystem.roles,
      semanticTokens: _designSystem.semanticTokens,
      motionTokens: _designSystem.motionTokens,
      lastModified: _designSystem.lastModified,
      versionHistory: _designSystem.versionHistory,
      componentVersions: _designSystem.componentVersions,
    );
    notifyListeners();
  }

  void updateSemanticTokens(models.SemanticTokens semanticTokens) {
    _designSystem = models.DesignSystem(
      name: _designSystem.name,
      version: _designSystem.version,
      description: _designSystem.description,
      created: _designSystem.created,
      colors: _designSystem.colors,
      typography: _designSystem.typography,
      spacing: _designSystem.spacing,
      borderRadius: _designSystem.borderRadius,
      shadows: _designSystem.shadows,
      effects: _designSystem.effects,
      components: _designSystem.components,
      grid: _designSystem.grid,
      icons: _designSystem.icons,
      gradients: _designSystem.gradients,
      roles: _designSystem.roles,
      semanticTokens: semanticTokens,
      motionTokens: _designSystem.motionTokens,
      lastModified: _designSystem.lastModified,
      versionHistory: _designSystem.versionHistory,
      componentVersions: _designSystem.componentVersions,
    );
    notifyListeners();
  }

  void updateMotionTokens(models.MotionTokens motionTokens) {
    _designSystem = models.DesignSystem(
      name: _designSystem.name,
      version: _designSystem.version,
      description: _designSystem.description,
      created: _designSystem.created,
      colors: _designSystem.colors,
      typography: _designSystem.typography,
      spacing: _designSystem.spacing,
      borderRadius: _designSystem.borderRadius,
      shadows: _designSystem.shadows,
      effects: _designSystem.effects,
      components: _designSystem.components,
      grid: _designSystem.grid,
      icons: _designSystem.icons,
      gradients: _designSystem.gradients,
      roles: _designSystem.roles,
      semanticTokens: _designSystem.semanticTokens,
      motionTokens: motionTokens,
      lastModified: _designSystem.lastModified,
      versionHistory: _designSystem.versionHistory,
      componentVersions: _designSystem.componentVersions,
    );
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
    
    _designSystem = models.DesignSystem(
      name: _designSystem.name,
      version: version,
      description: _designSystem.description,
      created: _designSystem.created,
      colors: _designSystem.colors,
      typography: _designSystem.typography,
      spacing: _designSystem.spacing,
      borderRadius: _designSystem.borderRadius,
      shadows: _designSystem.shadows,
      effects: _designSystem.effects,
      components: _designSystem.components,
      grid: _designSystem.grid,
      icons: _designSystem.icons,
      gradients: _designSystem.gradients,
      roles: _designSystem.roles,
      semanticTokens: _designSystem.semanticTokens,
      motionTokens: _designSystem.motionTokens,
      lastModified: DateTime.now().toIso8601String(),
      versionHistory: history,
      componentVersions: _designSystem.componentVersions,
    );
    notifyListeners();
  }

  /// Bump component version (e.g. "buttons", "primary" -> v2). Helps teams maintain stability.
  void bumpComponentVersion(String category, String componentName) {
    final key = '$category.$componentName';
    final versions = Map<String, String>.from(_designSystem.componentVersions ?? {});
    final current = int.tryParse(versions[key] ?? '1') ?? 1;
    versions[key] = '${current + 1}';
    _designSystem = models.DesignSystem(
      name: _designSystem.name,
      version: _designSystem.version,
      description: _designSystem.description,
      created: _designSystem.created,
      colors: _designSystem.colors,
      typography: _designSystem.typography,
      spacing: _designSystem.spacing,
      borderRadius: _designSystem.borderRadius,
      shadows: _designSystem.shadows,
      effects: _designSystem.effects,
      components: _designSystem.components,
      grid: _designSystem.grid,
      icons: _designSystem.icons,
      gradients: _designSystem.gradients,
      roles: _designSystem.roles,
      semanticTokens: _designSystem.semanticTokens,
      motionTokens: _designSystem.motionTokens,
      lastModified: DateTime.now().toIso8601String(),
      versionHistory: _designSystem.versionHistory,
      componentVersions: versions,
    );
    notifyListeners();
  }

  int getComponentVersion(String category, String componentName) {
    final key = '$category.$componentName';
    final v = _designSystem.componentVersions?[key];
    return int.tryParse(v ?? '1') ?? 1;
  }

  void loadProject(models.DesignSystem designSystem) {
    _designSystem = designSystem;
    _hasProject = true;
    notifyListeners();
  }

  /// Save current project to disk
  Future<String> saveProject() async {
    return await ProjectService.saveProject(_designSystem);
  }

  /// Load project from file path
  Future<void> loadProjectFromPath(String filePath) async {
    final designSystem = await ProjectService.loadProject(filePath);
    loadProject(designSystem);
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
    notifyListeners();
  }
}
