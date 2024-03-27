import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wefood/components/back_arrow.dart';
import 'package:wefood/components/loading_icon.dart';
import 'package:wefood/components/phone_input.dart';
import 'package:wefood/components/wefood_input.dart';
import 'package:wefood/components/wefood_screen.dart';
import 'package:wefood/environment.dart';
import 'package:wefood/models/auth_model.dart';
import 'package:wefood/models/business_expanded_model.dart';
import 'package:wefood/models/country_model.dart';
import 'package:wefood/services/auth/api/api.dart';
import 'package:wefood/services/secure_storage.dart';
import 'package:wefood/types.dart';
import 'package:wefood/views/terms_and_conditions.dart';
import 'package:http/http.dart' as http;

class RegisterBusiness extends StatefulWidget {
  const RegisterBusiness({super.key});

  @override
  State<RegisterBusiness> createState() => _RegisterBusinessState();
}

class _RegisterBusinessState extends State<RegisterBusiness> {
  LoadingStatus authenticating = LoadingStatus.unset;
  LoadingStatus searchingEmailAvailability = LoadingStatus.unset;
  LoadingStatus searchingPhoneAvailability = LoadingStatus.unset;
  LoadingStatus searchingRucAvailability = LoadingStatus.unset;
  String error = '';
  String email = '';
  bool emailIsAvailable = false;
  bool phoneIsAvailable = false;
  bool rucIsAvailable = false;
  String password = '';
  String confirmPassword = '';
  String businessName = '';
  String businessDescription = '';
  String location = '';
  String ruc = '';
  int prefix = 51; // Perú
  String phone = '';
  bool conditionsAccepted = false;

  final Completer<GoogleMapController> _mapController = Completer<GoogleMapController>();
  LatLng userLocation = const LatLng(-12.063449, -77.014574); // TODO poner aquí la ubicación del usuario si nos la da
  LatLng? businessLocation;
  String businessLocationString = '';
  CameraPosition cameraPosition = const CameraPosition(
    target: LatLng(-12.063449, -77.014574),
    zoom: 16,
  );
  bool errorOnFindingLocation = false;

