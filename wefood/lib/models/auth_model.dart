class AuthModel {
  final String? accessToken;
  final int? expiresAt;
  final String? error;

  AuthModel.fromJson(Map<String, dynamic> json):
    accessToken = json['access_token'] as String?,
    expiresAt = json['expires_in'] as int?,
    error = json['error'] as String?;

  AuthModel.empty():
    accessToken = null,
    expiresAt = null,
    error = null;

  AuthModel.fromParameters(String? newAccessToken, int? newExpiresAt):
    accessToken = newAccessToken,
    expiresAt = newExpiresAt,
    error = null;
}