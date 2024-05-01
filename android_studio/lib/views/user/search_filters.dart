import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wefood/blocs/blocs.dart';
import 'package:wefood/components/components.dart';
import 'package:wefood/models/models.dart';
import 'package:wefood/services/auth/api/api.dart';
import 'package:wefood/types.dart';
import 'package:wefood/views/user/searched_items.dart';
import 'package:wefood/views/views.dart';

class SearchFilters extends StatefulWidget {
  const SearchFilters({super.key});

  @override
  State<SearchFilters> createState() => _SearchFiltersState();
}

class _SearchFiltersState extends State<SearchFilters> {

  void _navigateToSearchedItems(List<ProductExpandedModel> items) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SearchedItems(items: items)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WefoodScreen(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BackUpBar(
            title: 'Filtros de búsqueda',
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.5,
            child: WefoodInput(
              onChanged: (String value) {
                setState(() {
                  context.read<SearchFiltersCubit>().setMaximumPrice(double.tryParse(value));
                });
              },
              labelText: 'Precio máximo',
              type: InputType.decimal,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          const Text('Hora de recogida:'),
          Row(
            children: <Widget>[
              const Text('Desde las'),
              TextButton(
                onPressed: () async {
                  final selectedTime = await showTimePicker(
                    barrierDismissible: false,
                    context: context,
                    initialTime: TimeOfDay.now(),
                  ) ?? TimeOfDay.now();
                  setState(() {
                    context.read<SearchFiltersCubit>().setStartTime(selectedTime);
                  });
                },
                child: Text('${(context.read<SearchFiltersCubit>().state.startTime != null)
                  ? context.read<SearchFiltersCubit>().state.startTime!.format(context)
                  : '00:01'} h'),
              ),
              const Text('hasta las'),
              TextButton(
                onPressed: () async {
                  final selectedTime = await showTimePicker(
                    barrierDismissible: false,
                    context: context,
                    initialTime: TimeOfDay.now(),
                  ) ?? TimeOfDay.now();
                  setState(() {
                    context.read<SearchFiltersCubit>().setEndTime(selectedTime);
                  });
                },
                child: Text('${(context.read<SearchFiltersCubit>().state.endTime != null)
                  ? context.read<SearchFiltersCubit>().state.endTime!.format(context)
                  : '23:59'} h'),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              const Text('Sólo para recoger hoy'),
              Switch(
                value: context.read<SearchFiltersCubit>().state.onlyToday,
                onChanged: (bool value) {
                  setState(() {
                    context.read<SearchFiltersCubit>().setOnlyToday(value);
                  });
                }
              ),
            ],
          ),
          Row(
            children: <Widget>[
              const Text('Ver productos agotados'),
              Switch(
                value: context.read<SearchFiltersCubit>().state.onlyAvailable,
                onChanged: (bool value) {
                  setState(() {
                    context.read<SearchFiltersCubit>().setOnlyAvailable(value);
                  });
                }
              ),
            ],
          ),
          const Text('Categorías'),
          CheckBoxRow(
            title: 'Comida rápida',
            value: context.read<SearchFiltersCubit>().state.junk,
            onChanged: () {
              setState(() {
                context.read<SearchFiltersCubit>().setJunk(!context.read<SearchFiltersCubit>().state.junk);
              });
            }
          ),
          CheckBoxRow(
            title: 'Postres',
            value: context.read<SearchFiltersCubit>().state.dessert,
            onChanged: () {
              setState(() {
                context.read<SearchFiltersCubit>().setDessert(!context.read<SearchFiltersCubit>().state.dessert);
              });
            }
          ),
          CheckBoxRow(
            title: 'Vegetariano',
            value: context.read<SearchFiltersCubit>().state.vegetarian,
            onChanged: () {
              setState(() {
                context.read<SearchFiltersCubit>().setVegetarian(!context.read<SearchFiltersCubit>().state.vegetarian);
              });
            }
          ),
          CheckBoxRow(
            title: 'Vegano',
            value: context.read<SearchFiltersCubit>().state.vegan,
            onChanged: () {
              setState(() {
                context.read<SearchFiltersCubit>().setVegan(!context.read<SearchFiltersCubit>().state.vegan);
              });
            }
          ),
          Align(
            alignment: Alignment.center,
            child: ElevatedButton(
              child: const Text('BUSCAR'),
              onPressed: () async {
                // TODO antes hacer comprobaciones!!! (startTime < endTime; y precio > 0
                List<ProductExpandedModel> items = await Api.searchItemsByFilters(
                  longitude: -77, // TODO deshardcodear
                  latitude: -12.5, // TODO deshardcodear
                  distance: 99999, // TODO deshardcodear
                  vegetarian: context.read<SearchFiltersCubit>().state.vegetarian,
                  vegan: context.read<SearchFiltersCubit>().state.vegan,
                  dessert: context.read<SearchFiltersCubit>().state.dessert,
                  junk: context.read<SearchFiltersCubit>().state.junk,
                  price: context.read<SearchFiltersCubit>().state.maximumPrice ?? 999999,
                  startingHour: context.read<SearchFiltersCubit>().state.startTime ?? const TimeOfDay(hour: 0, minute: 0),
                  endingHour: context.read<SearchFiltersCubit>().state.endTime ?? const TimeOfDay(hour: 23, minute: 59),
                  onlyToday: context.read<SearchFiltersCubit>().state.onlyToday,
                  onlyAvailable: context.read<SearchFiltersCubit>().state.onlyAvailable,
                );
                _navigateToSearchedItems(items);
              },
            ),
          )
        ],
      ),
    );
  }
}