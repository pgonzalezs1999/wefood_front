import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wefood/blocs/blocs.dart';
import 'package:wefood/components/components.dart';
import 'package:wefood/models/models.dart';
import 'package:wefood/services/auth/api.dart';
import 'package:wefood/types.dart';

class History extends StatefulWidget {
  const History({super.key});

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {

  bool askedToRetrieve = false;
  LoadingStatus _retrievingStatus = LoadingStatus.unset;
  double saved = 0;
  double purchases = 0;
  dynamic _error;

  _calculateStats() {
    setState(() {
      saved = 0;
      purchases = 0;
    });
    List<ProductExpandedModel> orders = context.read<OrderHistoryCubit>().state;
    for(int i = 0; i < orders.length; i++) {
      saved += (orders[i].product.originalPrice! - orders[i].product.price!);
      purchases++;
    }
    setState(() {
      saved;
      purchases;
    });
  }

  _retrieveData(BuildContext context) async {
    setState(() {
      _retrievingStatus = LoadingStatus.loading;
    });
    try {
      List<ProductExpandedModel> orders = await Api.getOrderHistoryCustomer(); // TODO pasar a callrequestwith...
      orders = orders.reversed.toList();
      setState(() {
        context.read<OrderHistoryCubit>().set(orders);
        _retrievingStatus = LoadingStatus.successful;
      });
    } catch(error) {
      setState(() {
        _error = error;
        _retrievingStatus = LoadingStatus.error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if(context.read<OrderHistoryCubit>().state.isEmpty && askedToRetrieve == false) {
      askedToRetrieve = true;
      _retrieveData(context);
    }
    _calculateStats();
    return WefoodScreen(
      title: 'Historial de pedidos',
      body: [
        if(_retrievingStatus == LoadingStatus.loading) Container(
          margin: const EdgeInsets.only(
            left: 10,
          ),
          child: const LoadingIcon(),
        ),
        if(_retrievingStatus == LoadingStatus.error) Container(
          margin: EdgeInsets.symmetric(
            vertical: MediaQuery.of(context).size.height * 0.05,
          ),
          child: Text('Error: $_error'),
        ),
        if(_retrievingStatus == LoadingStatus.successful && context.read<OrderHistoryCubit>().state.isEmpty) Align(
          alignment: Alignment.center,
          child: Card(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 30,
                vertical: 20,
              ),
              child: const Text(
                'Los pedidos pasados aparecerán aquí. ¡Hoy puede ser un buen día para comenzar a salvar el desperdicio de alimentos!',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        if((_retrievingStatus == LoadingStatus.unset || _retrievingStatus == LoadingStatus.successful) && context.read<OrderHistoryCubit>().state.isNotEmpty) Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Card(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
                  elevation: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 0.5,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 20,
                    ),
                    alignment: Alignment.center,
                    width: MediaQuery.of(context).size.width * 0.4,
                    child: Column(
                      children: <Widget>[
                        Icon(
                          Icons.credit_card_rounded,
                          size: MediaQuery.of(context).size.width * 0.1,
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          'Realizados:',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          '${context.read<OrderHistoryCubit>().state.length}',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(
                          'pedidos',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    )
                  ),
                ),
                Card(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
                  elevation: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 0.5,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 20,
                    ),
                    alignment: Alignment.center,
                    width: MediaQuery.of(context).size.width * 0.4,
                    child: Column(
                      children: <Widget>[
                        Icon(
                          Icons.stacked_bar_chart,
                          size: MediaQuery.of(context).size.width * 0.1,
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          'Ahorrado:',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          saved.toStringAsFixed(2),
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(
                          's/.',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    )
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 30,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Pedidos pasados:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Column(
              children: context.read<OrderHistoryCubit>().state.map((ProductExpandedModel i) => OrderHistoryButtonCustomer(
                productExpanded: i,
                comebackBehaviour: () async {
                  await _retrieveData(context);
                },
              )).toList(),
            ),
          ],
        ),
        const SizedBox(
          height: 20,
        ),
      ],
    );
  }
}