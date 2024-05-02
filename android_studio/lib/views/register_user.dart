import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wefood/components/components.dart';
import 'package:wefood/models/models.dart';
import 'package:wefood/services/auth/api/api.dart';
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
  bool emailIsAvailable = false;
  String password = '';
  String confirmPassword = '';
  bool conditionsAccepted = false;

  Widget reducedLoadingIcon(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(15),
      child: LoadingIcon(
        size: Theme.of(context).textTheme.displaySmall?.fontSize,
      ),
    );
  }

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
      error = '';
      searchingEmailAvailability = LoadingStatus.loading;
      email = value;
    });
    bool available = false;
    if(email.isEmail) {
      try {
        available = await Api.checkEmailAvailability(email: value);
      } catch(e) {
        available = false;
      }
    }
    setState(() {
      email = value;
      emailIsAvailable = available;
      searchingEmailAvailability = LoadingStatus.successful;
    });
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
      result = _setError('La contraseña y confirmar contraseña no coinciden');
    } else if(conditionsAccepted == false) {
      result = _setError('Necesitamos que aceptes los términos y condiciones para usar la app');
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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          const Align(
            alignment: Alignment.centerLeft,
            child: BackArrow(),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.15,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Regístrate en',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.5,
                  margin: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.01,
                  ),
                  child: Image.asset('assets/images/logo.png'),
                ),
              ],
            ),
          ) ,
          Container(
            margin: EdgeInsets.symmetric(
              vertical: MediaQuery.of(context).size.height * 0.025,
            ),
            child: Wrap(
              runSpacing: MediaQuery.of(context).size.height * 0.025,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    WefoodInput(
                      labelText: 'Nombre de usuario',
                      onChanged: (value) => _handleUsernameChange(value),
                    ),
                    if(searchingUsernameAvailability == LoadingStatus.loading) reducedLoadingIcon(context),
                    if(searchingUsernameAvailability != LoadingStatus.loading && username != '') Container(
                      margin: const EdgeInsets.only(
                        top: 15,
                      ),
                      child: (username.length >= 6)
                        ? (username.length <= 30)
                          ? (usernameIsAvailable == false)
                            ? const FeedbackMessage(
                              message: 'Nombre de usuario no disponible',
                              isError: true,
                            )
                            : const FeedbackMessage(
                              message: '¡Nombre de usuario libre!',
                              isError: false,
                            )
                          : const FeedbackMessage(
                            message: 'Nombre de usuario demasiado largo',
                            isError: true,
                          )
                        : const FeedbackMessage(
                          message: 'Nombre de usuario demasiado corto',
                          isError: true,
                        ),
                    ),
                  ],
                ),
                WefoodInput(
                  labelText: 'Correo electrónico',
                  onChanged: (value) => _handleEmailChange(value),
                ),
                const SizedBox(height: 15),
                if(searchingEmailAvailability == LoadingStatus.loading) reducedLoadingIcon(context),
                if(searchingEmailAvailability != LoadingStatus.loading && email != "") Text(
                  (emailIsAvailable == false)
                    ? ("Correo electrónico no disponible")
                    : "¡Correo electrónico libre!"
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
                ),
              ],
            ),
          ),
          Row(
            children: <Widget>[
              Checkbox(
                value: conditionsAccepted,
                onChanged: (value) {
                  setState(() {
                    error = '';
                    conditionsAccepted = !conditionsAccepted;
                  });
                },
              ),
              const Text('He leído y acepto los'),
              TextButton(
                onPressed: () {
                  _navigateToTermsAndConditions();
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                  ),
                ),
                child: const Text('términos y condiciones')
              ),
            ],
          ),
          if(authenticating == LoadingStatus.loading) reducedLoadingIcon(context),
          if(authenticating != LoadingStatus.loading) ElevatedButton(
            onPressed: () async {
              if(_readyToRegister() == true) {
                setState(() {
                  authenticating = LoadingStatus.loading;
                });
                try {
                  UserModel user = await Api.signIn(
                      username: username,
                      email: email,
                      password: password,
                  );
                  UserSecureStorage().write(key: 'username', value: username);
                  UserSecureStorage().write(key: 'password', value: password);
                  AuthModel? auth = await Api.login(
                      context: context,
                      username: username,
                      password: password
                  );
                  authenticating = LoadingStatus.successful;
                }
                catch(e) {
                  setState(() {
                    UserSecureStorage().delete(key: 'username');
                    UserSecureStorage().delete(key: 'password');
                    error = 'Ha ocurrido un error. Por favor, inténtalo de nuevo más tarde.';
                    authenticating = LoadingStatus.error;
                    print('ERROR: $e');
                  });
                }
              }
            },
            child: const Text('REGISTRARME'),
          ),
          if(error != '') Text(error),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text('¿Quieres listar tu negocio?'),
              TextButton(
                onPressed: () {
                  _navigateToRegisterBusiness();
                },
                child: const Text('Regístralo gratis'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}