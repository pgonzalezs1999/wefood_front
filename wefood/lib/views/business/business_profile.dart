import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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

class BusinessProfile extends StatefulWidget {
  const BusinessProfile({super.key});

  @override
  State<BusinessProfile> createState() => _BusinessProfileState();
}

class _BusinessProfileState extends State<BusinessProfile> {

  void _navigateToEditPersonalData({
    required EditPersonalInfo field,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditPersonalData(
        editPersonalInfo: field,
      )),
    ).whenComplete(() {
      setState(() { });
    });
  }

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

  void _navigateToBusinessComments() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BusinessComments()),
    );
  }

  void _navigateToTermsAndConditions() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TermsAndConditions()),
    );
  }

  void _navigateToRetributions() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BusinessRetributions()),
    );
  }

  void _getProfileImage() {
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
    }).onError((error, stackTrace) {
      if(kDebugMode) {
        print('No se ha encontrado la imagen en la base de datos');
      }
    });
  }

  _pickImageFrom({
    required ImageSource source,
  }) {
    ImagePicker().pickImage(source: source).then((XFile? returnedImage) {
      if(returnedImage != null) {
        setState(() {
          _selectedImage = File(returnedImage.path);
        });
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const WefoodLoadingPopup(),
        );
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
          Navigator.of(context).pop();
          wefoodShowDialog(
            context: context,
            title: '¡Imagen añadida correctamente!',
          ).then((_) {
            Navigator.of(context).pop();
          });
        });
      }
    });
  }

  _removePicture() {
    Navigator.of(context).pop();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const WefoodLoadingPopup(),
    );
    Api.removeImage(
      idUser: context.read<UserInfoCubit>().state.user.id!,
      meaning: 'profile',
    ).then((_) {
      context.read<UserInfoCubit>().removePicture();
      setState(() {
        context.read<UserInfoCubit>().state;
      });
      Navigator.of(context).pop();
      wefoodShowDialog(
        context: context,
        title: 'Imagen eliminada correctamente',
        cancelButtonTitle: 'OK',
      );
    }).onError(() {
      Navigator.of(context).pop();
      wefoodShowDialog(
        context: context,
        title: 'Ha ocurrido un error',
        description: 'Por favor, inténtelo de nuevo más tarde',
        cancelButtonTitle: 'OK',
      );
    });
  }

  _retrieveBusinessData() {
    if(context.read<UserInfoCubit>().state.business.id == null) {
      Api.getSessionBusiness().then((BusinessExpandedModel data) {
        setState(() {
          context.read<UserInfoCubit>().setBusiness(data.business);
          context.read<UserInfoCubit>().setBusinessName(data.business.name);
          context.read<UserInfoCubit>().setBusinessDescription(data.business.description);
          context.read<UserInfoCubit>().setBusinessDirections(data.business.directions);
          context.read<UserInfoCubit>().setBusinessLatLng(
            LatLng(
              data.business.latitude ?? 0,
              data.business.longitude ?? 0,
            )
          );
          isRetrievingData = false;
        });
      }).onError((error, stackTrace) {
        setState(() {
          isRetrievingData = false;
          retrievingDataError = true;
        });
      });
    } else {
      setState(() {
        isRetrievingData = false;
      });
    }
  }

  @override
  void initState() {
    if(context.read<UserInfoCubit>().state.image == null) {
      _getProfileImage();
    }
    _retrieveBusinessData();
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
            children: (isRetrievingData)
            ? <Widget>[
              Container(
                margin: EdgeInsets.only(
                  right: MediaQuery.of(context).size.width * 0.05,
                ),
                child: Container(
                  padding: EdgeInsets.only(
                    right: MediaQuery.of(context).size.width * 0.025,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(1000),
                    child: SizedBox.fromSize(
                      size: Size.fromRadius(MediaQuery.of(context).size.width * 0.1),
                      child: Container(
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
              Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.symmetric(
                      vertical: MediaQuery.of(context).size.width * 0.01,
                    ),
                    child: SkeletonText(
                      width: MediaQuery.of(context).size.width * 0.5,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(
                      vertical: MediaQuery.of(context).size.width * 0.01,
                    ),
                    child: SkeletonText(
                      width: MediaQuery.of(context).size.width * 0.5,
                    ),
                  ),
                ],
              ),
            ]
            : <Widget>[
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
                            source: ImageSource.gallery,
                          );
                        },
                      ),
                      TextButton(
                        onPressed: () async {
                          _pickImageFrom(
                            source: ImageSource.camera,
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
              ), // Profile picture
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
                    GestureDetector(
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              'Nombre: ${context.read<UserInfoCubit>().state.business.name}',
                            ),
                          ),
                          const Icon(
                            Icons.edit,
                          ),
                        ],
                      ),
                      onTap: () => _navigateToEditPersonalData(field: EditPersonalInfo.businessName),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    GestureDetector(
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              'Descripción: ${context.read<UserInfoCubit>().state.business.description}',
                            ),
                          ),
                          const Icon(
                            Icons.edit,
                          ),
                        ],
                      ),
                      onTap: () => _navigateToEditPersonalData(field: EditPersonalInfo.businessDescription),
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
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            (isRetrievingData == true)
              ? Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SkeletonText(
                    width: MediaQuery.of(context).size.width * 0.75,
                  ),
                  SkeletonText(
                    width: MediaQuery.of(context).size.width * 0.5,
                  ),
                ],
              )
              : GestureDetector(
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
              title: 'Historial de pedidos (próximamente)',
              onTap: () {
                // TODO falta esto
              },
            ),
            SettingsElement(
              iconData: Icons.comment_outlined,
              title: 'Ver comentarios',
              onTap: () {
                _navigateToBusinessComments();
              },
            ),
            SettingsElement(
              iconData: Icons.credit_card_outlined,
              title: 'Cobros',
              onTap: () {
                _navigateToRetributions();
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
                        }).onError((error, StackTrace stackTrace) {
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