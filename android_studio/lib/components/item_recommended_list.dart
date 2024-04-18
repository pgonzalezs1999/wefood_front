import 'package:flutter/material.dart';
import 'package:wefood/components/loading_icon.dart';
import 'package:wefood/components/item_button.dart';
import 'package:wefood/models/product_expanded_model.dart';
import 'package:wefood/services/auth/api/api.dart';

class ItemRecommendedList extends StatefulWidget {

  final double longitude;
  final double latitude;

  const ItemRecommendedList({
    super.key,
    required this.longitude,
    required this.latitude,
  });

  @override
  State<ItemRecommendedList> createState() => _ItemRecommendedListState();
}

class _ItemRecommendedListState extends State<ItemRecommendedList> {
  Widget resultWidget = const LoadingIcon();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ProductExpandedModel>>(
      future: Api.getRecommendedItems(
        longitude: widget.longitude,
        latitude: widget.latitude,
      ),
      builder: (BuildContext context, AsyncSnapshot<List<ProductExpandedModel>> response) {
        if(response.hasError) {
          resultWidget = Container(
            margin: EdgeInsets.symmetric(
              vertical: MediaQuery.of(context).size.height * 0.05,
            ),
            child: Text('Error ${response.error}'),
          );
          print('------------> ${response.error}');
        } else if(response.hasData) { // TODO devolver otra cosa si no hay cercanos o no nos da su ubi
          resultWidget = Column(
            children: response.data!.map((ProductExpandedModel product) => ItemButton(
              productExpanded: product,
            )).toList(),
          );
        }
        return resultWidget;
      }
    );
  }
}