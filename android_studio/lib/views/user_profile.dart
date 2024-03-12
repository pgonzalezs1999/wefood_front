import 'package:flutter/material.dart';
import 'package:wefood/components/profile_name.dart';
import 'package:wefood/components/settings_element.dart';
import 'package:wefood/components/wefood_navigation_screen.dart';
import 'package:wefood/components/wefood_popup.dart';
import 'package:wefood/main.dart';
import 'package:wefood/services/auth/api/api.dart';
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
    await UserSecureStorage().delete(key: 'username');
    await UserSecureStorage().delete(key: 'password');
  }

  @override
  Widget build(BuildContext context) {
    return WefoodNavigationScreen(
      children: [
        Container(
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height * 0.01,
          ),
          child: Row(
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(
                  right: MediaQuery.of(context).size.width * 0.05,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(1000),
                  child: SizedBox.fromSize(
                    size: Size.fromRadius(MediaQuery.of(context).size.width * 0.1),
                    child: Image.asset(
                      'assets/images/logo.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const ProfileName(),
            ],
          ),
        ),
        Column(
          children: <Widget>[
            SettingsElement(
              iconData: Icons.timelapse,
              title: 'Pedidos pendientes - FALTA',
              isFirst: true,
              onTap: () async {
                // TODO falta esto (quitar async y el mostrar accessToken)
                String? at = await UserSecureStorage().read(key: 'accessToken');
                print('ACCESS_TOKEN: $at');
              },
            ),
            SettingsElement(
              iconData: Icons.history,
              title: 'Historial de pedidos - FALTA',
              onTap: () {
                // TODO falta esto
              },
            ),
            SettingsElement(
              iconData: Icons.favorite,
              title: 'Favoritos - FALTA',
              onTap: () {
                // TODO falta esto
              },
            ),
            SettingsElement(
              iconData: Icons.notifications,
              title: 'Notificaciones - FALTA',
              onTap: () {
                // TODO falta esto
              },
            ),
            SettingsElement(
              iconData: Icons.share,
              title: 'Comparte la app - FALTA',
              onTap: () {
                // TODO falta esto
              },
            ),SettingsElement(
              iconData: Icons.support_agent,
              title: 'Contáctanos - FALTA',
              onTap: () {
                // TODO falta esto
              },
            ),
            SettingsElement(
              iconData: Icons.business,
              title: 'Términos y condiciones - FALTA',
              onTap: () {
                // TODO falta esto
              },
            ),
            SettingsElement(
              iconData: Icons.logout,
              title: 'Cerrar sesión',
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return WefoodPopup(
                      title: '¿Seguro que quieres cerrar sesión?',
                      onYes: () async {
                        await Api.logout();
                        _deleteToken();
                        Navigator.pop(context);
                        _navigateToMain();
                      },
                    );
                  }
                );
              },
            ),
            SettingsElement(
              iconData: Icons.delete,
              title: 'Darme de baja - FALTA',
              onTap: () {
                // TODO falta esto
              },
            ),
          ],
        ),
      ],
    );
  }
}