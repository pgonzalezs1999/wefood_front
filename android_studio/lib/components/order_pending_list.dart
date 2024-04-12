import 'package:flutter/material.dart';
import 'package:wefood/components/loading_icon.dart';
import 'package:wefood/components/item_button.dart';
import 'package:wefood/models/product_expanded_model.dart';
import 'package:wefood/services/auth/api/api.dart';

class OrderPendingList extends StatefulWidget {

  const OrderPendingList({
    super.key,
  });

  @override
  State<OrderPendingList> createState() => _OrderPendingListState();
}

class _OrderPendingListState extends State<OrderPendingList> {
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
            child: const Text('Error'),
          );
        } else if(response.hasData) {
          if(response.data!.isNotEmpty) {
            resultWidget = SingleChildScrollView(
              child: Column(
                children: response.data!.map((ProductExpandedModel product) =>
                  ItemButton(
                    horizontalScroll: false,
                    productExpanded: product,
                    nextScreen: NextScreen.orderCustomer,
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