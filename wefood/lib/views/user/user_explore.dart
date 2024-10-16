import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wefood/blocs.dart';
import 'package:wefood/commands/call_request.dart';
import 'package:wefood/components/components.dart';
import 'package:wefood/services/auth/api.dart';
import 'package:wefood/models.dart';
import 'package:wefood/views/user/searched_items.dart';
import 'package:wefood/views/views.dart';

class UserExplore extends StatefulWidget {
  const UserExplore({super.key});

  @override
  State<UserExplore> createState() => _UserExploreState();
}

class _UserExploreState extends State<UserExplore> {
  LatLng userLocation = const LatLng(-12.5, -77);
  bool locationDenied = true;
  Widget recommendedList = const SkeletonItemButtonList();
  Widget nearbyList =  const SkeletonItemButtonList(
    horizontalScroll: true,
  );
  final TextEditingController _searchController = TextEditingController();
  bool errorOnFavourites = false;

  Widget _exploreTitle(String title) {
    return Container(
      margin: const EdgeInsets.only(
        top: 20,
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }

  _getUserLocation() {
    if(context.read<UserLocationCubit>().state == null) {
      Permission.locationWhenInUse.request().then((PermissionStatus permissionStatus) {
        // If permission granted (permanently or not)...
        if(permissionStatus != PermissionStatus.permanentlyDenied && permissionStatus != PermissionStatus.denied) {
          setState(() {
            locationDenied = false;
            recommendedList = const SkeletonItemButtonList();
            nearbyList =  const SkeletonItemButtonList(
              horizontalScroll: true,
            );
          });
          Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
            ),
          ).then((Position position) {
            LatLng newPosition = LatLng(position.latitude, position.longitude);
            context.read<UserLocationCubit>().set(
              location: newPosition,
            );
            setState(() {
              userLocation = newPosition;
            });
            _refreshData();
          });
        } else { // Denied (permanently or not
          setState(() {
            locationDenied = true;
          });
          _refreshData();
        }
      });
    } else {
      setState(() {
        locationDenied = false;
        userLocation = context.read<UserLocationCubit>().state!;
      });
      _refreshData();
    }
  }

  _refreshData() async {
    if(locationDenied == false) {
      setState(() {
        context.read<NearbyItemsCubit>().set(List<ProductExpandedModel>.empty());
        context.read<RecommendedItemsCubit>().set(List<ProductExpandedModel>.empty());
      });
      _retrieveRecommended();
      _retrieveNearby();
    }
  }

  _retrieveRecommended() async {
    try {
      if(context.read<RecommendedItemsCubit>().state.isEmpty) {
        Api.getRecommendedItems(
          longitude: userLocation.longitude,
          latitude: userLocation.latitude,
        ).then((List<ProductExpandedModel> items) {
          if(items.isEmpty) {
            setState(() {
              recommendedList = Align(
                alignment: Alignment.center,
                child: Card(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.05,
                      vertical: MediaQuery.of(context).size.width * 0.025,
                    ),
                    child: const Text(
                      'Solo recomendamos ofertas cercanas',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            });
          } else {
            setState(() {
            context.read<RecommendedItemsCubit>().set(items);
              recommendedList = Column(
                children: context.read<RecommendedItemsCubit>().state.map((ProductExpandedModel product) => ItemButton(
                  productExpanded: product,
                  comebackBehaviour: () async {
                    await _retrieveFavourites();
                  },
                )).toList(),
              );
            });
          }
        });
      }
    } catch(error) {
      setState(() {
        recommendedList = Container(
          margin: EdgeInsets.symmetric(
            vertical: MediaQuery.of(context).size.height * 0.05,
          ),
          child: Text('Error $error'),
        );
      });
    }
  }

  _retrieveNearby() async {
    try {
      if(context.read<NearbyItemsCubit>().state.isEmpty) {
        Api.getNearbyItems(
          longitude: userLocation.longitude,
          latitude: userLocation.latitude,
        ).then((List<ProductExpandedModel> items) {
          if(items.isEmpty) {
            setState(() {
              nearbyList = Align(
                alignment: Alignment.center,
                child: Card(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.05,
                      vertical: MediaQuery.of(context).size.width * 0.05,
                    ),
                    child: const Text(
                      'No hemos encontrado ofertas cerca.\n'
                      'Pruebe a buscar en el mapa, o por nombre desde el buscador',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            });
          } else {
            setState(() {
              context.read<NearbyItemsCubit>().set(items);
            });
            setState(() {
              nearbyList = SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: context.read<NearbyItemsCubit>().state.map((ProductExpandedModel i) => ItemButton(
                    horizontalScroll: true,
                    productExpanded: i,
                    comebackBehaviour: () async {
                      await _retrieveFavourites();
                    },
                  )).toList(),
                ),
              );
            });
          }
        });
      } else {
        setState(() {
          nearbyList = SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: context.read<NearbyItemsCubit>().state.map((ProductExpandedModel i) => ItemButton(
                horizontalScroll: true,
                productExpanded: i,
                comebackBehaviour: () async {
                  await _retrieveFavourites();
                },
              )).toList(),
            ),
          );
        });
      }
    } catch(error) {
      setState(() {
        nearbyList = Container(
          margin: EdgeInsets.symmetric(
            vertical: MediaQuery.of(context).size.height * 0.05,
          ),
          child: Text('Error $error'),
        );
      });
    }
  }

