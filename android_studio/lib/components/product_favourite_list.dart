import 'package:flutter/material.dart';
import 'package:wefood/components/loading_icon.dart';
import 'package:wefood/components/product_button.dart';
import 'package:wefood/models/product_expanded_model.dart';
import 'package:wefood/services/auth/api/api.dart';

class ProductFavouriteList extends StatefulWidget {
  const ProductFavouriteList({super.key});

  @override
  State<ProductFavouriteList> createState() => _ProductFavouriteListState();
}

class _ProductFavouriteListState extends State<ProductFavouriteList> {
  Widget resultWidget = const LoadingIcon();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ProductExpandedModel>>(
      future: Api.getFavouriteProducts(),
      builder: (BuildContext context, AsyncSnapshot<List<ProductExpandedModel>> response) {
        if(response.hasError) {
          print('ERROR EN FAV_LIST: ${response.error}');
          resultWidget = Container(
            margin: EdgeInsets.symmetric(
              vertical: MediaQuery.of(context).size.height * 0.05,
            ),
            child: const Text('Error'),
          );
        } else if(response.hasData) { // TODO devolver otra cosa si no hay favoritos
          resultWidget = SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: response.data!.map((ProductExpandedModel product) => ProductButton(
                horizontalScroll: true,
                productExpanded: product,
              )).toList(),
            ),
          );
        }
        return resultWidget;
      }
    );
  }
}