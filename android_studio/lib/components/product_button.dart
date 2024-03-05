import 'package:flutter/material.dart';
import 'package:wefood/components/product_tag.dart';

class ProductButton extends StatefulWidget {

  final List<String>? tags;
  final bool isFavourite;
  final String title;
  final double rate;
  final double price;
  final String currency;
  final TimeOfDay startTime;
  final TimeOfDay endTime;

  const ProductButton({
    super.key,
    this.tags,
    required this.isFavourite,
    required this. title,
    required this.rate,
    required this.price,
    required this.currency,
    required this.startTime,
    required this.endTime,
  }) : assert(
    rate==0.5 || rate==1 || rate==1.5 || rate==2 || rate==2.5 || rate==3 || rate==3.5 || rate==4 || rate==4.5 || rate==5,
    'Rate must be one of: 0.5, 1, 1.5, 2, 2.5, 3, 3.5, 4, 4.5, or 5'
  );

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

    return SizedBox(
      height: 150,
      width: double.infinity,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            children: <Widget>[
              Image.asset(
                'assets/images/logo.jpg',
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
                        if(widget.tags != null) Row(
                          children: widget.tags!.map((tag) => ProductTag(title: tag)).toList(),
                        ),
                        if(widget.isFavourite == true) Container(
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
                      children: <Widget>[
                        Text(widget.title),
                        Text(
                          '${widget.rate}  |  '
                          '${widget.price} ${widget.currency}  |  '
                          '${widget.startTime.hour}:${widget.startTime.minute}h-${widget.endTime.hour}:${widget.endTime.minute}h'
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
    );
  }
}