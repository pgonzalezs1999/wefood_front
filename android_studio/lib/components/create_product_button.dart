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
          elevation: 2,
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
                  Expanded(
                    child: Text(
                      'Venda un producto en el horario de ${
                        (widget.productType == ProductType.breakfast) ? 'desayuno'
                        : (widget.productType == ProductType.lunch) ? 'almuerzo'
                        : 'cena'
                      }s',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  const SizedBox(
                    width: 35,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary,
                        width: 0.5,
                      ),
                      borderRadius: BorderRadius.circular(9999999),
                      color: Theme.of(context).colorScheme.surface.withOpacity(0.75),
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