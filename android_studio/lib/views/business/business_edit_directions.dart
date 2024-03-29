import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:wefood/components/back_arrow.dart';
import 'package:wefood/components/wefood_input.dart';
import 'package:wefood/components/wefood_screen.dart';
import 'package:wefood/environment.dart';
import 'package:wefood/services/auth/api/api.dart';

class BusinessEditDirections extends StatefulWidget {

  final double longitude;
  final double latitude;

  const BusinessEditDirections({
    super.key,
    required this.longitude,
    required this.latitude,
  });

  @override
  State<BusinessEditDirections> createState() => _BusinessEditDirectionsState();
}

class _BusinessEditDirectionsState extends State<BusinessEditDirections> {

  String directions = '';
  String businessCountry = '';
  final Completer<GoogleMapController> _mapController = Completer<GoogleMapController>();
  LatLng userLocation = const LatLng(-12.063449, -77.014574);
  LatLng? businessLocation;
  String businessLocationString = '';
  CameraPosition cameraPosition = const CameraPosition(
    target: LatLng(-12.063449, -77.014574),
    zoom: 16,
  );
  bool errorOnFindingLocation = false;
  String error = '';

  updateMarker(businessLocationString) async {
    LatLng newLocation = await getLatLngFromAddress(businessLocationString);
    setState(() {
      directions = businessLocationString;
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
          directions = results[0]['formatted_address'];

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

  Future<void> _cameraToPosition(LatLng newPosition) async {
    final GoogleMapController controller = await _mapController.future;
    CameraPosition newCameraPosition = CameraPosition(
      target: newPosition,
      zoom: 16,
    );
    await controller.animateCamera(CameraUpdate.newCameraPosition(newCameraPosition));
  }

  @override
  Widget build(BuildContext context) {
    return WefoodScreen(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: <Widget>[
              BackArrow(
                margin: EdgeInsets.zero,
              ),
              Text('Elija su nueva ubicación'),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Expanded(
                child: WefoodInput(
                  upperDescription: 'Escriba la dirección lo más exacta posible, y compruebe en el mapa que es correcta',
                  labelText: 'Ubicación de su negocio',
                  onChanged: (String value) {
                    setState(() {
                      businessLocationString = value;
                      error = '';
                    });
                  },
                  errorText: (errorOnFindingLocation == true) ? 'No se ha encontrado ubicación para esas direcciones' : null,
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
              initialCameraPosition:  CameraPosition(
                target: LatLng(widget.latitude, widget.longitude),
                zoom: 16,
              ),
              markers: {
                if(businessLocation != null) Marker(
                  markerId: const MarkerId('typed'),
                  icon: BitmapDescriptor.defaultMarker,
                  position: LatLng(businessLocation!.latitude, businessLocation!.longitude),
                ),
                if(businessLocation == null) Marker(
                  markerId: const MarkerId('current'),
                  icon: BitmapDescriptor.defaultMarker,
                  position: LatLng(widget.latitude, widget.longitude),
                ),
              },
              onMapCreated: (GoogleMapController controller) async {
                _mapController.complete(controller);
              },
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.05,
          ),
          Align(
            alignment: Alignment.center,
            child: ElevatedButton(
              onPressed: () async {
                setState(() {
                  error = '';
                });
                if(directions != '' && businessCountry != '' && businessLocation != null) {
                  try {
                    await Api.updateBusinessDirections(
                      directions: directions,
                      country: businessCountry,
                      longitude: businessLocation!.longitude,
                      latitude: businessLocation!.latitude,
                    );
                    Navigator.pop(context);
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
              child: const Text('GUARDAR'),
            ),
          ),
          if(error != '') Container(
            margin: EdgeInsets.only(
              top: MediaQuery.of(context).size.height * 0.05,
            ),
            child: Align(
              alignment: Alignment.center,
              child: Text(error),
            ),
          ),
        ],
      ),
    );
  }
}