import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wefood/commands/call_request.dart';
import 'package:wefood/components/components.dart';
import 'package:wefood/services/app_links/app_links_subscription.dart';
import 'package:wefood/services/auth/api.dart';
import 'package:wefood/views/views.dart';

class ChangePasswordAskScreen extends StatefulWidget {
  const ChangePasswordAskScreen({super.key});

  @override
  State<ChangePasswordAskScreen> createState() => _ChangePasswordAskScreenState();
}

class _ChangePasswordAskScreenState extends State<ChangePasswordAskScreen> {

  String email = '';

  @override
  void initState() {
    super.initState();
    AppLinksSubscription.setOnAppLinkReceivedCallback((uri) {
      _handleAppLink(uri);
    });
    AppLinksSubscription.start();
  }

  void _handleAppLink(Uri uri) {
    if(uri.path.contains('changePassword')) {
      _navigateToChangePasswordSetScreen(
        appLink: uri,
      );
    }
  }

  void _navigateToChangePasswordSetScreen({
    required Uri appLink,
  }) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => ChangePasswordSetScreen(
        appLink: appLink,
      )),
    ).whenComplete(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _popUntilFirst();
      });
    });
  }

  void _popUntilFirst() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _popUntilFirst();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WefoodScreen(
      bodyCrossAxisAlignment: CrossAxisAlignment.center,
      body: [
        const BackUpBar(title: 'Recuperar contraseña'),
        Container(
          height: MediaQuery.of(context).size.height * 0.75,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Introduce el correo asociado a tu usuario:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.01,
              ),
              Text(
                'Enviaremos un correo electrónico desde el que establecer una nueva contraseña',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.02,
              ),
              WefoodInput(
                labelText: 'Correo electrónico',
                onChanged: (value) {
                  if(value.isEmail) {
                    setState(() {
                      email = value;
                    });
                  } else {
                    setState(() {
                      email = '';
                    });
                  }
                },
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.05,
              ),
              Align(
                alignment: Alignment.center,
                child: (email.isEmail)
                  ? ElevatedButton(
                    onPressed: () async {
                      FocusScope.of(context).unfocus();
                      List<String> emailParts = email.split('@');
                      String part1 = emailParts[0];
                      String part2 = emailParts[1].split('.')[0];
                      String part3 = emailParts[1].split('.')[1];
                      callRequestWithLoading(
                        context: context,
                        request: () async {
                          return await Api.emailChangePassword(
                            part1: part1,
                            part2: part2,
                            part3: part3,
                          );
                        },
                        onSuccess: (String message) {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return WefoodPopup(
                                context: context,
                                title: 'Correo enviado',
                                description: 'Si existe algún usuario asociado a esa dirección, recibirá un correo para establecer una nueva contraseña. Por favor, abra ese correo con el mismo dispositivo que tiene instalada la aplicación de WeFood',
                                cancelButtonTitle: 'OK',
                              );
                            }
                          );
                        },
                      );
                    },
                    child: const Text('ENVIAR'),
                  )
                : const BlockedButton(
                  text: 'ENVIAR',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}