import 'package:flutter/material.dart';
import 'package:wefood/components/loading_icon.dart';
import 'package:wefood/components/product_button.dart';
import 'package:wefood/models/product_expanded_model.dart';
import 'package:wefood/services/auth/api/api.dart';
import 'package:wefood/services/secure_storage.dart';

class ProductRecommendedList extends StatefulWidget {

  final double longitude;
  final double latitude;

  const ProductRecommendedList({
    super.key,
    required this.longitude,
    required this.latitude,
  });

  @override
  State<ProductRecommendedList> createState() => _ProductRecommendedListState();
}

class _ProductRecommendedListState extends State<ProductRecommendedList> {
  Widget resultWidget = const LoadingIcon();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ProductExpandedModel>>(
      future: Api.getRecommendedProducts(
        longitude: widget.longitude,
        latitude: widget.latitude,
      ),
      builder: (BuildContext context, AsyncSnapshot<List<ProductExpandedModel>> response) {
        if(response.hasError) {
          print('RECOMMENDED_LIST ERROR: ${response.error}');
          resultWidget = Container(
            margin: EdgeInsets.symmetric(
              vertical: MediaQuery.of(context).size.height * 0.05,
            ),
            child: const Text('Error'),
          );
        } else if(response.hasData) { // TODO devolver otra cosa si no hay cercanos o no nos da su ubi
          resultWidget = Column(
            children: response.data!.map((ProductExpandedModel product) => ProductButton(
              productExpanded: product,
            )).toList(),
          );
        }
        return resultWidget;
      }
    );
  }
}