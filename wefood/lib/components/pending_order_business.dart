import 'package:flutter/material.dart';
import 'package:wefood/commands/utils.dart';
import 'package:wefood/types.dart';

class PendingOrderBusiness extends StatefulWidget {

  final int id;
  final OrderReceptionMethod? receptionMethod;
  final bool isFirst;

  const PendingOrderBusiness({
    super.key,
    required this.id,
    this.receptionMethod,
    required this.isFirst,
  });

  @override
  State<PendingOrderBusiness> createState() => _PendingOrderBusinessState();
}

class _PendingOrderBusinessState extends State<PendingOrderBusiness> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: (widget.isFirst == true) ? const Border(
          top: BorderSide(
            width: 0.25,
          ),
        ) : null,
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
                Utils.numberToHexadecimal(widget.id),
                style: const TextStyle(
                  fontWeight: FontWeight.w900, // TODO deshardcodear estilo
                ),
              ),
              Text(' (${widget.id}):'),
            ],
          ),
          Text(
            (widget.receptionMethod != null) ? 'Entregado' : 'Pendiente',
            style: TextStyle(
              color: (widget.receptionMethod != null) ? Colors.green : Colors.red, // TODO deshardcodear por colores de Matthew
            ),
          ),
        ],
      ),
    );
  }
}
