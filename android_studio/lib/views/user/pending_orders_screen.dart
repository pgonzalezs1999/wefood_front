import 'package:flutter/material.dart';
import 'package:wefood/components/back_arrow.dart';
import 'package:wefood/components/order_pending_list.dart';
import 'package:wefood/components/wefood_screen.dart';

class PendingOrdersScreen extends StatefulWidget {
  const PendingOrdersScreen({super.key});

  @override
  State<PendingOrdersScreen> createState() => _PendingOrdersScreenState();
}

class _PendingOrdersScreenState extends State<PendingOrdersScreen> {

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
          OrderPendingList(),
        ],
      ),
    );
  }
}