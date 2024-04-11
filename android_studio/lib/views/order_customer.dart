import 'package:flutter/material.dart';
import 'package:wefood/components/back_arrow.dart';
import 'package:wefood/components/wefood_screen.dart';
import 'package:wefood/models/product_expanded_model.dart';
import 'package:wefood/services/auth/api/api.dart';
import 'package:wefood/views/loading_screen.dart';

class OrderCustomer extends StatefulWidget {

  final int id;

  const OrderCustomer({
    super.key,
    required this.id,
  });

  @override
  State<OrderCustomer> createState() => _OrderCustomerState();
}
class _OrderCustomerState extends State<OrderCustomer> {

  Widget resultWidget = const LoadingScreen();
  Widget favouriteIcon = const Icon(Icons.favorite_outline);
  late ProductExpandedModel info;
  int selectedAmount = 1;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ProductExpandedModel>(
      future: Api.getItem( // TODO ESTE ENDPOINT NO ES!!!!
        id: widget.id,
      ),
      builder: (BuildContext context, AsyncSnapshot<ProductExpandedModel> response) {
        if(response.hasError) {
          resultWidget = Container(
            margin: EdgeInsets.symmetric(
              vertical: MediaQuery.of(context).size.height * 0.05,
            ),
            child: const Text('Error'),
          );
        } else if(response.hasData) {
          info = response.data!;
          resultWidget = WefoodScreen(
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: <Widget>[
                    const BackArrow(
                      margin: EdgeInsets.zero,
                    ),
                    Text('Pedido con id ${widget.id}'),
                  ],
                )
              ],
            ),
          );
        }
        return resultWidget;
      }
    );
  }
}