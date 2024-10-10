import 'package:flutter/material.dart';
import 'package:wefood/commands/utils.dart';
import 'package:wefood/models.dart';

class Retribution extends StatefulWidget {

  final RetributionModel retribution;
  final bool isFirst;

  const Retribution({
    super.key,
    required this.retribution,
    this.isFirst = false,
  });

  @override
  State<Retribution> createState() => _RetributionsState();
}

class _RetributionsState extends State<Retribution> {

  String _statusIntToMeaning(int status) {
    switch(status) {
      case 1:
        return 'En proceso';
      break;
      case 2:
        return 'Enviada';
      break;
      case 3:
        return 'Error';
      break;
      default:
        return 'Futuro';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: (!widget.isFirst) ?
            const BorderSide(
              width: 0.25,
            ) : BorderSide.none,
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 15,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Text('Transferencia: '),
              Text(
                '${widget.retribution.transferId}',
                style: const TextStyle(
                  fontWeight: FontWeight.w900, // TODO deshardcodear estilo
                ),
              ),
            ],
          ),
          Text('Cantidad: ${widget.retribution.amount} S/.'),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'Estado: ${_statusIntToMeaning(widget.retribution.status ?? 0)}',
              ),
              Text(
                '${Utils.dateTimeToString(
                  date: widget.retribution.date,
                  showTime: false,
                )}',
                textAlign: TextAlign.right,
              ),
            ]
          ),
        ],
      ),
    );
  }
}
