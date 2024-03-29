import 'package:flutter/material.dart';
import 'package:wefood/commands/share_app.dart';
import 'package:wefood/components/back_arrow.dart';
import 'package:wefood/components/product_favourite_list.dart';
import 'package:wefood/components/profile_name.dart';
import 'package:wefood/components/settings_element.dart';
import 'package:wefood/components/wefood_navigation_screen.dart';
import 'package:wefood/components/wefood_popup.dart';
import 'package:wefood/components/wefood_screen.dart';
import 'package:wefood/main.dart';
import 'package:wefood/services/auth/api/api.dart';
import 'package:wefood/services/secure_storage.dart';
import 'package:wefood/views/terms_and_conditions.dart';

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
          Row(
            children: <Widget>[
              BackArrow(
                margin: EdgeInsets.zero,
              ),
              Text('Mis productos favoritos'),
            ],
          ),
          ProductFavouriteList(
            axis: Axis.vertical,
          ),
        ],
      ),
    );
  }
}