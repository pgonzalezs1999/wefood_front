import 'package:flutter/material.dart';
import 'package:wefood/models/auth_model.dart';
import 'package:wefood/models/exceptions.dart';
import 'package:wefood/models/product_expanded_model.dart';
import 'package:wefood/models/user_model.dart';
import 'package:wefood/services/auth/middleware.dart';
import 'package:wefood/services/secure_storage.dart';
import 'package:wefood/types.dart';
import 'package:wefood/views/home.dart';

class Api {

  static List<AppException> handledErrors = [
    WefoodApiNotRespondingException(),
    WefoodUnauthorizedException(),
    WefoodBadRequestException(),
    WefoodFetchDataException(),
    WefoodDefaultException(),
  ];

  static _displayError({
    required BuildContext context,
    required dynamic error,
    String title = 'Error desconocido',
    String description = '',
    String imageUrl = 'assets/images/logo.jpg',
  }) {
    FocusScope.of(context).unfocus();
    if(handledErrors.any((e) => e.runtimeType == error.runtimeType)) {
      title = error.titleMessage;
      description = error.descriptionMessage ?? '';
      imageUrl = error.imageUrl ?? '';
    } else if(error.runtimeType == String) {
      title = error;
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                margin: EdgeInsets.symmetric(
                  vertical: MediaQuery.of(context).size.height * 0.025,
                ),
                child: Image.asset(
                  imageUrl,
                  width: MediaQuery.of(context).size.width * 0.5,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.05,
                  vertical: MediaQuery.of(context).size.height * 0.025,
                ),
                child: Text(title),
              ),
              Text(description),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      },
    );
  }

  static void login({
    required BuildContext context,
    required String username,
    required String password,
    required Function() onError,
  }) async {
    try {
      final response = await Middleware.endpoint(
        name: 'login',
        type: HttpType.post,
        body: {
          'username': username,
          'password': password,
        },
        needsAccessToken: false,
      );
      if(response['access_token'] == null) {
        onError();
        _displayError(context: context, error: response['error']);
      } else {
        AuthModel authModel = AuthModel.fromParameters(
            response['access_token'],
            response['expires_in']
        );
        await UserSecureStorage().write(key: 'accessToken', value: authModel.accessToken!);
        await UserSecureStorage().writeDateTime(
            key: 'accessTokenExpiresAt',
            value: DateTime.now().add(Duration(seconds: authModel.expiresAt!))
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Home()),
        );
      }
    } catch(error) {
      onError();
      _displayError(context: context, error: error);
    }
  }

  static Future<UserModel> getProfile() async {
    try {
      final response = await Middleware.endpoint(
        name: 'getProfile',
        type: HttpType.get,
      );
      UserModel userModel = UserModel.fromJson(response['message']);
      return userModel;
    } catch(error) {
      throw Exception(error);
    }
  }

  static updateUsername({
    required String username,
  }) async {
    try {
      dynamic response = await Middleware.endpoint(
          name: 'updateUsername',
          type: HttpType.post,
          body: {
            'username': username,
          }
      );
      return response;
    } catch(error) {
      throw Exception(error);
    }
  }

  static updateRealName({
    required String name,
    required String surname,
  }) async {
    try {
      dynamic response = await Middleware.endpoint(
        name: 'updateRealName',
        type: HttpType.post,
        body: {
          'real_name': name,
          'real_surname': surname,
        }
      );
      return response;
    } catch(error) {
      throw Exception(error);
    }
  }

  static Future<List<ProductExpandedModel>> getFavouriteProducts() async {
    try {
      dynamic response = await Middleware.endpoint(
        name: 'getFavouriteProducts',
        type: HttpType.get,
      );
      List<ProductExpandedModel> products = (response['products'] as List<dynamic>).map((product) => ProductExpandedModel.fromJson(product)).toList();
      return products;
    } catch(error) {
      throw Exception(error);
    }
  }

  static Future<List<ProductExpandedModel>> getNearbyBusinesses({
    required double longitude,
    required double latitude,
  }) async {
    try {
      dynamic response = await Middleware.endpoint(
        name: 'getNearbyBusinesses',
        type: HttpType.post,
        body: {
          'longitude': longitude.toString(),
          'latitude': latitude.toString(),
        }
      );
      List<ProductExpandedModel> products = (response['products'] as List<dynamic>).map((product) => ProductExpandedModel.fromJson(product)).toList();
      return products;
    } catch(error) {
      throw Exception(error);
    }
  }

  static Future<List<ProductExpandedModel>> getRecommendedProducts({
    required double longitude,
    required double latitude,
  }) async {
    try {
      dynamic response = await Middleware.endpoint(
          name: 'getRecommendedProducts',
          type: HttpType.post,
          body: {
            'longitude': longitude.toString(),
            'latitude': latitude.toString(),
          }
      );
      List<ProductExpandedModel> products = (response['products'] as List<dynamic>).map((product) => ProductExpandedModel.fromJson(product)).toList();
      return products;
    } catch(error) {
      throw Exception(error);
    }
  }

  static Future<ProductExpandedModel> getProduct({
    required int id,
  }) async {
    try {
      dynamic response = await Middleware.endpoint(
          name: 'getProduct/$id',
          type: HttpType.get,
      );
      ProductExpandedModel product = ProductExpandedModel.fromJson(response);
      return product;
    } catch(error) {
      throw Exception(error);
    }
  }
}