  _retrieveFavourites() async {
    if(context.read<FavouriteItemsCubit>().state == null || context.read<FavouriteItemsCubit>().needsRefresh == true) {
      try {
        List<ProductExpandedModel> items = await Api.getFavouriteItems();
        setState(() {
          context.read<FavouriteItemsCubit>().set(items);
        });
      } catch(error) {
        setState(() {
          errorOnFavourites = true;
        });
      }
    }
  }

  _navigateToMapScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MapSearchScreen()),
    ).whenComplete(() {
      setState(() {
        context.read<SearchFiltersCubit>().state;
      });
    });
  }

  _navigateToSearchFilters() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SearchFilters()),
    ).whenComplete(() {
      setState(() {
        context.read<SearchFiltersCubit>().state;
      });
    });
  }

  _navigateToSearchedFilters({
    required String text,
    required List<ProductExpandedModel> items
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SearchedItems(
          text: text,
          items: items
      )),
    ).whenComplete(() {
      setState(() {
        context.read<SearchFiltersCubit>().state;
      });
    });
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _getUserLocation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _retrieveFavourites();
    return WefoodNavigationScreen(
      children: <Widget>[
        if(locationDenied == true) Container(
          margin: EdgeInsets.symmetric(
            vertical: MediaQuery.of(context).size.height * 0.2,
          ),
          padding: const EdgeInsets.symmetric(
            vertical: 30,
          ),
          child: Card(
            elevation: 2,
            child: Container(
              padding: const EdgeInsets.all(30),
              child: Column(
                children: <Widget>[
                  const Text(
                    'Para poder recomendarte ofertas cercanas, necesitamos que nos des permiso para acceder a tu ubicación',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      openAppSettings().then((bool value) {
                        _getUserLocation();
                      });
                    },
                    child: const Text('ABRIR AJUSTES'),
                  ),
                ],
              ),
            ),
          ),
        ),
        if(locationDenied == false) Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  child: const Icon(
                    Icons.map,
                  ),
                  onTap: () {
                    _navigateToMapScreen();
                  },
                ),
                const SizedBox(
                  width: 15,
                ),
                Expanded(
                  child: TextFormField(
                    controller: _searchController,
                    keyboardType: TextInputType.visiblePassword,
                    onChanged: (String value) {
                      setState(() {
                        _searchController.text;
                      });
                    },
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                      ),
                      hintText: 'Busca tu próxima comida',
                      hintStyle: TextStyle(
                        color: Theme.of(context).primaryColor.withOpacity(0.5),
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context).primaryColor,
                        ),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      suffixIcon: (_searchController.text != '') ? Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 20,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            SizedBox(
                              height: 40,
                              width: 35,
                              child: GestureDetector(
                                child: const Icon(
                                  Icons.search,
                                ),
                                onTap: () async {
                                  callRequestWithLoading(
                                    context: context,
                                    request: () async {
                                      return await Api.searchItemsByText(
                                        text: _searchController.text,
                                      );
                                    },
                                    onSuccess: (List<ProductExpandedModel> items) {
                                      _navigateToSearchedFilters(
                                        text: _searchController.text,
                                        items: items,
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                            SizedBox(
                              height: 40,
                              width: 35,
                              child: GestureDetector(
                                child: const Icon(
                                  Icons.cancel_outlined,
                                ),
                                onTap: () {
                                  setState(() {
                                    _searchController.text = '';
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ) : null,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 60,
                  width: 10,
                ),
                GestureDetector(
                  child: const Icon(
                    Icons.filter_list,
                  ),
                  onTap: () => _navigateToSearchFilters(),
                ),
              ],
            ),
            _exploreTitle('Recomendados'),
            recommendedList,
            _exploreTitle('Cerca de tí'),
            nearbyList,
            _exploreTitle('Ofertas de tus favoritos'),
            if(context.read<FavouriteItemsCubit>().state == null) Container(
              margin: const EdgeInsets.only(
                left: 10,
              ),
              child: const SkeletonItemButtonList(
                horizontalScroll: true,
              ),
            ),
            if(errorOnFavourites == true) Container(
              margin: EdgeInsets.symmetric(
                vertical: MediaQuery.of(context).size.height * 0.05,
              ),
              child: const Text('No se han podido obtener los productos favoritos'),
            ),
            if(context.read<FavouriteItemsCubit>().state != null && context.read<FavouriteItemsCubit>().state!.isEmpty) Align(
              alignment: Alignment.center,
              child: Card(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 20,
                  ),
                  child: const Text(
                    '¡Añade negocios a favoritos para tener acceso a sus productos fácilmente!',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            if(context.read<FavouriteItemsCubit>().state != null && context.read<FavouriteItemsCubit>().state!.isNotEmpty) SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: context.read<FavouriteItemsCubit>().state!.map((ProductExpandedModel i) => ItemButton(
                  horizontalScroll: true,
                  productExpanded: i,
                  comebackBehaviour: () async {
                    await _retrieveFavourites();
                  },
                )).toList(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}