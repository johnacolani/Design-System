import 'package:flutter/material.dart';
import '../models/design_system.dart';

class DesignSystemProvider extends ChangeNotifier {
  DesignSystem _designSystem = DesignSystem.empty();
  bool _hasProject = false;

  DesignSystem get designSystem => _designSystem;
  bool get hasProject => _hasProject;

  void createNewProject({
    required String name,
    required String description,
    Color? primaryColor,
  }) {
    _designSystem = DesignSystem(
      name: name,
      version: '1.0.0',
      description: description,
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

  void updateDesignSystem(DesignSystem designSystem) {
    _designSystem = designSystem;
    notifyListeners();
  }

  void updateColors(Colors colors) {
    _designSystem = DesignSystem(
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

  void updateTypography(Typography typography) {
    _designSystem = DesignSystem(
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

  void loadProject(DesignSystem designSystem) {
    _designSystem = designSystem;
    _hasProject = true;
    notifyListeners();
  }

  void reset() {
    _designSystem = DesignSystem.empty();
    _hasProject = false;
    notifyListeners();
  }
}
