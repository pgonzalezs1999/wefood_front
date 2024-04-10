import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:wefood/components/product_tag.dart';
import 'package:wefood/models/product_expanded_model.dart';
import 'package:wefood/commands/utils.dart';
import 'package:wefood/views/item.dart';

class ItemButton extends StatefulWidget {

  final ProductExpandedModel productExpanded;
  final bool? horizontalScroll;

  const ItemButton({
    super.key,
    this.horizontalScroll,
    required this.productExpanded,
  });

  @override
  State<ItemButton> createState() => _ItemButtonState();
}

class _ItemButtonState extends State<ItemButton> {

  @override
  void initState() {
    super.initState();
  }

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
          print('ABRIENDO PAGINA ITEM CON "ID" = ${widget.productExpanded.item!.id}');
          if(widget.productExpanded.item!.id != null) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Item(
                id: widget.productExpanded.item!.id!,
              )),
            );
          } else {
            print('ERA NULL');
          }
        },
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Container(
            decoration: BoxDecoration(
              image: const DecorationImage(
                image: AssetImage('assets/images/salmon.jpg'),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
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
                      if(widget.productExpanded.isFavourite == true) Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          color: Colors.white.withOpacity(0.5),
                        ),
                        padding: const EdgeInsets.all(5),
                        child: const Icon(Icons.favorite),
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
                              Text('${widget.productExpanded.business?.rate ?? 0} '),
                              const Icon(Icons.star, size: 15),
                              Text(' | ${widget.productExpanded.product!.price} Sol/. | '
                                  '${widget.productExpanded.product!.startingHour?.hour}:${widget.productExpanded.product!.startingHour?.minute}h-${widget.productExpanded.product!.endingHour?.hour}:${widget.productExpanded.product!.endingHour?.minute}h'
                              ),
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