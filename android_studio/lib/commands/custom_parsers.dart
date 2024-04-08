import 'package:flutter/material.dart';
import 'package:wefood/commands/utils.dart';

class CustomParsers {

  static DateTime timeOfDayToDateTime(TimeOfDay time) {
    return DateTime.now().copyWith(
      hour: time.hour,
      minute: time.minute,
    );
  }

  static String timeOfDayToSqlTimeString(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
      '${time.minute.toString().padLeft(2, '0')}';
  }

  static String timeOfDayToSqlDateTimeString(TimeOfDay time) {
    return '${DateTime.now().year}-'
      '${DateTime.now().month.toString().padLeft(2, '0')}-'
      '${DateTime.now().day.toString().padLeft(2, '0')} '
      '${time.hour.toString().padLeft(2, '0')}:'
      '${time.minute.toString().padLeft(2, '0')}'
      ':00';
  }

  static String dateTimeToSqlDateTimeString(DateTime? time) {
    String result = '';
    if(time != null) {
      result = '${time.year}-'
        '${time.month.toString().padLeft(2, '0')}-'
        '${time.day.toString().padLeft(2, '0')} '
        '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}:'
        '${time.second.toString().padLeft(2, '0')}';
    }
    return result;
  }

  static String boolToSqlString(bool boolean) {
    return boolean ? '1' : '0';
  }

  static String? dateTimeToString(DateTime? time) {
    String result = '';
    if(time != null) {
      result = '${time.day}/${Utils.monthNumberToString(
        number: time.month,
        shortened: true,
      )}/${time.year}, ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}h';
    }
    return result;
  }
}