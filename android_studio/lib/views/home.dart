import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wefood/blocs/blocs.dart';
import 'package:wefood/commands/call_request.dart';
import 'package:wefood/commands/clear_data.dart';
import 'package:wefood/components/components.dart';
import 'package:wefood/main.dart';
import 'package:wefood/models/models.dart';
import 'package:wefood/services/auth/api.dart';
import 'package:wefood/services/secure_storage.dart';
import 'package:wefood/views/views.dart';

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
  int _selectedScreenIndex = 0;

  void _onScreenTapped(int index) {
    setState(() {
      _selectedScreenIndex = index;
    });
  }

  void _navigateToMain() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MyApp()),
    );
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
                  _timer.cancel();
                  clearData(context);
                  _navigateToMain();
                }
              );
            }
          });
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _getAccessToken() {
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
    _getAccessToken();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserModel>(
      future: Api.getProfile(),
      builder: (BuildContext context, AsyncSnapshot<UserModel> response) {
        if(response.hasError) {
          clearData(context);
          _navigateToMain();
          return Container(
            margin: EdgeInsets.symmetric(
            vertical: MediaQuery.of(context).size.height * 0.05),
            child: const Text('Ha ocurrido un error'),
          );
        } else if(response.hasData) {
          context.read<UserInfoCubit>().setUser(response.data!);
          final List<Widget> screens = [
            if(response.data!.idBusiness == null && response.data!.isAdmin != true) const UserExplore(),
            if(response.data!.idBusiness == null && response.data!.isAdmin != true) const UserProfile(),
            if(response.data!.idBusiness != null && response.data!.isAdmin != true) const BusinessManagement(),
            if(response.data!.idBusiness != null && response.data!.isAdmin != true) const BusinessProfile(),
            if(response.data!.isAdmin == true) const AdminManagement(),
            if(response.data!.isAdmin == true) const AdminProfile(),
          ];
          return(shouldWaitForValidation(
            idBusiness: response.data!.idBusiness,
            businessVerified: response.data!.businessVerified
          ) == false) ? WefoodScreen(
            canPop: false,
            body: [ screens[_selectedScreenIndex] ],
            bottomNavigationBar: SizedBox(
              height: (MediaQuery.of(context).size.height - MediaQuery.of(context).viewPadding.top) * 0.075,
              child: BottomNavigationBar(
                items: <BottomNavigationBarItem>[
                  if(response.data!.idBusiness == null && response.data!.isAdmin != true) const BottomNavigationBarItem(
                    icon: Icon(Icons.search),
                    label: 'Explora',
                  ),
                  if(response.data!.idBusiness == null && response.data!.isAdmin != true) const BottomNavigationBarItem(
                    icon: Icon(Icons.person),
                    label: 'Perfil',
                  ),
                  if(response.data!.idBusiness != null && response.data!.isAdmin != true) const BottomNavigationBarItem(
                    icon: Icon(Icons.business),
                    label: 'Gestión',
                  ),
                  if(response.data!.idBusiness != null && response.data!.isAdmin != true) const BottomNavigationBarItem(
                    icon: Icon(Icons.person),
                    label: 'Perfil',
                  ),
                  if(response.data!.isAdmin == true) const BottomNavigationBarItem(
                    icon: Icon(Icons.business),
                    label: 'Gestión',
                  ),
                  if(response.data!.isAdmin == true) const BottomNavigationBarItem(
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
        } else {
          return const LoadingScreen();
        }
      }
    );
  }
}