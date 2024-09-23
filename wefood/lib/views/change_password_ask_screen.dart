import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wefood/commands/call_request.dart';
import 'package:wefood/components/components.dart';
import 'package:wefood/services/auth/api.dart';
import 'package:wefood/types.dart';
import 'package:wefood/views/views.dart';

class ChangePasswordAskScreen extends StatefulWidget {
  const ChangePasswordAskScreen({super.key});

  @override
  State<ChangePasswordAskScreen> createState() => _ChangePasswordAskScreenState();
}

class _ChangePasswordAskScreenState extends State<ChangePasswordAskScreen> {

  String email = '';
  String code = '';
  bool codeSent = false;
  bool codeCorrect = false;
  String feedback = '';
  String password = '';
  String confirmPassword = '';
  bool showResendButton = false;
  Timer? resendEmailTimer;
  double resendEmailProgress = 0;
  int resendEmailDelaySeconds = 30;

  _navigateToMain() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MyApp()),
    );
  }

  bool _readyToChangePassword() {
    bool result = true;
    if(password.length < 6) {
      result = _setError('La contraseña debe tener 6 caracteres o más');
    } else if(password.length > 20) {
      result = _setError('La contraseña debe tener 20 caracteres o menos');
    } else if(confirmPassword != password) {
      result = _setError('Las contraseñas no coinciden');
    } else {
      setState(() {
        feedback = '';
      });
    }
    return result;
  }

  bool _setError(String reason) {
    setState(() {
      feedback = reason;
    });
    return false;
  }

  void _startTimeForResend() {
    int intervalMilliseconds = 200;
    resendEmailTimer = Timer.periodic(
      Duration(milliseconds: intervalMilliseconds),
      (Timer t) {
        setState(() {
          resendEmailProgress += (intervalMilliseconds / 1000);
          if(resendEmailProgress >= resendEmailDelaySeconds) {
            showResendButton = true;
            resendEmailTimer?.cancel();
          }
        });
      }
    );
  }

  List<String> _splitEmail(String email) {
    List<String> parts = email.split('@');
    String part1 = parts[0];
    String part2 = parts[1].split('.')[0];
    String part3 = parts[1].split('.')[1];
    return [ part1, part2, part3 ];
  }

  void _sendEmail() async {
    setState(() {
      showResendButton = false;
    });
    FocusScope.of(context).unfocus();
    List<String> emailParts = _splitEmail(email);
    callRequestWithLoading(
      context: context,
      request: () async {
        return await Api.emailChangePassword(
          part1: emailParts[0],
          part2: emailParts[1],
          part3: emailParts[2],
        );
      },
      onSuccess: (String message) {
        setState(() {
          codeSent = true;
        });
        _startTimeForResend();
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return WefoodPopup(
              context: context,
              title: 'Correo enviado',
              description: 'Si existe algún usuario asociado a esa dirección, recibirá un correo para establecer una nueva contraseña',
              cancelButtonTitle: 'OK',
            );
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    Widget typeEmailWidgets = Column(
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
          'Enviaremos un correo electrónico para establecer una nueva contraseña',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.02,
        ),
        WefoodInput(
          type: InputType.email,
          labelText: 'Correo electrónico',
          onChanged: (value) {
            if(value.isEmail) {
              setState(() {
                email = value;
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
            onPressed: _sendEmail,
            child: const Text('ENVIAR'),
          )
              : const BlockedButton(
            text: 'ENVIAR',
          ),
        ),
      ],
    );

    Widget typeVerificationCodeWidgets = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Hemos enviado un correo a $email',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.01,
        ),
        Text(
          'Introdúcelo aquí para verificar que eres tú',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.02,
        ),
        TextFormField(
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          initialValue: '',
          onChanged: (value) {
            setState(() {
              code = value;
            });
          },
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                width: 0.5,
                color: Theme.of(context).primaryColor,
              ),
            ),
            labelText: 'Código de verificación',
            focusColor: Colors.green,
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor,
              ),
              gapPadding: 4,
              borderRadius: const BorderRadius.all(Radius.circular(10))
            ),
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.05,
        ),
        Align(
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              (int.tryParse(code) != null && 5 <= code.length && code.length <= 7)
                ? ElevatedButton(
                  onPressed: () async {
                    FocusScope.of(context).unfocus();
                    callRequestWithLoading(
                      context: context,
                      request: () async {
                        List<String> emailParts = _splitEmail(email);
                        return await Api.checkChangePasswordCode(
                          part1: emailParts[0],
                          part2: emailParts[1],
                          part3: emailParts[2],
                          code: code,
                        );
                      },
                      onSuccess: (bool response) {
                        setState(() {
                          codeCorrect = response;
                        });
                      },
                      onError: (String message) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return WefoodPopup(
                              context: context,
                              title: 'Ha ocurrido un error',
                              description: 'Por favor, inténtelo de nuevo más tarde',
                              cancelButtonTitle: 'OK',
                            );
                          }
                        );
                      },
                    );
                  },
                  child: const Text('VERIFICAR'),
                )
                : const BlockedButton(
                  text: 'VERIFICAR',
                ),
              const SizedBox(
                height: 30,
              ),
              const Text(
                '¿No ha recibido el correo?',
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 10,
              ),
              if(resendEmailProgress < resendEmailDelaySeconds) Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    'Enviar de nuevo',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  SizedBox(
                    height: 25,
                    width: 25,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      value: (resendEmailProgress / resendEmailDelaySeconds),
                      backgroundColor: const Color(0x18000000),
                    ),
                  )
                ],
              ),
              if(resendEmailProgress >= resendEmailDelaySeconds) Align(
                alignment: Alignment.center,
                child: TextButton(
                  onPressed: _sendEmail,
                  child: const Text('Enviar de nuevo'),
                ),
              ),
              const SizedBox(
                width: 20,
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    codeSent = false;
                    codeCorrect = false;
                  });
                },
                child: const Text('Enviar a otro correo'),
              ),
            ],
          )
        ),
      ],
    );

    Widget typePasswordWidgets = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          '¡Código correcto!',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.01,
        ),
        Text(
          'Elige una nueva contraseña',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.02,
        ),
        WefoodInput(
          type: InputType.secret,
          labelText: 'Contraseña',
          onChanged: (value) {
            setState(() {
              password = value;
            });
            _readyToChangePassword();
          },
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.02,
        ),
        WefoodInput(
          type: InputType.secret,
          labelText: 'Confirmar contraseña',
          onChanged: (value) {
            setState(() {
              confirmPassword = value;
            });
            _readyToChangePassword();
          },
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.05,
        ),
        Align(
          alignment: Alignment.center,
          child: (feedback == '')
              ? ElevatedButton(
            onPressed: () async {
              FocusScope.of(context).unfocus();
              callRequestWithLoading(
                context: context,
                request: () async {
                  List<String> emailParts = _splitEmail(email);
                  return await Api.updatePassword(
                    email1: emailParts[0],
                    email2: emailParts[1],
                    email3: emailParts[2],
                    password: password,
                    verificationCode: code,
                  );
                },
                onSuccess: (response) {
                  _navigateToMain();
                },
                onError: (String message) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return WefoodPopup(
                        context: context,
                        title: 'Ha ocurrido un error',
                        description: 'Por favor, inténtelo de nuevo más tarde',
                        cancelButtonTitle: 'OK',
                      );
                    }
                  );
                },
              );
            },
            child: const Text('CAMBIAR'),
          )
              : const BlockedButton(
            text: 'CAMBIAR',
          ),
        ),
      ],
    );

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
              if(codeSent == false && codeCorrect == false) typeEmailWidgets,
              if(codeSent == true && codeCorrect == false) typeVerificationCodeWidgets,
              if(codeSent == true && codeCorrect == true) typePasswordWidgets,
            ],
          ),
        ),
      ],
    );
  }
}