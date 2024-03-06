import 'package:flutter/material.dart';
import 'package:wefood/components/loading_icon.dart';
import 'package:wefood/components/product_button.dart';
import 'package:wefood/models/explore_model.dart';
import 'package:wefood/services/auth/api/api.dart';

class ProductNearbyList extends StatefulWidget {

  final double longitude;
  final double latitude;

  const ProductNearbyList({
    super.key,
    required this.longitude,
    required this.latitude,
  });

  @override
  State<ProductNearbyList> createState() => _ProductNearbyListState();
}

class _ProductNearbyListState extends State<ProductNearbyList> {
  Widget resultWidget = const LoadingIcon();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ExploreModel>>(
      future: Api.getNearbyBusinesses(
        longitude: widget.longitude,
        latitude: widget.latitude,
      ),
      builder: (BuildContext context, AsyncSnapshot<List<ExploreModel>> response) {
        if(response.hasError) {
          print('NEARBY_LIST ERROR: ${response.error}');
          resultWidget = Container(
            margin: EdgeInsets.symmetric(
              vertical: MediaQuery.of(context).size.height * 0.05,
            ),
            child: const Text('Error'),
          );
        } else if(response.hasData) { // TODO devolver otra cosa si no hay cercanos o no nos da su ubi
          resultWidget = SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: response.data!.map((ExploreModel product) => ProductButton(
                isFavourite: product.isFavourite,
                title: product.title,
                rate: product.rate,
                price: product.price,
                currency: 'Sol/.', // TODO automatizar campo
                startTime: product.startTime,
                endTime: product.endTime,
                tags: _categoriesToTags(product: product),
                horizontalScroll: true,
              )).toList(),
            ),
          );
        }
        return resultWidget;
      }
    );
  }

  static List<String> _categoriesToTags({
    required ExploreModel product,
  }) {
    List<String> tags = [];
    if(product.vegetarian == true) {
      tags.add('Vegetariano');
    }
    if(product.vegan == true) {
      tags.add('Vegano');
    }
    if(product.bakery == true) {
      tags.add('Bollería');
    }
    if(product.fresh == true) {
      tags.add('Frescos');
    }
    return tags;
  }
}