import 'package:flutter/material.dart';
import 'package:wefood/components/loading_icon.dart';
import 'package:wefood/components/item_button.dart';
import 'package:wefood/models/product_expanded_model.dart';
import 'package:wefood/services/auth/api/api.dart';

class ItemNearbyList extends StatefulWidget {

  final double longitude;
  final double latitude;

  const ItemNearbyList({
    super.key,
    required this.longitude,
    required this.latitude,
  });

  @override
  State<ItemNearbyList> createState() => _ItemNearbyListState();
}

class _ItemNearbyListState extends State<ItemNearbyList> {
  Widget resultWidget = const LoadingIcon();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ProductExpandedModel>>(
      future: Api.getNearbyItems(
        longitude: widget.longitude,
        latitude: widget.latitude,
      ),
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
              scrollDirection: Axis.horizontal,
              child: Row(
                children: response.data!.map((ProductExpandedModel product) => ItemButton(
                  horizontalScroll: true,
                  productExpanded: product,
                )).toList(),
              ),
            );
          } else { // TODO currárselo un poco más
            resultWidget = Align(
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
          }
        }
        return resultWidget;
      }
    );
  }
}