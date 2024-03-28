import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
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

  static Future multipartPost({
    required String url,
    required Map<String, String> auth,
    body,
  }) async {
    var request = http.MultipartRequest('POST', Uri.parse(url),);
    auth.forEach((key, value) {
      request.headers[key] = value;
    });
    if(body != null) {
      body.forEach((key, value) {
        request.fields[key] = value;
      });
    }
    var picture = http.MultipartFile.fromBytes(
      'logo_file',
      (await rootBundle.load('assets/images/logo.png')).buffer.asUint8List(),
      filename: 'testImage.png',
    );
    request.files.add(picture);
    var response = await request.send();
    return response.stream.toBytes();
  }

  static Future endpoint({
    required String name,
    required HttpType type,
    body,
    bool needsAccessToken = true,
  }) async {
    String? accessToken = await UserSecureStorage().read(key: 'accessToken');
    final auth = needsAccessToken ? { 'Authorization': 'Bearer $accessToken' } : null;
    final String fullUrl = '${Environment.apiUrl}$name';
    final Uri uri = Uri.parse(fullUrl);
    dynamic response;
    try {
      switch(type) {
        case HttpType.get:
          print('HACIENDO GET DE: $uri');
          response = await get(
            url: uri,
            auth: auth,
          ).timeout(timeOutDuration);
          return jsonDecode(utf8.decode(response.bodyBytes));
        case HttpType.post:
          print('HACIENDO POST DE: $uri CON BODY: $body');
          response = await post(
            url: uri,
            body: body,
            auth: auth,
          ).timeout(timeOutDuration);
          return jsonDecode(utf8.decode(response.bodyBytes));
        case HttpType.multipartPost:
          print('HACIENDO MULTIPART_POST DE: $fullUrl CON BODY: $body');
          response = await multipartPost(
            url: fullUrl,
            body: body,
            auth: auth!,
          ).timeout(timeOutDuration);
          jsonDecode(utf8.decode(response));
        default:
          throw Exception("Unsupported HTTP method");
      }
    } catch(error) {
      return error;
    }
  }
}