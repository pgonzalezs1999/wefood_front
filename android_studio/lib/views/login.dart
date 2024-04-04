import 'package:flutter/material.dart';
import 'package:wefood/components/wefood_input.dart';
import 'package:wefood/components/wefood_screen.dart';
import 'package:wefood/models/auth_model.dart';
import 'package:wefood/services/auth/api/api.dart';
import 'package:wefood/types.dart';
import 'package:sign_in_button/sign_in_button.dart';
import 'package:wefood/views/register_business.dart';
import 'package:wefood/views/register_user.dart';
import 'package:wefood/views/terms_and_conditions.dart';

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

  void _navigateToRegisterUser() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegisterUser()),
    );
  }

  void _navigateToRegisterBusiness() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegisterBusiness()),
    );
  }

  void _navigateToTermsAndConditions() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TermsAndConditions()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WefoodScreen(
      canPop: false,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.333,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('Bienvenido a'),
                Container(
                  width: MediaQuery.of(context).size.width * 0.5,
                  margin: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.01,
                  ),
                  child: Image.asset('assets/images/logo.png'),
                ),
              ],
            ),
          ) ,
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
              AuthModel? auth = await Api.login(
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
                  _navigateToRegisterUser();
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
                  _navigateToRegisterBusiness();
                },
                child: const Text('Regístralo gratis'),
              ),
            ],
          ),
          TextButton(
            onPressed: () {
              _navigateToTermsAndConditions();
            },
            child: const Text('Términos y condiciones legales'),
          ),
        ],
      ),
    );
  }
}