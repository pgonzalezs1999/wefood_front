import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wefood/components/back_arrow.dart';
import 'package:wefood/components/loading_icon.dart';
import 'package:wefood/components/wefood_input.dart';
import 'package:wefood/components/wefood_screen.dart';
import 'package:wefood/models/auth_model.dart';
import 'package:wefood/models/user_model.dart';
import 'package:wefood/services/auth/api/api.dart';
import 'package:wefood/services/secure_storage.dart';
import 'package:wefood/types.dart';
import 'package:wefood/views/register_business.dart';
import 'package:wefood/views/terms_and_conditions.dart';

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
  bool usernameIsAvailable = false;
  String email = '';
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
      result = _setError('Formato de correo no válido');
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
                const Text('Regístrate en'),
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
                      onChanged: (value) async {
                        setState(() {
                          error = '';
                          searchingUsernameAvailability = LoadingStatus.loading;
                        });
                        bool available = false;
                        try {
                          available = await Api.checkUsernameAvailability(username: value);
                        } catch(e) {
                          available = false;
                        }
                        setState(() {
                          username = value;
                          usernameIsAvailable = available;
                          searchingUsernameAvailability = LoadingStatus.successful;
                        });
                      },
                    ),
                    const SizedBox(height: 15),
                    if(searchingUsernameAvailability == LoadingStatus.loading) const LoadingIcon(),
                    if(searchingUsernameAvailability != LoadingStatus.loading && username != "") Text(
                      (usernameIsAvailable == false)
                        ? ("Nombre de usuario no disponible")
                        : "¡Nombre de usuario libre!"
                    ),
                  ],
                ),
                WefoodInput(
                  labelText: 'Correo electrónico',
                  onChanged: (value) async {
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
                  },
                ),
                const SizedBox(height: 15),
                if(searchingEmailAvailability == LoadingStatus.loading) const LoadingIcon(),
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
          if(authenticating == LoadingStatus.loading) const LoadingIcon(),
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