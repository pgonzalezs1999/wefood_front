import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wefood/blocs/blocs.dart';
import 'package:wefood/blocs/recommended_items_cubit.dart';
import 'package:wefood/models/models.dart';
import 'package:wefood/services/auth/api/api.dart';
import 'package:wefood/services/secure_storage.dart';
import 'package:wefood/views/views.dart';

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
        BlocProvider(create: (context) => UserInfoCubit(), lazy: false),
        BlocProvider(create: (context) => PendingOrdersBusinessCubit(), lazy: false),
        BlocProvider(create: (context) => RecommendedItemsCubit(), lazy: false),
        BlocProvider(create: (context) => NearbyItemsCubit(), lazy: false),
        BlocProvider(create: (context) => FavouriteItemsCubit(), lazy: false),
        BlocProvider(create: (context) => SearchFiltersCubit(), lazy: false),
      ],
      child: const MyApp(),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    Color wefoodPrimaryColor = const Color(0xFF392FAA);
    Color wefoodSecondaryColor = const Color(0xFFF96478);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return MaterialApp(
      title: 'WeFood',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: wefoodPrimaryColor,
          primary: wefoodPrimaryColor,
          secondary: wefoodSecondaryColor,
          surfaceContainer: Colors.grey.withOpacity(0.333),
          brightness: Brightness.light,
        ),
        iconTheme: IconThemeData(
          color: Theme.of(context).primaryColor,
        ),
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: TextStyle(
            color: wefoodPrimaryColor.withOpacity(0.66),
          ),
          floatingLabelStyle: TextStyle(
            color: wefoodPrimaryColor,
          ),
          suffixIconColor: wefoodPrimaryColor,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
            backgroundColor: WidgetStateProperty.all<Color>(wefoodPrimaryColor),
          ),
        ),
        textTheme: TextTheme(
          titleLarge: GoogleFonts.balooPaaji2(
            fontSize: 25,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
          ),
          // upperTitle de WefoodInput
          // title del WefoodPopup
          // títulos del userExplore
          titleMedium: GoogleFonts.balooPaaji2(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          // "Bienvenido a" del login
          titleSmall: GoogleFonts.balooPaaji2(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.5,
          ),
          headlineLarge: GoogleFonts.balooPaaji2(), // TODO sin utilizar
          headlineMedium: GoogleFonts.balooPaaji2(), // TODO sin utilizar
          headlineSmall: GoogleFonts.balooPaaji2(), // TODO sin utilizar
          bodyLarge: GoogleFonts.balooPaaji2(), // TODO sin utilizar
          bodyMedium: GoogleFonts.balooPaaji2(
            fontSize: 15,
          ),
          bodySmall: GoogleFonts.balooPaaji2(), // TODO sin utilizar
          // Botones
          labelLarge: GoogleFonts.balooPaaji2(
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ), // TODO sin utilizar
          labelMedium: GoogleFonts.balooPaaji2(), // TODO sin utilizar
          labelSmall: GoogleFonts.balooPaaji2(), // TODO sin utilizar
          displayLarge: GoogleFonts.balooPaaji2(), // TODO sin utilizar
          displayMedium: GoogleFonts.balooPaaji2(), // TODO sin utilizar
          // Feedback de los WefoodInput
          displaySmall: GoogleFonts.balooPaaji2(
            color: wefoodSecondaryColor,
            fontSize: 15,
          ),
        ),
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