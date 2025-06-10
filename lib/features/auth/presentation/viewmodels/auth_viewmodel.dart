import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fit2eat/features/auth/data/services/auth_service.dart'; // Assuming AuthService is here

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService;
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  AuthViewModel({required AuthService authService}) : _authService = authService {
    // It's generally better to listen to authStateChanges from FirebaseAuth directly
    // or ensure your AuthService exposes a similar reliable stream.
    // For simplicity, if AuthService wraps FirebaseAuth, it might have its own stream.
    // If AuthService directly uses FirebaseAuth.instance.authStateChanges(), that's fine.
    // Remove this listener as we will expose the stream directly from AuthService
    // FirebaseAuth.instance.authStateChanges().listen((user) {
    //   _user = user;
    //   notifyListeners();
    // });
    _authService.authStateChanges.listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  // Expose the authStateChanges stream from AuthService
  Stream<User?> get authStateChanges => _authService.authStateChanges;

  Future<void> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      // Corrected: Added named arguments
      await _authService.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred during sign in.';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> signUp(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      // Corrected: Added named arguments
      await _authService.createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred during sign up.';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();
    await _authService.signOut();
    _isLoading = false;
    notifyListeners();
  }
}