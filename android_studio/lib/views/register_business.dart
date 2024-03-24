import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wefood/components/back_arrow.dart';
import 'package:wefood/components/loading_icon.dart';
import 'package:wefood/components/phone_input.dart';
import 'package:wefood/components/wefood_input.dart';
import 'package:wefood/components/wefood_screen.dart';
import 'package:wefood/models/auth_model.dart';
import 'package:wefood/models/business_expanded_model.dart';
import 'package:wefood/models/country_model.dart';
import 'package:wefood/services/auth/api/api.dart';
import 'package:wefood/services/secure_storage.dart';
import 'package:wefood/types.dart';
import 'package:wefood/views/terms_and_conditions.dart';

class RegisterBusiness extends StatefulWidget {
  const RegisterBusiness({super.key});

  @override
  State<RegisterBusiness> createState() => _RegisterBusinessState();
}

class _RegisterBusinessState extends State<RegisterBusiness> {

  LoadingStatus authenticating = LoadingStatus.unset;
  LoadingStatus searchingEmailAvailability = LoadingStatus.unset;
  LoadingStatus searchingPhoneAvailability = LoadingStatus.unset;
  String error = '';
  String email = '';
  bool emailIsAvailable = false;
  bool phoneIsAvailable = false;
  String password = '';
  String confirmPassword = '';
  String businessName = '';
  String ruc = '';
  String location = '';
  int prefix = 51; // Perú
  String phone = '';
  bool conditionsAccepted = false;

  void _navigateToTermsAndConditions() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TermsAndConditions()),
    );
  }

  void onChangedPrefix(CountryModel country) {
    setState(() {
      error = '';
      prefix = country.prefix;
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
    if(email.isEmail == false) {
      result = _setError('Formato de correo no válido');
    } else if(emailIsAvailable == false) {
      result = _setError('Correo electrónico no disponible');
    } else if(password.length < 6) {
      result = _setError('La contraseña debe tener 6 caracteres o más');
    } else if(password.length > 20) {
      result = _setError('La contraseña debe tener 20 caracteres o menos');
    } else if(confirmPassword != password) {
      result = _setError('La contraseña y confirmar contraseña no coinciden');
    } else if(phone == '') {
      result = _setError('El campo teléfono es obligatorio');
    } else if(int.parse(phone) < 9999999) {
      result = _setError('El teléfono debe tener 8 dígitos o más');
    } else if(int.parse(phone) > 1000000000000) {
      result = _setError('El teléfono debe tener 12 dígitos o menos');
    } else if(phoneIsAvailable == false) {
      result = _setError('Teléfono no disponible');
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
          const Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              BackArrow(
                margin: EdgeInsets.zero,
              ),
              Text('Registro de establecimiento'),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Antes de comenzar, necesitamos algo de información'),
          ),
          Container(
            margin: const EdgeInsets.symmetric(
              vertical: 10,
            ),
            child: Wrap(
              runSpacing: MediaQuery.of(context).size.height * 0.025,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    WefoodInput(
                      upperTitle: '¿A qué email pueden contactar sus clientes?',
                      upperDescription: 'Será también el que use para iniciar sesión',
                      labelText: 'Correo electrónico',
                      onChanged: (value) async {
                        setState(() {
                          error = '';
                          email = value;
                          if(value.isEmail) {
                            searchingEmailAvailability = LoadingStatus.loading;
                          }
                        });
                        if(value.isEmail) {
                          bool available = false;
                          try {
                            available = await Api.checkEmailAvailability(email: value);
                          } catch(e) {
                            available = false;
                          }
                          setState(() {
                            email = value;
                            emailIsAvailable = available;
                            searchingEmailAvailability = LoadingStatus.successful;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 15),
                    if(searchingEmailAvailability == LoadingStatus.loading) const LoadingIcon(),
                    if(searchingEmailAvailability != LoadingStatus.loading && email != '') Text(
                      (email.isEmail) ?
                        (emailIsAvailable == false)
                          ? 'Correo no disponible'
                          : '¡Correo libre!'
                        : 'Formato de correo incorrecto'
                    ),
                  ],
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
                WefoodInput(
                  labelText: 'Nombre de su negocio',
                  onChanged: (value) {
                    setState(() {
                      error = '';
                      businessName = value;
                    });
                  },
                ),
                WefoodInput(
                  labelText: 'RUC de su negocio',
                  onChanged: (value) {
                    setState(() {
                      error = '';
                      ruc = value;
                    });
                  },
                ),
                WefoodInput(
                  labelText: 'Ubicación de su negocio',
                  onChanged: (value) {
                    setState(() {
                      error = '';
                      location = value;
                    });
                  },
                ),
                const Text('¿A qué teléfono pueden llamar sus clientes?'),
                PhoneInput(
                  onChangedPrefix: onChangedPrefix,
                  onChangedNumber: (String value) {
                    setState(() {
                      error = '';
                      phone = value;
                    });
                  },
                  // TODO meter aquí un onCheckAvailability y llamar al endpoint desde PhoneInput
                )
              ],
            ),
          ),
          const Text('Añade una foto para dar más confianza a tus clientes:'),
          Container(
            padding: EdgeInsets.symmetric(
              vertical: MediaQuery.of(context).size.height * 0.025,
            ),
            child: ClipRRect( // TODO cambiar esto por algo para elegir y guardar una foto
              borderRadius: BorderRadius.circular(999),
              child: SizedBox.fromSize(
                size: Size.fromRadius(MediaQuery.of(context).size.width * 0.15),
                child: Container(
                  color: Colors.black.withOpacity(0.15),
                  child: Icon(
                    Icons.add,
                    size: MediaQuery.of(context).size.width * 0.2,
                    color: Colors.grey,
                  ),
                ),
              ),
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
                  BusinessExpandedModel business = await Api.createBusiness(
                    email: email,
                    password: password,
                    businessName: 'Nombre del business hardcodeado',
                    businessDescription: 'Descripción del business hardcodeada',
                    phonePrefix: 123,
                    phone: 123456789,
                    directions: 'Calle hardcodeada nº 404 bajo B',
                    idCountry: 12345,
                    taxId: 'Tax id hardcodeado',
                    logoFile: Image.asset('assets/images/logo.png'),
                    latitude: 123.456,
                    longitude: 123.456,
                  );
                  UserSecureStorage().write(key: 'username', value: email);
                  UserSecureStorage().write(key: 'password', value: password);
                  AuthModel? auth = await Api.login(
                      context: context,
                      username: email,
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
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.1,
          )
        ],
      ),
    );
  }
}