import 'package:flutter/material.dart';
import 'package:wefood/commands/utils.dart';
import 'package:wefood/components/components.dart';

class ScheduleSetter extends StatefulWidget {

  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final Function onChangeStartTime;
  final Function onChangeEndTime;

  const ScheduleSetter({
    super.key,
    required this.startTime,
    required this.endTime,
    required this.onChangeStartTime,
    required this.onChangeEndTime,
  });

  @override
  State<ScheduleSetter> createState() => _ScheduleSetterState();
}

class _ScheduleSetterState extends State<ScheduleSetter> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        ClockGraphic(
          startTime: widget.startTime,
          endTime: widget.endTime,
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
                  child: Text('${widget.startTime.format(context)} h'),
                  onPressed: () {
                    showTimePicker(
                      barrierDismissible: false,
                      context: context,
                      initialTime: widget.startTime,
                    ).then((TimeOfDay? selectedTime) {
                      if(selectedTime != null) {
                        if(Utils.timesOfDayFirstIsSooner(
                          selectedTime,
                          widget.endTime,
                        )) {
                          if(Utils.timesOfDayDifferenceInMinutes(selectedTime, widget.endTime) >= (12 * 60)) {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return WefoodPopup(
                                  context: context,
                                  title: 'Datos incorrectos',
                                  description: 'Por motivos de higiene, no permitimos que el periodo de recogida supere las 12h',
                                  cancelButtonTitle: 'OK',
                                );
                              }
                            );
                          } else {
                            widget.onChangeStartTime(selectedTime);
                          }
                        } else {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return WefoodPopup(
                                context: context,
                                title: 'Datos incorrectos',
                                description: 'La hora "desde las" tiene que ser más temprano que la hora "hasta las"',
                                cancelButtonTitle: 'OK',
                              );
                            }
                          );
                        }
                      }
                    });
                  },
                ),
              ],
            ),
            Row(
              children: <Widget>[
                const Text('Hasta las'),
                TextButton(
                  child: Text('${widget.endTime.format(context)} h'),
                  onPressed: () {
                    showTimePicker(
                      barrierDismissible: false,
                      context: context,
                      initialTime: widget.endTime,
                    ).then((TimeOfDay? selectedTime) {
                      if(selectedTime != null) {
                        if(Utils.timesOfDayFirstIsSooner(
                          widget.startTime,
                          selectedTime,
                        )) {
                          if(Utils.timesOfDayDifferenceInMinutes(widget.startTime, selectedTime) >= (12 * 60)) {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return WefoodPopup(
                                  context: context,
                                  title: 'Datos incorrectos',
                                  description: 'Por motivos de higiene, no permitimos que el periodo de recogida supere las 12h',
                                  cancelButtonTitle: 'OK',
                                );
                              }
                            );
                          } else {
                            widget.onChangeEndTime(selectedTime);
                          }
                        } else {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return WefoodPopup(
                                context: context,
                                title: 'Datos incorrectos',
                                description: 'La hora "desde las" tiene que ser más temprano que la hora "hasta las"',
                                cancelButtonTitle: 'OK',
                              );
                            }
                          );
                        }
                      }
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
