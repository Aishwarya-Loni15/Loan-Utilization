import '../entities/user.dart';
import '../../core/enums/user_role.dart';

abstract class AuthRepository {
  Stream<UserEntity?> get authStateChanges;
  Future<UserEntity?> getCurrentUser();
  Future<UserEntity> login({required String email, required String password});
  Future<UserEntity> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String address,
    required String state,
    required String district,
    required String taluka,
    required String village,
    required UserRole role,
  });
  Future<void> logout();
  Future<void> sendPasswordResetEmail(String email);
  Future<void> sendEmailVerification();
}
