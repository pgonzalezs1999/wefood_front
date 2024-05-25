import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wefood/blocs/blocs.dart';
import 'package:wefood/components/components.dart';
import 'package:wefood/models/models.dart';
import 'package:wefood/services/auth/api.dart';
import 'package:wefood/types.dart';

class FavouritesScreen extends StatefulWidget {
  const FavouritesScreen({super.key});

  @override
  State<FavouritesScreen> createState() => _FavouritesScreenState();
}

class _FavouritesScreenState extends State<FavouritesScreen> {

  LoadingStatus _retrievingFavourites = LoadingStatus.unset;

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
    if(context.read<FavouriteItemsCubit>().state == null || context.read<FavouriteItemsCubit>().needsRefresh == true) {
      _retrieveFavourites();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WefoodScreen(
      title: 'Productos de mis favoritos',
      body: [
        if(_retrievingFavourites == LoadingStatus.loading) Container(
          margin: const EdgeInsets.only(
            left: 10,
          ),
          child: const LoadingIcon(),
        ),
        if(_retrievingFavourites == LoadingStatus.error) Container(
          margin: EdgeInsets.symmetric(
            vertical: MediaQuery.of(context).size.height * 0.05,
          ),
          child: const Text('Error'),
        ),
        if(_retrievingFavourites == LoadingStatus.successful && context.read<FavouriteItemsCubit>().state!.isEmpty) Align(
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
        if((_retrievingFavourites == LoadingStatus.unset || _retrievingFavourites == LoadingStatus.successful) && context.read<FavouriteItemsCubit>().state!.isNotEmpty) Column(
          children: context.read<FavouriteItemsCubit>().state!.map((ProductExpandedModel i) => ItemButton(
            productExpanded: i,
            comebackBehaviour: () async {
              await _retrieveFavourites();
            },
          )).toList(),
        ),
        const SizedBox(
          height: 20,
        ),
      ],
    );
  }
}