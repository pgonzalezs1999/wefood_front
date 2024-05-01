import 'package:flutter/material.dart';
import 'package:wefood/components/components.dart';

class FavouritesScreen extends StatefulWidget {
  const FavouritesScreen({super.key});

  @override
  State<FavouritesScreen> createState() => _FavouritesScreenState();
}

class _FavouritesScreenState extends State<FavouritesScreen> {

  @override
  Widget build(BuildContext context) {
    return const WefoodScreen(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BackUpBar(
            title: 'Productos de mis favoritos',
          ),
          ItemFavouriteList(
            axis: Axis.vertical,
          ),
        ],
      ),
    );
  }
}