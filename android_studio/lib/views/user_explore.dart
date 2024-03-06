import 'package:flutter/material.dart';
import 'package:wefood/components/product_favourite_list.dart';
import 'package:wefood/components/product_button.dart';
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
    return WefoodNavigationScreen(
      children: <Widget>[
        SearchInput(
            onChanged: (value) {

            }
        ),
        _exploreTitle('Recomendados'),
        const ProductRecommendedList(
          longitude: -77,
          latitude: -12.5,
        ), // TODO deshardcodear longitud y latitud
        _exploreTitle('Cerca de tí'), // TODO que esto no exista si no tenemos su ubicación
        const ProductNearbyList(
            longitude: -77,
            latitude: -12.5,
        ), // TODO deshardcodear longitud y latitud
        _exploreTitle('Tus favoritos'), // TODO que esto no exista si no tiene nada en favoritos
        const ProductFavouriteList(),
      ],
    );
  }
}