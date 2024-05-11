import 'dart:async';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ClockGraphic extends StatefulWidget {

  final TimeOfDay startTime;
  final TimeOfDay endTime;

  const ClockGraphic({
    super.key,
    required this.startTime,
    required this.endTime,
  });

  @override
  State<ClockGraphic> createState() => _ClockGraphicState();
}

class _ClockGraphicState extends State<ClockGraphic> {

  Color? _scheduleBorderColor = Colors.white;

  _setScheduleBorderColor() {
    Timer(
      const Duration(milliseconds: 1),
          () {
        setState(() {
          _scheduleBorderColor = Theme.of(context).colorScheme.primary;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double startMinutes = (((widget.startTime.hour - ((widget.startTime.hour >= 12) ? 12 : 0)) * 60) + widget.startTime.minute).toDouble();
    double endMinutes = (((widget.endTime.hour - ((widget.endTime.hour >= 12) ? 12 : 0)) * 60) + widget.endTime.minute).toDouble();
    _setScheduleBorderColor();
    return Transform.rotate(
      angle: 0, // (endMinutes > startMinutes) ? 0 : 3.14159,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(9999),
            child: Container(
              color: _scheduleBorderColor,
              height: 80,
              width: 80,
              child: SfCircularChart(
                series: <CircularSeries>[
                  PieSeries<PieData, String>(
                    radius: '130%',
                    dataSource: (endMinutes > startMinutes)
                      ? <PieData>[
                        PieData( // Before range
                          value: startMinutes,
                          color: Theme.of(context).colorScheme.surface,
                        ),
                        PieData( // Actual range
                          value: endMinutes - startMinutes,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        PieData( // After range
                          value: (12 * 60) - endMinutes,
                          color: Theme.of(context).colorScheme.surface,
                        ),
                      ]
                    : <PieData>[
                      PieData( // Actual range
                        value: endMinutes,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      PieData( // Before range
                        value: startMinutes - endMinutes,
                        color: Theme.of(context).colorScheme.surface,
                      ),
                      PieData( // Actual range
                        value: (12 * 60) - startMinutes,
                        color: Theme.of(context).colorScheme.secondary,
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
              child: Transform.rotate(
                angle: 0, // (endMinutes > startMinutes) ? 0 : 3.14159,
                child: Icon(
                  Icons.timer_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
        ],
      ),
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
