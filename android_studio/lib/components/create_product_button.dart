import 'package:flutter/material.dart';
import 'package:wefood/types.dart';
import 'package:wefood/views/views.dart';

class CreateProductButton extends StatefulWidget {

  final ProductType productType;

  const CreateProductButton({
    super.key,
    required this.productType,
  });

  @override
  State<CreateProductButton> createState() => _CreateProductButtonState();
}

class _CreateProductButtonState extends State<CreateProductButton> {

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
            MaterialPageRoute(builder: (context) => CreateProductScreen(
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
            child: Container(
              margin: const EdgeInsets.symmetric(
                horizontal: 35,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  if(widget.productType == ProductType.breakfast) const Expanded(
                    child: Text('Vende un producto en el horario de desayunos'),
                  ),
                  if(widget.productType == ProductType.lunch) const Expanded(
                    child: Text('Vende un producto en el horario de almuerzos'),
                  ),
                  if(widget.productType == ProductType.dinner) const Expanded(
                    child: Text('Vende un producto en el horario de cenas'),
                  ),
                  const SizedBox(
                    width: 35,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(9999999),
                      color: Colors.grey.withOpacity(0.25),
                    ),
                    height: 80,
                    width: 80,
                    child: const Icon(
                      Icons.add,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}