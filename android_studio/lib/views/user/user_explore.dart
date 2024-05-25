import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wefood/blocs/blocs.dart';
import 'package:wefood/commands/call_request.dart';
import 'package:wefood/components/components.dart';
import 'package:wefood/services/auth/api.dart';
import 'package:wefood/models/models.dart';
import 'package:wefood/views/user/searched_items.dart';
import 'package:wefood/views/views.dart';

class UserExplore extends StatefulWidget {
  const UserExplore({super.key});

  @override
  State<UserExplore> createState() => _UserExploreState();
}

class _UserExploreState extends State<UserExplore> {

  double userLongitude = -77; // TODO deshardcodear
  double userLatitude = -12.5; // TODO deshardcodear
  Widget recommendedList = const LoadingIcon();
  Widget nearbyList =  const LoadingIcon();
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

  _retrieveRecommended() async {
    try {
      if(context.read<RecommendedItemsCubit>().state.isEmpty) {
        List<ProductExpandedModel> items = await Api.getRecommendedItems(
          longitude: userLongitude,
          latitude: userLatitude,
        );
        setState(() {
          context.read<RecommendedItemsCubit>().set(items);
        });
      }
      setState(() {
        recommendedList = Column(
          children: context.read<RecommendedItemsCubit>().state.map((ProductExpandedModel product) => ItemButton(
            productExpanded: product,
            comebackBehaviour: () async {
              await _retrieveFavourites();
            },
          )).toList(),
        );
      });
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
        List<ProductExpandedModel> items = await Api.getNearbyItems(
          longitude: userLongitude,
          latitude: userLatitude,
        );
        if(items.isEmpty) {
          setState(() {
            nearbyList = Align(
              alignment: Alignment.center,
              child: Card(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.05,
                    vertical: MediaQuery.of(context).size.width * 0.025,
                  ),
                  child: const Text('No hemos encontrado ofertas cerca...'),
                ),
              ),
            );
          });
        } else {
          setState(() {
            context.read<NearbyItemsCubit>().set(items);
          });
        }
      }
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
    _retrieveRecommended();
    _retrieveNearby();
    _retrieveFavourites();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if(context.read<FavouriteItemsCubit>().state != null) {
      print('FAVOURITE_CUBIT LENGTH: ${context.read<FavouriteItemsCubit>().state!.length}');
    }
    _retrieveFavourites();
    return WefoodNavigationScreen(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
          child: const LoadingIcon(),
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
    );
  }
}