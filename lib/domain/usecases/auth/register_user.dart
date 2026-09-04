import '../../../core/enums/user_role.dart';
import '../../entities/user.dart';
import '../../repositories/auth_repository.dart';

class RegisterUser {
  final AuthRepository repository;

  RegisterUser(this.repository);

  Future<UserEntity> call({
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
  }) async {
    return await repository.register(
      name: name,
      email: email,
      password: password,
      phone: phone,
      address: address,
      state: state,
      district: district,
      taluka: taluka,
      village: village,
      role: role,
    );
  }
}
