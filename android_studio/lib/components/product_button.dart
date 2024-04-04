import 'package:flutter/material.dart';
import 'package:wefood/components/product_tag.dart';
import 'package:wefood/models/product_expanded_model.dart';
import 'package:wefood/views/product.dart';

class ProductButton extends StatefulWidget {

  final ProductExpandedModel productExpanded;
  final bool? horizontalScroll;

  const ProductButton({
    super.key,
    this.horizontalScroll,
    required this.productExpanded,
  });

  @override
  State<ProductButton> createState() => _ProductButtonState();
}

class _ProductButtonState extends State<ProductButton> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      width: (widget.horizontalScroll == true)
        ? MediaQuery.of(context).size.width * 0.8
        : MediaQuery.of(context).size.width,
      padding: (widget.horizontalScroll == true)
        ? const EdgeInsets.only(right: 10)
        : null,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Product(
                id: widget.productExpanded.product!.id,
            )),
          );
        },
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Stack(
              children: <Widget>[
                Image.asset(
                  'assets/images/salmon.jpg',
                  fit: BoxFit.fitWidth,
                  width: double.infinity,
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
                    Container(
                      color: Colors.white.withOpacity(0.8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      width: double.infinity,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.productExpanded.business?.name ?? ''),
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