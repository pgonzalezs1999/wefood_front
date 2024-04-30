import 'package:flutter/material.dart';
import 'package:wefood/components/components.dart';
import 'package:wefood/models/models.dart';
import 'package:wefood/services/auth/api/api.dart';

class SearchedItems extends StatefulWidget {

  final List<ProductExpandedModel> items;

  const SearchedItems({
    super.key,
    required this.items,
  });

  @override
  State<SearchedItems> createState() => _SearchedItemsState();
}

class _SearchedItemsState extends State<SearchedItems> {

  _setImages() async {
    for(int i=0; i<widget.items.length; i++) {
      Api.getImage(
        idUser: widget.items[i].user.id!,
        meaning: '${widget.items[i].product.type!.toLowerCase()}1',
      ).then((ImageModel imageModel) {
        setState(() {
          widget.items[i].image = imageModel;
        });
      });
    }
  }

  @override
  void initState() {
    _setImages();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WefoodScreen(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Row(
            children: <Widget>[
              BackArrow(
                margin: EdgeInsets.zero,
              ),
              Text('Resultados de la búsqueda'),
            ],
          ),
          if(widget.items.isNotEmpty) Column(
            children: widget.items.map((i) {
              return ItemButton(
                productExpanded: i,
              );
            }).toList(),
          ),
          if(widget.items.isEmpty) Align( // TODO currarse más esto
            alignment: Alignment.center,
            child: Card(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 20,
                ),
                child: const Text('No se han encontrado productos'),
              ),
            ),
          ),
          const Divider(
            height: 50,
          ),
          const Align(
            alignment: Alignment.center,
            child: Column(
              children: <Text>[
                Text(
                  '¿Pocos resultados?',
                  style: TextStyle(
                    color: Colors.grey, // TODO deshardcodear estilo
                  ),
                ),
                Text(
                  'Prueba a flexibilizar los filtros o buscar palabras más generales. ¡Seguro que encuentras lo que buscas!',
                  style: TextStyle(
                    color: Colors.grey, // TODO deshardcodear estilo
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 25,
          )
        ],
      ),
    );
  }
}