import 'package:firebase_core/firebase_core.dart';
import 'failure.dart';

class FirebaseExceptionHandler {
  static Failure handleException(Object e) {
    if (e is Failure) return e;

    if (e is FirebaseException) {
      switch (e.code) {
        case 'user-not-found':
          return const AuthFailure(message: 'User is not registered.');
        case 'invalid-credential':
          return const AuthFailure(message: 'Invalid email or password. Please check your credentials.');
        case 'wrong-password':
          return const AuthFailure(message: 'Wrong password provided.');
        case 'email-already-in-use':
          return const AuthFailure(message: 'The account already exists for that email.');
        case 'invalid-email':
          return const AuthFailure(message: 'The email address is badly formatted.');
        case 'permission-denied':
          return const AuthFailure(message: 'Authentication failed: Permission denied.');
        case 'unavailable':
          return const NetworkFailure(message: 'Firebase service is currently unavailable.');
        default:
          return AuthFailure(message: e.message ?? 'An auth error occurred.', code: e.code);
      }
    }

    final str = e.toString().replaceAll('Exception: ', '');
    return AuthFailure(message: str);
  }
}
