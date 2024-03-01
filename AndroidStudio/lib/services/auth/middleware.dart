import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:wefood/environment.dart';
import 'package:wefood/models/exceptions.dart';
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
          print('HA RESPONDIDO: $response, QUE ES DE TIPO: ${response.runtimeType}');
          break;
        default:
          throw Exception("Unsupported HTTP method");
      }
      return _processResponse(response);
    } on SocketException {
      throw FetchDataException('Unable to get a response from the API', url.toString());
    } on TimeoutException {
      throw ApiNotRespondingException('API not responded in time', url.toString());
    } catch(error) {
      print('ERROR: $error');
    }
  }

  static dynamic _processResponse(http.Response response) {
    print('STATUS CODE: ${response.statusCode}');
    switch(response.statusCode) {
      case 200:
        final responseJson = jsonDecode(utf8.decode(response.bodyBytes));
        print('RESPONSE_JSON: $responseJson, de tipo ${responseJson.runtimeType}');
        return responseJson;
      case 201:
        final responseJson = jsonDecode(utf8.decode(response.bodyBytes));
        return responseJson;
      case 403:
      case 422:
        throw UnauthorizedException(utf8.decode(response.bodyBytes), response.request!.url.toString());
      case 500:
      default:
        FetchDataException('Error occured with code: ${response.statusCode}', response.request!.url.toString());
    }
  }
}