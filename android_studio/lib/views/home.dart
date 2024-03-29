import 'dart:async';
import 'package:flutter/material.dart';
import 'package:wefood/components/wefood_screen.dart';
import 'package:wefood/models/user_model.dart';
import 'package:wefood/services/auth/api/api.dart';
import 'package:wefood/services/secure_storage.dart';
import 'package:wefood/views/admin/admin_management.dart';
import 'package:wefood/views/business/business_management.dart';
import 'package:wefood/views/business/business_profile.dart';
import 'package:wefood/views/loading_screen.dart';
import 'package:wefood/views/user/user_explore.dart';
import 'package:wefood/views/user/user_profile.dart';
import 'package:wefood/views/business/waiting_verification.dart';

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

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 60), (timer) {
      _showPopup();
    });
  }

  void _showPopup() {
    final snackBar = SnackBar(
      content: Text('El JWT caduca en $accessTokenMinutesLeft minutos'),
      duration: const Duration(seconds: 5),
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
    accessTokenExpiresAt =
    await UserSecureStorage().readDateTime(key: 'accessTokenExpiresAt');
    if (accessTokenExpiresAt != null) {
      Duration difference = accessTokenExpiresAt!.difference(DateTime.now());
      accessTokenMinutesLeft = difference.inMinutes;
    }
    setState(() {});
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
    _getAccessToken();
    _getAccessTokenExpiresAt();
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserModel>(
      future: Api.getProfile(),
      builder: (BuildContext context, AsyncSnapshot<UserModel> response) {
        if(response.hasError) {
          return Container(
            margin: EdgeInsets.symmetric(
            vertical: MediaQuery.of(context).size.height * 0.05),
            child: const Text('Error'),
          );
        } else if(response.hasData) {
          final List<Widget> screens = [
            if(response.data!.idBusiness == null && response.data!.isAdmin != true) const UserExplore(),
            if(response.data!.idBusiness == null && response.data!.isAdmin != true) const UserProfile(),
            if(response.data!.idBusiness != null && response.data!.isAdmin != true) const BusinessManagement(),
            if(response.data!.idBusiness != null && response.data!.isAdmin != true) const BusinessProfile(),
            if(response.data!.isAdmin == true) const AdminManagement(),
            if(response.data!.isAdmin == true) const AdminManagement(),
          ];
          return (shouldWaitForValidation(
              idBusiness: response.data!.idBusiness,
              businessVerified: response.data!.businessVerified
          ) == false) ? WefoodScreen(
            canPop: false,
            body: screens[_selectedScreenIndex],
            bottomNavigationBar: BottomNavigationBar(
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
                  icon: Icon(Icons.business),
                  label: 'Gestión',
                ),
              ],
              currentIndex: _selectedScreenIndex,
              selectedItemColor: Colors.amber[800],
              onTap: _onScreenTapped,
            ),
          ) : const WaitingVerification();
        } else {
          return const LoadingScreen();
        }
      }
    );
  }
}