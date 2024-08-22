import 'package:flutter/material.dart';
import 'package:wefood/commands/call_request.dart';
import 'package:wefood/commands/clear_data.dart';
import 'package:wefood/commands/share_app.dart';
import 'package:wefood/components/components.dart';
import 'package:wefood/main.dart';
import 'package:wefood/services/auth/api.dart';
import 'package:wefood/views/views.dart';

class AdminProfile extends StatefulWidget {
  const AdminProfile({super.key});

  @override
  State<AdminProfile> createState() => _AdminProfileState();
}

class _AdminProfileState extends State<AdminProfile> {

  void _navigateToMain() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MyApp()),
    );
  }

  void _navigateToTermsAndConditions() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TermsAndConditions()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WefoodNavigationScreen(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(
            vertical: 20,
          ),
          alignment: Alignment.center,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                'Gestión de administradores',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Container(
                margin: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.01,
                  bottom: MediaQuery.of(context).size.height * 0.025,
                ),
                child: Image.asset(
                  'assets/images/logo.png',
                  width: MediaQuery.of(context).size.width * 0.5,
                ),
              ),
            ],
          ),
        ),
        Column(
          children: <Widget>[
            SettingsElement(
              iconData: Icons.share,
              title: 'Comparte la app',
              onTap: () async {
                await shareApp(context);
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
              iconData: Icons.logout,
              title: 'Cerrar sesión',
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return WefoodPopup(
                      context: context,
                      title: '¿Seguro que quieres cerrar sesión?',
                      actions: <TextButton>[
                        TextButton(
                          onPressed: () async {
                            callRequestWithLoading(
                              context: context,
                              request: () async {
                                return await Api.logout();
                              },
                              onSuccess: (_) async {
                                await clearData(context);
                                _navigateToMain();
                              },
                              onError: (error) async {
                                await clearData(context);
                                _navigateToMain();
                              },
                            );
                          },
                          child: const Text('SÍ'),
                        ),
                      ],
                    );
                  },
                );
              }
            ),
          ],
        ),
      ],
    );
  }
}