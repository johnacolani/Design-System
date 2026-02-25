import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';
import '../services/firebase_service.dart';

class UserProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  bool get isLoggedIn {
    // Check if user is actually authenticated with Firebase (not just a guest)
    final firebaseUser = firebase_auth.FirebaseAuth.instance.currentUser;
    if (firebaseUser == null || _currentUser == null) {
      return false;
    }
    // Check that it's not a guest user (guests have IDs starting with 'guest_')
    return !_currentUser!.id.startsWith('guest_');
  }
  bool get isLoading => _isLoading;
  bool get isPremium => _currentUser?.isPremium ?? false;
  UserRole get userRole => _currentUser?.role ?? UserRole.free;

  /// Initialize with guest user or load saved user
  void initialize() {
    _currentUser = User.guest();
    notifyListeners();
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

  /// Sign in with Google
  Future<void> signInWithGoogle() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Configure Google Sign-In
      // IMPORTANT: For web, you MUST add the client ID to web/index.html:
      // <meta name="google-signin-client_id" content="YOUR_CLIENT_ID.apps.googleusercontent.com">
      // 
      // To get your Web Client ID:
      // 1. Go to: https://console.firebase.google.com/project/my-flutter-apps-f87ea/authentication/providers
      // 2. Click on "Google" provider
      // 3. Under "Web SDK configuration", copy the "Web client ID"
      // 4. Replace YOUR_WEB_CLIENT_ID in web/index.html line 43 with your actual client ID
      //
      // Alternatively, uncomment the clientId parameter below and add your client ID here
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
        // Uncomment and add your web client ID here if meta tag doesn't work:
        // clientId: '47033728900-xxxxx.apps.googleusercontent.com',
      );
      
      // Sign out any previous session first (helps with web and prevents cached auth issues)
      try {
        await googleSignIn.signOut();
      } catch (e) {
        // Ignore sign out errors (user might not be signed in)
        debugPrint('Sign out error (ignored): $e');
      }
      
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        // User canceled the sign-in
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      if (googleAuth.accessToken == null && googleAuth.idToken == null) {
        throw Exception('Failed to obtain Google authentication tokens');
      }

      // Create a new credential
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final userCredential = await FirebaseService.auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        // Check if user exists in Firestore
        final userDoc = await FirebaseService.usersCollection
            .doc(userCredential.user!.uid)
            .get();

        if (!userDoc.exists) {
          // Create new user document
          final userData = {
            'name': userCredential.user!.displayName ?? googleUser.displayName ?? 'User',
            'email': userCredential.user!.email ?? googleUser.email,
            'avatarUrl': userCredential.user!.photoURL ?? googleUser.photoUrl,
            'role': 'free',
            'createdAt': FieldValue.serverTimestamp(),
            'lastLoginAt': FieldValue.serverTimestamp(),
            'isPremium': false,
            'projectsCreated': 0,
          };

          await FirebaseService.usersCollection
              .doc(userCredential.user!.uid)
              .set(userData);
        } else {
          // Update last login
          await FirebaseService.usersCollection
              .doc(userCredential.user!.uid)
              .update({'lastLoginAt': FieldValue.serverTimestamp()});
        }

        await _loadUserFromFirebase(userCredential.user!);
      } else {
        throw Exception('Failed to sign in with Google: No user returned');
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      // Log the error for debugging
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

  /// Logout user
  Future<void> logout() async {
    try {
      await FirebaseService.auth.signOut();
      final GoogleSignIn googleSignIn = GoogleSignIn();
      await googleSignIn.signOut();
    } catch (e) {
      // Ignore errors
    }
    _currentUser = null;
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
