import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_sign_in_all_platforms/google_sign_in_all_platforms.dart'
    as gsi_desktop;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../config/google_oauth_desktop.dart';
import '../models/user.dart';
import '../services/firebase_service.dart';

class UserProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;

  /// Lazily created for Windows/Linux OAuth (browser + localhost callback).
  gsi_desktop.GoogleSignIn? _desktopGoogleSignIn;

  User? get currentUser => _currentUser;
  /// True when we have a non-guest user in memory. Avoids touching Firebase during build
  /// so tests and web without Firebase config don't throw.
  bool get isLoggedIn =>
      _currentUser != null && !_currentUser!.id.startsWith('guest_');
  bool get isLoading => _isLoading;
  bool get isPremium => _currentUser?.isPremium ?? false;
  UserRole get userRole => _currentUser?.role ?? UserRole.free;

  /// Official [GoogleSignIn] supports Android, iOS, macOS, web only — not Windows/Linux.
  bool get _useGoogleAuthDesktop =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.linux);

  gsi_desktop.GoogleSignIn _googleSignInDesktopInstance() {
    return _desktopGoogleSignIn ??= gsi_desktop.GoogleSignIn(
      params: gsi_desktop.GoogleSignInParams(
        clientId: GoogleOAuthDesktopConfig.clientId,
        clientSecret: GoogleOAuthDesktopConfig.clientSecret,
        scopes: const [
          'openid',
          'https://www.googleapis.com/auth/userinfo.profile',
          'https://www.googleapis.com/auth/userinfo.email',
        ],
      ),
    );
  }

  /// Initialize: start as guest, then restore session if Firebase has a saved user.
  void initialize() {
    _currentUser = User.guest();
    notifyListeners();
    _restoreSession();
  }

  /// Restore logged-in user from Firebase Auth (persisted across app restarts).
  Future<void> _restoreSession() async {
    try {
      final firebaseUser = firebase_auth.FirebaseAuth.instance.currentUser;
      if (firebaseUser != null) {
        await _loadUserFromFirebase(firebaseUser);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Session restore failed (staying as guest): $e');
    }
  }

  /// Login user with email and password
  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Sign in with Firebase Auth
      final credential = await FirebaseService.auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        await _loadUserFromFirebase(credential.user!);
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Sign up new user with email and password
  Future<void> signUp(String name, String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Create user with Firebase Auth
      final credential = await FirebaseService.auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // Update display name
        await credential.user!.updateDisplayName(name);
        
        // Create user document in Firestore
        final userData = {
          'name': name,
          'email': email,
          'role': 'free',
          'createdAt': FieldValue.serverTimestamp(),
          'lastLoginAt': FieldValue.serverTimestamp(),
          'isPremium': false,
          'projectsCreated': 0,
        };

        await FirebaseService.usersCollection.doc(credential.user!.uid).set(userData);

        await _loadUserFromFirebase(credential.user!);
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Windows / Linux: OAuth via browser + localhost (see [GoogleOAuthDesktopConfig]).
  Future<void> _signInWithGoogleDesktop() async {
    if (!GoogleOAuthDesktopConfig.isConfigured) {
      throw GoogleSignInDesktopNotConfigured();
    }

    final googleSignIn = _googleSignInDesktopInstance();
    try {
      await googleSignIn.signOut();
    } catch (e) {
      debugPrint('Desktop Google signOut (ignored): $e');
    }

    final gsi_desktop.GoogleSignInCredentials? creds = await googleSignIn.signIn();
    if (creds == null) {
      return;
    }

    if (creds.accessToken.isEmpty &&
        (creds.idToken == null || creds.idToken!.isEmpty)) {
      throw Exception('Google did not return an access token or id token');
    }

    final credential = firebase_auth.GoogleAuthProvider.credential(
      accessToken: creds.accessToken,
      idToken: creds.idToken,
    );

    final userCredential = await FirebaseService.auth.signInWithCredential(credential);

    if (userCredential.user == null) {
      throw Exception('Failed to sign in with Google: No user returned');
    }

    await _ensureFirestoreUserForGoogleSignIn(userCredential.user!);
    await _loadUserFromFirebase(userCredential.user!);
  }

  /// Creates or updates Firestore user doc after Google + Firebase Auth succeeds.
  Future<void> _ensureFirestoreUserForGoogleSignIn(
    firebase_auth.User firebaseUser, {
    String? displayNameFallback,
    String? emailFallback,
    String? photoUrlFallback,
  }) async {
    final userDoc =
        await FirebaseService.usersCollection.doc(firebaseUser.uid).get();

    if (!userDoc.exists) {
      final userData = {
        'name': firebaseUser.displayName ?? displayNameFallback ?? 'User',
        'email': firebaseUser.email ?? emailFallback ?? '',
        'avatarUrl': firebaseUser.photoURL ?? photoUrlFallback,
        'role': 'free',
        'createdAt': FieldValue.serverTimestamp(),
        'lastLoginAt': FieldValue.serverTimestamp(),
        'isPremium': false,
        'projectsCreated': 0,
      };

      await FirebaseService.usersCollection.doc(firebaseUser.uid).set(userData);
    } else {
      await FirebaseService.usersCollection.doc(firebaseUser.uid).update({
        'lastLoginAt': FieldValue.serverTimestamp(),
      });
    }
  }

  /// Sign in with Google
  Future<void> signInWithGoogle() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_useGoogleAuthDesktop) {
        await _signInWithGoogleDesktop();
      } else {
        // Android, iOS, macOS, Web — official google_sign_in plugin.
        // Web: add client ID to web/index.html (google-signin-client_id meta tag).
        final GoogleSignIn googleSignIn = GoogleSignIn(
          scopes: ['email', 'profile'],
        );

        try {
          await googleSignIn.signOut();
        } catch (e) {
          debugPrint('Sign out error (ignored): $e');
        }

        final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

        if (googleUser == null) {
          _isLoading = false;
          notifyListeners();
          return;
        }

        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

        if (googleAuth.accessToken == null && googleAuth.idToken == null) {
          throw Exception('Failed to obtain Google authentication tokens');
        }

        final credential = firebase_auth.GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final userCredential =
            await FirebaseService.auth.signInWithCredential(credential);

        if (userCredential.user != null) {
          await _ensureFirestoreUserForGoogleSignIn(
            userCredential.user!,
            displayNameFallback: googleUser.displayName,
            emailFallback: googleUser.email,
            photoUrlFallback: googleUser.photoUrl,
          );
          await _loadUserFromFirebase(userCredential.user!);
        } else {
          throw Exception('Failed to sign in with Google: No user returned');
        }
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Google Sign-In Error: $e');
      rethrow;
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Load user data from Firebase
  Future<void> _loadUserFromFirebase(firebase_auth.User firebaseUser) async {
    try {
      final userDoc = await FirebaseService.usersCollection.doc(firebaseUser.uid).get();

      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>?;
        if (data != null) {
          _currentUser = User(
            id: firebaseUser.uid,
            name: data['name'] as String? ?? firebaseUser.displayName ?? 'User',
            email: data['email'] as String? ?? firebaseUser.email ?? '',
            avatarUrl: data['avatarUrl'] as String? ?? firebaseUser.photoURL,
            role: UserRole.values.firstWhere(
              (r) => r.name == (data['role'] as String? ?? 'free'),
              orElse: () => UserRole.free,
            ),
            createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
            lastLoginAt: (data['lastLoginAt'] as Timestamp?)?.toDate(),
            isPremium: data['isPremium'] as bool? ?? false,
            projectsCreated: data['projectsCreated'] as int? ?? 0,
          );
        } else {
          // Fallback if data is null
          _currentUser = User(
            id: firebaseUser.uid,
            name: firebaseUser.displayName ?? 'User',
            email: firebaseUser.email ?? '',
            avatarUrl: firebaseUser.photoURL,
            role: UserRole.free,
            createdAt: DateTime.now(),
            lastLoginAt: DateTime.now(),
            isPremium: false,
            projectsCreated: 0,
          );
        }
      } else {
        // Create user if document doesn't exist
        _currentUser = User(
          id: firebaseUser.uid,
          name: firebaseUser.displayName ?? 'User',
          email: firebaseUser.email ?? '',
          avatarUrl: firebaseUser.photoURL,
          role: UserRole.free,
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
          isPremium: false,
          projectsCreated: 0,
        );

        await FirebaseService.usersCollection.doc(firebaseUser.uid).set({
          'name': _currentUser!.name,
          'email': _currentUser!.email,
          'avatarUrl': _currentUser!.avatarUrl,
          'role': _currentUser!.role.name,
          'createdAt': FieldValue.serverTimestamp(),
          'lastLoginAt': FieldValue.serverTimestamp(),
          'isPremium': false,
          'projectsCreated': 0,
        });
      }
    } catch (e) {
      // Fallback to basic user if Firestore fails
      _currentUser = User(
        id: firebaseUser.uid,
        name: firebaseUser.displayName ?? 'User',
        email: firebaseUser.email ?? '',
        avatarUrl: firebaseUser.photoURL,
        role: UserRole.free,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
        isPremium: false,
        projectsCreated: 0,
      );
    }
  }

  /// Logout user (Firebase + Google). Sets [currentUser] to guest — not null — so
  /// the app does not treat a signed-out session as "uninitialized" and callers
  /// should also clear [DesignSystemProvider] / [TokensProvider] so no prior work stays visible.
  Future<void> logout() async {
    try {
      await FirebaseService.auth.signOut();
      final GoogleSignIn googleSignIn = GoogleSignIn();
      await googleSignIn.signOut();
      if (_desktopGoogleSignIn != null) {
        await _desktopGoogleSignIn!.signOut();
      }
    } catch (e) {
      // Ignore errors
    }
    _currentUser = User.guest();
    notifyListeners();
  }

  /// Update user profile
  void updateProfile({
    String? name,
    String? avatarUrl,
  }) {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(
        name: name,
        avatarUrl: avatarUrl,
      );
      notifyListeners();
    }
  }

  /// Upgrade to premium
  Future<void> upgradeToPremium() async {
    if (_currentUser != null) {
      _isLoading = true;
      notifyListeners();

      // Simulate payment processing
      await Future.delayed(const Duration(seconds: 2));

      _currentUser = _currentUser!.copyWith(
        isPremium: true,
        role: UserRole.pro,
      );

      _isLoading = false;
      notifyListeners();
    }
  }

  /// Increment projects created count
  void incrementProjectsCreated() {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(
        projectsCreated: (_currentUser!.projectsCreated) + 1,
      );
      notifyListeners();
    }
  }
}
