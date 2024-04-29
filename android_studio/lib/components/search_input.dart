import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wefood/blocs/blocs.dart';
import 'package:wefood/views/views.dart';

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

  _navigateToSearchFilters() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SearchFilters()),
    ).whenComplete(() {
      setState(() {
        context.read<SearchFiltersCubit>().state;
      });
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
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
            children: <Widget>[
              GestureDetector(
                child: const Icon(
                  Icons.search,
                ),
                onTap: () {

                },
              ),
              const SizedBox(
                width: 10,
              ),
              GestureDetector(
                child: Stack(
                  alignment: Alignment.topRight,
                  children: [
                    if(
                      context.read<SearchFiltersCubit>().state.dessert == true
                      || context.read<SearchFiltersCubit>().state.junk == true
                      || context.read<SearchFiltersCubit>().state.vegan == true
                      || context.read<SearchFiltersCubit>().state.vegetarian == true
                      || context.read<SearchFiltersCubit>().state.maximumPrice != null
                      || context.read<SearchFiltersCubit>().state.startTime != null
                      || context.read<SearchFiltersCubit>().state.endTime != null
                      || context.read<SearchFiltersCubit>().state.onlyToday == true
                      || context.read<SearchFiltersCubit>().state.showRunOutProducts == true
                    ) Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        color: Theme.of(context).primaryColor,
                      ),
                      width: 10,
                      height: 10,
                    ),
                    const Icon(
                      Icons.filter_list,
                    ),
                  ],
                ),
                onTap: () {
                  _navigateToSearchFilters();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}