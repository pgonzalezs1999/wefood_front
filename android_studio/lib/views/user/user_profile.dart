import 'package:flutter/material.dart';
import 'package:wefood/commands/share_app.dart';
import 'package:wefood/components/profile_name.dart';
import 'package:wefood/components/settings_element.dart';
import 'package:wefood/components/wefood_navigation_screen.dart';
import 'package:wefood/components/wefood_popup.dart';
import 'package:wefood/main.dart';
import 'package:wefood/services/auth/api/api.dart';
import 'package:wefood/services/secure_storage.dart';
import 'package:wefood/views/user/favourites_screen.dart';
import 'package:wefood/views/terms_and_conditions.dart';
import 'package:wefood/views/user/pending_orders_screen.dart';

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

  void _navigateToFavourites() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FavouritesScreen()),
    );
  }

  void _navigateToPendingOrders() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PendingOrdersScreen()),
    );
  }

  void _navigateToTermsAndConditions() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TermsAndConditions()),
    );
  }

  void _deleteTokens() async {
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
          margin: const EdgeInsets.only(
            bottom: 20,
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
                      'assets/images/salmon.jpg', // TODO esta foto no es !!
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
              title: 'Pedidos pendientes',
              onTap: () {
                _navigateToPendingOrders();
              },
            ),
            SettingsElement(
              iconData: Icons.history,
              title: 'Historial de pedidos - FALTA',
              onTap: () async { // TODO falta esto
                // TODO quitar async y el mostrar accessToken
                String? at = await UserSecureStorage().read(key: 'accessToken');
                print('ACCESS_TOKEN: $at');
                // TODO falta esto
              },
            ),
            SettingsElement(
              iconData: Icons.favorite,
              title: 'Productos favoritos',
              onTap: () {
                _navigateToFavourites();
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
              title: 'Comparte la app',
              onTap: () async {
                await shareApp(context);
              },
            ),
            SettingsElement(
              iconData: Icons.support_agent,
              title: 'Contáctanos - FALTA',
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
                          _deleteTokens();
                          Navigator.pop(context);
                          _navigateToMain();
                        },
                      );
                    }
                );
              },
            ),
            SettingsElement(
              iconData: Icons.business,
              title: 'Términos y condiciones',
              onTap: () {
                _navigateToTermsAndConditions();
              },
            ),
            SettingsElement(
              iconData: Icons.delete,
              title: 'Darme de baja',
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return WefoodPopup(
                      title: '¿Seguro que quieres darte de baja?',
                      description: 'Perderás toda tu información y no podrás recuperarla más adelante.',
                      onYes: () async {
                        await Api.signOut();
                        _deleteTokens();
                        Navigator.pop(context);
                        _navigateToMain();
                      },
                    );
                  }
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}