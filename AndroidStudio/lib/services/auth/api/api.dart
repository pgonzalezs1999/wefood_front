import 'package:flutter/material.dart';
import 'package:wefood/models/auth_model.dart';
import 'package:wefood/services/auth/middleware.dart';
import 'package:wefood/services/secure_storage.dart';
import 'package:wefood/types.dart';
import 'package:wefood/views/home.dart';

class Api {

  static _displayError({
    required BuildContext context,
    String title = 'Error',
    String description = '',
  }) {
    FocusScope.of(context).unfocus();
    showDialog(
      context: context,
      // barrierDismissible: false,
      builder: (BuildContext context) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.symmetric(
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
      onError();
      _displayError(context: context);
    }
  }
}