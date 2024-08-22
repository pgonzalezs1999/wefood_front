import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
// import 'package:syncfusion_flutter_charts/charts.dart';

class ClockGraphic extends StatefulWidget {

  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final double size;

  const ClockGraphic({
    super.key,
    required this.startTime,
    required this.endTime,
    this.size = 80,
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
              height: widget.size,
              width: widget.size,
              child: const Text('Aquí iría un relojito'),
              /*SfCircularChart(
                series: <CircularSeries>[
                  PieSeries<PieData, String>(
                    radius: '${(220 * pow(e, -0.03 * widget.size)) + 110}%', // Looks good on a size between 50 - 200
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
              ),*/
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
          SizedBox(
            width: widget.size * 0.8,
            height: widget.size * 0.9,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [9, 3].map((i) {
                return Text(
                  '$i',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: widget.size * 0.1,
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w900,
                  ),
                );
              }).toList(),
            ),
          ),
          SizedBox(
            width: widget.size * 0.8,
            height: widget.size * 0.9,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [12, 6].map((i) {
                return Text(
                  '$i',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: widget.size * 0.1,
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w900,
                  ),
                );
              }).toList(),
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
