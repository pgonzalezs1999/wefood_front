class HttpErrorResponseModel implements Exception {
  final String code;
  final String message;

  HttpErrorResponseModel(this.code, this.message);

  HttpErrorResponseModel.fromJson(Map<String, dynamic> json) :
        code = json['code'],
        message = json['message'];
}