import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:wefood/blocs/blocs.dart';
import 'package:wefood/commands/utils.dart';
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
                      ? (context.read<SearchFiltersCubit>().state.maximumPrice! < 5)
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
                    title: 'Vegano',
                    value: context.read<SearchFiltersCubit>().state.vegan,
                    onChanged: () {
                      setState(() {
                        context.read<SearchFiltersCubit>().setVegan(!context.read<SearchFiltersCubit>().state.vegan);
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(9999),
                          child: Container(
                            color: scheduleBorderColor,
                            height: 80,
                            width: 80,
                            child: SfCircularChart(
                              series: <CircularSeries>[
                                PieSeries<PieData, String>(
                                  radius: '130%',
                                  dataSource: <PieData>[
                                    PieData( // Before range
                                      value: ((context.read<SearchFiltersCubit>().state.startTime!.hour * 60) + context.read<SearchFiltersCubit>().state.startTime!.minute).toDouble(),
                                      color: Theme.of(context).colorScheme.surface,
                                    ),
                                    PieData( // Actual range
                                      value: (((context.read<SearchFiltersCubit>().state.endTime!.hour - context.read<SearchFiltersCubit>().state.startTime!.hour) * 60) + (context.read<SearchFiltersCubit>().state.endTime!.minute - context.read<SearchFiltersCubit>().state.startTime!.minute)).toDouble(),
                                      color: Theme.of(context).colorScheme.secondary,
                                    ),
                                    PieData( // After range
                                      value: (((23 - context.read<SearchFiltersCubit>().state.endTime!.hour) * 60) + (60 - context.read<SearchFiltersCubit>().state.endTime!.minute)).toDouble(),
                                      color: Theme.of(context).colorScheme.surface,
                                    ),
                                  ],
                                  pointColorMapper: (PieData data, _) => data.color,
                                  xValueMapper: (PieData data, _) => 'Section',
                                  yValueMapper: (PieData data, _) => data.value,
                                ),
                              ],
                            ),
                          ),
                        ),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(1000),
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            color: Theme.of(context).colorScheme.surface,
                            child: Icon(
                              Icons.timer_outlined,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            const Text('Desde las'),
                            TextButton(
                              onPressed: () {
                                showTimePicker(
                                  barrierDismissible: false,
                                  context: context,
                                  initialTime: TimeOfDay.now(),
                                ).then((TimeOfDay? selectedTime) {
                                  if(selectedTime != null) {
                                    if(Utils.timesOfDayFirstIsSooner(
                                      selectedTime,
                                      context.read<SearchFiltersCubit>().state.endTime!,
                                    )) {
                                      setState(() {
                                        context.read<SearchFiltersCubit>().setStartTime(selectedTime);
                                      });
                                    } else {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return WefoodPopup(
                                              context: context,
                                              title: 'Dato incorrecto',
                                              description: 'La hora "desde las" tiene que ser más temprano que la hora "hasta las"',
                                              cancelButtonTitle: 'OK',
                                            );
                                          }
                                      );
                                    }
                                  }
                                });
                              },
                              child: Text('${(context.read<SearchFiltersCubit>().state.startTime != null)
                                  ? context.read<SearchFiltersCubit>().state.startTime!.format(context)
                                  : '00:01'} h'),
                            ),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            const Text('Hasta las'),
                            TextButton(
                              onPressed: () {
                                showTimePicker(
                                  barrierDismissible: false,
                                  context: context,
                                  initialTime: TimeOfDay.now(),
                                ).then((TimeOfDay? selectedTime) {
                                  if(selectedTime != null) {
                                    if(Utils.timesOfDayFirstIsSooner(
                                      context.read<SearchFiltersCubit>().state.startTime!,
                                      selectedTime,
                                    )) {
                                      setState(() {
                                        context.read<SearchFiltersCubit>().setEndTime(selectedTime);
                                      });
                                    } else {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return WefoodPopup(
                                              context: context,
                                              title: 'Datos incorrecto',
                                              description: 'La hora "desde las" tiene que ser más temprano que la hora "hasta las"',
                                              cancelButtonTitle: 'OK',
                                            );
                                          }
                                      );
                                    }
                                  }
                                });
                              },
                              child: Text('${(context.read<SearchFiltersCubit>().state.endTime != null)
                                  ? context.read<SearchFiltersCubit>().state.endTime!.format(context)
                                  : '23:59'} h'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                child: const Text('BUSCAR'),
                onPressed: () async {
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
                  _navigateToSearchedItems(
                    items: items,
                  );
                },
              ),
            )
          ],
        ),
      ],
    );
  }
}

class PieData {
  final double value;
  final Color color;

  PieData({
    required this.value,
    required this.color,
  });
}