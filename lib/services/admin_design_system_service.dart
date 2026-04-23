import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/design_system.dart' as models;
import '../models/design_system_wrapper.dart';
import '../services/firebase_service.dart';

class AdminDesignSystemService {
  static Future<void> saveDesignSystemForAdmin({
    required String adminUserId,
    required models.DesignSystem designSystem,
  }) async {
    final wrapper = DesignSystemWrapper(designSystem: designSystem);
    final payload = wrapper.toJson()['designSystem'] as Map<String, dynamic>;
    final now = DateTime.now().toUtc();

    final docId =
        '${_safeSlug(designSystem.name.isEmpty ? 'design_system' : designSystem.name)}_${now.millisecondsSinceEpoch}';

    final data = <String, dynamic>{
      'name': designSystem.name,
      'version': designSystem.version,
      'description': designSystem.description,
      'created': designSystem.created,
      'targetPlatforms': designSystem.targetPlatforms,
      'savedBy': adminUserId,
      'savedAt': FieldValue.serverTimestamp(),
      'designSystem': payload,
    };

    await FirebaseService.userDesignSystems(adminUserId).doc(docId).set(data);
  }

  static Stream<List<AdminSavedDesignSystemItem>> watchSavedDesignSystems({
    required String adminUserId,
    int limit = 20,
  }) {
    return FirebaseService.userDesignSystems(adminUserId)
        .orderBy('savedAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AdminSavedDesignSystemItem.fromDoc(doc))
            .toList());
  }

  static String _safeSlug(String input) {
    final normalized = input.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');
    return normalized.isEmpty ? 'design_system' : normalized;
  }
}

class AdminSavedDesignSystemItem {
  final String id;
  final String name;
  final String version;
  final String description;
  final DateTime? savedAt;

  const AdminSavedDesignSystemItem({
    required this.id,
    required this.name,
    required this.version,
    required this.description,
    required this.savedAt,
  });

  factory AdminSavedDesignSystemItem.fromDoc(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>? ?? <String, dynamic>{});
    return AdminSavedDesignSystemItem(
      id: doc.id,
      name: (data['name'] as String?) ?? 'Untitled',
      version: (data['version'] as String?) ?? '1.0.0',
      description: (data['description'] as String?) ?? '',
      savedAt: (data['savedAt'] as Timestamp?)?.toDate(),
    );
  }
}
