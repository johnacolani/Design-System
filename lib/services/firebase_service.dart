import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

/// Firebase service wrapper for easy access to Firebase services
class FirebaseService {
  // Firebase Auth instance
  static FirebaseAuth get auth => FirebaseAuth.instance;
  
  // Firestore instance
  static FirebaseFirestore get firestore => FirebaseFirestore.instance;
  
  // Storage instance
  static FirebaseStorage get storage => FirebaseStorage.instance;
  
  // Current user
  static User? get currentUser => auth.currentUser;
  
  // Check if user is logged in
  static bool get isLoggedIn => currentUser != null;
  
  // Users collection reference
  static CollectionReference get usersCollection => firestore.collection('users');
  
  // Design systems collection reference
  static CollectionReference get designSystemsCollection => firestore.collection('design_systems');
  
  // Projects collection reference
  static CollectionReference get projectsCollection => firestore.collection('projects');
  
  // User's design systems reference
  static CollectionReference userDesignSystems(String userId) {
    return usersCollection.doc(userId).collection('design_systems');
  }
  
  // User's projects reference
  static CollectionReference userProjects(String userId) {
    return usersCollection.doc(userId).collection('projects');
  }
  
  // Storage reference for user files
  static Reference userStorage(String userId) {
    return storage.ref().child('users').child(userId);
  }
  
  // Storage reference for design system exports
  static Reference designSystemStorage(String userId, String designSystemId) {
    return userStorage(userId).child('design_systems').child(designSystemId);
  }
}
