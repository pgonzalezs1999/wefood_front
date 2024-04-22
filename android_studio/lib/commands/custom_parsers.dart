import 'package:flutter/material.dart';
import 'package:wefood/commands/utils.dart';
import 'package:wefood/types.dart';

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

  static String numberToHexadecimal(int number) {
    String result = number.toRadixString(36).toUpperCase();
    while(result.length < 5) {
      result = '0$result';
    }
    return result;
  }

  static int hexadecimalToNumber(String hexadecimalNumber) {
    int result = int.parse(
      hexadecimalNumber,
      radix: 36,
    );
    return result;
  }

  static OrderReceptionMethod? stringToOrderReceptionMethod(String? string) {
    OrderReceptionMethod? result;
    if(string != null) {
      if(string.toLowerCase() == 'pm') {
        result = OrderReceptionMethod.pm;
      } else if(string.toLowerCase() == 'normal') {
        result = OrderReceptionMethod.normal;
      }
    }
    return result;
  }

  static String? productTypeInitialToName({
    String? string,
    bool isCapitalized = false,
    bool isPlural = false,
  }) {
    String? result;
   if(string != null) {
     if(string.toLowerCase() == 'b') {
       result = 'desayuno';
     } else if(string.toLowerCase() == 'l') {
       result =  'almuerzo';
     } else if(string.toLowerCase() == 'd') {
       result =  'cena';
     }
     if(isCapitalized == true) {
       result = result![0].toUpperCase() + result.substring(1);
     }
     if(isPlural == true) {
       result = '${result}s';
     }
   }
   return result;
  }
}