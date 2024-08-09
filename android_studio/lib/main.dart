import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wefood/blocs/blocs.dart';
import 'package:wefood/components/components.dart';
import 'package:wefood/models/models.dart';
import 'package:wefood/services/app_links/app_links_subscription.dart';
import 'package:wefood/services/auth/api.dart';
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
        BlocProvider(create: (context) => UserLocationCubit(), lazy: false),
        BlocProvider(create: (context) => PendingOrdersBusinessCubit(), lazy: false),
        BlocProvider(create: (context) => RecommendedItemsCubit(), lazy: false),
        BlocProvider(create: (context) => NearbyItemsCubit(), lazy: false),
        BlocProvider(create: (context) => FavouriteItemsCubit(), lazy: false),
        BlocProvider(create: (context) => SearchFiltersCubit(), lazy: false),
        BlocProvider(create: (context) => OrderHistoryCubit(), lazy: false),
      ],
      child: const MyApp(),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  void _navigateToChangePasswordSetScreen({
    required Uri appLink,
  }) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => ChangePasswordSetScreen(
        appLink: appLink,
      )),
    );
  }

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

  @override
  void dispose() {
    AppLinksSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color wefoodPrimaryColor = const Color(0xFF392FAA);
    Color wefoodPrimaryAccent = const Color(0xFFCCDDFF);
    Color wefoodSecondaryColor = const Color(0xFFF96478);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return MaterialApp(
      title: 'Wefood',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: wefoodPrimaryColor,
          primary: wefoodPrimaryColor,
          secondary: wefoodSecondaryColor,
          // Placeholders
          surfaceContainer: Colors.grey.withOpacity(0.333),
          // BgColor de orderButton
          primaryContainer: wefoodPrimaryAccent,
          brightness: Brightness.light,
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.all<Color>(Theme.of(context).colorScheme.surface),
          trackOutlineColor: WidgetStateProperty.all<Color>(wefoodPrimaryColor),
          trackOutlineWidth: WidgetStateProperty.all<double>(1),
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
      debugShowCheckedModeBanner: false,
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
      MaterialPageRoute(builder: (context) => Login(
        appLink: AppLinksSubscription.getUri(),
      )),
    );
  }

  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Home()),
    );
  }

  void _getAccessToken() {
    debugPrint('ENTRA EN GET_ACCESS_TOKEN');
    UserSecureStorage().read(key: 'accessToken').then((String? accessToken) {
      UserSecureStorage().readDateTime(key: 'accessTokenExpiresAt').then((DateTime? expiresAt) {
        UserSecureStorage().read(key: 'username').then((String? username) {
          UserSecureStorage().read(key: 'password').then((String? password) {
            if(accessToken != null && accessToken != '' && expiresAt != null) {
              if(expiresAt.difference(DateTime.now()) > const Duration(milliseconds: 0)) {
                Api.login(
                  context: context,
                  username: username!,
                  password: password!,
                ).then((AuthModel? auth) {
                  if(auth != null) {
                    _navigateToHome();
                  } else {
                    _navigateToLogin();
                  }
                }).onError((error, stackTrace) {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return WefoodPopup(
                        context: context,
                        title: 'No se ha podido conectar con el servidor',
                        description: 'Por favor, inicie sesión de nuevo',
                        cancelButtonTitle: 'OK',
                      );
                    }
                  );
                  _navigateToLogin();
                });
              } else {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return WefoodPopup(
                      context: context,
                      title: 'Ha caducado la sesión',
                      description: 'Por favor, inicie sesión de nuevo',
                      cancelButtonTitle: 'OK',
                    );
                  }
                );
                _navigateToLogin();
              }
            } else {
              _navigateToLogin();
            }
          });
        });
      });
    });
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