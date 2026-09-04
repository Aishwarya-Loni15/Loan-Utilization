abstract class Failure {
  final String message;
  final String? code;

  const Failure({required this.message, this.code});
}

class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.code});
}

class CacheFailure extends Failure {
  const CacheFailure({required super.message, super.code});
}

class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'Network error occurred', super.code});
}

class AuthFailure extends Failure {
  const AuthFailure({required super.message, super.code});
}
