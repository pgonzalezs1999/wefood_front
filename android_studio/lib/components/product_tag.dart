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
    switch(widget.title) {
      case 'Vegetariano': Icons.energy_savings_leaf;
      break;
      case 'Vegano': Icons.nature;
      break;
      case 'Bollería': Icons.free_breakfast;
      break;
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Colors.white.withOpacity(0.8),
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