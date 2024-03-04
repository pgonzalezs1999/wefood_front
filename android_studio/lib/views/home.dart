import 'dart:async';
import 'package:flutter/material.dart';
import 'package:wefood/components/wefood_screen.dart';
import 'package:wefood/services/secure_storage.dart';
import 'package:wefood/views/user_explore.dart';
import 'package:wefood/views/user_profile.dart';

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
  final List<Widget> _screens = [
    const UserExplore(),
    const UserProfile(),
  ];

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
    accessTokenExpiresAt = await UserSecureStorage().readDateTime(key: 'accessTokenExpiresAt');
    if(accessTokenExpiresAt != null) {
      Duration difference = accessTokenExpiresAt!.difference(DateTime.now());
      accessTokenMinutesLeft = difference.inMinutes;
    }
    setState(() {});
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
    return WefoodScreen(
      canPop: false,
      body: _screens[_selectedScreenIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Explora',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
        currentIndex: _selectedScreenIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onScreenTapped,
      ),
    );
  }
}