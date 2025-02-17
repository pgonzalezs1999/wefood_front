import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wefood/commands/wefood_show_dialog.dart';
import 'package:wefood/components/components.dart';
import 'package:wefood/models.dart';
import 'package:wefood/services/auth/api.dart';
import 'package:wefood/services/secure_storage.dart';
import 'package:wefood/types.dart';
import 'package:wefood/views/views.dart';

class RegisterUser extends StatefulWidget {
  const RegisterUser({super.key});

  @override
  State<RegisterUser> createState() => _RegisterUserState();
}

class _RegisterUserState extends State<RegisterUser> {

  LoadingStatus authenticating = LoadingStatus.unset;
  LoadingStatus searchingUsernameAvailability = LoadingStatus.unset;
  LoadingStatus searchingEmailAvailability = LoadingStatus.unset;
  String error = '';
  String username = '';
  String auxUsername = '';
  bool usernameIsAvailable = false;
  String email = '';
  String auxEmail = '';
  bool emailIsAvailable = false;
  String password = '';
  String confirmPassword = '';
  bool conditionsAccepted = false;

  void _navigateToRegisterBusiness() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegisterBusiness()),
    );
  }

  void _navigateToTermsAndConditions() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TermsAndConditions()),
    );
  }

  void _navigateToMain() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MyApp()),
    );
  }

  _handleUsernameChange(String value) async {
    if(6 <= value.length && value.length <= 30) {
      setState(() {
        auxUsername = value;
        error = '';
        searchingUsernameAvailability = LoadingStatus.loading;
      });
      bool available = false;
      Timer(
        const Duration(seconds: 1),
          () async {
          if(value == auxUsername) {
            Api.checkUsernameAvailability(username: value).then((bool availability) {
              available = availability;
              setState(() {
                username = value;
                usernameIsAvailable = available;
                searchingUsernameAvailability = LoadingStatus.successful;
              });
            }).onError(
              (Object error, StackTrace stackTrace) {
                available = false;
                setState(() {
                  username = value;
                  usernameIsAvailable = false;
                  searchingUsernameAvailability = LoadingStatus.error;
                });
              }
            );
          }
        }
      );
    } else {
      setState(() {
        auxUsername = '';
        username = value;
        error = '';
        searchingUsernameAvailability = LoadingStatus.unset;
      });
    }
  }

  _handleEmailChange(String value) async {
    setState(() {
      auxEmail = value;
      error = '';
      searchingEmailAvailability = LoadingStatus.loading;
    });
    bool available = false;
    Timer(
      const Duration(seconds: 1),
      () async {
        if(value == auxEmail) {
          Api.checkEmailAvailability(email: value).then((bool availability) {
            available = availability;
            setState(() {
              email = value;
              emailIsAvailable = available;
              searchingEmailAvailability = LoadingStatus.successful;
            });
          }).onError(
            (Object error, StackTrace stackTrace) {
              available = false;
              setState(() {
                email = value;
                emailIsAvailable = false;
                searchingEmailAvailability = LoadingStatus.error;
              });
            }
          );
        }
      }
    );
  }

  bool _setError(String reason) {
    setState(() {
      error = reason;
    });
    return false;
  }

  bool _readyToRegister() {
    bool result = true;
    if(username.length < 5) {
      result = _setError('El nombre de usuario debe tener 5 caracteres o más');
    } else if(username.length > 30) {
      result = _setError('El nombre de usuario debe tener 30 caracteres o menos');
    } else if(usernameIsAvailable == false) {
      result = _setError('Nombre de usuario no disponible');
    } else if(email.isEmail == false) {
      result = _setError('Formato de correo incorrecto');
    } else if(emailIsAvailable == false) {
      result = _setError('Correo electrónico no disponible');
    } else if(password.length < 6) {
      result = _setError('La contraseña debe tener 6 caracteres o más');
    } else if(password.length > 20) {
      result = _setError('La contraseña debe tener 20 caracteres o menos');
    } else if(confirmPassword != password) {
      result = _setError('Las contraseñas no coinciden');
    } else if(conditionsAccepted == false) {
      result = _setError('Debes aceptar los términos y condiciones');
    } else {
      setState(() {
        error = '';
      });
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return WefoodScreen(
      title: 'Regístrate en',
      bodyCrossAxisAlignment: CrossAxisAlignment.center,
      body: [
        Container(
          margin: const EdgeInsets.only(
            bottom: 50,
          ),
          width: MediaQuery.of(context).size.width * 0.666,
          child: Image.asset('assets/images/logo.png'),
        ),
        Container(
          margin: EdgeInsets.symmetric(
            vertical: MediaQuery.of(context).size.height * 0.025,
          ),
          child: Wrap(
            runSpacing: MediaQuery.of(context).size.height * 0.025,
            children: <Widget>[
              WefoodInput(
                labelText: 'Nombre de usuario',
                onChanged: (value) => _handleUsernameChange(value),
                feedbackWidget: (searchingUsernameAvailability == LoadingStatus.loading)
                ? const ReducedLoadingIcon()
                : (searchingUsernameAvailability != LoadingStatus.loading && username != '')
                  ? (username.length >= 6)
                    ? (username.length <= 30)
                      ? (usernameIsAvailable == false)
                        ? const FeedbackMessage(
                          message: 'No disponible',
                          isError: true,
                        )
                        : const FeedbackMessage(
                          message: '¡Libre!',
                          isError: false,
                        )
                      : const FeedbackMessage(
                        message: 'Demasiado largo',
                        isError: true,
                      )
                  : const FeedbackMessage(
                    message: 'Demasiado corto',
                    isError: true,
                  )
                : null,
              ),
              WefoodInput(
                labelText: 'Correo electrónico',
                type: InputType.email,
                onChanged: (value) => _handleEmailChange(value),
                feedbackWidget: (searchingEmailAvailability == LoadingStatus.loading)
                ? const ReducedLoadingIcon()
                : (email != '')
                  ? (email.isEmail)
                    ? (emailIsAvailable == false)
                      ? const FeedbackMessage(
                        message: 'No disponible',
                        isError: true,
                      )
                      : const FeedbackMessage(
                        message: '¡Libre!',
                        isError: false,
                      )
                    : const FeedbackMessage(
                      message: 'Formato incorrecto',
                      isError: true,
                    )
                  : null,
              ),
              WefoodInput(
                labelText: 'Contraseña',
                type: InputType.secret,
                onChanged: (value) {
                  setState(() {
                    error = '';
                    password = value;
                  });
                },
                feedbackWidget: (password != '' && password.length < 6)
                  ? const FeedbackMessage(
                    message: 'Demasiado corta',
                    isError: true
                  )
                  : (password != '' && password.length > 20)
                    ? const FeedbackMessage(
                        message: 'Demasiado larga',
                        isError: true
                    )
                    : null,
              ),
              WefoodInput(
                labelText: 'Confirmar contraseña',
                type: InputType.secret,
                onChanged: (value) {
                  setState(() {
                    error = '';
                    confirmPassword = value;
                  });
                },
                feedbackWidget: (confirmPassword != '' && confirmPassword != password)
                  ? const FeedbackMessage(
                    message: 'Las contraseñas no coinciden',
                    isError: true,
                  )
                  : null,
              ),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Checkbox(
              value: conditionsAccepted,
              onChanged: (value) {
                FocusManager.instance.primaryFocus?.unfocus();
                setState(() {
                  error = '';
                  conditionsAccepted = !conditionsAccepted;
                });
              },
            ),
            const Text('He leído y acepto los'),
            TextButton(
              onPressed: () => _navigateToTermsAndConditions(),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 5,
                ),
              ),
              child: const Text('términos y condiciones')
            ),
          ],
        ),
        if(authenticating == LoadingStatus.loading) const LoadingIcon(),
        if(authenticating != LoadingStatus.loading) Container(
          margin: const EdgeInsets.symmetric(
            vertical: 10,
          ),
          child: ElevatedButton(
            onPressed: () async {
              if(_readyToRegister() == true) {
                setState(() {
                  authenticating = LoadingStatus.loading;
                });
                try {
                  Api.signIn(
                    username: username,
                    email: email,
                    password: password,
                  ).then((UserModel userModel) async {
                    UserSecureStorage().write(key: 'username', value: username);
                    UserSecureStorage().write(key: 'password', value: password);
                    Api.login(
                      context: context,
                      username: username,
                      password: password
                    ).then((AuthModel authModel) {
                      if(authModel.accessToken != null) {
                        UserSecureStorage().writeDateTime(
                            key: 'accessTokenExpiresAt',
                            value: DateTime.now().add(Duration(seconds: authModel.expiresAt!))
                        );
                        UserSecureStorage().write(key: 'accessToken', value: authModel.accessToken!);
                        UserSecureStorage().write(key: 'username', value: username);
                        UserSecureStorage().write(key: 'password', value: password);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const MyApp()),
                        );
                      } else if(authModel.error != null) {
                        setState(() {
                          authenticating = LoadingStatus.error;
                        });
                        String? title = 'Ha ocurrido un error';
                        String? description = 'Por favor, inténtelo de nuevo más tarde. Si el error persiste, póngase en contacto con soporte.';
                        if(authModel.error!.toLowerCase().contains('unauthorized')) {
                          title = 'Usuario o contraseña incorrectos';
                          description = null;
                        }
                        wefoodShowDialog(
                          context: context,
                          title: title,
                          description: description,
                          cancelButtonTitle: 'OK',
                        );
                      }
                      authenticating = LoadingStatus.successful;
                      _navigateToMain();
                    });
                  });
                }
                catch(e) {
                  setState(() {
                    UserSecureStorage().delete(key: 'username');
                    UserSecureStorage().delete(key: 'password');
                    error = 'Ha ocurrido un error. Por favor, inténtalo de nuevo más tarde.';
                    authenticating = LoadingStatus.error;
                  });
                }
              }
            },
            child: const Text('REGISTRARME'),
          ),
        ),
        if(error != '') FeedbackMessage(
          message: error,
          isError: true,
          isCentered: true,
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('¿Quieres listar tu negocio?'),
            TextButton(
              onPressed: () => _navigateToRegisterBusiness(),
              child: const Text('Regístralo gratis'),
            ),
          ],
        ),
      ],
    );
  }
}