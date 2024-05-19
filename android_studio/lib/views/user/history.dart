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

  LoadingStatus _retrievingFavourites = LoadingStatus.unset;

  _retrieveData() async {
    setState(() {
      _retrievingFavourites = LoadingStatus.loading;
    });
    try {
      List<ProductExpandedModel> orders = await Api.getOrderHistoryCustomer();
      orders = orders.reversed.toList();
      setState(() {
        context.read<FavouriteItemsCubit>().set(orders);
        _retrievingFavourites = LoadingStatus.successful;
      });
    } catch(error) {
      setState(() {
        _retrievingFavourites = LoadingStatus.error;
      });
    }
  }

  @override
  void initState() {
    _retrieveData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WefoodScreen(
      title: 'Historial de pedidos',
      body: [
        if(_retrievingFavourites == LoadingStatus.loading) Container(
          margin: const EdgeInsets.only(
            left: 10,
          ),
          child: const LoadingIcon(),
        ),
        if(_retrievingFavourites == LoadingStatus.error) Container(
          margin: EdgeInsets.symmetric(
            vertical: MediaQuery.of(context).size.height * 0.05,
          ),
          child: const Text('Error'),
        ),
        if(_retrievingFavourites == LoadingStatus.successful && context.read<FavouriteItemsCubit>().state.isEmpty) Align(
          alignment: Alignment.center,
          child: Card(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 30,
                vertical: 20,
              ),
              child: const Text(
                '¡Añade negocios a favoritos para tener acceso a sus productos fácilmente!',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        if((_retrievingFavourites == LoadingStatus.unset || _retrievingFavourites == LoadingStatus.successful) && context.read<FavouriteItemsCubit>().state.isNotEmpty) Column(
          children: context.read<FavouriteItemsCubit>().state.map((ProductExpandedModel i) => OrderHistoryButtonCustomer(
            productExpanded: i,
            comebackBehaviour: () async {
              await _retrieveData();
            },
          )).toList(),
        ),
        const SizedBox(
          height: 20,
        ),
      ],
    );
  }
}