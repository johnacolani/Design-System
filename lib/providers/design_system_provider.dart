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
    _designSystem = designSystem;
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
    );
    notifyListeners();
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
