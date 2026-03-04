import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/firebase_service.dart';

/// Paginated read of component items from Firestore. Use for lazy-loaded gallery:
/// load one category at a time when the user opens that section.
///
/// Firestore assumption: design_systems/{designSystemId}/component_items
/// Each doc: category (string), name (string), data (map), order (int, optional).
/// Query: where category == X orderBy order, limit N startAfter lastDoc.
class ComponentRepository {
  ComponentRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseService.firestore;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _itemsRef(String designSystemId) {
    return _firestore
        .collection('design_systems')
        .doc(designSystemId)
        .collection('component_items');
  }

  static const int defaultPageSize = 20;

  /// Fetch one page of component items for a category. Call when user opens
  /// that category (e.g. ExpansionTile onExpand or Tab onTap).
  Future<ComponentPageResult> getComponentPage({
    required String designSystemId,
    required String category,
    int limit = defaultPageSize,
    DocumentSnapshot<Map<String, dynamic>>? startAfter,
  }) async {
    if (designSystemId.isEmpty) return ComponentPageResult(items: [], lastDoc: null, hasMore: false);

    // Single orderBy avoids composite index in Firestore; add 'order' field and index if needed.
    var query = _itemsRef(designSystemId)
        .where('category', isEqualTo: category)
        .orderBy('name')
        .limit(limit);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final snap = await query.get();
    final items = snap.docs.map((d) {
      final data = d.data();
      return ComponentItem(
        id: d.id,
        category: data['category'] as String? ?? category,
        name: data['name'] as String? ?? '',
        data: data['data'] is Map ? Map<String, dynamic>.from(data['data'] as Map<dynamic, dynamic>) : {},
      );
    }).toList();

    return ComponentPageResult(
      items: items,
      lastDoc: snap.docs.isEmpty ? null : snap.docs.last,
      hasMore: snap.docs.length == limit,
    );
  }

  /// Stream of items for one category (optional; use for real-time gallery).
  /// Prefer getComponentPage for lazy load to avoid reading all items.
  Stream<List<ComponentItem>> watchCategory({
    required String designSystemId,
    required String category,
    int limit = 50,
  }) {
    if (designSystemId.isEmpty) return Stream.value([]);

    return _itemsRef(designSystemId)
        .where('category', isEqualTo: category)
        .orderBy('name')
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map((d) {
              final data = d.data();
              return ComponentItem(
                id: d.id,
                category: data['category'] as String? ?? category,
                name: data['name'] as String? ?? '',
                data: data['data'] is Map ? Map<String, dynamic>.from(data['data'] as Map<dynamic, dynamic>) : {},
              );
            }).toList());
  }

  /// List of category IDs that have at least one item (for sidebar/tabs).
  /// Single read; use at gallery init to show which categories exist.
  Future<List<String>> getCategoryIds(String designSystemId) async {
    if (designSystemId.isEmpty) return [];
    final ref = _firestore
        .collection('design_systems')
        .doc(designSystemId)
        .collection('component_items');
    final snap = await ref.limit(1).get();
    if (snap.docs.isEmpty) return [];
    // Firestore has no distinct; assume categories are known or stored in meta.
    // Alternative: design_systems/{id}/meta with categories: ['buttons','cards',...]
    final metaSnap = await _firestore
        .collection('design_systems')
        .doc(designSystemId)
        .collection('meta')
        .doc('components')
        .get();
    final data = metaSnap.data();
    if (data != null && data['categories'] is List) {
      return List<String>.from(data['categories'] as List);
    }
    return ['buttons', 'cards', 'inputs', 'navigation', 'avatars', 'modals', 'tables', 'progress', 'alerts'];
  }
}

class ComponentItem {
  const ComponentItem({
    required this.id,
    required this.category,
    required this.name,
    required this.data,
  });
  final String id;
  final String category;
  final String name;
  final Map<String, dynamic> data;
}

class ComponentPageResult {
  const ComponentPageResult({
    required this.items,
    this.lastDoc,
    required this.hasMore,
  });
  final List<ComponentItem> items;
  final DocumentSnapshot<Map<String, dynamic>>? lastDoc;
  final bool hasMore;
}
