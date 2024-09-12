import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wefood/blocs/blocs.dart';
import 'package:wefood/commands/call_request.dart';
import 'package:wefood/commands/clear_data.dart';
import 'package:wefood/components/components.dart';
import 'package:wefood/models/models.dart';
import 'package:wefood/services/auth/api.dart';
import 'package:wefood/services/secure_storage.dart';
import 'package:wefood/views/views.dart';

class Home extends StatefulWidget {

  const Home({
    super.key
  });

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

  _retrieveDate() {
    Api.getProfile().then((UserModel response) {
      context.read<UserInfoCubit>().setUser(response);
      setState(() {
        context.read<UserInfoCubit>().state;
      });
    }).onError((error, stackTrace) {
      clearData(context);
      _navigateToMain();
    });
  }

  @override
  void initState() {
    _getAccessToken();
    _retrieveDate();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if(context.read<UserInfoCubit>().state.user.id == null) {
      return const LoadingScreen();
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