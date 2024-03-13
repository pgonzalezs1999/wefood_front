import 'package:flutter/material.dart';
import 'package:wefood/components/product_favourite_list.dart';
import 'package:wefood/components/product_nearby_list.dart';
import 'package:wefood/components/product_recommended_list.dart';
import 'package:wefood/components/search_input.dart';
import 'package:wefood/components/wefood_navigation_screen.dart';

class UserExplore extends StatefulWidget {
  const UserExplore({super.key});

  @override
  State<UserExplore> createState() => _UserExploreState();
}

class _UserExploreState extends State<UserExplore> {

  Widget recommendedList = const ProductRecommendedList(
    longitude: -77,
    latitude: -12.5,
  ); // TODO deshardcodear longitud y latitud
  Widget nearbyList = const ProductNearbyList(
  longitude: -77,
  latitude: -12.5,
  ); // TODO deshardcodear longitud y latitud
  Widget favouriteList = const ProductFavouriteList();

  _reloadLists() async {
    setState(() {
      recommendedList = const ProductRecommendedList(
        longitude: -77,
        latitude: -12.5,
      ); // TODO deshardcodear longitud y latitud
      nearbyList = const ProductNearbyList(
        longitude: -77,
        latitude: -12.5,
      ); // TODO deshardcodear longitud y latitud
      favouriteList = const ProductFavouriteList();
    });
  }

  Widget _exploreTitle(String title) {
    return Container(
      margin: const EdgeInsets.only(
        top: 20,
        bottom: 10,
      ),
      child: Text(title),
    );
  }

  @override
  Widget build(BuildContext context) {
    _reloadLists();

    return WefoodNavigationScreen(
      children: <Widget>[
        SearchInput(
            onChanged: (value) {

            }
        ),
        _exploreTitle('Recomendados'),
        recommendedList,
        _exploreTitle('Cerca de tí'),
        nearbyList,
        _exploreTitle('Ofertas de tus favoritos'),
        favouriteList,
      ],
    );
  }
}