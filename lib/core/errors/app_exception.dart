class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  AppException({
    required this.message,
    this.code,
    this.details,
  });

  @override
  String toString() => 'AppException(message: $message, code: $code, details: $details)';
}

class NetworkException extends AppException {
  NetworkException({super.message = 'No internet connection', super.code = 'network_error'});
}

class AuthException extends AppException {
  AuthException({required super.message, super.code});
}

class StorageException extends AppException {
  StorageException({required super.message, super.code});
}

class ServerException extends AppException {
  ServerException({required super.message, super.code});
}
