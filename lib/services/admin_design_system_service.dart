import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/design_system.dart' as models;
import '../models/design_system_wrapper.dart';
import '../services/firebase_service.dart';

class AdminDesignSystemService {
  /// Returns the Firestore document id for the saved snapshot.
  static Future<String> saveDesignSystemForAdmin({
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

    final batch = FirebaseService.firestore.batch();
    // Ensure the parent user doc exists so the nested collection is easy to discover in Firebase Console.
    batch.set(
      FirebaseService.usersCollection.doc(adminUserId),
      {
        'lastAdminDesignSystemSaveAt': FieldValue.serverTimestamp(),
        'lastAdminDesignSystemSaveDocId': docId,
      },
      SetOptions(merge: true),
    );
    batch.set(FirebaseService.userDesignSystems(adminUserId).doc(docId), data);
    await batch.commit();
    return docId;
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

  static Future<void> updateSavedDesignSystem({
    required String adminUserId,
    required String docId,
    required String name,
    required String version,
    required String description,
  }) async {
    await FirebaseService.userDesignSystems(adminUserId).doc(docId).update({
      'name': name.trim(),
      'version': version.trim(),
      'description': description.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> deleteSavedDesignSystem({
    required String adminUserId,
    required String docId,
  }) async {
    await FirebaseService.userDesignSystems(adminUserId).doc(docId).delete();
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
