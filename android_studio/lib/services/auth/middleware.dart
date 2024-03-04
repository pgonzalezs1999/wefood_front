import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:get/get_connect/http/src/exceptions/exceptions.dart';
import 'package:http/http.dart' as http;
import 'package:wefood/environment.dart';
import 'package:wefood/models/exceptions.dart';
import 'package:wefood/services/secure_storage.dart';
import 'package:wefood/types.dart';

class Middleware {

  static const Duration timeOutDuration = Duration(seconds: 5);

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
    if(type == HttpType.get && needsAccessToken == false) {
      Exception("All GET endpoints require an access token");
    }
    String? accessToken = await UserSecureStorage().read(key: 'accessToken');
    final auth = needsAccessToken ? { 'Authorization': 'Bearer $accessToken' } : null;
    final Uri url = Uri.parse('${Environment.apiUrl}$name');
    dynamic response;
    try {
      switch(type) {
        case HttpType.get:
          print('HACIENDO GET DE: $url CON HEADER: $auth');
          response = await get(
            url: url,
            auth: auth,
          ).timeout(timeOutDuration);
          break;
        case HttpType.post:
          print('HACIENDO POST DE: $url CON HEADER: $auth Y BODY: $body');
          response = await post(
            url: url,
            body: body,
            auth: auth,
          ).timeout(timeOutDuration);
          break;
        default:
          throw Exception("Unsupported HTTP method");
      }
      print('DEVUELVE EL JSON DECODE: ${jsonDecode(utf8.decode(response.bodyBytes))}');
      return jsonDecode(utf8.decode(response.bodyBytes));
    } catch(error) {
      print('ERROR: $error');
      return error;
    }
  }
}