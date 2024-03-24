import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:wefood/environment.dart';
import 'package:wefood/services/secure_storage.dart';
import 'package:wefood/types.dart';

class Middleware {

  static const Duration timeOutDuration = Duration(seconds: 20);

  static Future get({
    required Uri url,
    required auth,
  }) async {
    final response = await http.get(
        url,
        headers: auth
    );
    return response;
  }

  static Future post({
    required Uri url,
    required auth,
    body,
  }) async {
    final response = await http.post(
        url,
        headers: auth,
        body: body
    );
    return response;
  }

  static Future endpoint({
    required String name,
    required HttpType type,
    body,
    bool needsAccessToken = true,
  }) async {
    String? accessToken = await UserSecureStorage().read(key: 'accessToken');
    final auth = needsAccessToken ? { 'Authorization': 'Bearer $accessToken' } : null;
    final Uri url = Uri.parse('${Environment.apiUrl}$name');
    dynamic response;
    try {
      switch(type) {
        case HttpType.get:
          print('HACIENDO GET DE: $url');
          response = await get(
            url: url,
            auth: auth,
          ).timeout(timeOutDuration);
          break;
        case HttpType.post:
          print('HACIENDO POST DE: $url CON BODY: $body');
          response = await post(
            url: url,
            body: body,
            auth: auth,
          ).timeout(timeOutDuration);
          break;
        default:
          throw Exception("Unsupported HTTP method");
      }
      return jsonDecode(utf8.decode(response.bodyBytes));
    } catch(error) {
      return error;
    }
  }
}