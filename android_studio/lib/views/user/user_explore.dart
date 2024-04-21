import 'package:flutter/material.dart';
import 'package:wefood/components/components.dart';

class UserExplore extends StatefulWidget {
  const UserExplore({super.key});

  @override
  State<UserExplore> createState() => _UserExploreState();
}

class _UserExploreState extends State<UserExplore> {

  double userLongitude = -77; // TODO deshardcodear
  double userLatitude = -12.5; // TODO deshardcodear

  Widget recommendedList = const SizedBox();
  Widget nearbyList =  const SizedBox();
  Widget favouriteList = const SizedBox();

  _reloadLists() async {
    setState(() {
      recommendedList = ItemRecommendedList(
        longitude: userLongitude,
        latitude: userLatitude,
      );
      nearbyList = ItemNearbyList(
        longitude: userLongitude,
        latitude: userLatitude,
      );
      favouriteList = const ItemFavouriteList();
    });
  }

  Widget _exploreTitle(String title) {
    return Container(
      margin: const EdgeInsets.only(
        top: 20,
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
            // TODO falta esto
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