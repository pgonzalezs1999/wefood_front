import 'package:flutter/material.dart';

class ProductTag extends StatefulWidget {

  final String title;

  const ProductTag({
    super.key,
    required this.title,
});

  @override
  State<ProductTag> createState() => _ProductTagState();
}

class _ProductTagState extends State<ProductTag> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    IconData icon = Icons.hide_source;
    switch(widget.title) { // TODO poner iconos con mas sentido
      case 'Vegetariano': icon = Icons.energy_savings_leaf;
      break;
      case 'Vegano': icon = Icons.nature;
      break;
      case 'Bollería': icon = Icons.free_breakfast;
      break;
      case 'Frescos': icon = Icons.ac_unit;
      break;
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black,
          width: 0.25,
        ),
        borderRadius: BorderRadius.circular(999),
        color: Colors.white.withOpacity(0.75),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 3,
      ),
      margin: const EdgeInsets.only(
        right: 10,
        bottom: 10,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon),
          const SizedBox(
            width: 5,
          ),
          Text(widget.title),
        ],
      ),
    );
  }
}