import 'package:flutter/material.dart';
import 'package:wefood/components/components.dart';

class PendingOrdersCustomer extends StatefulWidget {
  const PendingOrdersCustomer({super.key});

  @override
  State<PendingOrdersCustomer> createState() => _PendingOrdersCustomerState();
}

class _PendingOrdersCustomerState extends State<PendingOrdersCustomer> {

  @override
  Widget build(BuildContext context) {
    return const WefoodScreen(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: <Widget>[
              BackArrow(
                margin: EdgeInsets.zero,
              ),
              Text('Pedidos pendientes'),
            ],
          ),
          OrderPendingListCustomer(),
        ],
      ),
    );
  }
}