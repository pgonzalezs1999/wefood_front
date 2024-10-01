import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wefood/blocs/blocs.dart';
import 'package:wefood/commands/call_request.dart';
import 'package:wefood/commands/clear_data.dart';
import 'package:wefood/commands/contact_support.dart';
import 'package:wefood/commands/share_app.dart';
import 'package:wefood/commands/wefood_show_dialog.dart';
import 'package:wefood/components/components.dart';
import 'package:wefood/models/models.dart';
import 'package:wefood/services/auth/api.dart';
import 'package:wefood/types.dart';
import 'package:wefood/views/views.dart';
import 'package:http/http.dart' as http;

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {

  void _navigateToEditPersonalData({
    required EditPersonalInfo field,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditPersonalData(
        editPersonalInfo: field,
      )),
    ).whenComplete(() {
      setState(() {
        _refreshPersonalInfo();
      });
    });
  }

  void _navigateToMain() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MyApp()),
    );
  }

  void _navigateToPendingOrders() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PendingOrdersCustomer()),
    );
  }

  void _navigateToHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const History()),
    );
  }

  void _navigateToFavourites() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FavouritesScreen()),
    );
  }

  void _navigateToTermsAndConditions() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TermsAndConditions()),
    );
  }

  void _getProfileImage() async {
    if(context.read<UserInfoCubit>().state.image == null) {
      try {
        Api.getImage(
          idUser: context.read<UserInfoCubit>().state.user.id!,
          meaning: 'profile',
        ).then((ImageModel imageModel) {
          if(imageModel.route != null) {
            http.get(
              Uri.parse(imageModel.route!)
            ).then((response) {
              setState(() {
                context.read<UserInfoCubit>().setPicture(
                  ImageWithLoader.network(
                    route: imageModel.route!,
                    fit: BoxFit.cover,
                    height: MediaQuery.of(context).size.width * 0.5,
                    width: MediaQuery.of(context).size.width * 0.5,
                  ),
                );
              });
            });
          }
        }).onError((error, stackTrace) {
          if(kDebugMode) {
            print('No se ha encontrado la foto de perfil para este usuario');
          }
        });
      } catch(e) {
        return;
      }
    }
  }

  _pickImageFrom({
    required ImageSource imageSource
  }) {
    ImagePicker().pickImage(source: imageSource).then((XFile? returnedImage) {
      if(returnedImage != null) {
        callRequestWithLoading(
          context: context,
          request: () async {
            return await Api.uploadImage(
              idUser: context.read<UserInfoCubit>().state.user.id!,
              meaning: 'profile',
              file: File(returnedImage.path),
            );
          },
          onSuccess: (ImageModel imageModel) {
            Navigator.of(context).pop();
            if(imageModel.route != null) {
              setState(() {
                context.read<UserInfoCubit>().setPicture(
                  Image.network(
                    imageModel.route!,
                    fit: BoxFit.cover,
                    height: MediaQuery.of(context).size.width * 0.5,
                    width: MediaQuery.of(context).size.width * 0.5,
                  )
                );
              });
              wefoodShowDialog(
                context: context,
                title: '¡Foto de perfil cambiada correctamente!',
                cancelButtonTitle: 'OK',
              );
            }
          }
        );
      }
    });
  }

  _rebuildDirectionsCubit() async {
    setState(() {
      context.read<UserInfoCubit>().state;
    });
  }

  _refreshPersonalInfo() {
    auxRealName = context.read<UserInfoCubit>().state.user.realName ?? '';
    auxRealSurname = context.read<UserInfoCubit>().state.user.realSurname ?? '';
    auxUsername = context.read<UserInfoCubit>().state.user.username ?? '';
  }

  @override
  void initState() {
    _refreshPersonalInfo();
    _getProfileImage();
    super.initState();
  }

  String auxRealName = '';
  String auxRealSurname = '';
  String auxUsername = '';
  LoadingStatus usernameAvailabilityStatus = LoadingStatus.unset;
  bool usernameAvailable = false;

  @override
  Widget build(BuildContext context) {
    _rebuildDirectionsCubit();
    return WefoodNavigationScreen(
      children: [
        Container(
          margin: const EdgeInsets.only(
            bottom: 20,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              GestureDetector(
                onTap: () => wefoodShowDialog(
                  context: context,
                  image: context.read<UserInfoCubit>().state.image,
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton(
                        child: const Text('ESCOGER FOTO DE LA GALERÍA'),
                        onPressed: () async {
                          _pickImageFrom(
                            imageSource: ImageSource.gallery,
                          );
                        },
                      ),
                      TextButton(
                        onPressed: () async {
                          _pickImageFrom(
                            imageSource: ImageSource.camera,
                          );
                        },
                        child: const Text('SACAR FOTO CON LA CÁMARA'),
                      ),
                      if(context.read<UserInfoCubit>().state.image != null) TextButton(
                        child: const Text('ELIMINAR FOTO'),
                        onPressed: () {
                          callRequestWithLoading(
                            closePreviousPopup: true,
                            context: context,
                            request: () async {
                              return await Api.removeImage(
                                idUser: context.read<UserInfoCubit>().state.user.id!,
                                meaning: 'profile',
                              );
                            },
                            onSuccess: (_) {
                              wefoodShowDialog(
                                context: context,
                                title: 'Imagen eliminada correctamente',
                                cancelButtonTitle: 'OK',
                              );
                              context.read<UserInfoCubit>().removePicture();
                              setState(() {
                                context.read<UserInfoCubit>().state;
                              });
                            },
                          );
                        },
                      ),
                    ],
                  ),
                  cancelButtonTitle: 'SALIR',
                ),
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
                          right: MediaQuery.of(context).size.width * 0.02,
                        ),
                        child: Material(
                          elevation: 2,
                          borderRadius: BorderRadius.circular(1000),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(1000),
                            child: SizedBox.fromSize(
                              size: Size.fromRadius(MediaQuery.of(context).size.width * 0.1),
                              child: (context.read<UserInfoCubit>().state.image != null)
                                ? context.read<UserInfoCubit>().state.image
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
                      ),
                    ],
                  )
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    GestureDetector(
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              (context.read<UserInfoCubit>().state.user.realName != null)
                                ? '¡Hola de nuevo, ${context.read<UserInfoCubit>().state.user.realName}!'
                                : 'Introduzca su nombre',
                            ),
                          ),
                          const Icon(
                            Icons.edit,
                          ),
                        ],
                      ),
                      onTap: () => _navigateToEditPersonalData(field: EditPersonalInfo.realName),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    GestureDetector(
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              'Usuario: ${context.read<UserInfoCubit>().state.user.username}',
                            ),
                          ),
                          const Icon(
                            Icons.edit,
                          ),
                        ],
                      ),
                      onTap: () => _navigateToEditPersonalData(field: EditPersonalInfo.username),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    '${context.read<UserInfoCubit>().state.user.email}',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if(context.read<UserInfoCubit>().state.user.emailVerified == true) const Row(
                  children: [
                    SizedBox(
                      width: 10,
                    ),
                    Icon(
                      Icons.verified,
                    ),
                  ],
                )
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            SettingsElement(
              iconData: Icons.timelapse,
              title: 'Pedidos pendientes',
              onTap: () {
                _navigateToPendingOrders();
              },
            ),
            SettingsElement(
              iconData: Icons.history,
              title: 'Historial de pedidos',
              onTap: () {
                _navigateToHistory();
              },
            ),
            SettingsElement(
              iconData: Icons.favorite_outline,
              title: 'Productos favoritos',
              onTap: () {
                _navigateToFavourites();
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
              title: 'Contáctanos',
              onTap: () {
                launchContact(
                  context: context,
                );
              },
            ),
            SettingsElement(
              iconData: Icons.logout,
              title: 'Cerrar sesión',
              onTap: () => wefoodShowDialog(
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
              ),
            ),
            SettingsElement(
              iconData: Icons.business,
              title: 'Términos y condiciones',
              onTap: () {
                _navigateToTermsAndConditions();
              },
            ),
            SettingsElement(
              iconData: Icons.delete_outline,
              title: 'Darme de baja',
              onTap: () {
                wefoodShowDialog(
                  context: context,
                  title: '¿Seguro que quieres darte de baja?',
                  description: 'Perderás toda tu información y no podrás recuperarla más adelante.',
                  actions: <TextButton>[
                    TextButton(
                      onPressed: () {
                        Api.signOut(context).then((_) {
                          Navigator.of(context).pop();
                          _navigateToMain();
                        }).onError((error, stackTrace) {
                          Navigator.of(context).pop();
                          wefoodShowDialog(
                            context: context,
                            title: 'Ha ocurrido un error',
                            description: 'Por favor, inténtelo de nuevo más tarde',
                            cancelButtonTitle: 'OK',
                          );
                        });
                      },
                      child: const Text('SÍ'),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}