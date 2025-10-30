import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../utils/app_logger.dart';

enum AuthStatus { initial, authenticated, unauthenticated, loading }

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth;
  late final StreamSubscription<User?> _authSubscription;
  User? _user;
  AuthStatus _status = AuthStatus.initial;
  String? _errorMessage;
  bool _isDisposed = false;

  User? get user => _user;

  AuthStatus get status => _status;

  String? get errorMessage => _errorMessage;

  bool get isAuthenticated => _status == AuthStatus.authenticated;

  AuthProvider({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance {
    _authSubscription = _auth.authStateChanges().listen(
      _onAuthStateChanged,
      onError: (Object error, StackTrace stackTrace) {
        _errorMessage = 'Failed to listen for auth changes';
        appLogger.e('Auth stream error', error: error, stackTrace: stackTrace);
        _safeNotifyListeners();
      },
    );
  }

  void _onAuthStateChanged(User? user) {
    if (_isDisposed) return;

    if (user == null) {
      _user = null;
      _status = AuthStatus.unauthenticated;
      _safeNotifyListeners();
      return;
    }
    _user = user;
    _status = AuthStatus.authenticated;

    appLogger.i('Auth state changed: ${_status.name}, User: ${user.email}');
    _safeNotifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _authSubscription.cancel();
    super.dispose();
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      _status = AuthStatus.loading;
      _errorMessage = null;
      _safeNotifyListeners();

      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await credential.user?.updateDisplayName(name);
      await credential.user?.reload();
      _user = _auth.currentUser;

      appLogger.i('User signed up successfully: ${_user?.email}');
      return true;
    } on FirebaseAuthException catch (e) {
      _status = AuthStatus.unauthenticated;
      _errorMessage = _getErrorMessage(e.code);
      appLogger.w('Sign up failed: ${e.code}');
      _safeNotifyListeners();
      return false;
    } catch (e, stackTrace) {
      _status = AuthStatus.unauthenticated;
      _errorMessage = 'An unexpected error occurred';
      appLogger.e(
        'Unexpected error during sign up',
        error: e,
        stackTrace: stackTrace,
      );
      _safeNotifyListeners();
      return false;
    }
  }

  Future<bool> signIn({required String email, required String password}) async {
    try {
      _status = AuthStatus.loading;
      _errorMessage = null;
      _safeNotifyListeners();

      await _auth.signInWithEmailAndPassword(email: email, password: password);

      appLogger.i('User signed in successfully: $email');
      return true;
    } on FirebaseAuthException catch (e) {
      _status = AuthStatus.unauthenticated;
      _errorMessage = _getErrorMessage(e.code);
      appLogger.w('Sign in failed: ${e.code}');
      _safeNotifyListeners();
      return false;
    } catch (e, stackTrace) {
      _status = AuthStatus.unauthenticated;
      _errorMessage = 'An unexpected error occurred';
      appLogger.e(
        'Unexpected error during sign in',
        error: e,
        stackTrace: stackTrace,
      );
      _safeNotifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    appLogger.i('User signed out: ${_user?.email}');
    await _auth.signOut();
  }

  void clearError() {
    _errorMessage = null;
    _safeNotifyListeners();
  }

  Future<void> handleSignIn({
    required String email,
    required String password,
    required Function(String) onError,
  }) async {
    final success = await signIn(email: email, password: password);
    if (!success && _errorMessage != null) {
      onError(_errorMessage!);
    }
  }

  Future<void> handleSignUp({
    required String email,
    required String password,
    required String name,
    required Function() onSuccess,
    required Function(String) onError,
  }) async {
    final success = await signUp(email: email, password: password, name: name);
    if (success) {
      onSuccess();
    } else if (_errorMessage != null) {
      onError(_errorMessage!);
    }
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'weak-password':
        return 'Password is too weak';
      case 'email-already-in-use':
        return 'Email is already registered';
      case 'invalid-email':
        return 'Invalid email address';
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'invalid-credential':
        return 'Invalid email or password';
      default:
        return 'Authentication failed. Please try again';
    }
  }

  void _safeNotifyListeners() {
    if (_isDisposed) {
      return;
    }
    super.notifyListeners();
  }
}
