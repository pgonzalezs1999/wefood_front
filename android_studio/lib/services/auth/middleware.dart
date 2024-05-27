import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:wefood/environment.dart';
import 'package:wefood/services/secure_storage.dart';
import 'package:wefood/types.dart';

class Middleware {

  static const Duration timeOutDuration = Duration(seconds: 20);

  static Future get({ required Uri url,  required auth }) async {
    try {
      final response = await http.get(
        url,
        headers: auth
      ).timeout(timeOutDuration, onTimeout: () {
        throw TimeoutException('TimeoutException');
      });
      return response;
    } catch (error) {
      rethrow;
    }
  }

  static Future post({ required Uri url,  required auth,  body, }) async {
    try {
      final response = await http.post(
        url,
        headers: auth,
        body: body
      ).timeout(timeOutDuration, onTimeout: () {
        throw TimeoutException('TimeoutException');
      });
      return response;
    } catch (error) {
      rethrow;
    }
  }

  static Future multipartPost({
    required String url,
    required Map<String, String> auth,
    body,
    file,
  }) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(url),);
      request.headers.addAll(auth);
      request.fields.addAll(body);
      final sendFile = await http.MultipartFile.fromPath(
        'image',
        file.path,
      ).timeout(timeOutDuration, onTimeout: () {
        throw TimeoutException('TimeoutException');
      });
      request.files.add(sendFile);
      final response = await http.Response.fromStream(await request.send());
      return response;
    } catch (error) {
      rethrow;
    }
  }

  static Future endpoint({
    required String name,
    required HttpType type,
    body,
    file,
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
          if(kDebugMode) { print('HACIENDO GET DE: $uri'); }
          response = await get(
            url: uri,
            auth: auth,
          );
          return jsonDecode(utf8.decode(response.bodyBytes));
        case HttpType.post:
          if(kDebugMode) { print('HACIENDO POST DE: $uri CON BODY: $body'); }
          response = await post(
            url: uri,
            body: body,
            auth: auth,
          );
          return jsonDecode(utf8.decode(response.bodyBytes));
        case HttpType.multipartPost:
          if(kDebugMode) { print('HACIENDO MULTIPART_POST DE: $fullUrl CON BODY: $body'); }
          response = await multipartPost(
            url: fullUrl,
            body: body,
            file: file,
            auth: auth!,
          );
          return response;
        default:
          throw Exception("Unsupported HTTP method");
      }
    } catch(error) {
      rethrow;
    }
  }
}