import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wefood/blocs.dart';
import 'package:wefood/commands/call_request.dart';
import 'package:wefood/commands/wefood_show_dialog.dart';
import 'package:wefood/components/components.dart';
import 'package:wefood/models.dart';
import 'package:wefood/services/auth/api.dart';
import 'package:wefood/types.dart';

class EditPersonalData extends StatefulWidget {

  final EditPersonalInfo editPersonalInfo;

  const EditPersonalData({
    required this.editPersonalInfo,
    super.key
  });

  @override
  State<EditPersonalData> createState() => _EditPersonalDataState();
}

class _EditPersonalDataState extends State<EditPersonalData> {

  String auxRealName = '';
  String auxRealSurname = '';
  String auxUsername = '';
  String auxBusinessName = '';
  String auxBusinessDescription = '';

  LoadingStatus usernameAvailabilityStatus = LoadingStatus.unset;
  bool usernameAvailable = false;

  EditPersonalInfo editPersonalInfo = EditPersonalInfo.none;
  BusinessExpandedModel userInfo = BusinessExpandedModel.empty();

  _rebuildDirectionsCubit() async {
    setState(() {
      context.read<UserInfoCubit>().state;
    });
  }

  String _feedbackMessageRealName() {
    String result = '';
    if(auxRealName.length < 2) {
      result = 'Debe tener 2 caracteres o más';
    } else if(auxRealName.length > 30) {
      result = 'Debe tener 30 caracteres o menos';
    }
    return result;
  }

  String _feedbackMessageRealSurname() {
    String result = '';
    if(auxRealSurname.length < 2) {
      result = 'Debe tener 2 caracteres o más';
    } else if(auxRealSurname.length > 30) {
      result = 'Debe tener 30 caracteres o menos';
    }
    return result;
  }

  Widget _feedbackMessageUsername() {
    Widget result;
    if(auxUsername.length < 5) {
      result = const FeedbackMessage(
        message: 'Debe tener 5 caracteres o más',
        isError: true,
      );
      setState(() {
        usernameAvailable = false;
      });
    } else if(auxUsername.length > 50) {
      result = const FeedbackMessage(
        message: 'Debe tener 50 caracteres o menos',
        isError: true,
      );
      setState(() {
        usernameAvailable = false;
      });
    } else if(usernameAvailabilityStatus == LoadingStatus.loading) {
      result = const ReducedLoadingIcon();
      setState(() {
        usernameAvailable = false;
      });
    } else if(usernameAvailable == true) {
      result = const FeedbackMessage(
        message: '¡Libre!',
        isError: false,
      );
      setState(() {
        usernameAvailable = true;
      });
    } else if(auxUsername == context.read<UserInfoCubit>().state.user.username) {
      result = const FeedbackMessage(
        message: 'Nombre actual',
        isError: true,
      );
      setState(() {
        usernameAvailable = false;
      });
    } else {
      result = const FeedbackMessage(
        message: 'No disponible',
        isError: true,
      );
      setState(() {
        usernameAvailable = false;
      });
    }
    return result;
  }

  String _feedbackMessageBusinessDescription() {
    String result = '';
    if(auxBusinessDescription.length < 6) {
      result = 'Debe tener 6 caracteres o más';
    } else if(auxBusinessDescription.length > 255) {
      result = 'Debe tener 255 caracteres o menos';
    }
    return result;
  }

  String _feedbackMessageBusinessName() {
    String result = '';
    if(auxBusinessName.length < 6) {
      result = 'Debe tener 6 caracteres o más';
    } else if(auxBusinessName.length > 100) {
      result = 'Debe tener 100 caracteres o menos';
    }
    return result;
  }

