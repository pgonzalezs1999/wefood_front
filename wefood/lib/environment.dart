class Environment {
  static const int appVersion = 1;

  static const String serverUrl = 'https://api.wefoodcompany.com';
  static const String apiUrl = '$serverUrl/api/auth/';
  static const String storageUrl = '$serverUrl/storage/';

  static const double defaultHorizontalMargin = 0.05;
  static const double defaultVerticalMargin = 0.05;

  static const String googleMapsApiKey = 'AIzaSyBSyMRo2cAF7qSaS8ZTA2BjoqiwKiENsHM';
  static const String supportPhone = '+51912051667';
  static const String supportEmail = 'info@wefoodcompany.com';

  static const bool openpayIsSandbox = false;
  static const String openpayMerchantId = 'mg1ippvpuekjrkszeuxc'; // Sandbox -> 'muorexrewu3587xbmooq'; Production -> 'mg1ippvpuekjrkszeuxc'
  static const String openpayPublicKey = 'pk_540273ba143943b999db84f432e85aa3'; // Sandbox -> 'pk_d0651ad6528145c69c79de9002864eac'; Production -> 'pk_540273ba143943b999db84f432e85aa3'
  static const String openpaySecretKey = 'sk_da74b3a391734614a0ab59eae4c3cb9c'; // Sandbox -> 'sk_11db13e676de4739ba6c728fbba3efe0'; Production -> 'sk_da74b3a391734614a0ab59eae4c3cb9c'
  static const String openpayApiUrl = 'https://${Environment.openpayIsSandbox ? 'sandbox-' : ''}api.openpay.pe/v1/${Environment.openpayMerchantId}/';

  static const double minimumPrice = 5;
}