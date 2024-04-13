import 'package:flutter/material.dart';
import 'package:wefood/commands/custom_parsers.dart';
import 'package:wefood/components/loading_icon.dart';
import 'package:wefood/components/pending_order_business.dart';
import 'package:wefood/models/order_model.dart';
import 'package:wefood/services/auth/api/api.dart';

class OrderPendingListBusiness extends StatefulWidget {

  const OrderPendingListBusiness({
    super.key,
  });

  @override
  State<OrderPendingListBusiness> createState() => _OrderPendingListBusinessState();
}

class _OrderPendingListBusinessState extends State<OrderPendingListBusiness> {
  Widget resultWidget = const LoadingIcon();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<OrderModel>>(
      future: Api.getPendingOrdersBusiness(),
      builder: (BuildContext context, AsyncSnapshot<List<OrderModel>> response) {
        if(response.hasError) {
          resultWidget = Container(
            margin: EdgeInsets.symmetric(
              vertical: MediaQuery.of(context).size.height * 0.05,
            ),
            child: const Text('Error'),
          );
        } else if(response.hasData) {
          if(response.data!.isNotEmpty) {
            resultWidget = SingleChildScrollView(
              child: Column(
                children: response.data!.map((OrderModel order) => PendingOrderBusiness(
                  id: order.id!,
                  receptionMethod: CustomParsers.stringToOrderReceptionMethod(order.receptionMethod),
                )).toList(),
              ),
            );
          }
          else {
            resultWidget = Align( // TODO poner algo más currado
              alignment: Alignment.center,
              child: Card(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.05,
                    vertical: MediaQuery.of(context).size.width * 0.025,
                  ),
                  child: const Text('¡Estás al día! Aquí aparecerán los productos que compres mientras aún puedas recogerlos'),
                ),
              ),
            );
          }
        }
        return resultWidget;
      }
    );
  }
}