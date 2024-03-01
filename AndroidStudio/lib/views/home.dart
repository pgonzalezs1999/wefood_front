import 'dart:async';
import 'package:flutter/material.dart';
import 'package:wefood/components/wefood_screen.dart';
import 'package:wefood/services/secure_storage.dart';
import 'package:wefood/main.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  String? accessToken;
  DateTime? accessTokenExpiresAt;
  int? accessTokenMinutesLeft;
  late Timer _timer;

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
    _showPopup();
    });
  }

  void _showPopup() {
    final snackBar = SnackBar(
      content: Text('El JWT caduca en $accessTokenMinutesLeft minutos'),
      duration: const Duration(seconds: 2), // Duración del SnackBar
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _getAccessToken() async {
    accessToken = await UserSecureStorage().read(key: 'accessToken') ?? '';
    setState(() {});
  }

  void _getAccessTokenExpiresAt() async {
    accessTokenExpiresAt = await UserSecureStorage().readDateTime(key: 'accessTokenExpiresAt');
    if(accessTokenExpiresAt != null) {
      Duration difference = accessTokenExpiresAt!.difference(DateTime.now());
      accessTokenMinutesLeft = difference.inMinutes;
    }
    setState(() {});
  }

  void _navigateToMain() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MyApp()),
    );
  }

  void _deleteToken() async {
    await UserSecureStorage().delete(key: 'accessToken');
    await UserSecureStorage().delete(key: 'accessTokenExpiresAt');
  }

  @override
  void initState() {
    super.initState();
    _getAccessToken();
    _getAccessTokenExpiresAt();
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: WefoodScreen(
        child: Center(
          child: Column(
            children: [
              Text('Estás dentro de la app! JWT: $accessToken'),
              ElevatedButton(
                  onPressed: () {
                    // Endpoint logout
                    _deleteToken();
                    _navigateToMain();
                  },
                  child: const Text('CERRAR SESIÓN'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}