class AsianPaintsException implements Exception {
  final String message;
  final String? prefix;
  AsianPaintsException({
    required this.message,
    this.prefix = '',
  });

  @override
  String toString() => '$prefix$message';
}

class NetworkException extends AsianPaintsException {
  NetworkException({required message}) : super(message: message);
}

class BadRequestException extends AsianPaintsException {
  BadRequestException({required message}) : super(message: message);
}

class AuthenticationException extends BadRequestException {
  AuthenticationException({required message}) : super(message: message);
}

class InternalServerError extends BadRequestException {
  InternalServerError({required message}) : super(message: message);
}

class TypeException extends AsianPaintsException {
  TypeException({required message}) : super(message: message);
}

class BackendException extends AsianPaintsException {
  BackendException({required message}) : super(message: message);
}
