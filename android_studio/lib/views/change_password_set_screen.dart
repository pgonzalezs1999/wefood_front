import 'package:flutter/material.dart';
import 'package:wefood/components/components.dart';
import 'package:wefood/services/auth/api.dart';
import 'package:wefood/types.dart';
import 'package:wefood/views/views.dart';

class ChangePasswordSetScreen extends StatefulWidget {

  final Uri appLink;

  const ChangePasswordSetScreen({
    super.key,
    required this.appLink,
  });

  @override
  State<ChangePasswordSetScreen> createState() => _ChangePasswordSetScreenState();
}

class _ChangePasswordSetScreenState extends State<ChangePasswordSetScreen> {

  String email = '';
  String password = '';
  String confirmPassword = '';
  int verificationCode = 0;
  String feedback = '';

  _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Login()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WefoodScreen(
      canPop: false,
      bodyCrossAxisAlignment: CrossAxisAlignment.center,
      body: [
        Container(
          height: MediaQuery.of(context).size.height,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Resetear contraseña',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.015,
              ),
              WefoodInput(
                labelText: 'Contraseña',
                type: InputType.secret,
                onChanged: (value) {
                  setState(() {
                    password = value;
                    if(password.length < 6) {
                      feedback = 'Demasiado corta';
                    } else if(password.length > 20) {
                      feedback = 'Demasiado larga';
                    } else if(password != confirmPassword){
                      feedback = 'Las contraseñas no coinciden';
                    } else {
                      feedback = '';
                    }
                  });
                },
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.025,
              ),
              WefoodInput(
                labelText: 'Confirmar contraseña',
                type: InputType.secret,
                onChanged: (value) {
                  setState(() {
                    confirmPassword = value;
                    if(password != confirmPassword){
                      feedback = 'Las contraseñas no coinciden';
                    } else {
                      feedback = '';
                    }
                  });
                },
              ),
              if(feedback != '') FeedbackMessage(
                message: feedback,
                isError: true,
              ) ,
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.05,
              ),
              Align(
                alignment: Alignment.center,
                child: (feedback == '')
                  ? ElevatedButton(
                    onPressed: () async {
                      FocusScope.of(context).unfocus();
                      Api.updatePassword(
                        id: widget.appLink.queryParameters['id'] ?? '-1',
                        verificationCode: widget.appLink.queryParameters['code'] ?? '-1',
                        password: password,
                      ).then((String response) {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) {
                            return WefoodPopup(
                              context: context,
                              title: 'Contraseña modificada',
                              description: 'Utilícela para iniciar sesión a continuación',
                              cancelButtonTitle: 'INICIAR SESIÓN',
                              cancelButtonBehaviour: () {
                                _navigateToLogin();
                              },
                            );
                          }
                        );
                      }).onError((error, stackTrace) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return WefoodPopup(
                              context: context,
                              title: 'Ha ocurrido un error',
                              description: 'Por favor, inténtelo de nuevo más tarde. Si el error persiste, contacte con soporte.\n\n$error',
                              cancelButtonTitle: 'REGRESAR',
                              cancelButtonBehaviour: () {
                                _navigateToLogin();
                              },
                            );
                          }
                        );
                      });
                    },
                    child: const Text('CAMBIAR'),
                  )
                : const BlockedButton(
                  text: 'CAMBIAR',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}