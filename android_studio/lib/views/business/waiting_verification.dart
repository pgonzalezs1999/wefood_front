import 'dart:async';
import 'package:flutter/material.dart';
import 'package:wefood/components/components.dart';
import 'package:wefood/models/models.dart';
import 'package:wefood/services/auth/api/api.dart';
import 'package:wefood/services/secure_storage.dart';
import 'package:wefood/views/views.dart';

class WaitingVerification extends StatefulWidget {
  const WaitingVerification({super.key});

  @override
  State<WaitingVerification> createState() => _WaitingVerificationState();
}

class _WaitingVerificationState extends State<WaitingVerification> {

  late Timer _timer;
  bool isChecking = false;
  static const double delaySeconds = 60;
  double secondsToReload = 60;

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Login()),
    );
  }

  void _startTimer() async {
    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) async {
      setState(() {
        if(secondsToReload > 0.5) {
          if(isChecking  == false) {
            secondsToReload = secondsToReload - 0.5;
          }
        } else {
          secondsToReload = delaySeconds;
        }
      });
      if(secondsToReload == 0.5) {
        setState(() {
          isChecking = true;
        });
        try {
          String? username = await UserSecureStorage().read(key: 'username');
          String? password = await UserSecureStorage().read(key: 'password');
          bool validity = await Api.checkValidity(
            username: username ?? '',
          );
          if(validity == true) {
            AuthModel? auth = await Api.login(
              context: context,
              username: username!,
              password: password!,
            );
            _timer.cancel();
          }
          setState(() {
            isChecking = false;
          });
        } catch(e) {
          isChecking = false;
        }
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  void initState() {
    _startTimer();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    confirmPopup() {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, StateSetter setState) {
            return AlertDialog(
              content: Container(
                padding: EdgeInsets.symmetric(
                  vertical: MediaQuery.of(context).size.height * 0.01,
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('¿Seguro que quiere cancelar la solicitud?'),
                    Text('Tendrá que volver a rellenar todos los datos'),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('CANCELAR'),
                ),
                TextButton(
                  onPressed: () async {
                    await Api.cancelValidation(
                      username: (await UserSecureStorage().read(key: 'username'))!
                    );
                    await UserSecureStorage().delete(key: 'username');
                    await UserSecureStorage().delete(key: 'password');
                    _navigateToLogin();
                  },
                  child: const Text('CONFIRMAR'),
                ),
              ],
            );
          });
        }
      );
    }

    return WefoodScreen(
      canPop: false,
      body: SizedBox(
        height: MediaQuery.of(context).size.height * 0.9,
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Image.asset(
              'assets/images/logo.png',
              width: MediaQuery.of(context).size.width * 0.5,
            ),
            Column(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20
                  ),
                  child: const Text(
                    'Estamos verificando que los datos proporcionados son correctos. Pronto contactaremos con usted',
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(40),
                  child: const Text(
                    '¡Queremos que WeFood sea un lugar seguro!',
                    textAlign: TextAlign.center,
                  ),
                ),
                if(isChecking == true) const CircularProgressIndicator(),
                if(isChecking == false) SizedBox(
                  width: MediaQuery.of(context).size.width * 0.75,
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Text('Volveremos a comprobar si ha sido validado en ${secondsToReload.round()} segundos'),
                      ),
                      CircularProgressIndicator(
                        value: 1 - (secondsToReload / delaySeconds),
                        backgroundColor: Colors.grey.withAlpha(70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            ElevatedButton(
                onPressed: () {
                  confirmPopup();
                },
                child: const Text('CANCELAR ALTA'),
            )
          ],
        ),
      ),
    );
  }
}