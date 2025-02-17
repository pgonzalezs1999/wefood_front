import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wefood/blocs.dart';
import 'package:wefood/commands/clear_data.dart';
import 'package:wefood/commands/wefood_show_dialog.dart';
import 'package:wefood/components/components.dart';
import 'package:wefood/models.dart';
import 'package:wefood/services/auth/api.dart';
import 'package:wefood/services/secure_storage.dart';
import 'package:wefood/views/views.dart';
import 'commands/call_request.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  final int totalActions = 3;
  int completedActions = 0;
  bool optionalUpdateAvailable = false;

  String? accessToken;
  DateTime? accessTokenExpiresAt;
  int? accessTokenMinutesLeft;
  Timer? _timer;
  int _selectedScreenIndex = 0;

  List<String> feedback = [
    'Comprobando actualizaciones...',
    'Buscando última sesión...',
    'Recuperando datos de usuario...',
    '¡Listo!',
  ];

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Login()),
    );
  }

  void _navigateToMain() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MyApp()),
    );
  }

  void _navigateToUpdateRequired() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const UpdateRequired()),
    );
  }

  void _checkForUpdates() {
    Api.checkForUpdates().then((int response) {
      print('CHECK_FOR_UPDATES: $response');
      switch(response) {
        case 1:
          setState(() {
            completedActions++;
          });
          _getAccessToken();
          break;
        case 2:
          optionalUpdateAvailable = true;
          // TODO gestionar esto más adelante
          setState(() {
            completedActions++;
          });
          _getAccessToken();
          break;
        case 3:
          _navigateToUpdateRequired();
        default:
          // TODO Pantalla de ha ocurrido un error: intentarlo de nuevo
          // TODO Poner solo un texto que lo explique, y un boton para volver a ejecutar el Main();
          break;
      }
    }).onError((error, stackTrace) {
      print('ERROR EN CHECK_FOR_UPDATES: $error');
      _navigateToLogin();
    });
  }

  void _getAccessToken() {
    print('ENTRA EN GET_ACCESS_TOKEN');
    UserSecureStorage().read(key: 'accessToken').then((String? accessToken) {
      print('ACCESS_TOKEN: $accessToken');
      UserSecureStorage().readDateTime(key: 'accessTokenExpiresAt').then((DateTime? expiresAt) {
        print('ACCESS_TOKEN_EXPIRES_AT: $accessTokenExpiresAt');
        UserSecureStorage().read(key: 'username').then((String? username) {
          print('USERNAME: $username');
          UserSecureStorage().read(key: 'password').then((String? password) {
            print('PASSWORD: $password');
            if(accessToken != null && accessToken != '' && expiresAt != null) {
              print('(accessToken != null && accessToken != '' && expiresAt != null): ${accessToken != null && accessToken != '' && expiresAt != null}');
              if(expiresAt.difference(DateTime.now()) > const Duration(milliseconds: 0)) {
                print('expiresAt.difference(DateTime.now()) > const Duration(milliseconds: 0): ${expiresAt.difference(DateTime.now()) > const Duration(milliseconds: 0)}');
                Api.login(
                  context: context,
                  username: username!,
                  password: password!,
                ).then((AuthModel? auth) {
                  if(auth != null) {
                    setState(() {
                      completedActions++;
                    });
                    _checkAccessTokenExpiry();
                  } else {
                    _navigateToLogin();
                  }
                }).onError((error, stackTrace) {
                  wefoodShowDialog(
                    context: context,
                    title: 'No se ha podido conectar con el servidor',
                    description: 'Por favor, inicie sesión de nuevo',
                    cancelButtonTitle: 'OK',
                  );
                  _navigateToLogin();
                });
              } else {
                wefoodShowDialog(
                  context: context,
                  title: 'Ha caducado la sesión',
                  description: 'Por favor, inicie sesión de nuevo',
                  cancelButtonTitle: 'OK',
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

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 20), (timer) async {
      Duration difference = accessTokenExpiresAt!.difference(DateTime.now());
      accessTokenMinutesLeft = difference.inMinutes;
      if(accessTokenMinutesLeft == null || accessTokenMinutesLeft! <= 0) {
        UserSecureStorage().read(key: 'username').then((String? storedUser) {
          UserSecureStorage().read(key: 'password').then((String? storedPass) {
            if(storedUser != null && storedUser != '' && storedPass != null && storedPass != '') {
              callRequestWithLoading(
                context: context,
                request: () async {
                  Api.login(context: context, username: storedUser, password: storedPass);
                },
                onSuccess: (AuthModel auth) {
                  UserSecureStorage().writeDateTime(
                    key: 'accessTokenExpiresAt',
                    value: DateTime.now().add(Duration(seconds: auth.expiresAt!))
                  );
                  UserSecureStorage().write(key: 'accessToken', value: auth.accessToken!);
                },
                onError: (error) {
                  _timer?.cancel();
                  clearData(context);
                  _navigateToMain();
                }
              );
            }
          });
        });
      }
    });
    _retrieveData();
  }

  _retrieveData() {
    Api.getProfile().then((UserModel response) {
      context.read<UserInfoCubit>().setUser(response);
      setState(() {
        context.read<UserInfoCubit>().state;
        completedActions++;
      });
    }).onError((error, stackTrace) {
      clearData(context);
      _navigateToMain();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _checkAccessTokenExpiry() {
    UserSecureStorage().read(key: 'accessToken').then((String? token) {
      accessToken = (token != null) ? token : '';
      UserSecureStorage().readDateTime(key: 'accessTokenExpiresAt').then((DateTime? expirationDate) {
        accessTokenExpiresAt = expirationDate;
        Duration difference = accessTokenExpiresAt!.difference(DateTime.now());
        accessTokenMinutesLeft = difference.inMinutes;
        _startTimer();
      });
    });
  }

  void _onScreenTapped(int index) {
    setState(() {
      _selectedScreenIndex = index;
    });
  }

  bool shouldWaitForValidation({
    required dynamic idBusiness,
    required dynamic businessVerified,
  }) {
    bool result = false;
    if(idBusiness != null) {
      if(businessVerified == 0) {
        result = true;
      }
    }
    return result;
  }

  @override
  void initState() {
    super.initState();
    _checkForUpdates();
  }

  @override
  Widget build(BuildContext context) {
    if(completedActions != totalActions) {
      return Scaffold(
        body: Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.fitWidth,
                  width: MediaQuery.of(context).size.width * 0.5,
                ),
                const SizedBox(
                  height: 50,
                ),
                Text(
                  feedback[completedActions],
                ),
                const SizedBox(
                  height: 15,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.75,
                  child: LinearProgressIndicator(
                    value: completedActions / totalActions,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      UserModel userInfo = context.read<UserInfoCubit>().state.user;
      final List<Widget> screens = [
        if(userInfo.idBusiness == null && userInfo.isAdmin != true) const UserExplore(),
        if(userInfo.idBusiness == null && userInfo.isAdmin != true) const UserProfile(),
        if(userInfo.idBusiness != null && userInfo.isAdmin != true) const BusinessManagement(),
        if(userInfo.idBusiness != null && userInfo.isAdmin != true) const BusinessProfile(),
        if(userInfo.isAdmin == true) const AdminManagement(),
        if(userInfo.isAdmin == true) const AdminProfile(),
      ];
      return(shouldWaitForValidation(
          idBusiness: userInfo.idBusiness,
          businessVerified: userInfo.businessVerified
      ) == false) ? WefoodScreen(
        canPop: false,
        body: [ screens[_selectedScreenIndex] ],
        bottomNavigationBar: SizedBox(
          height: (MediaQuery.of(context).size.height - MediaQuery.of(context).viewPadding.top) * 0.075,
          child: BottomNavigationBar(
            items: <BottomNavigationBarItem>[
              if(userInfo.idBusiness == null && userInfo.isAdmin != true) const BottomNavigationBarItem(
                icon: Icon(Icons.search),
                label: 'Explora',
              ),
              if(userInfo.idBusiness == null && userInfo.isAdmin != true) const BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Perfil',
              ),
              if(userInfo.idBusiness != null && userInfo.isAdmin != true) const BottomNavigationBarItem(
                icon: Icon(Icons.business),
                label: 'Gestión',
              ),
              if(userInfo.idBusiness != null && userInfo.isAdmin != true) const BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Perfil',
              ),
              if(userInfo.isAdmin == true) const BottomNavigationBarItem(
                icon: Icon(Icons.business),
                label: 'Gestión',
              ),
              if(userInfo.isAdmin == true) const BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Perfil',
              ),
            ],
            currentIndex: _selectedScreenIndex,
            selectedItemColor: Theme.of(context).colorScheme.secondary,
            onTap: _onScreenTapped,
          ),
        ),
      ) : const WaitingVerification();
    }
  }
}