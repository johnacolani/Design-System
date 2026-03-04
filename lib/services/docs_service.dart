import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_service.dart';

/// Selects doc source (bundled assets vs Firestore) and caches results.
/// For web performance: prefer assets for public docs; use Firestore only for
/// authenticated "private docs". Caching avoids repeated reads on rebuild.
///
/// Firestore assumption: public docs at docs/{docId}, private at
/// users/{userId}/private_docs/{docId}. Each document has: content (string),
/// updatedAt (Timestamp), title (string, optional).
class DocsService {
  DocsService({
    FirebaseFirestore? firestore,
    SharedPreferences? preferences,
  })  : _firestore = firestore ?? FirebaseService.firestore,
        _prefs = preferences;

  final FirebaseFirestore _firestore;
  final SharedPreferences? _prefs;

  static const String _cachePrefix = 'docs_cache_';
  static const String _cachePrivatePrefix = 'docs_private_';

  final Map<String, _CachedDoc> _memoryCache = {};

  /// Get markdown content for a doc. Prefer asset for public docs (no Firestore read).
  /// [docId] e.g. 'getting-started', 'tokens-guide'.
  /// [useAsset] true = load from assets/docs/{docId}.md (bundled); false = load from Firestore.
  /// [userId] required when loading private doc from users/{userId}/private_docs/{docId}.
  Future<String> getDoc({
    required String docId,
    bool useAsset = true,
    String? userId,
  }) async {
    final cacheKey = _cacheKey(docId, userId);
    final cached = _memoryCache[cacheKey];
    if (cached != null && !cached.isExpired) return cached.content;

    if (useAsset && userId == null) {
      final content = await _loadFromAsset(docId);
      _memoryCache[cacheKey] = _CachedDoc(content: content, updatedAt: DateTime.now());
      return content;
    }

    return _loadFromFirestore(docId, userId, cacheKey);
  }

  String _cacheKey(String docId, String? userId) {
    if (userId != null) return '$_cachePrivatePrefix${userId}_$docId';
    return '$_cachePrefix$docId';
  }

  Future<String> _loadFromAsset(String docId) async {
    try {
      final path = 'assets/docs/$docId.md';
      return await rootBundle.loadString(path);
    } catch (e) {
      debugPrint('DocsService: asset load failed for $docId: $e');
      return _loadFromFirestore(docId, null, _cacheKey(docId, null));
    }
  }

  Future<String> _loadFromFirestore(String docId, String? userId, String cacheKey) async {
    try {
      DocumentReference<Map<String, dynamic>> ref;
      if (userId != null) {
        ref = _firestore.collection('users').doc(userId).collection('private_docs').doc(docId);
      } else {
        ref = _firestore.collection('docs').doc(docId);
      }
      final snap = await ref.get();
      final data = snap.data();
      final content = data != null ? (data['content'] as String? ?? '') : '';
      final updatedAt = data?['updatedAt'] is Timestamp
          ? (data!['updatedAt'] as Timestamp).toDate()
          : DateTime.now();
      _memoryCache[cacheKey] = _CachedDoc(content: content, updatedAt: updatedAt);
      return content;
    } catch (e) {
      debugPrint('DocsService: Firestore load failed for $docId: $e');
      final stored = await _loadFromLocalCache(cacheKey);
      return stored;
    }
  }

  Future<String> _loadFromLocalCache(String cacheKey) async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    final raw = prefs.getString(cacheKey);
    if (raw != null) return raw;
    return '';
  }

  /// Invalidate cache for one doc or all.
  void invalidateCache({String? docId, String? userId}) {
    if (docId == null && userId == null) {
      _memoryCache.clear();
      return;
    }
    if (docId != null) {
      _memoryCache.remove(_cacheKey(docId, userId));
    }
  }
}

class _CachedDoc {
  _CachedDoc({required this.content, required this.updatedAt});
  final String content;
  final DateTime updatedAt;
  bool get isExpired => DateTime.now().difference(updatedAt) > const Duration(hours: 24);
}
