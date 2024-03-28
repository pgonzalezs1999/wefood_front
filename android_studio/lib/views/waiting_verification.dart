import 'dart:async';
import 'package:flutter/material.dart';
import 'package:wefood/components/wefood_screen.dart';
import 'package:wefood/services/auth/api/api.dart';
import 'package:wefood/services/secure_storage.dart';
import 'package:wefood/views/home.dart';
import 'package:wefood/views/login.dart';

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

  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Home()),
    );
  }

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
          secondsToReload = secondsToReload - 0.5;
        } else {
          secondsToReload = delaySeconds;
        }
      });
      if(secondsToReload == 0.5) {
        setState(() {
          isChecking = true;
        });
        String? username = await UserSecureStorage().read(key: 'username');
        bool validity = await Api.checkValidity(
          username: username ?? '',
        );
        if(validity == true) {
          _navigateToHome();
          _timer.cancel();
        }
        setState(() {
          isChecking = false;
        });
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
                    // TODO llamada para poner a "2" el validated de ese business.
                      // TODO Un admin la eliminará a mano más tarde (para evitar hackeos, ya que
                      // TODO ese endpoint no requiere auth
                    // TODO also, hacer en back que un negocio validado no se pueda anular con este endpoint, sino
                      // TODO con signOut normal (que sí requiere auth)
                    // TODO eliminar username y pass de UserSecureStorage()
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
                      const Expanded(
                        child: Text('Volveremos a comprobar si ha sido validado en...'),
                      ),
                      CircularProgressIndicator(
                        value: 1 - (secondsToReload / delaySeconds),
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