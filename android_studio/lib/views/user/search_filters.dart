import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wefood/blocs/blocs.dart';
import 'package:wefood/commands/call_request.dart';
import 'package:wefood/components/components.dart';
import 'package:wefood/environment.dart';
import 'package:wefood/models/models.dart';
import 'package:wefood/services/auth/api.dart';
import 'package:wefood/types.dart';
import 'package:wefood/views/user/searched_items.dart';

class SearchFilters extends StatefulWidget {
  const SearchFilters({super.key});

  @override
  State<SearchFilters> createState() => _SearchFiltersState();
}

class _SearchFiltersState extends State<SearchFilters> {

  void _navigateToSearchedItems({
      required List<ProductExpandedModel> items,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SearchedItems(
        items: items,
      )),
    );
  }

  Color? scheduleBorderColor = Colors.white;

  setScheduleBorderColor() {
    Timer(
      const Duration(milliseconds: 1),
      () {
        setState(() {
          scheduleBorderColor = Theme.of(context).colorScheme.primary;
        });
      },
    );
  }

  @override
  void initState() {
    if(context.read<SearchFiltersCubit>().state.startTime == null) {
      setState(() {
        context.read<SearchFiltersCubit>().state.startTime = const TimeOfDay(
          hour: 0,
          minute: 1,
        );
      });
    }
    if(context.read<SearchFiltersCubit>().state.endTime == null) {
      setState(() {
        context.read<SearchFiltersCubit>().state.endTime = const TimeOfDay(
          hour: 23,
          minute: 59,
        );
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    setScheduleBorderColor();
    return WefoodScreen(
      title: 'Filtros de búsqueda',
      body: [
        Wrap(
          runSpacing: 30,
          crossAxisAlignment: WrapCrossAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Precio máximo (Sol/.)',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(
                  height: 10,
                ),
                WefoodInput(
                  onChanged: (String value) {
                    setState(() {
                      context.read<SearchFiltersCubit>().setMaximumPrice(double.tryParse(value));
                    });
                  },
                  labelText: 'Hasta',
                  type: InputType.decimal,
                  feedbackWidget: (context.read<SearchFiltersCubit>().state.maximumPrice != null)
                    ? (context.read<SearchFiltersCubit>().state.maximumPrice! < Environment.minimumPrice)
                      ? const FeedbackMessage(
                        message: 'No tenemos productos a ese precio',
                        isError: true,
                      )
                      : null
                    : null,
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Categorías',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(
                  height: 10,
                ),
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
                    title: 'Mediterráneo',
                    value: context.read<SearchFiltersCubit>().state.mediterranean,
                    onChanged: () {
                      setState(() {
                        context.read<SearchFiltersCubit>().setMediterranean(!context.read<SearchFiltersCubit>().state.mediterranean);
                      });
                    }
                ),
              ],
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 20,
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
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 20,
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
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Hora de recogida:',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                ScheduleSetter(
                  startTime: context.read<SearchFiltersCubit>().state.startTime!,
                  endTime: context.read<SearchFiltersCubit>().state.endTime!,
                  onChangeStartTime: (TimeOfDay selectedTime) {
                    setState(() {
                      context.read<SearchFiltersCubit>().setStartTime(selectedTime);
                    });
                  },
                  onChangeEndTime: (TimeOfDay selectedTime) {
                    setState(() {
                      context.read<SearchFiltersCubit>().setEndTime(selectedTime);
                    });
                  },
                ),
              ],
            ),
            Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                child: const Text('BUSCAR'),
                onPressed: () {
                  callRequestWithLoading(
                    context: context,
                    request: () async {
                      Filters filters = context.read<SearchFiltersCubit>().state;
                      return await Api.searchItemsByFilters(
                        longitude: -77, // TODO deshardcodear
                        latitude: -12.5, // TODO deshardcodear
                        distance: 99999, // TODO deshardcodear
                        filters: filters,
                      );
                    },
                    onSuccess: (List<ProductExpandedModel> items) {
                      _navigateToSearchedItems(
                        items: items,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}