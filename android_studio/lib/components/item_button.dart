import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:wefood/components/components.dart';
import 'package:wefood/models/models.dart';
import 'package:wefood/commands/utils.dart';
import 'package:wefood/views/views.dart';

enum NextScreen {
  item,
  orderCustomer,
}

class ItemButton extends StatefulWidget {

  final ProductExpandedModel productExpanded;
  final bool? horizontalScroll;
  final Function()? comebackBehaviour;

  const ItemButton({
    super.key,
    this.horizontalScroll,
    required this.productExpanded,
    this.comebackBehaviour,
  });

  @override
  State<ItemButton> createState() => _ItemButtonState();
}

class _ItemButtonState extends State<ItemButton> {
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
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Item(
              productExpanded: widget.productExpanded,
            )),
          ).whenComplete(() {
            (widget.comebackBehaviour != null) ? widget.comebackBehaviour!() : null;
          });
        },
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: SizedBox(
            height: 145,
            child: Stack(
              alignment: Alignment.topCenter,
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    height: 145,
                    child: (widget.productExpanded.image.route != null)
                    ? ImageWithLoader.network(
                      route: widget.productExpanded.image.route!,
                      fit: BoxFit.fitWidth,
                      width: double.infinity,
                    )
                    : Image(
                      image: const AssetImage('assets/images/logo.png'),
                      width: MediaQuery.of(context).size.width * 0.666,
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.only(
                        top: 10,
                        left: 10,
                        right: 12,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              if(widget.productExpanded.product.vegetarian == true) const ProductTag(title: 'Vegetariano'),
                              if(widget.productExpanded.product.mediterranean == true) const ProductTag(title: 'Mediterráneo'),
                              if(widget.productExpanded.product.junk == true) const ProductTag(title: 'C. rápida'),
                              if(widget.productExpanded.product.dessert == true) const ProductTag(title: 'Postres'),
                              if(widget.productExpanded.product.vegetarian == false && widget.productExpanded.product.mediterranean == false && widget.productExpanded.product.junk == false && widget.productExpanded.product.dessert == false) const Text(''),
                            ],
                          ),
                          if(widget.productExpanded.isFavourite == true) ClipRect(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(
                                sigmaX: 2,
                                sigmaY: 2,
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(999),
                                  color: Colors.white.withOpacity(0.66),
                                ),
                                padding: const EdgeInsets.all(5),
                                child: const Icon(
                                  Icons.favorite,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ClipRect(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(
                          sigmaX: 3,
                          sigmaY: 3,
                        ),
                        child: Container(
                          color: Colors.white.withOpacity(0.75),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          width: double.infinity,
                          child: Wrap(
                            runSpacing: -3,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Text>[
                                  Text('${Utils.productTypeCharToString(
                                    type: widget.productExpanded.product.type,
                                    isCapitalized: true,
                                  )} de'),
                                  if(widget.productExpanded.item.date != null) Text((widget.productExpanded.item.date!.day == DateTime.now().day) ? '(hoy)' : '(mañana)'),
                                ],
                              ),
                              Text(
                                widget.productExpanded.business.name ?? '',
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              Row(
                                children: [
                                  if(widget.productExpanded.business.rate != null) if(widget.productExpanded.business.rate! > 0) Row(
                                    children: <Widget>[
                                      const Icon(
                                        Icons.star,
                                        size: 15,
                                      ),
                                      Text(' ${widget.productExpanded.business.rate?.toStringAsFixed(1) ?? 0} | '),
                                    ],
                                  ),
                                  const Icon(
                                    Icons.price_change,
                                    size: 15,
                                  ),
                                  Text(' ${widget.productExpanded.product.price} Sol/. | '),
                                  const Icon(
                                    Icons.watch_later,
                                    size: 15,
                                  ),
                                  Text(' ${widget.productExpanded.product.startingHour?.hour}:${widget.productExpanded.product.startingHour?.minute}h - ${widget.productExpanded.product.endingHour?.hour}:${widget.productExpanded.product.endingHour?.minute}h'),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}