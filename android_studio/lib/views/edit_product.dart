import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:wefood/components/comment.dart';
import 'package:wefood/components/back_arrow.dart';
import 'package:wefood/components/product_tag.dart';
import 'package:wefood/components/wefood_screen.dart';
import 'package:wefood/environment.dart';
import 'package:wefood/models/comment_expanded_model.dart';
import 'package:wefood/models/product_expanded_model.dart';
import 'package:wefood/services/auth/api/api.dart';
import 'package:wefood/views/loading_screen.dart';

class EditProduct extends StatefulWidget {

  final int id;

  const EditProduct({
    super.key,
    required this.id,
  });

  @override
  State<EditProduct> createState() => _EditProductState();
}


class _EditProductState extends State<EditProduct> {

  Widget resultWidget = const LoadingScreen();
  Widget favouriteIcon = const Icon(Icons.favorite_outline);
  late ProductExpandedModel info;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ProductExpandedModel>(
      future: Api.getProduct(
        id: widget.id,
      ),
      builder: (BuildContext context, AsyncSnapshot<ProductExpandedModel> response) {
        if(response.hasError) {
          resultWidget = Container(
            margin: EdgeInsets.symmetric(
              vertical: MediaQuery.of(context).size.height * 0.05,
            ),
            child: Text('${response.error}'),
          );
        } else if(response.hasData) {
          info = response.data!;
          resultWidget = WefoodScreen(
            body: Column(
              children: [
                Container(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).viewPadding.top,
                  ),
                  width: MediaQuery.of(context).size.width,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      BackArrow(
                        margin: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * Environment.defaultHorizontalMargin,
                    vertical: MediaQuery.of(context).size.width * Environment.defaultHorizontalMargin,
                  ),
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      if(info.business!.description != null) Text(info.business!.description!),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                      Text('Precio: ${info.product!.price} Sol/.'),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                      Text('Hora de recogida: De ${_parseTime(info.product!.startingHour)} a ${_parseTime(info.product!.endingHour)} h'),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text('Ubicación: ${info.business?.directions}'),
                          Card(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(999),
                              ),
                              padding: const EdgeInsets.all(10),
                              child: GestureDetector(
                                child: const Icon(Icons.location_pin),
                                onTap: () {
                                  MapsLauncher.launchQuery(info.business!.directions ?? '');
                                },
                              ),
                            ),
                          )
                        ],
                      ),
                      if(info.product!.vegetarian == true || info.product!.vegan == true || info.product!.bakery == true || info.product!.fresh == true) Column(
                        children: <Widget>[
                          const Text('Categoría:'),
                          SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          if(info.product!.vegetarian == true) const ProductTag(title: 'Vegetariano'),
                          if(info.product!.vegan == true) const ProductTag(title: 'Vegano'),
                          if(info.product!.bakery == true) const ProductTag(title: 'Bollería'),
                          if(info.product!.fresh == true) const ProductTag(title: 'Frescos'),
                        ],
                      ),
                      const Divider(),
                      Container(
                        margin: EdgeInsets.symmetric(
                          vertical: MediaQuery.of(context).size.height * 0.02,
                        ),
                        child: Center(
                          child: ElevatedButton(
                            child: const Text('COMPRAR'),
                            onPressed: () {

                            },
                          ),
                        ),
                      ),
                      const Divider(),
                      const Text('¿Qué opinan los compradores?'),
                      if(info.business?.comments != null && info.business!.comments!.isNotEmpty) Column(
                        children: info.business!.comments!.map((CommentExpandedModel c) => Comment(comment: c)).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
        return resultWidget;
      }
    );
  }

  String _parseTime(DateTime? dateTime) {
    if(dateTime == null) {
      return '[No data]';
    } else {
      String timeRaw = dateTime.toString().split(' ')[1];
      String time = timeRaw.split('.')[0];
      String result = '${time.split(":")[0]}:${time.split(":")[1]}';
      return result;
    }
  }
}