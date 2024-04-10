import 'package:flutter/material.dart';
import 'package:wefood/components/loading_icon.dart';
import 'package:wefood/components/item_button.dart';
import 'package:wefood/models/product_expanded_model.dart';
import 'package:wefood/services/auth/api/api.dart';

class ItemFavouriteList extends StatefulWidget {

  final Axis axis;

  const ItemFavouriteList({
    super.key,
    this.axis = Axis.horizontal,
  });

  @override
  State<ItemFavouriteList> createState() => _ItemFavouriteListState();
}

class _ItemFavouriteListState extends State<ItemFavouriteList> {
  Widget resultWidget = const LoadingIcon();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ProductExpandedModel>>(
      future: Api.getFavouriteItems(),
      builder: (BuildContext context, AsyncSnapshot<List<ProductExpandedModel>> response) {
        if(response.hasError) {
          resultWidget = Container(
            margin: EdgeInsets.symmetric(
              vertical: MediaQuery.of(context).size.height * 0.05,
            ),
            child: const Text('Error'),
          );
        } else if(response.hasData) {
          if(response.data!.isNotEmpty) {
            resultWidget = SingleChildScrollView(
              scrollDirection: widget.axis,
              child: (widget.axis == Axis.horizontal)
                ? Row(
                  children: response.data!.map((ProductExpandedModel product) =>
                    ItemButton(
                      horizontalScroll: true,
                      productExpanded: product,
                    )).toList(),
                  )
                : Column(
                  children: response.data!.map((ProductExpandedModel product) =>
                    ItemButton(
                      horizontalScroll: false,
                      productExpanded: product,
                    )).toList(),
                  ),
            );
          }
          else {
            resultWidget = Align( // TODO poner algo más currado
              alignment: Alignment.center,
              child: Card(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.05,
                    vertical: MediaQuery.of(context).size.width * 0.025,
                  ),
                  child: const Text('¡Añade productos a favoritos para encontrarlos más fácilmente!'),
                ),
              ),
            );
          }
        }
        return resultWidget;
      }
    );
  }
}