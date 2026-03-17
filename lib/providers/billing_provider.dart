import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/billing.dart';
import '../services/firebase_service.dart';

/// Holds billing state from Firestore users/{uid}/billing. Single source of
/// truth for plan/status; swap Stripe later by writing to this doc from webhooks.
/// When Firebase/Firestore is unavailable (e.g. tests, no config), acts as free tier.
class BillingProvider extends ChangeNotifier {
  BillingProvider({FirebaseFirestore? firestore}) : _firestore = firestore;

  FirebaseFirestore? _firestore;

  /// Lazy: avoid touching Firestore in constructor so tests/web without Firebase don't crash.
  FirebaseFirestore? get _firestoreOrNull {
    if (_firestore != null) return _firestore;
    try {
      _firestore = FirebaseService.firestore;
      return _firestore;
    } catch (_) {
      return null;
    }
  }

  BillingInfo _billing = BillingInfo.free();
  String? _userId;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _subscription;
  bool _loading = false;
  String? _error;

  BillingInfo get billing => _billing;
  SubscriptionPlan get plan => _billing.plan;
  bool get isProOrTeam =>
      _billing.plan == SubscriptionPlan.pro || _billing.plan == SubscriptionPlan.team;
  bool get isTeam => _billing.plan == SubscriptionPlan.team;
  bool get isLoading => _loading;
  String? get error => _error;

  DocumentReference<Map<String, dynamic>>? _billingRef(String uid) {
    final fs = _firestoreOrNull;
    if (fs == null) return null;
    return fs.collection('users').doc(uid).collection('billing').doc('subscription');
  }

  /// Load billing once (e.g. after login). Prefer watchBilling for live updates.
  Future<void> loadBilling(String userId) async {
    if (userId.isEmpty || userId.startsWith('guest_')) {
      _billing = BillingInfo.free();
      _userId = null;
      notifyListeners();
      return;
    }
    final ref = _billingRef(userId);
    if (ref == null) {
      _billing = BillingInfo.free();
      _loading = false;
      notifyListeners();
      return;
    }
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final snap = await ref.get();
      _billing = BillingInfo.fromFirestore(snap.data());
      _userId = userId;
    } catch (e) {
      _error = e.toString();
      _billing = BillingInfo.free();
    }
    _loading = false;
    notifyListeners();
  }

  /// Watch billing doc for live updates (e.g. after Stripe webhook).
  void watchBilling(String userId) {
    if (userId.isEmpty || userId.startsWith('guest_')) {
      _subscription?.cancel();
      _subscription = null;
      _billing = BillingInfo.free();
      _userId = null;
      notifyListeners();
      return;
    }
    final ref = _billingRef(userId);
    if (ref == null) {
      _billing = BillingInfo.free();
      _userId = null;
      notifyListeners();
      return;
    }
    if (_userId == userId) return;
    _subscription?.cancel();
    _userId = userId;
    _subscription = ref.snapshots().listen(
      (snap) {
        _billing = BillingInfo.fromFirestore(snap.data());
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
    _userId = null;
    _billing = BillingInfo.free();
    notifyListeners();
  }

  /// Set billing locally (for mock or after successful checkout). Persists to Firestore.
  /// In production, Stripe webhooks would write to Firestore; this is for placeholder flow.
  Future<void> setBilling(String userId, BillingInfo info) async {
    if (userId.isEmpty) return;
    final ref = _billingRef(userId);
    if (ref == null) return;
    try {
      await ref.set(info.toFirestore());
      _billing = info;
      _userId = userId;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
