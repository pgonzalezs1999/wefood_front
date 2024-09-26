import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wefood/blocs/blocs.dart';
import 'package:wefood/commands/call_request.dart';
import 'package:wefood/components/components.dart';
import 'package:wefood/models/models.dart';
import 'package:wefood/models/product_expanded_model.dart';
import 'package:wefood/services/auth/api.dart';

class MapSearchScreen extends StatefulWidget {
  const MapSearchScreen({super.key});

  @override
  State<MapSearchScreen> createState() => _MapSearchScreenState();
}

class _MapSearchScreenState extends State<MapSearchScreen> {

  GoogleMapController? _mapController;
  LatLng? lastSearchCameraPosition;
  LatLng? cameraPosition;
  Set<Marker> markers = {};
  List<ProductExpandedModel> items = [];
  List<ItemButton> itemButtons = [];
  String chosenBusinessName = '';

  _getUserLocation() async {
    if(context.read<UserLocationCubit>().state != null) {
      setState(() {
        cameraPosition = context.read<UserLocationCubit>().state!;
      });
    } else {
      Permission.location.request().then((PermissionStatus permissionStatus) {
        if(permissionStatus.isGranted) {
          Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
          ).then((Position position) {
             setState(() {
               cameraPosition = LatLng(position.latitude, position.longitude);
             });
          });
        } else {
          cameraPosition = const LatLng(-12.1, -77);
        }
      });
    }
  }

  _retrieveData(BuildContext context) {
    callRequestWithLoading(
      context: context,
      request: () async {
        return await Api.getNearbyBusinesses(
          longitude: cameraPosition?.longitude ?? -77,
          latitude: cameraPosition?.latitude ?? -12.1,
        );
      },
      onSuccess: (List<ProductExpandedModel> newItems) {
        _updateMarkers(newItems);
      },
    );
  }

  _updateMarkers(List<ProductExpandedModel> newItems) {
    items = newItems;
    markers.clear();
    lastSearchCameraPosition = cameraPosition;
    setState(() {
      markers.addAll(
        newItems.map((it) => Marker(
          markerId: MarkerId(it.item.id.toString()),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            (it.business.name! == chosenBusinessName) ? BitmapDescriptor.hueViolet : BitmapDescriptor.hueRed,
          ),
          position: LatLng(
            it.business.latitude!,
            it.business.longitude!,
          ),
          onTap: () {
            setState(() {
              chosenBusinessName = it.business.name!;
            });
            List<ItemButton> newItemButtons = [];
            itemButtons = [];
            for(int i = 0; i < newItems.length; i++) {
              if(newItems[i].business.id == it.business.id) {
                newItemButtons.add(
                  ItemButton(
                    productExpanded: newItems[i],
                    horizontalScroll: true,
                  ),
                );
              }
            }
            setState(() {
              itemButtons = newItemButtons;
              _updateMarkers(newItems);
            });
          }
        )),
      );
    });
  }

  bool _canRefreshItems() {
    bool result = false;
    if(lastSearchCameraPosition != null && cameraPosition != null) {
      double longitudeDifference = (lastSearchCameraPosition!.longitude - cameraPosition!.longitude).abs();
      double latitudeDifference = (lastSearchCameraPosition!.latitude - cameraPosition!.latitude).abs();
      if(longitudeDifference > 0.04 || latitudeDifference > 0.04) { // TODO deshardcodear este límite
        result = true;
      }
    }
    return result;
  }

  @override
  void initState() {
    _getUserLocation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: WefoodScreen(
        preventScrolling: true,
        ignoreHorizontalPadding: true,
        title: 'Buscar productos',
        body: [
          Expanded(
            child: Stack(
              children: <Widget>[
                GoogleMap(
                  onMapCreated: (GoogleMapController mapController) {
                    _mapController = mapController;
                    _retrieveData(context);
                  },
                  onCameraMove: (CameraPosition newCameraPosition) {
                    setState(() {
                      cameraPosition = newCameraPosition.target;
                    });
                  },
                  gestureRecognizers: <Factory<OneSequenceGestureRecognizer>> {
                    Factory<OneSequenceGestureRecognizer>(
                      () => EagerGestureRecognizer() // Skip screen scroll on GoogleMap touch
                    ),
                  },
                  zoomControlsEnabled: false,
                  initialCameraPosition: CameraPosition(
                    target: cameraPosition ?? const LatLng(-12.1, -77),
                    zoom: 14,
                  ),
                  minMaxZoomPreference: const MinMaxZoomPreference(12, 21),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  markers: markers,
                ),
                if(_canRefreshItems() == true) Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    margin: const EdgeInsets.only(
                      top: 15,
                    ),
                    child: ElevatedButton(
                      child: const Text(
                        'Buscar en esta zona',
                      ),
                      onPressed: () {
                        setState(() {
                          itemButtons = [];
                        });
                        if(cameraPosition != null && _mapController != null) {
                          _mapController!.animateCamera(
                            CameraUpdate.newCameraPosition(
                              CameraPosition(
                                target: cameraPosition!,
                                zoom: 13,
                              ),
                            ),
                          );
                        }
                        _retrieveData(context);
                      },
                    ),
                  ),
                ),
                if(itemButtons.isNotEmpty) Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary,
                        width: 0.5,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10,
                    ),
                    margin: const EdgeInsets.all(15),
                    child: Stack(
                      alignment: Alignment.topRight,
                      children: <Widget>[
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              chosenBusinessName,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: itemButtons,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          child: const Icon(
                            Icons.close,
                          ),
                          onTap: () {
                            setState(() {
                              itemButtons = [];
                            });
                          },
                        ),
                      ],
                    )
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}