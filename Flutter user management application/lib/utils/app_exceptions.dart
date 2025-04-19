// Centralized exceptions for the application

/// Base exception class for the application
abstract class AppException implements Exception {
  final String message;
  final String? prefix;
  final Object? error;
  
  AppException({
    required this.message,
    this.prefix,
    this.error,
  });
  
  @override
  String toString() {
    return '${prefix ?? 'Error'}: $message${error != null ? '\nError: $error' : ''}';
  }
}

/// Network exceptions
class NetworkException extends AppException {
  NetworkException({
    required String message,
    Object? error,
  }) : super(
    message: message,
    prefix: 'Network Error',
    error: error,
  );
}

/// API exceptions
class ApiException extends AppException {
  final int? statusCode;
  
  ApiException({
    required String message,
    this.statusCode,
    Object? error,
  }) : super(
    message: message,
    prefix: 'API Error${statusCode != null ? ' ($statusCode)' : ''}',
    error: error,
  );
}

/// Local storage exceptions
class StorageException extends AppException {
  StorageException({
    required String message,
    Object? error,
  }) : super(
    message: message,
    prefix: 'Storage Error',
    error: error,
  );
}

/// Validation exceptions
class ValidationException extends AppException {
  ValidationException({
    required String message,
    Object? error,
  }) : super(
    message: message,
    prefix: 'Validation Error',
    error: error,
  );
}

/// Authentication exceptions
class AuthException extends AppException {
  AuthException({
    required String message,
    Object? error,
  }) : super(
    message: message,
    prefix: 'Authentication Error',
    error: error,
  );
}

/// Not found exceptions
class NotFoundException extends AppException {
  NotFoundException({
    required String message,
    Object? error,
  }) : super(
    message: message,
    prefix: 'Not Found',
    error: error,
  );
}

/// Timeout exceptions
class TimeoutException extends AppException {
  TimeoutException({
    String message = 'Request timed out',
    Object? error,
  }) : super(
    message: message,
    prefix: 'Timeout',
    error: error,
  );
}

/// General exceptions
class GeneralException extends AppException {
  GeneralException({
    required String message,
    Object? error,
  }) : super(
    message: message,
    prefix: 'Error',
    error: error,
  );
}