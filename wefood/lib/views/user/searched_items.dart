import 'package:flutter/material.dart';
import 'package:wefood/components/components.dart';
import 'package:wefood/models.dart';

class SearchedItems extends StatefulWidget {

  final String text;
  final List<ProductExpandedModel> items;

  const SearchedItems({
    super.key,
    this.text = '',
    required this.items,
  });

  @override
  State<SearchedItems> createState() => _SearchedItemsState();
}

class _SearchedItemsState extends State<SearchedItems> {
  @override
  Widget build(BuildContext context) {
    return WefoodScreen(
      title: 'Resultados ${(widget.text != '') ? 'para "${widget.text}"' : 'de la búsqueda'}',
      body: [
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
                '¿Pocos resultados?\nPrueba a flexibilizar los filtros o buscar palabras más generales. ¡Seguro que encuentras lo que buscas!',
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
    );
  }
}