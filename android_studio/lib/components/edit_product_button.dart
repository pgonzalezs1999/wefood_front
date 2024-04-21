import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:wefood/models/models.dart';
import 'package:wefood/types.dart';
import 'package:wefood/views/views.dart';

class EditProductButton extends StatefulWidget {

  final ProductModel product;
  final ProductType productType;

  const EditProductButton({
    super.key,
    required this.product,
    required this.productType,
  });

  @override
  State<EditProductButton> createState() => _EditProductButtonState();
}

class _EditProductButtonState extends State<EditProductButton> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      width: MediaQuery.of(context).size.width,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => EditProduct(
              productId: widget.product.id,
              productType: widget.productType,
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
              alignment: Alignment.center,
              children: <Widget>[
                Image.asset(
                  'assets/images/salmon.jpg',
                  fit: BoxFit.fitWidth,
                  width: double.infinity,
                ),
                Container(
                  color: Colors.white.withOpacity(0.66),
                  width: double.infinity,
                  height: double.infinity,
                ),
                ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: 3,
                      sigmaY: 3,
                    ),
                    child: Container(
                      height: double.infinity,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 35,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          if(widget.productType == ProductType.breakfast) const Expanded(
                            child: Text('Edite sus desayunos'),
                          ),
                          if(widget.productType == ProductType.lunch) const Expanded(
                            child: Text('Edite sus almuerzos'),
                          ),
                          if(widget.productType == ProductType.dinner) const Expanded(
                            child: Text('Edite sus cenas'),
                          ),
                          const SizedBox(
                            width: 35,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(9999999),
                              color: Colors.grey.withOpacity(0.5),
                            ),
                            height: 80,
                            width: 80,
                            child: const Icon(
                              Icons.edit,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}