import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wefood/blocs/blocs.dart';
import 'package:wefood/commands/share_app.dart';
import 'package:wefood/components/components.dart';
import 'package:wefood/main.dart';
import 'package:wefood/models/models.dart';
import 'package:wefood/services/auth/api/api.dart';
import 'package:wefood/services/secure_storage.dart';
import 'package:wefood/views/views.dart';

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
      MaterialPageRoute(builder: (context) => const PendingOrdersCustomer()),
    );
  }

  void _navigateToTermsAndConditions() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TermsAndConditions()),
    );
  }

  void _getProfileImage() async {
      try {
        ImageModel? imageModel = await Api.getImage(
          idUser: context.read<UserInfoCubit>().state.user.id!,
          meaning: 'profile',
        );
        setState(() {
          imageRoute = imageModel.image;
        });
      } catch(e) {
        print('No se ha encontrado la imagen en la base de datos');
      }
  }

  Future _pickImageFromGallery() async {
    final returnedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
    if(returnedImage != null) {
      setState(() {
        _selectedImage = File(returnedImage.path);
      });
      ImageModel responseImage = await Api.uploadImage(
        idUser: context.read<UserInfoCubit>().state.user.id!,
        meaning: 'profile',
        file: _selectedImage!,
      );
      setState(() {
        imageRoute = responseImage.image;
      });
    }
  }

  Future _pickImageFromCamera() async {
    final returnedImage = await ImagePicker().pickImage(source: ImageSource.camera);
    if(returnedImage != null) {
      setState(() {
        _selectedImage = File(returnedImage.path);
      });
      ImageModel responseImage = await Api.uploadImage(
        idUser: 34,
        meaning: 'profile',
        file: _selectedImage!,
      );
      setState(() {
        imageRoute = responseImage.image;
      });
    }
  }

  void _deleteTokens() async {
    await UserSecureStorage().delete(key: 'accessToken');
    await UserSecureStorage().delete(key: 'accessTokenExpiresAt');
    await UserSecureStorage().delete(key: 'username');
    await UserSecureStorage().delete(key: 'password');
  }

  @override
  void initState() {
    _getProfileImage();
    super.initState();
  }

  String? imageRoute;
  File? _selectedImage;

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
              GestureDetector(
                onTap: () async {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return StatefulBuilder(builder: (context, StateSetter setState) {
                        return AlertDialog(
                          content: Container(
                            padding: EdgeInsets.symmetric(
                              vertical: MediaQuery.of(context).size.height * 0.01,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextButton(
                                  onPressed: () async {
                                    _pickImageFromGallery();
                                  },
                                  child: const Text('ESCOGER FOTO DE LA GALERÍA'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    _pickImageFromCamera();
                                  },
                                  child: const Text('SACAR FOTO CON LA CÁMARA'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    // TODO FALTA ESTO
                                  },
                                  child: const Text('ELIMINAR FOTO'),
                                ),
                              ],
                            ),
                          ),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('SALIR'),
                            ),
                          ],
                        );
                      });
                    },
                  );
                },
                child: Container(
                  margin: EdgeInsets.only(
                    right: MediaQuery.of(context).size.width * 0.05,
                  ),
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: <Widget>[
                      const Icon(
                        Icons.edit,
                      ),
                      Container(
                        padding: EdgeInsets.only(
                          right: MediaQuery.of(context).size.width * 0.025,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(1000),
                          child: SizedBox.fromSize(
                            size: Size.fromRadius(MediaQuery.of(context).size.width * 0.1),
                            child: (imageRoute != null)
                                ? Image.network(
                              imageRoute!,
                              fit: BoxFit.cover,
                            )
                                : Container(
                              color: Colors.grey.withOpacity(0.25),
                              child: Icon(
                                Icons.person,
                                size: MediaQuery.of(context).size.width * 0.1,
                                color: Colors.black.withOpacity(0.5),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
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