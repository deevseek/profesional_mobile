class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'ApiException(statusCode: $statusCode, message: $message)';
}

class UnauthorizedException extends ApiException {
  UnauthorizedException({String message = 'Unauthorized', int? statusCode})
      : super(message, statusCode: statusCode ?? 401);
}

class ValidationException extends ApiException {
  ValidationException({String message = 'Validation error', int? statusCode})
      : super(message, statusCode: statusCode ?? 422);
}

class NotFoundException extends ApiException {
  NotFoundException({String message = 'Not found', int? statusCode})
      : super(message, statusCode: statusCode ?? 404);
}

class ServiceUnavailableException extends ApiException {
  ServiceUnavailableException({
    String message = 'Service unavailable',
    int? statusCode,
  }) : super(message, statusCode: statusCode ?? 502);
}
