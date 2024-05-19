import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wefood/blocs/blocs.dart';
import 'package:wefood/components/components.dart';
import 'package:wefood/environment.dart';
import 'package:wefood/services/auth/api.dart';

class BusinessEditDirections extends StatefulWidget {

  const BusinessEditDirections({super.key});

  @override
  State<BusinessEditDirections> createState() => _BusinessEditDirectionsState();
}

class _BusinessEditDirectionsState extends State<BusinessEditDirections> {

  LatLng? initialUserLocation;
  LatLng? initialBusinessLocation;
  String finalDirections = '';
  String? typedLocation;
  LatLng? typedLatLng;
  String finalBusinessCountry = '';
  final Completer<GoogleMapController> _mapController = Completer<GoogleMapController>();
  CameraPosition? cameraPosition;
  bool errorOnFindingLocation = false;
  String error = '';

  _getBusinessLocation() async {
    finalDirections = context.read<UserInfoCubit>().state.business.directions ?? '';
    initialBusinessLocation = LatLng(
      context.read<UserInfoCubit>().state.business.latitude ?? 0,
      context.read<UserInfoCubit>().state.business.longitude ?? 0,
    );
    setState(() {
      cameraPosition = CameraPosition(
        target: LatLng(
          initialBusinessLocation!.latitude,
          initialBusinessLocation!.longitude,
        ),
        zoom: 17,
      );
    });
  }

  _getUserLocation() async {
    PermissionStatus permissionStatus = await Permission.location.request();
    if(permissionStatus.isGranted) {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
      setState(() {
        initialUserLocation = LatLng(position.latitude, position.longitude);
      });
      if(initialUserLocation != null) {
        // await _cameraToPosition(userLocation!);
      }
    }
  }

  updateMarker(typedLocation) async {
    LatLng newLocation = await getLatLngFromAddress(typedLocation);
    setState(() {
      typedLatLng = newLocation;
      _cameraToPosition(newLocation);
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
          finalDirections = results[0]['formatted_address'];
          final addressComponents = results[0]['address_components'] as List<dynamic>;
          for(var component in addressComponents) {
            final types = component['types'] as List<dynamic>;
            if(types.contains('country')) {
              finalBusinessCountry = component['long_name'] as String;
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

  Future<void> _cameraToPosition(LatLng newPosition) async {
    final GoogleMapController controller = await _mapController.future;
    CameraPosition newCameraPosition = CameraPosition(
      target: LatLng(
        newPosition.latitude,
        newPosition.longitude,
      ),
      zoom: 16,
    );
    await controller.animateCamera(CameraUpdate.newCameraPosition(newCameraPosition));
  }

  _retrieveData() async {
    await _getBusinessLocation();
    await _getUserLocation();
  }

  @override
  void initState() {
    _retrieveData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WefoodScreen(
      title: 'Elija su nueva ubicación',
      body: [
        if(cameraPosition != null) Column(
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Expanded(
                  child: WefoodInput(
                    upperDescription: 'Escriba la dirección lo más exacta posible, y compruebe en el mapa que es correcta',
                    labelText: 'Ubicación de su negocio',
                    onChanged: (String value) {
                      setState(() {
                        typedLocation = value;
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
                IconButton(
                  onPressed: () async {
                    FocusManager.instance.primaryFocus?.unfocus();
                    if(typedLocation != '') {
                      try {
                        await updateMarker(typedLocation);
                        // await _cameraToPosition(businessLocation!);
                        errorOnFindingLocation = false;
                      } catch(e) {
                        setState(() {
                          errorOnFindingLocation = true;
                          finalDirections = '';
                        });
                      }
                    }
                  },
                  icon: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.grey.withOpacity(0.25), // TODO poner esto con los colores del estilo
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
              height: MediaQuery.of(context).size.width,
              width: MediaQuery.of(context).size.width,
              child: GoogleMap(
                gestureRecognizers: <Factory<OneSequenceGestureRecognizer>> {
                  Factory<OneSequenceGestureRecognizer>(
                    () => EagerGestureRecognizer() // Skip screen scroll on GoogleMap touch
                  ),
                },
                initialCameraPosition: cameraPosition!,
                markers: {
                  if(initialBusinessLocation != null) Marker(
                    markerId: const MarkerId('current'),
                    icon: BitmapDescriptor.defaultMarker,
                    position: LatLng(
                      context.read<UserInfoCubit>().state.business.latitude ?? 0,
                      context.read<UserInfoCubit>().state.business.longitude ?? 0,
                    ),
                  ),
                  if(typedLatLng != null) Marker(
                    markerId: const MarkerId('typed'),
                    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
                    position: LatLng(
                      typedLatLng!.latitude,
                      typedLatLng!.longitude,
                    ),
                  ),
                },
                onMapCreated: (GoogleMapController controller) async {
                  _mapController.complete(controller);
                },
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
              ),
            ),
            if(typedLatLng != null) Column(
              children: <Widget>[
                const SizedBox(
                  height: 10,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'Se guardará: ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold, // TODO deshardcodear este estilo
                      ),
                    ),
                    Expanded(
                      child: Text(finalDirections),
                    ),
                  ],
                ),
              ],
            )
          ],
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.05,
        ),
        Align(
          alignment: Alignment.center,
          child: ElevatedButton(
            child: const Text('GUARDAR'),
            onPressed: () async {
              setState(() {
                error = '';
              });
              if(finalDirections != '' && finalBusinessCountry != '' && typedLatLng != null) {
                try {
                  Api.updateBusinessDirections(
                    directions: finalDirections,
                    country: finalBusinessCountry,
                    longitude: typedLatLng!.longitude,
                    latitude: typedLatLng!.latitude,
                  ).then((_) {
                    context.read<UserInfoCubit>().setBusinessDirections(finalDirections);
                    context.read<UserInfoCubit>().setBusinessLatLng(
                      LatLng(
                        typedLatLng!.latitude,
                        typedLatLng!.longitude
                      ),
                    );
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return WefoodPopup(
                          context: context,
                          title: 'Dirección guardada como',
                          description: finalDirections,
                          cancelButtonTitle: 'OK',
                          cancelButtonBehaviour: () {
                            Navigator.pop(context);
                          },
                        );
                      }
                    ).then((onValue) {
                      Navigator.pop(context);
                    });
                  });
                } catch(e) {
                  setState(() {
                    error = 'Error al guardar los datos. Por favor, inténtelo de nuevo más tarde';
                  });
                }
              } else {
                setState(() {
                  error = 'No se ha introducido una ubicación válida';
                });
              }
            },
          ),
        ),
        if(error != '') FeedbackMessage(
          message: error,
          isError: true,
          isCentered: true,
        )
      ],
    );
  }
}