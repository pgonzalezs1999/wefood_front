import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wefood/components/components.dart';
import 'package:wefood/environment.dart';
import 'package:wefood/models/models.dart';
import 'package:wefood/services/auth/api.dart';
import 'package:wefood/services/secure_storage.dart';
import 'package:wefood/types.dart';
import 'package:wefood/views/views.dart';
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
  String auxEmail = '';
  bool emailIsAvailable = false;
  bool phoneIsAvailable = false;
  bool rucIsAvailable = false;
  String password = '';
  String confirmPassword = '';
  String businessName = '';
  String businessDescription = '';
  String directions = '';
  String ruc = '';
  int prefix = 51; // Perú
  String phone = '';
  bool conditionsAccepted = false;
  String businessCountry = '';

  String selectedPrefix = '';

  getCountryItems() {
    List<CountryModel> countries = [
      CountryModel.fromParameters(2, 'Perú', 51, 'Peru'),
      CountryModel.fromParameters(4, 'España', 34, 'Spain'),
      CountryModel.fromParameters(5, 'Colombia', 57, 'Colombia'),
    ];
    List<DropdownMenuItem<String>> items = countries.map((country) {
      return DropdownMenuItem<String>(
        value: country.prefix.toString(),
        child: Text('(+${country.prefix}) ${country.name}'),
      );
    }).toList();
    return items;
  }

  final Completer<GoogleMapController> _mapController = Completer<GoogleMapController>();
  LatLng userLocation = const LatLng(-12.063449, -77.014574);
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
          setState(() {
            directions = results[0]['formatted_address'];
          });

          final addressComponents = results[0]['address_components'] as List<dynamic>;
          for(var component in addressComponents) {
            final types = component['types'] as List<dynamic>;
            if(types.contains('country')) {
              businessCountry = component['long_name'] as String;
              break;
            }
          }
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

  _handleEmailChange(String value) async {
    if(email.isEmail) {
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
    } else {
      setState(() {
        auxEmail = '';
        email = value;
        error = '';
        searchingEmailAvailability = LoadingStatus.unset;
      });
    }
  }

  void _navigateToWaitVerify() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const WaitingVerification()),
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
    } else if(ruc.length != 8 && ruc.length != 11) {
      result = _setError('El RUC debe tener 8 u 11 caracteres');
    } else if(rucIsAvailable == false) {
      result = _setError('RUC no disponible');
    } else if(errorOnFindingLocation == true) {
      result = _setError('La dirección no es válida');
    } else if(phone == '') {
      result = _setError('El campo teléfono es obligatorio');
    } else if(phone.length != 9) {
      result = _setError('El teléfono debe tener 9 dígitos');
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
      title: 'Registra tu negocio',
      body: [
        Wrap(
          runSpacing: MediaQuery.of(context).size.height * 0.025,
          children: <Widget>[
            WefoodInput(
              upperTitle: '¿A qué email pueden contactar sus clientes?',
              upperDescription: 'Será también el que use para iniciar sesión',
              labelText: 'Correo electrónico',
              onChanged: (value) => _handleEmailChange(value),
              feedbackWidget: (searchingEmailAvailability == LoadingStatus.loading)
                ? const ReducedLoadingIcon()
                : (searchingEmailAvailability != LoadingStatus.loading && email != '')
                  ? (email.isEmail)
                    ? (emailIsAvailable == true)
                      ? const FeedbackMessage(
                        message: '¡Libre!',
                        isError: false,
                      )
                      : const FeedbackMessage(
                        message: 'No disponible',
                        isError: true,
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
            WefoodInput(
              labelText: 'Nombre de su negocio',
              onChanged: (value) {
                setState(() {
                  error = '';
                  businessName = value;
                });
              },
              feedbackWidget: (businessName.isEmpty == false && businessName.length < 6)
                ?  const FeedbackMessage(
                  message: 'Demasiado corto',
                  isError: true,
                )
                : (businessName.isEmpty == false && businessName.length > 100)
                  ? const FeedbackMessage(
                    message: 'Demasiado larga',
                    isError: true,
                  )
                  : null,
            ),
            WefoodInput(
              upperTitle: 'Añada una descripción para quien no conozca su negocio',
              labelText: 'Descripción de su negocio',
              onChanged: (value) {
                setState(() {
                  error = '';
                  businessDescription = value;
                });
              },
              feedbackWidget: (businessDescription.isEmpty == false && businessDescription.length < 6)
                ? const FeedbackMessage(
                    message: 'Demasiado corta',
                    isError: true
                )
                : (businessDescription.isEmpty == false && businessDescription.length > 255)
                  ? const FeedbackMessage(
                    message: 'Demasiado larga',
                    isError: true
                  )
                  : null,
            ),
            WefoodInput(
              labelText: 'RUC de su negocio',
              onChanged: (String value) async {
                setState(() {
                  error = '';
                  ruc = value;
                  if(ruc.length == 8 || ruc.length == 11) {
                    searchingRucAvailability = LoadingStatus.loading;
                  }
                });
                if(ruc.length == 8 || ruc.length == 11) {
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
              feedbackWidget: (searchingRucAvailability == LoadingStatus.loading)
                ? const ReducedLoadingIcon()
                : (searchingRucAvailability != LoadingStatus.loading && ruc.isEmpty == false)
                  ? (ruc.length != 8 && ruc.length < 11)
                    ? const FeedbackMessage(
                      message: 'RUC demasiado corto',
                      isError: true,
                    )
                    : (ruc.length != 8 && ruc.length > 11)
                      ? const FeedbackMessage(
                        message: 'RUC demasiado largo',
                        isError: true,
                      )
                      : (rucIsAvailable == true)
                        ? const FeedbackMessage(
                          message: '¡RUC libre!',
                          isError: false,
                        )
                        : const FeedbackMessage(
                          message: 'RUC no disponible',
                          isError: true,
                        )
                  : null,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Añada la ubicación de su negocio',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Text('Escriba la dirección lo más exacta posible, y compruebe que es correcta en el mapa'),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(
                          top: 5,
                        ),
                        child: WefoodInput(
                          labelText: 'Ubicación de su negocio',
                          onChanged: (String value) {
                            setState(() {
                              errorOnFindingLocation = false;
                              businessLocationString = value;
                              error = '';
                            });
                          },
                          feedbackWidget: (errorOnFindingLocation == true)
                              ? const FeedbackMessage(
                            message: 'No se ha encontrado ubicación para esas direcciones',
                            isError: true,
                          )
                              : null,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        FocusManager.instance.primaryFocus?.unfocus();
                        if(businessLocationString != '') {
                          try {
                            await updateMarker(businessLocationString);
                            await _cameraToPosition(businessLocation!);
                            errorOnFindingLocation = false;
                            error = '';
                          } catch(e) {
                            setState(() {
                              errorOnFindingLocation = true;
                              businessLocation = null;
                              directions = '';
                            });
                          }
                        }
                      },
                      icon: Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Theme.of(context).primaryColor,
                        ),
                        child: const Icon(
                          Icons.search,
                          color: Colors.white,
                        ),
                      ),
                    )
                  ],
                ),
              ],
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
            Text('Se guardará: $directions'),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '¿A qué teléfono pueden llamar sus clientes?',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButton<String>(
                      value: selectedPrefix.isNotEmpty ? selectedPrefix : '51',
                      items: getCountryItems(),
                      onChanged: (value) {
                        setState(() {
                          selectedPrefix = value!;
                        });
                        setState(() {
                          error = '';
                          prefix = int.parse(value!);
                        });
                      },
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: WefoodInput(
                        onChanged: (String value) async {
                          setState(() {
                            error = '';
                            phone = value;
                            if(phone.length == 9) {
                              searchingPhoneAvailability = LoadingStatus.loading;
                            }
                          });
                          if(phone.length == 9) {
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
                        labelText: 'Número de teléfono',
                        type: InputType.integer,
                        feedbackWidget: (searchingPhoneAvailability == LoadingStatus.loading)
                          ? const ReducedLoadingIcon()
                          : (searchingPhoneAvailability != LoadingStatus.loading && phone != '')
                            ? (phone.length < 9)
                              ? const FeedbackMessage(
                                message: 'Demasiado corto',
                                isError: true,
                              )
                              : (phone.length > 9)
                                ? const FeedbackMessage(
                                  message: 'Demasiado largo',
                                  isError: true,
                                )
                                : (phoneIsAvailable == false)
                                  ? const FeedbackMessage(
                                    message: 'No disponible',
                                    isError: true,
                                  )
                                  : const FeedbackMessage(
                                    message: '¡Libre!',
                                    isError: false,
                                  )
                          : null,
                      ),
                    ),
                  ],
                ),
              ],
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
            if(authenticating == LoadingStatus.loading) const Center(
              child: LoadingIcon()
            ),
            if(authenticating != LoadingStatus.loading) Center(
              child: ElevatedButton(
                child: const Text('REGISTRARME'),
                onPressed: () async {
                  if(_readyToRegister() == true) {
                    setState(() {
                      authenticating = LoadingStatus.loading;
                    });
                    try {
                      await Api.createBusiness(
                        email: email,
                        password: password,
                        phonePrefix: prefix,
                        phone: int.parse(phone),
                        businessName: businessName,
                        businessDescription: businessDescription,
                        taxId: ruc,
                        directions: directions,
                        country: businessCountry,
                        longitude: businessLocation!.longitude,
                        latitude: businessLocation!.latitude,
                      );
                      await UserSecureStorage().write(key: 'username', value: email);
                      await UserSecureStorage().write(key: 'password', value: password);
                      _navigateToWaitVerify();
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
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            if(error != '') FeedbackMessage(
              message: error,
              isError: true,
              isCentered: true,
            ),
          ],
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.1,
        ),
      ],
    );
  }
}