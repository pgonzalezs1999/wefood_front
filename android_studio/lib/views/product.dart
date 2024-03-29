import 'package:flutter/material.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:wefood/components/comment.dart';
import 'package:wefood/components/back_arrow.dart';
import 'package:wefood/components/loading_icon.dart';
import 'package:wefood/components/product_tag.dart';
import 'package:wefood/components/wefood_screen.dart';
import 'package:wefood/environment.dart';
import 'package:wefood/models/comment_expanded_model.dart';
import 'package:wefood/models/favourite_model.dart';
import 'package:wefood/models/product_expanded_model.dart';
import 'package:wefood/services/auth/api/api.dart';
import 'package:wefood/views/loading_screen.dart';

class Product extends StatefulWidget {

  final int id;

  const Product({
    super.key,
    required this.id,
  });

  @override
  State<Product> createState() => _ProductState();
}


class _ProductState extends State<Product> {

  Widget resultWidget = const LoadingScreen();
  Widget favouriteIcon = const Icon(Icons.favorite_outline);
  late ProductExpandedModel info;

  _chooseFavouriteIcon(bool newState) {
    setState(() {
      if(newState == true) {
        info.isFavourite = true;
        favouriteIcon = const Icon(Icons.favorite);
      } else {
        info.isFavourite = false;
        favouriteIcon = const Icon(Icons.favorite_outline);
      }
    });
  }

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
            child: const Text('Error'),
          );
        } else if(response.hasData) {
          info = response.data!;
          resultWidget = WefoodScreen(
            ignoreHorizontalPadding: true,
            ignoreVerticalPadding: true,
            body: Column(
              children: [
                Container(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).viewPadding.top,
                  ),
                  width: MediaQuery.of(context).size.width,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/logo.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          const BackArrow(),
                          GestureDetector(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(999),
                                color: const Color.fromRGBO(255, 255, 255, 0.666),
                              ),
                              margin: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
                              padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.02),
                              child: (info.isFavourite == true)
                                ? const Icon(Icons.favorite)
                                : const Icon(Icons.favorite_outline),
                            ),
                            onTap: () async {
                              setState(() {
                                favouriteIcon = const LoadingIcon();
                              });
                              try {
                                late FavouriteModel favourite;
                                if(info.isFavourite == true) {
                                  _chooseFavouriteIcon(false);
                                  favourite = await Api.removeFavourite(idBusiness: info.business!.id!);
                                } else {
                                  _chooseFavouriteIcon(true);
                                  favourite = await Api.addFavourite(idBusiness: info.business!.id!);
                                }
                              } catch(e) {
                                _chooseFavouriteIcon(info.isFavourite!);
                              }
                            },
                          ),
                        ],
                      ),
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Color.fromRGBO(0, 0, 0, 0.666)],
                          ),
                        ),
                        child: Row(
                          children: <Widget>[
                            Container(
                              padding: const EdgeInsets.all(2),
                              margin: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(999),
                                child: SizedBox.fromSize(
                                  size: Size.fromRadius(MediaQuery.of(context).size.width * 0.05),
                                  child: Image.asset('assets/images/logo.jpg'),
                                ),
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                const Text(
                                  'Caja sorpresa de',
                                  style: TextStyle( // TODO deshardcodear estilo
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  info.business?.name ?? '',
                                  style: const TextStyle( // TODO deshardcodear estilo
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
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
                      SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                      Row(
                        children: <Widget>[
                          Text('Valoración: ${info.business?.rate}  '),
                        ] + _printStarts(info.business!.rate!),
                      ),
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

  Icon _chooseStarIcon({
    required double rate,
    required double step
  }) {
    IconData iconData = Icons.star_half;
    if(rate > step + 0.2) {
      iconData = Icons.star;
    } else if(rate < step - 0.2) {
      iconData = Icons.star_outline;
    }
    return Icon(
      iconData,
      size: 20,
    );
  }

  List<Widget> _printStarts(double rate) {
    List<Widget> result = [];
    result.add(_chooseStarIcon(rate: rate, step: 0.5));
    result.add(_chooseStarIcon(rate: rate, step: 1.5));
    result.add(_chooseStarIcon(rate: rate, step: 2.5));
    result.add(_chooseStarIcon(rate: rate, step: 3.5));
    result.add(_chooseStarIcon(rate: rate, step: 4.5));
    return result;
  }
}