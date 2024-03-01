class AppException implements Exception {
  final String message;
  final String prefix;
  final String url;

  AppException(this.message, this.prefix, this.url);
}

class BadRequestException extends AppException {
  BadRequestException(String message, String url): super(message, 'Bad request', url);
}

class FetchDataException extends AppException {
  FetchDataException(String message, String url): super(message, 'Unable to process', url);
}

class ApiNotRespondingException extends AppException {
  ApiNotRespondingException(String message, String url): super(message, 'API not responding', url);
}

class UnauthorizedException extends AppException {
  UnauthorizedException(String message, String url): super(message, 'Unauthorized', url);
}