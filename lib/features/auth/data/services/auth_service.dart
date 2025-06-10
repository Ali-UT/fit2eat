import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth;

  AuthService(this._firebaseAuth);

  /// Stream of [User] to listen to authentication state changes.
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Gets the current [User] if authenticated, otherwise null.
  User? get currentUser => _firebaseAuth.currentUser;

  /// Signs in a user with the given email and password.
  ///
  /// Returns the [UserCredential] if successful.
  /// Throws a [FirebaseAuthException] if an error occurs.
  Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      // Consider logging the error or handling specific error codes
      print('Firebase Auth Exception (Sign In): ${e.code} - ${e.message}');
      // Re-throw the exception to be handled by the UI layer
    }
  }

  /// Creates a new user with the given email and password.
  ///
  /// Returns the [UserCredential] if successful.
  /// Throws a [FirebaseAuthException] if an error occurs.
  Future<UserCredential?> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // You might want to do something with the userCredential here,
      // like creating a user document in Firestore.
      return userCredential;
    } on FirebaseAuthException catch (e) {
      // Consider logging the error or handling specific error codes
      print('Firebase Auth Exception (Create User): ${e.code} - ${e.message}');
      // Re-throw the exception to be handled by the UI layer
    }
  }

  /// Signs out the current user.
  ///
  /// Throws an error if sign-out fails, though this is rare.
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      // Consider logging the error
      print('Error signing out: $e');
      // Re-throw the exception if necessary
    }
  }
}