import 'package:flutter/material.dart';
import 'package:wefood/components/components.dart';
import 'package:wefood/models/models.dart';
import 'package:wefood/services/auth/api/api.dart';
import 'package:wefood/types.dart';
import 'package:wefood/views/views.dart';

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
      bodyCrossAxisAlignment: CrossAxisAlignment.center,
      body: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.333,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Bienvenido a',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.666,
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
          onPressed: () {
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
        const SizedBox(
          height: 20,
        ),
        if(authenticating == LoadingStatus.loading) const CircularProgressIndicator(),
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
    );
  }
}