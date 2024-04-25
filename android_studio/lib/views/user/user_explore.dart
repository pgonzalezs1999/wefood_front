import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wefood/blocs/recommended_items_cubit.dart';
import 'package:wefood/components/components.dart';
import 'package:wefood/services/auth/api/api.dart';
import 'package:wefood/models/models.dart';

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
  Widget favouriteList = const LoadingIcon();

  _reloadLists() async {
    setState(() {
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

  _retrieveRecommended() async {
    try {
      if(context.read<RecommendedItemsCubit>().state.isEmpty) {
        Api.getRecommendedItems(
          longitude: userLongitude,
          latitude: userLatitude,
        ).then((List<ProductExpandedModel> list) {
          context.read<RecommendedItemsCubit>().set(list);
          setState(() {
            recommendedList = Column(
              children: context.read<RecommendedItemsCubit>().state.map((ProductExpandedModel i) {
                Api.getImage(
                  idUser: i.user.id!,
                  meaning: '${i.product.type!.toLowerCase()}1',
                ).then((ImageModel image) {
                  setState(() {
                    context.read<RecommendedItemsCubit>().setImageById(
                      itemId: i.item.id!,
                      imageModel: image,
                    );
                    print('EL PRIMER PRODUCT_EXPANDED QUEDA:');
                    ProductExpandedModel.printInfo(context.read<RecommendedItemsCubit>().state.first);
                  });
                });
                return ItemButton(
                  productExpanded: i,
                );
              }).toList(),
            );
          });
        });
      } else {
        setState(() {
          recommendedList = Column(
            children: context.read<RecommendedItemsCubit>().state.map((ProductExpandedModel product) => ItemButton(
              productExpanded: product,
            )).toList(),
          );
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

  @override
  void initState() {
    _retrieveRecommended();
    super.initState();
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