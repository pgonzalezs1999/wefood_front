import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wefood/blocs/blocs.dart';
import 'package:wefood/blocs/recommended_items_cubit.dart';
import 'package:wefood/components/components.dart';
import 'package:wefood/services/auth/api/api.dart';
import 'package:wefood/models/models.dart';
import 'package:wefood/types.dart';

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

  LoadingStatus _retrievingFavourites = LoadingStatus.unset;

  Widget _exploreTitle(String title) {
    return Container(
      margin: const EdgeInsets.only(
        top: 20,
      ),
      child: Text(title),
    );
  }

  _retrieveRecommended() async {
    try {
      if(context.read<RecommendedItemsCubit>().state.isEmpty) {
        List<ProductExpandedModel> items = await Api.getRecommendedItems(
          longitude: userLongitude,
          latitude: userLatitude,
        );
        for(int i=0; i<items.length; i++) {
          items[i].image = await Api.getImage(
            idUser: items[i].user.id!,
            meaning: '${items[i].product.type!.toLowerCase()}1',
          );
        }
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
          for(int i=0; i<items.length; i++) {
            items[i].image = await Api.getImage(
              idUser: items[i].user.id!,
              meaning: '${items[i].product.type!.toLowerCase()}1',
            );
          }
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
    setState(() {
      _retrievingFavourites = LoadingStatus.loading;
    });
    try {
    List<ProductExpandedModel> items = await Api.getFavouriteItems();
      for(int i=0; i<items.length; i++) {
        items[i].image = await Api.getImage(
          idUser: items[i].user.id!,
          meaning: '${items[i].product.type!.toLowerCase()}1',
        );
      }
      setState(() {
        context.read<FavouriteItemsCubit>().set(items);
        _retrievingFavourites = LoadingStatus.successful;
      });
    } catch(error) {
      setState(() {
        _retrievingFavourites = LoadingStatus.error;
      });
    }
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
    return WefoodNavigationScreen(
      children: <Widget>[
        SearchInput(
          onChanged: (value) {
            // TODO falta esto
          }
        ),
        _exploreTitle('Recomendados'),
        recommendedList,
        _exploreTitle('Cerca de tí'),
        nearbyList,
        _exploreTitle('Ofertas de tus favoritos'),
        if(_retrievingFavourites == LoadingStatus.loading) const LoadingIcon(),
        if(_retrievingFavourites == LoadingStatus.error) Container(
          margin: EdgeInsets.symmetric(
            vertical: MediaQuery.of(context).size.height * 0.05,
          ),
          child: const Text('Error'),
        ),
        if(_retrievingFavourites == LoadingStatus.successful && context.read<FavouriteItemsCubit>().state.isEmpty) Align(
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
        ),
        if(_retrievingFavourites == LoadingStatus.successful && context.read<FavouriteItemsCubit>().state.isNotEmpty) SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: context.read<FavouriteItemsCubit>().state.map((ProductExpandedModel i) => ItemButton(
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