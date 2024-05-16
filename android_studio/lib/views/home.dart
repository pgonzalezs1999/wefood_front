import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wefood/blocs/blocs.dart';
import 'package:wefood/components/components.dart';
import 'package:wefood/models/models.dart';
import 'package:wefood/services/auth/api/api.dart';
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