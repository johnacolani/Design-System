import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/design_system.dart' as models;
import '../models/design_system_wrapper.dart';
import 'firebase_service.dart';
import 'project_service.dart';

/// Firestore path: `users/{uid}/projects/{docId}` (see [firestore.rules]).
class CloudProjectService {
  CloudProjectService._();

  static const String _cloudPathPrefix = 'cloud:';

  static String cloudPathForDocId(String docId) => '$_cloudPathPrefix$docId';

  static bool isCloudProjectPath(String path) => path.startsWith(_cloudPathPrefix);

  static String docIdFromCloudPath(String path) {
    if (!isCloudProjectPath(path)) {
      throw ArgumentError.value(path, 'path', 'Not a cloud project path');
    }
    return path.substring(_cloudPathPrefix.length);
  }

  /// Firestore document IDs: safe subset from sanitized project name.
  static String docIdForDesignSystem(models.DesignSystem ds) {
    var id = ProjectService.sanitizeFileName(ds.name.isEmpty ? 'untitled' : ds.name);
    if (id.isEmpty) id = 'untitled';
    if (id.length > 700) id = id.substring(0, 700);
    return id;
  }

  /// Writes full design system JSON under [payload] (same shape as `.ds.json` files).
  static Future<String> upsertProject(String userId, models.DesignSystem designSystem) async {
    final docId = docIdForDesignSystem(designSystem);
    final wrapper = DesignSystemWrapper(designSystem: designSystem);
    final payload = wrapper.toJson();
    await FirebaseService.userProjects(userId).doc(docId).set(
          {
            'name': designSystem.name,
            'description': designSystem.description,
            'version': designSystem.version,
            'created': designSystem.created,
            'modified': designSystem.lastModified ?? DateTime.now().toIso8601String(),
            'updatedAt': FieldValue.serverTimestamp(),
            'payload': payload,
          },
          SetOptions(merge: true),
        );
    return cloudPathForDocId(docId);
  }

  static Future<List<ProjectInfo>> listProjects(String userId) async {
    try {
      final snap = await FirebaseService.userProjects(userId).get();
      final out = <ProjectInfo>[];
      for (final doc in snap.docs) {
        final d = doc.data() as Map<String, dynamic>?;
        if (d == null) continue;
        final name = d['name'] as String? ?? doc.id;
        final description = d['description'] as String? ?? '';
        final version = d['version'] as String? ?? '1.0.0';
        final created = d['created'] as String? ?? '';
        DateTime modified = DateTime.now();
        final ts = d['updatedAt'];
        if (ts is Timestamp) {
          modified = ts.toDate();
        } else {
          final m = d['modified'] as String?;
          if (m != null) {
            try {
              modified = DateTime.parse(m);
            } catch (_) {}
          }
        }
        out.add(
          ProjectInfo(
            name: name,
            description: description,
            version: version,
            created: created,
            filePath: cloudPathForDocId(doc.id),
            modified: modified,
            fromCloud: true,
          ),
        );
      }
      out.sort((a, b) => b.modified.compareTo(a.modified));
      return out;
    } catch (e, st) {
      debugPrint('CloudProjectService.listProjects: $e\n$st');
      rethrow;
    }
  }

  static Future<models.DesignSystem> loadProject(String userId, String docId) async {
    final doc = await FirebaseService.userProjects(userId).doc(docId).get();
    final data = doc.data() as Map<String, dynamic>?;
    if (!doc.exists || data == null) {
      throw Exception('Cloud project not found');
    }
    final raw = data['payload'];
    if (raw is! Map<String, dynamic>) {
      throw Exception('Cloud project payload missing or invalid');
    }
    return DesignSystemWrapper.fromJson(Map<String, dynamic>.from(raw)).designSystem;
  }

  static Future<void> deleteProject(String userId, String docId) async {
    await FirebaseService.userProjects(userId).doc(docId).delete();
  }
}
