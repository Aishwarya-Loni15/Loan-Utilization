import '../../repositories/auth_repository.dart';

class VerifyEmail {
  final AuthRepository repository;

  VerifyEmail(this.repository);

  Future<void> call() async {
    await repository.sendEmailVerification();
  }
}
