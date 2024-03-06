import 'package:flutter/material.dart';
import 'package:wefood/components/wefood_input.dart';
import 'package:wefood/components/wefood_screen.dart';
import 'package:wefood/models/auth_model.dart';
import 'package:wefood/services/auth/api/api.dart';
import 'package:wefood/types.dart';
import 'package:sign_in_button/sign_in_button.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {

  LoadingStatus authenticating = LoadingStatus.unset;
  AuthModel authModel = AuthModel.empty();
  String username = '';
  String password = '';

  void _showButtonPressDialog(BuildContext context, String provider) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$provider Button Pressed!'),
        backgroundColor: Colors.black26,
        duration: const Duration(milliseconds: 1000),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WefoodScreen(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width * 0.5,
            margin: EdgeInsets.symmetric(
              vertical: MediaQuery.of(context).size.height * 0.025,
            ),
            child: Image.asset('assets/images/logo.jpg'),
          ),
          Text(
              '¡Bienvenido a WeFood!',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Container(
            margin: EdgeInsets.symmetric(
              vertical: MediaQuery.of(context).size.height * 0.025,
            ),
            child: Wrap(
              runSpacing: MediaQuery.of(context).size.height * 0.025,
              children: <WefoodInput>[
                WefoodInput(
                  labelText: 'Nombre de usuario o email',
                  onChanged: (value) {
                    username = value;
                  },
                ),
                WefoodInput(
                  labelText: 'Contraseña',
                  type: InputType.secret,
                  onChanged: (value) {
                    password = value;
                  },
                ),
              ],
            ),
          ),
          if(authenticating != LoadingStatus.loading) ElevatedButton(
            onPressed: () async {
              setState(() {
                authenticating = LoadingStatus.loading;
              });
              Api.login(
                context: context,
                username: username,
                password: password,
                onError: () {
                  setState(() {
                    authenticating = LoadingStatus.error;
                  });
                }
              );
            },
            child: const Text('INICIAR SESIÓN'),
          ),
          if(authenticating == LoadingStatus.loading) const CircularProgressIndicator(),
          Container(
            padding: EdgeInsets.symmetric(
              vertical: MediaQuery.of(context).size.height * 0.025,
            ),
            child: SignInButton(
              Buttons.google,
              onPressed: () {
                _showButtonPressDialog(context, 'Google');
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text('¿No tienes cuenta?'),
              TextButton(
                onPressed: () {

                },
                child: const Text('Regístrate gratis'),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text('¿Quieres listar tu negocio?'),
              TextButton(
                onPressed: () {

                },
                child: const Text('Regístralo gratis'),
              ),
            ],
          ),
          TextButton(
            onPressed: () {

            },
            child: const Text('Términos y condiciones legales'),
          ),
        ],
      ),
    );
  }
}