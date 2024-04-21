import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:wefood/components/product_tag.dart';
import 'package:wefood/models/image_model.dart';
import 'package:wefood/models/product_expanded_model.dart';
import 'package:wefood/commands/utils.dart';
import 'package:wefood/services/auth/api/api.dart';
import 'package:wefood/views/item.dart';
import 'package:wefood/views/order_customer.dart';

enum NextScreen {
  item,
  orderCustomer,
}

class ItemButton extends StatefulWidget {

  final ProductExpandedModel productExpanded;
  final bool? horizontalScroll;
  final NextScreen? nextScreen;

  const ItemButton({
    super.key,
    this.horizontalScroll,
    required this.productExpanded,
    this.nextScreen = NextScreen.item,
  });

  @override
  State<ItemButton> createState() => _ItemButtonState();
}

class _ItemButtonState extends State<ItemButton> {

  void retrieveData() async {
    ImageModel? imageModel = await Api.getImage(
      idUser: widget.productExpanded.user!.id!,
      meaning: '${widget.productExpanded.product!.type!.toLowerCase()}1',
    );
    setState(() {
      imageUrl = imageModel?.image;
    });
  }

  @override
  void initState() {
    retrieveData();
    super.initState();
  }

  String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: (widget.horizontalScroll == true)
        ? MediaQuery.of(context).size.width * 0.8
        : MediaQuery.of(context).size.width,
      margin: const EdgeInsets.only(
        top: 10,
      ),
      padding: (widget.horizontalScroll == true)
        ? const EdgeInsets.only(right: 10)
        : null,
      child: GestureDetector(
        onTap: () {
          if(widget.nextScreen == NextScreen.item) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Item(
                id: widget.productExpanded.item!.id!,
              )),
            );
          } else if(widget.nextScreen == NextScreen.orderCustomer) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => OrderCustomer(
                id: widget.productExpanded.order!.id!,
              )),
            );
          }
        },
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Container(
            decoration: (imageUrl != null)
              ? BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(imageUrl!),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(10),
              )
              : null,
            child: Column(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.only(
                    top: 10,
                    bottom: 10,
                    left: 10,
                    right: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          if(widget.productExpanded.product!.vegetarian == true) const ProductTag(title: 'Vegetariano'),
                          if(widget.productExpanded.product!.vegan == true) const ProductTag(title: 'Vegano'),
                          if(widget.productExpanded.product!.bakery == true) const ProductTag(title: 'Bollería'),
                          if(widget.productExpanded.product!.fresh == true) const ProductTag(title: 'Frescos'),
                          if(widget.productExpanded.product!.vegetarian == false && widget.productExpanded.product!.vegan == false && widget.productExpanded.product!.bakery == false && widget.productExpanded.product!.fresh == false) const Text(''),
                        ],
                      ),
                      if(widget.productExpanded.isFavourite == true) ClipRect(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(
                            sigmaX: 8,
                            sigmaY: 8,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(999),
                              color: Colors.white.withOpacity(0.66),
                            ),
                            padding: const EdgeInsets.all(5),
                            child: const Icon(Icons.favorite),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: 8,
                      sigmaY: 8,
                    ),
                    child: Container(
                      color: Colors.white.withOpacity(0.75),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      width: double.infinity,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Text>[
                              Text('${Utils.productTypeCharToString(
                                type: widget.productExpanded.product?.type,
                                isCapitalized: true,
                              )} de'),
                              if(widget.productExpanded.item?.date != null) Text((widget.productExpanded.item?.date?.day == DateTime.now().day) ? '(hoy)' : '(mañana)'),
                            ],
                          ),
                          Text(
                            widget.productExpanded.business?.name ?? '',
                            style: const TextStyle(fontWeight: FontWeight.w600), // TODO deshardcodear este estilo
                          ),
                          Row(
                            children: [
                              if(widget.productExpanded.business?.rate != null) if(widget.productExpanded.business!.rate! > 0) Row(
                                children: <Widget>[
                                  const Icon(
                                    Icons.star,
                                    size: 15,
                                  ),
                                  Text(' ${widget.productExpanded.business?.rate ?? 0} | '),
                                ],
                              ),
                              const Icon(
                                Icons.price_change,
                                size: 15,
                              ),
                              Text(' ${widget.productExpanded.product!.price} Sol/. | '),
                              const Icon(
                                Icons.watch_later,
                                size: 15,
                              ),
                              Text(' ${widget.productExpanded.product!.startingHour?.hour}:${widget.productExpanded.product!.startingHour?.minute}h - ${widget.productExpanded.product!.endingHour?.hour}:${widget.productExpanded.product!.endingHour?.minute}h'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}