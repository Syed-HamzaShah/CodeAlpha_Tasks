import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import 'supabase_posts_service.dart';

class AuthService extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isAuthenticated = false;
  bool _isInitialized = false;
  SupabasePostsService? _postsService;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  bool get isInitialized => _isInitialized;

  void setPostsService(SupabasePostsService postsService) {
    _postsService = postsService;
  }

  /// Initialize authentication state on app startup
  Future<void> initialize() async {
    try {
      // Listen to Firebase Auth state changes
      FirebaseAuth.instance.authStateChanges().listen((User? user) async {
        if (user != null) {
          await _loadUserFromFirestore(user.uid);
        } else {
          _currentUser = null;
          _isAuthenticated = false;
          notifyListeners();
        }
      });

      // Check if user is already signed in
      final currentFirebaseUser = FirebaseAuth.instance.currentUser;
      if (currentFirebaseUser != null) {
        await _loadUserFromFirestore(currentFirebaseUser.uid);
      } else {
        _isAuthenticated = false;
        _currentUser = null;
      }

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      _isAuthenticated = false;
      _currentUser = null;
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// Load user data from Firestore
  Future<void> _loadUserFromFirestore(String uid) async {
    try {
      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        _currentUser = UserModel.fromMap(userData);
        _isAuthenticated = true;
      } else {
        // If user document doesn't exist, create a minimal one
        final firebaseUser = FirebaseAuth.instance.currentUser!;
        _currentUser = UserModel(
          id: firebaseUser.uid,
          name: firebaseUser.displayName ?? 'User',
          email: firebaseUser.email ?? '',
          department: 'Unknown',
          semester: 'Unknown',
          profileImageUrl: firebaseUser.photoURL,
          createdAt: DateTime.now(),
        );

        // Save the user to Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(_currentUser!.id)
            .set(_currentUser!.toMap(), SetOptions(merge: true));

        _isAuthenticated = true;
      }
    } catch (e) {
      _isAuthenticated = false;
      _currentUser = null;
    }
  }

  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
    required String department,
    required String semester,
  }) async {
    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // Create user profile
      final user = UserModel(
        id: credential.user!.uid,
        name: name,
        email: email,
        department: department,
        semester: semester,
        profileImageUrl:
            'https://ui-avatars.com/api/?name=${Uri.encodeComponent(name)}&size=200&background=random',
        createdAt: DateTime.now(),
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.id)
          .set(user.toMap());

      _currentUser = user;
      _isAuthenticated = true;
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> signIn({required String email, required String password}) async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Load user data using the centralized method
      await _loadUserFromFirestore(credential.user!.uid);

      if (_isAuthenticated) {
        notifyListeners();
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      // Reset posts service (clear data and unsubscribe)
      _postsService?.reset();

      await FirebaseAuth.instance.signOut();

      _currentUser = null;
      _isAuthenticated = false;
      notifyListeners();
    } catch (e) {
      // Handle error silently
    }
  }

  Future<bool> updateProfile({
    String? name,
    String? department,
    String? semester,
    String? profileImageUrl,
  }) async {
    if (_currentUser == null) return false;

    try {
      final updatedUser = _currentUser!.copyWith(
        name: name,
        department: department,
        semester: semester,
        profileImageUrl: profileImageUrl,
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.id)
          .update(updatedUser.toMap());

      _currentUser = updatedUser;
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }
}
