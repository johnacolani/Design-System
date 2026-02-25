import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/design_system.dart' as models;
import '../models/design_system_wrapper.dart';

// Import dart:io only when not on web
// On web, this import will fail, but we guard all usages with kIsWeb checks
import 'dart:io' as io;
import 'package:path_provider/path_provider.dart';

class ProjectService {
  static const String _projectsFolder = 'design_systems';
  static const String _projectExtension = '.ds.json';

  /// Get the directory where projects are stored (non-web only)
  static Future<dynamic> _getProjectsDirectory() async {
    if (kIsWeb) {
      throw UnsupportedError('File system access not available on web');
    }
    final appDir = await getApplicationDocumentsDirectory();
    final projectsDir = io.Directory('${appDir.path}/$_projectsFolder');
    if (!await projectsDir.exists()) {
      await projectsDir.create(recursive: true);
    }
    return projectsDir;
  }

  /// Get SharedPreferences instance (web storage)
  static Future<SharedPreferences> _getPreferences() async {
    return await SharedPreferences.getInstance();
  }

  /// Get project key for SharedPreferences
  static String _getProjectKey(String fileName) {
    return 'project_$fileName';
  }

  /// Get projects list key for SharedPreferences
  static String _getProjectsListKey() {
    return 'projects_list';
  }

  /// Save a design system project to disk
  static Future<String> saveProject(models.DesignSystem designSystem) async {
    try {
      final fileName = _sanitizeFileName(designSystem.name);
      final fullFileName = '$fileName$_projectExtension';

      // Create wrapper for JSON structure
      final wrapper = DesignSystemWrapper(designSystem: designSystem);
      
      // Convert to JSON manually (since serialization is commented out)
      final json = wrapper.toJson();
      final jsonString = const JsonEncoder.withIndent('  ').convert(json);

      if (kIsWeb) {
        // Web: Use SharedPreferences
        final prefs = await _getPreferences();
        final projectKey = _getProjectKey(fullFileName);
        
        // Save project data
        await prefs.setString(projectKey, jsonString);
        
        // Update projects list
        final projectsList = prefs.getStringList(_getProjectsListKey()) ?? [];
        if (!projectsList.contains(fullFileName)) {
          projectsList.add(fullFileName);
          await prefs.setStringList(_getProjectsListKey(), projectsList);
        }
        
        // Save metadata
        await prefs.setString('${projectKey}_name', designSystem.name);
        await prefs.setString('${projectKey}_description', designSystem.description);
        await prefs.setString('${projectKey}_version', designSystem.version);
        await prefs.setString('${projectKey}_created', designSystem.created);
        await prefs.setString('${projectKey}_modified', DateTime.now().toIso8601String());
        
        return projectKey; // Return key instead of file path
      } else {
        // Mobile/Desktop: Use file system
        final projectsDir = await _getProjectsDirectory();
        final file = io.File('${projectsDir.path}/$fullFileName');
        await file.writeAsString(jsonString);
        return file.path;
      }
    } catch (e) {
      throw Exception('Failed to save project: $e');
    }
  }

  /// Load a design system project from disk
  static Future<models.DesignSystem> loadProject(String filePathOrKey) async {
    try {
      String jsonString;

      if (kIsWeb) {
        // Web: Load from SharedPreferences
        final prefs = await _getPreferences();
        jsonString = prefs.getString(filePathOrKey) ?? '';
        if (jsonString.isEmpty) {
          throw Exception('Project not found');
        }
      } else {
        // Mobile/Desktop: Load from file system
        final file = io.File(filePathOrKey);
        if (!await file.exists()) {
          throw Exception('Project file not found');
        }
        jsonString = await file.readAsString();
      }

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
      final projects = <ProjectInfo>[];

      if (kIsWeb) {
        // Web: Load from SharedPreferences
        final prefs = await _getPreferences();
        final projectsList = prefs.getStringList(_getProjectsListKey()) ?? [];

        for (final fileName in projectsList) {
          try {
            final projectKey = _getProjectKey(fileName);
            final name = prefs.getString('${projectKey}_name') ?? 'Unknown';
            final description = prefs.getString('${projectKey}_description') ?? '';
            final version = prefs.getString('${projectKey}_version') ?? '1.0.0';
            final created = prefs.getString('${projectKey}_created') ?? DateTime.now().toIso8601String();
            final modifiedStr = prefs.getString('${projectKey}_modified') ?? DateTime.now().toIso8601String();
            
            DateTime modified;
            try {
              modified = DateTime.parse(modifiedStr);
            } catch (e) {
              modified = DateTime.now();
            }

            projects.add(ProjectInfo(
              name: name,
              description: description,
              version: version,
              created: created,
              filePath: projectKey, // Use key instead of file path
              modified: modified,
            ));
          } catch (e) {
            // Skip corrupted entries
            continue;
          }
        }
      } else {
        // Mobile/Desktop: Load from file system
        final projectsDir = await _getProjectsDirectory();
        final files = projectsDir.listSync()
            .whereType<io.File>()
            .where((f) => f.path.endsWith(_projectExtension))
            .toList();

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
      }

      // Sort by modified date (newest first)
      projects.sort((a, b) => b.modified.compareTo(a.modified));
      return projects;
    } catch (e) {
      return [];
    }
  }

  /// Delete a project
  static Future<void> deleteProject(String filePathOrKey) async {
    try {
      if (kIsWeb) {
        // Web: Remove from SharedPreferences
        final prefs = await _getPreferences();
        
        // Find the file name from the key
        final projectsList = prefs.getStringList(_getProjectsListKey()) ?? [];
        String? fileName;
        for (final name in projectsList) {
          if (_getProjectKey(name) == filePathOrKey) {
            fileName = name;
            break;
          }
        }
        
        if (fileName != null) {
          final projectKey = _getProjectKey(fileName);
          
          // Remove project data and metadata
          await prefs.remove(projectKey);
          await prefs.remove('${projectKey}_name');
          await prefs.remove('${projectKey}_description');
          await prefs.remove('${projectKey}_version');
          await prefs.remove('${projectKey}_created');
          await prefs.remove('${projectKey}_modified');
          
          // Remove from projects list
          projectsList.remove(fileName);
          await prefs.setStringList(_getProjectsListKey(), projectsList);
        }
      } else {
        // Mobile/Desktop: Delete file
        final file = io.File(filePathOrKey);
        if (await file.exists()) {
          await file.delete();
        }
      }
    } catch (e) {
      throw Exception('Failed to delete project: $e');
    }
  }

  /// Export project to a specific location (for export functionality)
  /// Note: On web, this will return the JSON string
  static Future<String> exportProject(
    models.DesignSystem designSystem,
    String exportPath,
  ) async {
    try {
      final wrapper = DesignSystemWrapper(designSystem: designSystem);
      final json = wrapper.toJson();
      final jsonString = const JsonEncoder.withIndent('  ').convert(json);
      
      if (kIsWeb) {
        // Web: Can't write to file system, return the JSON string
        // The caller should handle downloading
        return jsonString;
      } else {
        // Mobile/Desktop: Write to file
        final file = io.File(exportPath);
        await file.writeAsString(jsonString);
        return file.path;
      }
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
