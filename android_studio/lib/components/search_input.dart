import 'package:flutter/material.dart';

class SearchInput extends StatefulWidget {

  final Function(String) onChanged;

  const SearchInput({
    super.key,
    required this.onChanged,
});

  @override
  State<SearchInput> createState() => _SearchInputState();
}

class _SearchInputState extends State<SearchInput> {
  static const double horizontalPadding = 20;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: horizontalPadding,
      ),
      child: TextFormField(
        keyboardType: TextInputType.visiblePassword,
        onChanged: (text) => widget.onChanged(text),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: horizontalPadding,
          ),
          hintText: 'Busca tu próxima comida',
          border: OutlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).primaryColor,
            ),
            borderRadius: BorderRadius.circular(999),
          ),
          suffixIcon: Container(
            margin: const EdgeInsets.symmetric(
              horizontal: horizontalPadding,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <GestureDetector>[
                GestureDetector(
                  child: const Icon(
                    Icons.search,
                  ),
                  onTap: () {

                  },
                ),
                GestureDetector(
                  child: const Icon(
                    Icons.filter_list,
                  ),
                  onTap: () {

                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}