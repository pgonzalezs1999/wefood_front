import 'package:flutter/material.dart';
import 'package:wefood/components/profile_name.dart';
import 'package:wefood/components/wefood_navigation_screen.dart';
import 'package:wefood/main.dart';
import 'package:wefood/services/secure_storage.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {

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
  Widget build(BuildContext context) {
    return WefoodNavigationScreen(
      children: [
        Row(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(
                right: MediaQuery.of(context).size.width * 0.05,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(1000),
                child: SizedBox.fromSize(
                  size: Size.fromRadius(MediaQuery.of(context).size.width * 0.1),
                  child: Image.asset('assets/images/logo.jpg'),
                ),
              ),
            ),
            const ProfileName(),
          ],
        ),
        ElevatedButton(
          onPressed: () {
            // TODO Endpoint logout
            _deleteToken();
            _navigateToMain();
          },
          child: const Text('CERRAR SESIÓN'),
        ),
      ],
    );
  }
}