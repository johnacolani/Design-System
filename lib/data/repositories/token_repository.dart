import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/firebase_service.dart';

/// Single source of truth for design tokens loaded from Firestore.
/// Loads once at startup/workspace open, caches in-memory and in local storage
/// to minimize Firestore reads. Cache invalidation via version or updatedAt.
///
/// Firestore assumption: document at
///   design_systems/[designSystemId]/meta/tokens
/// with fields: version (int), updatedAt (Timestamp), tokens (Map).
/// If your schema differs, adjust _tokensRef and fromFirestore.
class TokenRepository {
  TokenRepository({
    SharedPreferences? preferences,
    FirebaseFirestore? firestore,
  })  : _prefs = preferences,
        _firestore = firestore ?? FirebaseService.firestore;

  final SharedPreferences? _prefs;
  final FirebaseFirestore _firestore;

  static const String _cachePrefix = 'token_cache_';
  static const String _cacheVersionKey = '_version';
  static const String _cacheUpdatedAtKey = '_updatedAt';

  Map<String, dynamic>? _memoryCache;
  int? _cachedVersion;
  DateTime? _cachedUpdatedAt;
  String? _currentWorkspaceId;

  /// Tokens document reference. Assumption: one doc per design system for tokens.
  DocumentReference<Map<String, dynamic>> _tokensRef(String workspaceOrDesignSystemId) {
    return _firestore
        .collection('design_systems')
        .doc(workspaceOrDesignSystemId)
        .collection('meta')
        .doc('tokens');
  }

  String _cacheKey(String workspaceId) => '$_cachePrefix$workspaceId';

  /// Get tokens for the given workspace. Uses cache first; does not hit Firestore
  /// unless refresh was requested or cache is empty/invalid.
  /// Call from init/workspace open, not from build().
  Future<Map<String, dynamic>> getTokens({
    required String workspaceId,
    bool forceRefresh = false,
  }) async {
    if (workspaceId.isEmpty) return {};

    if (!forceRefresh && _memoryCache != null && _currentWorkspaceId == workspaceId) {
      return Map<String, dynamic>.from(_memoryCache!);
    }

    final prefs = _prefs ?? await SharedPreferences.getInstance();
    final key = _cacheKey(workspaceId);

    if (!forceRefresh) {
      final stored = prefs.getString(key);
      if (stored != null) {
        try {
          final decoded = jsonDecode(stored) as Map<String, dynamic>;
          final tokens = decoded['tokens'] as Map<String, dynamic>?;
          final version = decoded[_cacheVersionKey] as int?;
          final updatedAt = decoded[_cacheUpdatedAtKey] as String?;
          if (tokens != null) {
            _memoryCache = Map<String, dynamic>.from(tokens);
            _cachedVersion = version;
            _cachedUpdatedAt = updatedAt != null ? DateTime.tryParse(updatedAt) : null;
            _currentWorkspaceId = workspaceId;
            return Map<String, dynamic>.from(_memoryCache!);
          }
        } catch (e) {
          debugPrint('TokenRepository: local cache parse error $e');
        }
      }
    }

    return refreshTokens(workspaceId: workspaceId, prefs: prefs);
  }

  /// Force reload from Firestore and update caches. Use after workspace switch
  /// or when user explicitly refreshes.
  Future<Map<String, dynamic>> refreshTokens({
    required String workspaceId,
    SharedPreferences? prefs,
  }) async {
    if (workspaceId.isEmpty) return {};

    try {
      final snap = await _tokensRef(workspaceId).get();
      final data = snap.data();
      if (data == null || !snap.exists) {
        _memoryCache = {};
        _cachedVersion = null;
        _cachedUpdatedAt = null;
        _currentWorkspaceId = workspaceId;
        await _persistCache(workspaceId, {}, null, null, prefs);
        return {};
      }

      final version = data['version'] as int?;
      final updatedAt = data['updatedAt'] is Timestamp
          ? (data['updatedAt'] as Timestamp).toDate()
          : (data['updatedAt'] is String ? DateTime.tryParse(data['updatedAt'] as String) : null);
      final tokens = data['tokens'] is Map
          ? Map<String, dynamic>.from(data['tokens'] as Map<dynamic, dynamic>)
          : <String, dynamic>{};

      _memoryCache = tokens;
      _cachedVersion = version;
      _cachedUpdatedAt = updatedAt;
      _currentWorkspaceId = workspaceId;

      await _persistCache(workspaceId, tokens, version, updatedAt, prefs);
      return Map<String, dynamic>.from(tokens);
    } catch (e) {
      debugPrint('TokenRepository: Firestore read error $e');
      if (_memoryCache != null && _currentWorkspaceId == workspaceId) {
        return Map<String, dynamic>.from(_memoryCache!);
      }
      final fallback = await _loadFromLocalOnly(workspaceId, prefs);
      return fallback;
    }
  }