  @override
  void initState() {
    editPersonalInfo = widget.editPersonalInfo;
    userInfo = context.read<UserInfoCubit>().state;
    auxRealName = userInfo.user.realName ?? '';
    auxRealSurname = userInfo.user.realSurname ?? '';
    auxUsername = userInfo.user.username ?? '';
    auxBusinessName = userInfo.business.name ?? '';
    auxBusinessDescription = userInfo.business.description ?? '';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget spaceBetweenItems = const SizedBox(
      height: 25,
    );

    _rebuildDirectionsCubit();
    return WefoodScreen(
      title: 'Datos personales',
      body: [
        spaceBetweenItems,
        if(editPersonalInfo == EditPersonalInfo.realName) Row(
          children: <Widget>[
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  WefoodInput(
                    labelText: 'Nombre',
                    initialText: context.read<UserInfoCubit>().state.user.realName,
                    feedbackWidget: FeedbackMessage(
                      message: _feedbackMessageRealName(),
                      isError: _feedbackMessageRealName() != '',
                    ),
                    onChanged: (String value) {
                      setState(() {
                        auxRealName = value;
                      });
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  WefoodInput(
                    labelText: 'Apellidos',
                    initialText: context.read<UserInfoCubit>().state.user.realSurname,
                    feedbackWidget: FeedbackMessage(
                      message: _feedbackMessageRealSurname(),
                      isError: _feedbackMessageRealSurname() != '',
                    ),
                    onChanged: (String value) {
                      setState(() {
                        auxRealSurname = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.1,
            ),
            GestureDetector(
              child: Icon(
                Icons.send,
                color: (_feedbackMessageRealName() == '' && _feedbackMessageRealSurname() == '')
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.secondary,
              ),
              onTap: () {
                if(_feedbackMessageRealName() == '' && _feedbackMessageRealSurname() == '') {
                  callRequestWithLoading(
                    context: context,
                    request: () async {
                      return await Api.updateRealName(
                        name: auxRealName,
                        surname: auxRealSurname
                      );
                    },
                    onSuccess: (_) {
                      setState(() {
                        editPersonalInfo = EditPersonalInfo.none;
                        context.read<UserInfoCubit>().setRealName(
                          realName: auxRealName,
                          realSurname: auxRealSurname,
                        );
                      });
                      wefoodShowDialog(
                        context: context,
                        title: '¡Nombre cambiado correctamente!',
                        cancelButtonTitle: 'OK',
                      );
                    },
                  );
                }
              },
            ),
          ],
        ),
        if(userInfo.business.id == null && editPersonalInfo != EditPersonalInfo.realName) _InfoRow(
            title: 'Nombre',
            value: '${userInfo.user.realName} ${userInfo.user.realSurname}'
        ),
        if(userInfo.business.id != null && editPersonalInfo == EditPersonalInfo.businessName) Row(
          children: <Widget>[
            Expanded(
              child: WefoodInput(
                labelText: 'Nombre',
                initialText: context.read<UserInfoCubit>().state.business.name,
                feedbackWidget: FeedbackMessage(
                  message: _feedbackMessageBusinessName(),
                  isError: _feedbackMessageBusinessName() != '',
                ),
                onChanged: (String value) {
                  setState(() {
                    auxBusinessName = value;
                  });
                },
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.1,
            ),
            GestureDetector(
              child: Icon(
                Icons.send,
                color: (_feedbackMessageBusinessName() == '')
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.secondary,
              ),
              onTap: () {
                callRequestWithLoading(
                  context: context,
                  request: () async {
                    return await Api.updateBusinessName(
                      name: auxBusinessName,
                    );
                  },
                  onSuccess: (_) {
                    setState(() {
                      editPersonalInfo = EditPersonalInfo.none;
                      context.read<UserInfoCubit>().setBusinessName(auxBusinessName);
                    });
                    wefoodShowDialog(
                      context: context,
                      title: '¡Nombre cambiado correctamente!',
                      cancelButtonTitle: 'OK',
                    );
                  },
                );
              },
            ),
          ],
        ),
        if(userInfo.business.id != null && editPersonalInfo != EditPersonalInfo.businessName) _InfoRow(
            title: 'Nombre',
            value: '${userInfo.business.name}'
        ),
        spaceBetweenItems,
        if(userInfo.business.id != null && editPersonalInfo == EditPersonalInfo.businessDescription) Row(
          children: <Widget>[
            Expanded(
              child: WefoodInput(
                labelText: 'Descripción',
                initialText: context.read<UserInfoCubit>().state.business.description,
                feedbackWidget: FeedbackMessage(
                  message: _feedbackMessageBusinessDescription(),
                  isError: _feedbackMessageBusinessDescription() != '',
                ),
                onChanged: (String value) {
                  setState(() {
                    auxBusinessDescription = value;
                  });
                },
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.1,
            ),
            GestureDetector(
              child: Icon(
                Icons.send,
                color: (_feedbackMessageBusinessDescription() == '')
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.secondary,
              ),
              onTap: () {
                callRequestWithLoading(
                  context: context,
                  request: () async {
                    return await Api.updateBusinessDescription(
                      description: auxBusinessDescription,
                    );
                  },
                  onSuccess: (_) {
                    setState(() {
                      editPersonalInfo = EditPersonalInfo.none;
                      context.read<UserInfoCubit>().setBusinessDescription(auxBusinessDescription);
                    });
                    wefoodShowDialog(
                      context: context,
                      title: '¡Descripción cambiada correctamente!',
                      cancelButtonTitle: 'OK',
                    );
                  },
                );
              },
            ),
          ],
        ),
        if(userInfo.business.id != null && editPersonalInfo != EditPersonalInfo.businessDescription) _InfoRow(title: 'Descripción', value: userInfo.business.description),
        if(userInfo.business.id != null) spaceBetweenItems,
        if(editPersonalInfo == EditPersonalInfo.username) Row(
          children: <Widget>[
            Expanded(
              child: WefoodInput(
                labelText: 'Nombre de usuario',
                initialText: context.read<UserInfoCubit>().state.user.username,
                feedbackWidget: _feedbackMessageUsername(),
                onChanged: (String value) {
                  setState(() {
                    usernameAvailabilityStatus = LoadingStatus.loading;
                  });
                  Timer(
                    const Duration(seconds: 1),
                    () {
                      if(value == auxUsername) {
                        if(2 <= value.length && value.length <= 50) {
                          if(value == context.read<UserInfoCubit>().state.user.username) {
                            setState(() {
                              usernameAvailable = false;
                              usernameAvailabilityStatus = LoadingStatus.error;
                            });
                          } else {
                            Api.checkUsernameAvailability(
                              username: value,
                            ).then((bool availability) {
                              setState(() {
                                usernameAvailable = availability;
                                usernameAvailabilityStatus = LoadingStatus.successful;
                              });
                            }).onError((Object error, StackTrace stackTrace) {
                              setState(() {
                                usernameAvailable = false;
                                usernameAvailabilityStatus = LoadingStatus.error;
                              });
                            });
                          }
                        }
                      }
                    }
                  );
                  setState(() {
                    auxUsername = value;
                  });
                },
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.1,
            ),
            GestureDetector(
              child: Icon(
                Icons.send,
                color: (usernameAvailable)
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.secondary,
              ),
              onTap: () {
                callRequestWithLoading(
                  context: context,
                  request: () async {
                    return await Api.updateUsername(
                      username: auxUsername,
                    );
                  },
                  onSuccess: (_) {
                    setState(() {
                      editPersonalInfo = EditPersonalInfo.none;
                      context.read<UserInfoCubit>().setUsername(auxUsername);
                    });
                    wefoodShowDialog(
                      context: context,
                      title: '¡Nombre de usuario cambiado correctamente!',
                      cancelButtonTitle: 'OK',
                    );
                  },
                );
              },
            ),
          ],
        ),
        if(editPersonalInfo != EditPersonalInfo.username) _InfoRow(title: 'Nombre de usuario', value: userInfo.user.username),
        spaceBetweenItems,
        if(editPersonalInfo != EditPersonalInfo.email) _InfoRow(title: 'Correo', value: userInfo.user.email),
        spaceBetweenItems,
        if(editPersonalInfo != EditPersonalInfo.phone) _InfoRow(title: 'Teléfono', value: userInfo.user.phone.toString()),
        spaceBetweenItems,
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {

  final String title;
  final String? value;

  const _InfoRow({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Row(
          children: <Text>[
            Text(
              '$title: ',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Text(
              (value != null && value != 'null') ? value! : 'No configurado',
            ),
          ],
        ),
      ],
    );
  }
}
