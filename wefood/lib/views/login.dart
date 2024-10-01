import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wefood/commands/call_request.dart';
import 'package:wefood/commands/wefood_show_dialog.dart';
import 'package:wefood/components/components.dart';
import 'package:wefood/environment.dart';
import 'package:wefood/models/models.dart';
import 'package:wefood/services/auth/api.dart';
import 'package:wefood/services/secure_storage.dart';
import 'package:wefood/types.dart';
import 'package:wefood/views/views.dart';

class Login extends StatefulWidget {

  const Login({
    super.key,
  });

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {

  LoadingStatus authenticating = LoadingStatus.unset;
  AuthModel authModel = AuthModel.empty();
  String username = '';
  String password = '';

  void _navigateToChangePasswordAskScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ChangePasswordAskScreen()),
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

  void _popUntilFirst() {
    if(Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _popUntilFirst();
      });
    }
  }

  void _handleFirstUsage() {
    UserSecureStorage().read(key: 'isFirstUsage').then((String? response) {
      if(response == null) {
        wefoodShowDialog(
          context: context,
          hideImage: true,
          description: 'WeFood solicitará acceder a tu ubicación personalizar tu experiencia. Para más información, consulta nuestros términos y condiciones',
          cancelButtonTitle: 'OK',
        );
        UserSecureStorage().write(
          key: 'isFirstUsage',
          value: 'false',
        );
      }
    });
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _popUntilFirst();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _handleFirstUsage();
    return WefoodScreen(
      canPop: false,
      bodyCrossAxisAlignment: CrossAxisAlignment.center,
      body: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.25,
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
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height * 0.025,
          ),
          child: Column(
            children: <Widget>[
              WefoodInput(
                labelText: 'Nombre de usuario o email',
                type: InputType.email,
                onChanged: (value) {
                  setState(() {
                    username = value;
                  });
                },
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.025,
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
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                    onPressed: () {
                      _navigateToChangePasswordAskScreen();
                    },
                    child: const Text('¿Contraseña olvidada?')
                ),
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
            callRequestWithLoading(
              context: context,
              request: () async {
                return await Api.login(
                  context: context,
                  username: username,
                  password: password,
                );
              },
              onSuccess: (AuthModel authModel) {
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
                    MaterialPageRoute(builder: (context) => const MyApp()),
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
                  wefoodShowDialog(
                    context: context,
                    title: title,
                    description: description,
                    cancelButtonTitle: 'OK',
                  );
                }
              },
              onError: (error, stackTrace) {
                setState(() {
                  authenticating = LoadingStatus.error;
                });
                wefoodShowDialog(
                  context: context,
                  title: (error.runtimeType == TimeoutException) ? 'No se ha podido conectar con el servidor' : 'Ha ocurrido un error',
                  description: 'Por favor, inténtelo de nuevo más tarde. Si el error consiste, póngase en contacto con soporte.',
                  cancelButtonTitle: 'OK',
                );
              }
            );
          },
        ),
        if(authenticating != LoadingStatus.loading && (username == '' || password == '')) const BlockedButton(
          text: 'INICIAR SESIÓN',
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.05,
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