  Future<Map<String, dynamic>> _loadFromLocalOnly(String workspaceId, SharedPreferences? prefs) async {
    final p = prefs ?? await SharedPreferences.getInstance();
    final key = _cacheKey(workspaceId);
    final stored = p.getString(key);
    if (stored != null) {
      try {
        final decoded = jsonDecode(stored) as Map<String, dynamic>;
        final tokens = decoded['tokens'] as Map<String, dynamic>?;
        if (tokens != null) {
          _memoryCache = Map<String, dynamic>.from(tokens);
          _currentWorkspaceId = workspaceId;
          return Map<String, dynamic>.from(_memoryCache!);
        }
      } catch (_) {}
    }
    _memoryCache = {};
    _currentWorkspaceId = workspaceId;
    return {};
  }

  Future<void> _persistCache(
    String workspaceId,
    Map<String, dynamic> tokens,
    int? version,
    DateTime? updatedAt,
    SharedPreferences? prefs,
  ) async {
    final p = prefs ?? await SharedPreferences.getInstance();
    final key = _cacheKey(workspaceId);
    final payload = {
      'tokens': tokens,
      _cacheVersionKey: version,
      _cacheUpdatedAtKey: updatedAt?.toIso8601String(),
    };
    await p.setString(key, jsonEncode(payload));
  }

  /// Stream of token snapshots. Emit from cache immediately, then from Firestore.
  /// UI can listen without triggering repeated reads per rebuild if used at
  /// top-level (e.g. in a provider that holds the stream subscription).
  Stream<Map<String, dynamic>> watchTokens({required String workspaceId}) async* {
    if (workspaceId.isEmpty) {
      yield {};
      return;
    }

    Map<String, dynamic>? lastEmitted;
    void emitIfChanged(Map<String, dynamic> next) {
      if (lastEmitted == null || _mapEquals(lastEmitted!, next)) {
        lastEmitted = next;
        return;
      }
      lastEmitted = next;
      // Caller will use stream; we only yield in async* so we need to yield here
    }

    final cached = await getTokens(workspaceId: workspaceId, forceRefresh: false);
    yield cached;
    emitIfChanged(cached);

    await for (final snap in _tokensRef(workspaceId).snapshots()) {
      final data = snap.data();
      if (data == null || !snap.exists) {
        emitIfChanged({});
        yield {};
        continue;
      }
      final tokens = data['tokens'] is Map
          ? Map<String, dynamic>.from(data['tokens'] as Map<dynamic, dynamic>)
          : <String, dynamic>{};
      _memoryCache = tokens;
      _cachedVersion = data['version'] as int?;
      _cachedUpdatedAt = data['updatedAt'] is Timestamp
          ? (data['updatedAt'] as Timestamp).toDate()
          : null;
      _currentWorkspaceId = workspaceId;
      await _persistCache(workspaceId, tokens, _cachedVersion, _cachedUpdatedAt, _prefs);
      yield Map<String, dynamic>.from(tokens);
    }
  }

  static bool _mapEquals(Map<String, dynamic> a, Map<String, dynamic> b) {
    if (a.length != b.length) return false;
    for (final k in a.keys) {
      if (!b.containsKey(k) || a[k] != b[k]) return false;
    }
    return true;
  }

  /// Invalidate in-memory cache for a workspace (e.g. on logout). Persisted cache
  /// can still be used until next refresh.
  void invalidateMemory(String? workspaceId) {
    if (workspaceId == null || workspaceId == _currentWorkspaceId) {
      _memoryCache = null;
      _cachedVersion = null;
      _cachedUpdatedAt = null;
      _currentWorkspaceId = null;
    }
  }
}
