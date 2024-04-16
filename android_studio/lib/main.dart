import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wefood/blocs/blocs.dart';
import 'package:wefood/models/auth_model.dart';
import 'package:wefood/services/auth/api/api.dart';
import 'package:wefood/services/secure_storage.dart';
import 'package:wefood/views/home.dart';
import 'package:wefood/views/loading_screen.dart';
import 'package:wefood/views/login.dart';

void main() {
  runApp(const BlocsProvider());
}

class BlocsProvider extends StatelessWidget {
  const BlocsProvider({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => BusinessBreakfastCubit(), lazy: false),
        BlocProvider(create: (context) => BusinessLunchCubit(), lazy: false),
        BlocProvider(create: (context) => BusinessDinnerCubit(), lazy: false),
      ],
      child: const MyApp(),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return MaterialApp(
      title: 'WeFood',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Inicio'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Login()),
    );
  }

  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Home()),
    );
  }

  void _getAccessToken() async {
    String? accessToken = await UserSecureStorage().read(key: 'accessToken');
    DateTime? expiresAt = await UserSecureStorage().readDateTime(key: 'accessTokenExpiresAt');
    String? username = await UserSecureStorage().read(key: 'username');
    String? password = await UserSecureStorage().read(key: 'password');
    bool readyToLogin = false;
    if(accessToken != null && accessToken != '') {
      if(expiresAt != null && accessToken != '') {
        if(DateTime.now().difference(expiresAt) > const Duration(milliseconds: 0)) {
          readyToLogin = true;
        }
      }
    }
    if(readyToLogin == false) {
      if(username != null && password != null) {
        AuthModel? auth = await Api.login(
          context: context,
          username: username,
          password: password,
        );
        if(auth != null) {
          readyToLogin = true;
        }
      }
    }

    if(readyToLogin == true) {
      _navigateToHome();
    } else {
      _navigateToLogin();
    }
  }

  @override
  void initState() {
    super.initState();
    _getAccessToken();
  }

  @override
  Widget build(BuildContext context) {
    return const LoadingScreen();
  }
}