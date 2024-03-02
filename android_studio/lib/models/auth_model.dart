class AuthModel {
  final String? accessToken;
  final int? expiresAt;

  AuthModel.fromJson(Map<String, dynamic> json):
    accessToken = json['access_token'] as String,
    expiresAt = json['expires_in'] as int;

  AuthModel.empty():
    accessToken = null,
    expiresAt = null;

  AuthModel.fromParameters(String? newAccessToken, int? newExpiresAt):
    accessToken = newAccessToken,
    expiresAt = newExpiresAt;
}