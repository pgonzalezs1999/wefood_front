import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wefood/blocs/blocs.dart';
import 'package:wefood/commands/contact_support.dart';
import 'package:wefood/commands/open_loading_popup.dart';
import 'package:wefood/commands/share_app.dart';
import 'package:wefood/components/components.dart';
import 'package:wefood/main.dart';
import 'package:wefood/models/models.dart';
import 'package:wefood/services/auth/api/api.dart';
import 'package:wefood/services/secure_storage.dart';
import 'package:wefood/views/views.dart';

class BusinessProfile extends StatefulWidget {
  const BusinessProfile({super.key});

  @override
  State<BusinessProfile> createState() => _BusinessProfileState();
}

class _BusinessProfileState extends State<BusinessProfile> {

  void _navigateToBusinessEditDirections() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BusinessEditDirections()),
    ).then((_) {
      setState(() {
        context.read<UserInfoCubit>();
      });
    });
  }

  void _navigateToMain() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MyApp()),
    );
  }

  void _deleteTokens() async {
    await UserSecureStorage().delete(key: 'accessToken');
    await UserSecureStorage().delete(key: 'accessTokenExpiresAt');
    await UserSecureStorage().delete(key: 'username');
    await UserSecureStorage().delete(key: 'password');
  }

  void _navigateToTermsAndConditions() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TermsAndConditions()),
    );
  }

  void _getProfileImage() {
    try {
      Api.getImage(
        idUser: context.read<UserInfoCubit>().state.user.id!,
        meaning: 'profile',
      ).then((ImageModel imageModel) {
        Image image = Image.network(
          imageModel.route!,
          fit: BoxFit.cover,
        );
        context.read<UserInfoCubit>().setPicture(image);
        setState(() {
          context.read<UserInfoCubit>().state;
          imageRoute = imageModel.route;
        });
      });
    } catch(e) {
      if(kDebugMode) {
        print('No se ha encontrado la imagen en la base de datos');
      }
    }
  }

  _pickImageFrom({
    required ImageSource source,
  }) {
    ImagePicker().pickImage(source: source).then((XFile? returnedImage) {
      if(returnedImage != null) {
        setState(() {
          _selectedImage = File(returnedImage.path);
        });
        openLoadingPopup(context);
        Api.uploadImage(
          idUser: context.read<UserInfoCubit>().state.user.id!,
          meaning: 'profile',
          file: _selectedImage!,
        ).then((ImageModel imageModel) {
          Image image = Image.network(
            imageModel.route!,
            fit: BoxFit.cover,
          );
          context.read<UserInfoCubit>().setPicture(image);
          setState(() {
            context.read<UserInfoCubit>().state;
            imageRoute = imageModel.route;
          });
          Navigator.pop(context);
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return WefoodPopup(
                context: context,
                title: '¡Imagen añadida correctamente!',
              );
            }
          ).then((_) {
            Navigator.pop(context);
          });
        });
      }
    });
  }

  _removePicture() {
    Navigator.pop(context);
    openLoadingPopup(context);
    Api.removeImage(
      idUser: context.read<UserInfoCubit>().state.user.id!,
      meaning: 'profile',
    ).then((_) {
      context.read<UserInfoCubit>().removePicture();
      setState(() {
        context.read<UserInfoCubit>().state;
      });
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return WefoodPopup(
            context: context,
            title: 'Imagen eliminada correctamente',
            cancelButtonTitle: 'OK',
          );
        }
      );
    }).onError(() {
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return WefoodPopup(
            context: context,
            title: 'Ha ocurrido un error',
            description: 'Por favor, inténtelo de nuevo más tarde',
            cancelButtonTitle: 'OK',
          );
        }
      );
    });
  }

  _retrieveData() {
    if(context.read<UserInfoCubit>().state.business.id == null) {
      Api.getSessionBusiness().then((BusinessExpandedModel data) {
        setState(() {
          context.read<UserInfoCubit>().setBusinessName(data.business.name);
          context.read<UserInfoCubit>().setBusinessDescription(data.business.description);
          context.read<UserInfoCubit>().setBusinessDirections(data.business.directions);
          context.read<UserInfoCubit>().setBusinessLatLng(
              LatLng(
                data.business.latitude ?? 0,
                data.business.longitude ?? 0,
              )
          );
        });
        setState(() {
          isRetrievingData = false;
        });
      }).onError((error, stackTrace) {
        setState(() {
          isRetrievingData = false;
          retrievingDataError = true;
        });
      });
    }
  }

  @override
  void initState() {
    if(context.read<UserInfoCubit>().state.image == null) {
      _getProfileImage();
    }
    _retrieveData();
    super.initState();
  }

  String? imageRoute;
  File? _selectedImage;
  Widget resultWidget = const LoadingIcon();
  bool retrievingDataError = false;
  bool isRetrievingData = true;

  @override
  Widget build(BuildContext context) {
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
                                    _pickImageFrom(
                                      source: ImageSource.gallery,
                                    );
                                  },
                                  child: const Text('ESCOGER FOTO DE LA GALERÍA'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    _pickImageFrom(
                                      source: ImageSource.camera,
                                    );
                                  },
                                  child: const Text('SACAR FOTO CON LA CÁMARA'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    _removePicture();
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
                            child: (context.read<UserInfoCubit>().state.image != null)
                            ? context.read<UserInfoCubit>().state.image!
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
                  ),
                ),
              ),
              if(isRetrievingData == true) const LoadingIcon(),
              if(isRetrievingData == false && retrievingDataError == true) Container(
                margin: EdgeInsets.symmetric(
                  vertical: MediaQuery.of(context).size.height * 0.05,
                ),
                child: const Text('Error'),
              ),
              if(isRetrievingData == false && retrievingDataError == false) Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    EditableField(
                      feedbackText: (context.read<UserInfoCubit>().state.business.name != null) ? 'Nombre: ${context.read<UserInfoCubit>().state.business.name!}' : 'Añade tu nombre',
                      firstTopic: 'nombre',
                      firstInitialValue: (context.read<UserInfoCubit>().state.business.name != null) ? context.read<UserInfoCubit>().state.business.name! : '',
                      firstMinimumLength: 6,
                      firstMaximumLength: 100,
                      onSave: (newValue, newSecondValue) async {
                        dynamic response = await Api.updateBusinessName(
                          name: newValue,
                        );
                        setState(() {});
                        return response;
                      },
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    EditableField(
                      feedbackText: 'Descripción: ${context.read<UserInfoCubit>().state.business.description}',
                      firstTopic: 'descripción',
                      firstInitialValue: context.read<UserInfoCubit>().state.business.description ?? '',
                      firstMinimumLength: 6,
                      firstMaximumLength: 255,
                      onSave: (newValue, newSecondValue) async {
                        dynamic response = await Api.updateBusinessDescription(
                          description: newValue,
                        );
                        setState(() {});
                        return response;
                      },
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Column(
          children: <Widget>[
            GestureDetector(
              onTap: () async {
                _navigateToBusinessEditDirections();
              },
              child: Row(
                children: [
                  Expanded(
                    child: Text('Ubicación: ${context.read<UserInfoCubit>().state.business.directions}'),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  const Icon(
                    Icons.edit
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            SettingsElement(
              iconData: Icons.history,
              title: 'Historial de pedidos - FALTA',
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
              title: 'Contáctanos',
              onTap: () async {
                await launchWhatsapp(
                  context: context,
                );
              },
            ),
            SettingsElement(
              iconData: Icons.credit_card_outlined,
              title: 'Cobros - FALTA',
              onTap: () {
                // TODO falta por hacer
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
                          onPressed: () {
                            Api.logout().then((_) {
                              _deleteTokens();
                              Navigator.pop(context);
                              _navigateToMain();
                            }).onError((Object error, StackTrace stackTrace) {
                              _deleteTokens();
                              Navigator.pop(context);
                              _navigateToMain();
                            });
                          },
                          child: const Text('SÍ'),
                        )
                      ],
                    );
                  }
                );
              }
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
                      context: context,
                      title: '¿Seguro que quieres darte de baja?',
                      description: 'Perderás toda tu información y no podrás recuperarla más adelante.',
                      actions: <TextButton>[
                        TextButton(
                          onPressed: () {
                            Api.signOut().then((_) {
                              _deleteTokens();
                              Navigator.pop(context);
                              _navigateToMain();
                            }).onError((error, StackTrace stackTrace) {
                              Navigator.pop(context);
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return WefoodPopup(
                                    context: context,
                                    title: 'Ha ocurrido un error',
                                    description: 'Por favor, inténtelo de nuevo más tarde',
                                    cancelButtonTitle: 'OK',
                                  );
                                }
                              );
                            });
                          },
                          child: const Text('SÍ'),
                        ),
                      ],
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