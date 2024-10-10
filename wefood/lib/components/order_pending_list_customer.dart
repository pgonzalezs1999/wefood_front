import 'package:flutter/material.dart';
import 'package:wefood/components/components.dart';
import 'package:wefood/models.dart';
import 'package:wefood/services/auth/api.dart';

class OrderPendingListCustomer extends StatefulWidget {

  const OrderPendingListCustomer({
    super.key,
  });

  @override
  State<OrderPendingListCustomer> createState() => _OrderPendingListCustomerState();
}

class _OrderPendingListCustomerState extends State<OrderPendingListCustomer> {
  Widget resultWidget = const LoadingIcon();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ProductExpandedModel>>(
      future: Api.getPendingOrdersCustomer(),
      builder: (BuildContext context, AsyncSnapshot<List<ProductExpandedModel>> response) {
        if(response.hasError) {
          resultWidget = Container(
            margin: EdgeInsets.symmetric(
              vertical: MediaQuery.of(context).size.height * 0.05,
            ),
            child: Text('Error: ${response.error}'),
          );
        } else if(response.hasData) {
          if(response.data!.isNotEmpty) {
            resultWidget = SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Column(
                    children: response.data!.map((ProductExpandedModel product) =>
                      OrderButton(
                        productExpanded: product,
                      )).toList(),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              )
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