  void _navigateToTermsAndConditions() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TermsAndConditions()),
    );
  }

  getUserLocation() async {
    PermissionStatus permissionStatus = await Permission.location.request();
    if(permissionStatus.isGranted) {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
      setState(() {
        userLocation = LatLng(position.latitude, position.longitude);
        cameraPosition = CameraPosition(
          target: userLocation,
          zoom: 16,
        );
      });
    }
  }

  Future<void> _cameraToPosition(LatLng newPosition) async {
    final GoogleMapController controller = await _mapController.future;
    CameraPosition newCameraPosition = CameraPosition(
      target: newPosition,
      zoom: 16,
    );
    await controller.animateCamera(CameraUpdate.newCameraPosition(newCameraPosition));
  }

  updateMarker(businessLocationString) async {
    LatLng newLocation = await getLatLngFromAddress(businessLocationString);
    setState(() {
      location = businessLocationString;
      businessLocation = newLocation;
      cameraPosition = CameraPosition(
        target: businessLocation!,
        zoom: 16,
      );
    });
  }

  Future<LatLng> getLatLngFromAddress(String address) async {
    final query = Uri.encodeQueryComponent(address);
    final url = 'https://maps.googleapis.com/maps/api/geocode/json?address=$query&key=${Environment.googleMapsApiKey}';
    try {
      final response = await http.get(Uri.parse(url));
      if(response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List<dynamic>;
        if(results.isNotEmpty) {
          final location = results[0]['geometry']['location'];
          final lat = location['lat'] as double;
          final lng = location['lng'] as double;
          return LatLng(lat, lng);
        } else {
          throw Exception('No se encontraron resultados para la dirección proporcionada.');
        }
      } else {
        throw Exception('Hubo un error al obtener los datos de geocodificación. Código de estado: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error en la solicitud de geocodificación: $e');
    }
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
      result = _setError('Formato de correo incorrecto');
    } else if(emailIsAvailable == false) {
      result = _setError('Correo electrónico no disponible');
    } else if(password.length < 6) {
      result = _setError('La contraseña debe tener 6 caracteres o más');
    } else if(password.length > 20) {
      result = _setError('La contraseña debe tener 20 caracteres o menos');
    } else if(confirmPassword != password) {
      result = _setError('La contraseña y confirmar contraseña no coinciden');
    } else if(businessName.length < 6) {
      result = _setError('El nombre del establecimiento debe tener 6 caracteres o más');
    } else if(businessName.length > 100) {
      result = _setError('El nombre del establecimiento es demasiado largo');
    } else if(businessDescription.length < 6) {
      result = _setError('La descripción del establecimiento debe tener 6 caracteres o más');
    } else if(businessDescription.length > 255) {
      result = _setError('La descripción del establecimiento es demasiado larga');
    } else if(ruc.length < 6) {
      result = _setError('El RUC es demasiado corto');
    } else if(ruc.length > 50) {
      result = _setError('El RUC es demasiado largo');
    } else if(rucIsAvailable == false) {
      result = _setError('RUC no disponible');
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
                      errorText: (searchingEmailAvailability != LoadingStatus.loading && email != '')
                        ? (email.isEmail)
                          ? (emailIsAvailable == true)
                            ? '¡Correo libre!'
                            : 'Correo no disponible'
                          : 'Formato de correo incorrecto'
                        : null
                    ),
                    const SizedBox(height: 15),
                    if(searchingEmailAvailability == LoadingStatus.loading) const LoadingIcon(),
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
                  labelText: 'Nombre de su establecimiento',
                  onChanged: (value) {
                    setState(() {
                      error = '';
                      businessName = value;
                    });
                  },
                  errorText: (businessName.isEmpty == false && businessName.length < 6)
                    ? 'Nombre demasiado corto'
                    : (businessName.isEmpty == false && businessName.length > 100)
                      ? 'Nombre demasiado largo'
                      : null,
                ),
                WefoodInput(
                  upperDescription: 'Por si alguien aún no conoce su establecimiento, le recomendamos que añada una descripción',
                  labelText: 'Descripción de su establecimiento',
                  onChanged: (value) {
                    setState(() {
                      error = '';
                      businessDescription = value;
                    });
                  },
                  errorText: (businessDescription.isEmpty == false && businessDescription.length < 6)
                    ? 'Descripción demasiado corta'
                    : (businessDescription.isEmpty == false && businessDescription.length > 255)
                      ? 'Descripción demasiado larga'
                      : null,
                ),
                WefoodInput(
                  labelText: 'RUC de su negocio',
                  onChanged: (String value) async {
                    setState(() {
                      error = '';
                      ruc = value;
                      if(6 < ruc.length && ruc.length < 50) {
                        searchingRucAvailability = LoadingStatus.loading;
                      }
                    });
                    if(6 < ruc.length && ruc.length < 50) {
                      bool available = false;
                      try {
                        available = await Api.checkTaxIdAvailability(taxId: ruc);
                      } catch (e) {
                        available = false;
                      }
                      setState(() {
                        rucIsAvailable = available;
                        searchingRucAvailability = LoadingStatus.successful;
                      });
                    }
                  },
                  errorText: (searchingRucAvailability != LoadingStatus.loading && ruc.isEmpty == false)
                  ? (ruc.length < 6)
                    ? 'RUC demasiado corto'
                    : (ruc.length > 50)
                      ? 'RUC demasiado largo'
                      : (rucIsAvailable == true)
                        ? '¡RUC libre!'
                        : 'RUC no disponible'
                  : null,
                ),
                const SizedBox(height: 15),
                if(searchingRucAvailability == LoadingStatus.loading) const LoadingIcon(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Expanded(
                      child: WefoodInput(
                        upperTitle: 'Añada la ubicación de su negocio',
                        upperDescription: 'Escriba la dirección lo más exacta posible, y compruebe en el mapa que es correcta',
                        labelText: 'Ubicación de su negocio',
                        onChanged: (String value) {
                          setState(() {
                            errorOnFindingLocation = false;
                            businessLocationString = value;
                            error = '';
                          });
                        },
                        errorText: (errorOnFindingLocation == true) ? 'No se ha encontrado ubicación para esas direcciones' : null,
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        if(businessLocationString != '') {
                          try {
                            errorOnFindingLocation = false;
                            await updateMarker(businessLocationString);
                            await _cameraToPosition(businessLocation!);
                          } catch(e) {
                            setState(() {
                              errorOnFindingLocation = true;
                              businessLocation = null;
                              location = '';
                              error = '';
                            });
                          }
                        }
                      },
                      icon: Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.green, // TODO poner esto con los colores del estilo
                        ),
                        child: const Icon(
                          Icons.search,
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.width * 0.75,
                  width: MediaQuery.of(context).size.width,
                  child: GoogleMap(
                    gestureRecognizers: <Factory<OneSequenceGestureRecognizer>> {
                      Factory<OneSequenceGestureRecognizer>(
                        () => EagerGestureRecognizer() // Skip screen scroll on GoogleMap touch
                      ),
                    },
                    initialCameraPosition: cameraPosition,
                    markers: {
                      if(businessLocation != null) Marker(
                        markerId: const MarkerId('typed'),
                        icon: BitmapDescriptor.defaultMarker,
                        position: LatLng(businessLocation!.latitude, businessLocation!.longitude),
                      ),
                    },
                    onMapCreated: (GoogleMapController controller) async {
                      await getUserLocation();
                      _mapController.complete(controller);
                    },
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                  ),
                ),
                const Text('¿A qué teléfono pueden llamar sus clientes?'),
                PhoneInput(
                  onChangedPrefix: onChangedPrefix,
                  onChangedNumber: (String value) async {
                    setState(() {
                      error = '';
                      phone = value;
                      if(9999999 < int.parse(phone) && int.parse(phone) < 1000000000000) {
                        searchingPhoneAvailability = LoadingStatus.loading;
                      }
                    });
                    if(9999999 < int.parse(phone) && int.parse(phone) < 1000000000000) {
                      bool available = false;
                      try {
                        available = await Api.checkPhoneAvailability(phone: phone);
                      } catch(e) {
                        available = false;
                      }
                      setState(() {
                        phoneIsAvailable = available;
                        searchingPhoneAvailability = LoadingStatus.successful;
                      });
                    }
                  },
                ),
                if(searchingPhoneAvailability == LoadingStatus.loading) const LoadingIcon(),
                if(searchingPhoneAvailability != LoadingStatus.loading && phone != '') Text(
                  (int.parse(phone) < 9999999)
                    ? 'Teléfono demasiado corto'
                    : (int.parse(phone) > 1000000000000)
                      ? 'Teléfono demasiado largo'
                      : (phoneIsAvailable == false)
                        ? 'Teléfono no disponible'
                        : '¡Teléfono libre!'
                ),
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
          const SizedBox(
            height: 20,
          ),
          if(error != '') Text(
            error,
            textAlign: TextAlign.center,
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.1,
          ),
        ],
      ),
    );
  }
}