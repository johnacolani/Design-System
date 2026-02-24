import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import '../models/design_system.dart' as models;
import '../models/design_system_wrapper.dart';

class ProjectService {
  static const String _projectsFolder = 'design_systems';
  static const String _projectExtension = '.ds.json';

  /// Get the directory where projects are stored
  static Future<Directory> _getProjectsDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final projectsDir = Directory('${appDir.path}/$_projectsFolder');
    if (!await projectsDir.exists()) {
      await projectsDir.create(recursive: true);
    }
    return projectsDir;
  }

  /// Save a design system project to disk
  static Future<String> saveProject(models.DesignSystem designSystem) async {
    try {
      final projectsDir = await _getProjectsDirectory();
      final fileName = _sanitizeFileName(designSystem.name);
      final file = File('${projectsDir.path}/$fileName$_projectExtension');

      // Create wrapper for JSON structure
      final wrapper = DesignSystemWrapper(designSystem: designSystem);
      
      // Convert to JSON manually (since serialization is commented out)
      final json = wrapper.toJson();
      final jsonString = const JsonEncoder.withIndent('  ').convert(json);
      
      await file.writeAsString(jsonString);
      return file.path;
    } catch (e) {
      throw Exception('Failed to save project: $e');
    }
  }

  /// Load a design system project from disk
  static Future<models.DesignSystem> loadProject(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('Project file not found');
      }

      final jsonString = await file.readAsString();
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      
      // Parse from JSON manually
      return DesignSystemWrapper.fromJson(json).designSystem;
    } catch (e) {
      throw Exception('Failed to load project: $e');
    }
  }

  /// Get list of all saved projects
  static Future<List<ProjectInfo>> getProjectList() async {
    try {
      final projectsDir = await _getProjectsDirectory();
      final files = projectsDir.listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith(_projectExtension))
          .toList();

      final projects = <ProjectInfo>[];
      for (final file in files) {
        try {
          final jsonString = await file.readAsString();
          final json = jsonDecode(jsonString) as Map<String, dynamic>;
          final designSystem = DesignSystemWrapper.fromJson(json).designSystem;
          
          final stat = await file.stat();
          projects.add(ProjectInfo(
            name: designSystem.name,
            description: designSystem.description,
            version: designSystem.version,
            created: designSystem.created,
            filePath: file.path,
            modified: stat.modified,
          ));
        } catch (e) {
          // Skip corrupted files
          continue;
        }
      }

      // Sort by modified date (newest first)
      projects.sort((a, b) => b.modified.compareTo(a.modified));
      return projects;
    } catch (e) {
      return [];
    }
  }

  /// Delete a project
  static Future<void> deleteProject(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      throw Exception('Failed to delete project: $e');
    }
  }

  /// Export project to a specific location (for export functionality)
  static Future<String> exportProject(
    models.DesignSystem designSystem,
    String exportPath,
  ) async {
    try {
      final wrapper = DesignSystemWrapper(designSystem: designSystem);
      final json = wrapper.toJson();
      final jsonString = const JsonEncoder.withIndent('  ').convert(json);
      
      final file = File(exportPath);
      await file.writeAsString(jsonString);
      return file.path;
    } catch (e) {
      throw Exception('Failed to export project: $e');
    }
  }

  /// Sanitize file name to remove invalid characters
  static String _sanitizeFileName(String name) {
    return name
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
        .replaceAll(' ', '_')
        .toLowerCase();
  }
}

/// Information about a saved project
class ProjectInfo {
  final String name;
  final String description;
  final String version;
  final String created;
  final String filePath;
  final DateTime modified;

  ProjectInfo({
    required this.name,
    required this.description,
    required this.version,
    required this.created,
    required this.filePath,
    required this.modified,
  });
}
