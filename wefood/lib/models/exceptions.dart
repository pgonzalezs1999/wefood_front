class AppException implements Exception {
  final String? titleMessage;
  final String? descriptionMessage;
  final String imageUrl;

  AppException({
    this.titleMessage,
    this.descriptionMessage,
    this.imageUrl = 'assets/images/logo.png',
  });
}

class WefoodBadRequestException extends AppException {
  WefoodBadRequestException(): super(
    titleMessage: 'Bad request',
    descriptionMessage: 'Poner algo más bonito aquí',
  );
}

class WefoodFetchDataException extends AppException {
  WefoodFetchDataException(): super(
    titleMessage: '¡No hay internet!',
    descriptionMessage: 'No podemos encontrar tu comida favorita sin conexión a internet...',
  );
}

class WefoodApiNotRespondingException extends AppException {
  WefoodApiNotRespondingException(): super(
    titleMessage: 'No ha sido posible conectar con el servidor',
    descriptionMessage: 'Por favor, inténtelo de nuevo más tarde',
  );
}

class WefoodUnauthorizedException extends AppException {
  WefoodUnauthorizedException(): super(
    titleMessage: 'Usuario o contraseña incorrectos',
  );
}

class WefoodDefaultException extends AppException {
  WefoodDefaultException(): super(
    titleMessage: '¡Algo ha ido mal!',
    descriptionMessage: 'Si el error persiste, contacte con soporte técnico',
  );
}