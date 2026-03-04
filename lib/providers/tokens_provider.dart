import 'dart:async';
import 'package:flutter/foundation.dart';
import '../data/repositories/token_repository.dart';

/// Exposes tokens from TokenRepository. Load once at startup or workspace open;
/// UI must NOT call Firestore in build()—use getTokens() (cached) or listen to
/// watchTokens() at app/route level, not inside item builders.
class TokensProvider extends ChangeNotifier {
  TokensProvider({TokenRepository? repository})
      : _repository = repository ?? TokenRepository();

  final TokenRepository _repository;

  Map<String, dynamic> _tokens = {};
  String? _workspaceId;
  bool _loading = false;
  String? _error;
  StreamSubscription<Map<String, dynamic>>? _subscription;

  Map<String, dynamic> get tokens => Map.unmodifiable(_tokens);
  String? get workspaceId => _workspaceId;
  bool get isLoading => _loading;
  String? get error => _error;

  /// Call once at startup or when opening a workspace. Uses cache first.
  Future<void> loadTokens({required String workspaceId, bool force = false}) async {
    if (_workspaceId == workspaceId && !force && _tokens.isNotEmpty && !_loading) return;
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _tokens = await _repository.getTokens(workspaceId: workspaceId, forceRefresh: force);
      _workspaceId = workspaceId;
    } catch (e, st) {
      debugPrint('TokensProvider loadTokens error: $e $st');
      _error = e.toString();
    }
    _loading = false;
    notifyListeners();
  }

  /// Force refresh from Firestore and update caches.
  Future<void> refreshTokens({bool force = true}) async {
    if (_workspaceId == null) return;
    await loadTokens(workspaceId: _workspaceId!, force: force);
  }

  /// Start watching tokens (stream). Call once at app or route level; cancel on dispose.
  void watchTokens(String workspaceId) {
    if (_subscription != null) {
      _subscription!.cancel();
      _subscription = null;
    }
    _workspaceId = workspaceId;
    _subscription = _repository.watchTokens(workspaceId: workspaceId).listen(
      (next) {
        _tokens = next;
        _error = null;
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        notifyListeners();
      },
    );
  }

  void stopWatching() {
    _subscription?.cancel();
    _subscription = null;
  }

  /// Call on logout or workspace switch to avoid stale data.
  void invalidate() {
    _repository.invalidateMemory(_workspaceId);
    stopWatching();
    _tokens = {};
    _workspaceId = null;
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    stopWatching();
    super.dispose();
  }
}
