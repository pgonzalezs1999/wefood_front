import 'package:flutter/material.dart';
import 'package:wefood/commands/custom_parsers.dart';
import 'package:wefood/types.dart';

class PendingOrderBusiness extends StatefulWidget {

  final int id;
  final OrderReceptionMethod? receptionMethod;

  const PendingOrderBusiness({
    super.key,
    required this.id,
    this.receptionMethod,
  });

  @override
  State<PendingOrderBusiness> createState() => _PendingOrderBusinessState();
}

class _PendingOrderBusinessState extends State<PendingOrderBusiness> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            width: 0.25,
          ),
        ),
      ),
      margin: const EdgeInsets.symmetric(
        vertical: 10,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 15,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: <Text>[
              const Text('Pedido '),
              Text(
                CustomParsers.numberToHexadecimal(widget.id),
                style: const TextStyle(
                  fontWeight: FontWeight.w900, // TODO deshardcodear estilo
                ),
              ),
              const Text(':'),
            ],
          ),
          Text(widget.receptionMethod != null ? 'Entregado' : 'Pendiente'),
        ],
      ),
    );
  }
}
