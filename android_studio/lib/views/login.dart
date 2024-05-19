import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wefood/components/components.dart';
import 'package:wefood/environment.dart';
import 'package:wefood/models/models.dart';
import 'package:wefood/services/auth/api.dart';
import 'package:wefood/services/secure_storage.dart';
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
                  setState(() {
                    username = value;
                  });
                },
              ),
              WefoodInput(
                labelText: 'Contraseña',
                type: InputType.secret,
                onChanged: (value) {
                  setState(() {
                    password = value;
                  });
                },
              ),
            ],
          ),
        ),
        if(authenticating != LoadingStatus.loading && username != '' && password != '') ElevatedButton(
          child: const Text('INICIAR SESIÓN'),
          onPressed: () {
            setState(() {
              authenticating = LoadingStatus.loading;
            });
            Api.login(
              context: context,
              username: username,
              password: password,
            ).then((AuthModel authModel) {
              if(authModel.accessToken != null) {
                UserSecureStorage().writeDateTime(
                  key: 'accessTokenExpiresAt',
                  value: DateTime.now().add(Duration(seconds: authModel.expiresAt!))
                );
                UserSecureStorage().write(key: 'accessToken', value: authModel.accessToken!);
                UserSecureStorage().write(key: 'username', value: username);
                UserSecureStorage().write(key: 'password', value: password);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const Home()),
                );
              } else if(authModel.error != null) {
                setState(() {
                  authenticating = LoadingStatus.error;
                });
                String? title = 'Ha ocurrido un error';
                String? description = 'Por favor, inténtelo de nuevo más tarde. Si el error persiste, póngase en contacto con soporte.';
                if(authModel.error!.toLowerCase().contains('unauthorized')) {
                  title = 'Usuario o contraseña incorrectos';
                  description = null;
                }
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return WefoodPopup(
                      context: context,
                      title: title,
                      description: description,
                      cancelButtonTitle: 'OK',
                    );
                  }
                );
              }
            }).onError((error, stackTrace) {
              setState(() {
                authenticating = LoadingStatus.error;
              });
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return WefoodPopup(
                    context: context,
                    title: (error.runtimeType == TimeoutException) ? 'No se ha podido conectar con el servidor' : 'Ha ocurrido un error',
                    description: 'Por favor, inténtelo de nuevo más tarde. Si el error consiste, póngase en contacto con soporte.',
                    cancelButtonTitle: 'OK',
                  );
                }
              );
            });
          },
        ),
        if(authenticating != LoadingStatus.loading && (username == '' || password == '')) const BlockedButton(
          text: 'INICIAR SESIÓN',
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
        Container(
          padding: const EdgeInsets.only(
            bottom: 10,
          ),
          width: MediaQuery.of(context).size.width * 0.5,
          child: const Divider(
            height: 20,
          ),
        ),
        const Text('¿Alguna incidencia? Escríbenos a '),
        TextButton(
          onPressed: () async {
            String message = 'Buenas tardes. Quería hacer una consulta sobre la aplicación de WeFood:\n\n';
            String subject = 'Consulta sobre la aplicación WeFood';
            await launchUrl(
              Uri.parse('mailto:${Environment.supportEmail}?subject=$subject&body=$message'),
            );
          },
          child: const Text(Environment.supportEmail),
        ),
      ],
    );
  }
}