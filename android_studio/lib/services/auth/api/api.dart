import 'package:flutter/material.dart';
import 'package:wefood/models/auth_model.dart';
import 'package:wefood/models/exceptions.dart';
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
    print('ERROR TYPE: ${error.runtimeType}');
    if(handledErrors.any((e) => e.runtimeType == error.runtimeType)) {
      title = error.titleMessage;
      description = error.descriptionMessage ?? '';
      imageUrl = error.imageUrl ?? '';
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
    } catch(error) {
      print('ERROR $error');
      onError();
      print(error is NoSuchMethodError);
      if(error is NoSuchMethodError) {
        _displayError(context: context, error: WefoodUnauthorizedException());
      } else {
        _displayError(context: context, error: error);
      }
    }
  }
}