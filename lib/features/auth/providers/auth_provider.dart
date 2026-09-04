import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/enums/user_role.dart';
import '../../../data/repositories/auth_repository_impl.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/usecases/auth/login_user.dart';
import '../../../domain/usecases/auth/logout_user.dart';
import '../../../domain/usecases/auth/register_user.dart';
import '../../../domain/usecases/auth/reset_password.dart';
import '../../../domain/usecases/auth/verify_email.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl();
});

final loginUserUseCaseProvider = Provider<LoginUser>((ref) {
  return LoginUser(ref.watch(authRepositoryProvider));
});

final registerUserUseCaseProvider = Provider<RegisterUser>((ref) {
  return RegisterUser(ref.watch(authRepositoryProvider));
});

final logoutUserUseCaseProvider = Provider<LogoutUser>((ref) {
  return LogoutUser(ref.watch(authRepositoryProvider));
});

final resetPasswordUseCaseProvider = Provider<ResetPassword>((ref) {
  return ResetPassword(ref.watch(authRepositoryProvider));
});

final verifyEmailUseCaseProvider = Provider<VerifyEmail>((ref) {
  return VerifyEmail(ref.watch(authRepositoryProvider));
});

final authStateChangesProvider = StreamProvider<UserEntity?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

final currentUserProvider = StateNotifierProvider<CurrentUserNotifier, AsyncValue<UserEntity?>>((ref) {
  return CurrentUserNotifier(ref);
});

class CurrentUserNotifier extends StateNotifier<AsyncValue<UserEntity?>> {
  final Ref _ref;

  CurrentUserNotifier(this._ref) : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    try {
      final user = await _ref.read(authRepositoryProvider).getCurrentUser();
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final user = await _ref.read(loginUserUseCaseProvider).call(
            email: email,
            password: password,
          );
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String address,
    required String stateName,
    required String district,
    required String taluka,
    required String village,
    required UserRole role,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _ref.read(registerUserUseCaseProvider).call(
            name: name,
            email: email,
            password: password,
            phone: phone,
            address: address,
            state: stateName,
            district: district,
            taluka: taluka,
            village: village,
            role: role,
          );
      await logout();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> logout() async {
    await _ref.read(logoutUserUseCaseProvider).call();
    state = const AsyncValue.data(null);
  }

  Future<void> resetPassword(String email) async {
    await _ref.read(resetPasswordUseCaseProvider).call(email);
  }

  Future<void> sendEmailVerification() async {
    await _ref.read(verifyEmailUseCaseProvider).call();
  }
}
