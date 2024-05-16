import 'package:flutter/material.dart';
import 'package:wefood/environment.dart';
import 'package:wefood/types.dart';

class Utils {

  static bool controlBool(dynamic data) {
    bool result = false;
    if(data != null) {
      if(data == 1 || data == '1' || data == true || data == 'true') {
        result = true;
      }
    }
    return result;
  }

  static String monthNumberToString({
    required int number,
    bool shortened = false,
  }) {
    List<String> monthNames = [ 'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio', 'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre' ];
    return (shortened == true) ? monthNames[number].substring(0, 3) : monthNames[number];
  }

  static String displayDateTime(DateTime dateTime) {
    return '${dateTime.day} de ${monthNumberToString(
      number: dateTime.month,
    )} del ${dateTime.year}';
  }

  static String displayDateTimeShort(DateTime dateTime) {
    return '${dateTime.day}/${monthNumberToString(
      number: dateTime.month,
    )}/${dateTime.year}';
  }

  static String productTypeToChar(ProductType type) {
    String result;
    if(type == ProductType.breakfast) {
      result = 'B';
    } else if(type == ProductType.lunch) {
      result = 'L';
    } else if(type == ProductType.dinner) {
      result = 'D';
    } else {
      throw Exception('Unhandled productType on Utils.productTypeToChar');
    }
    return result;
  }

  static String? productTypeToString({
    required ProductType? type,
    bool isCapitalized = false,
  }) {
    String? result;
    if(type != null) {
      if(type == ProductType.breakfast) {
        result = isCapitalized ? 'Desayunos' : 'desayunos';
      } else if(type == ProductType.lunch) {
        result = isCapitalized ? 'Almuerzos' : 'almuerzos';
      } else if(type == ProductType.dinner){
        result = isCapitalized ? 'Cenas' : 'cenas';
      } else {
        throw Exception('Unhandled productType on Utils.productTypeToChar');
      }
    }
    return result;
  }

  static String? productTypeCharToString({
    String? type,
    bool isCapitalized = false,
    bool isPlural = true,
  }) {
    String? result;
    if(type != null) {
      if(type.toUpperCase() == 'B') {
        result = isCapitalized ? 'Desayuno' : 'desayuno';
      } else if(type.toUpperCase() == 'L') {
        result = isCapitalized ? 'Almuerzo' : 'almuerzo';
      } else if(type.toUpperCase() == 'D'){
        result = isCapitalized ? 'Cena' : 'cena';
      } else {
        throw Exception('Unhandled productType on Utils.productTypeToChar');
      }
      if(isPlural == true) {
        result = '${result}s';
      }
    }
    return result;
  }

  static bool timesOfDayFirstIsSooner(TimeOfDay first, TimeOfDay second) {
    bool result = false;
    if(second.hour > first.hour) {
      result = true;
    } else if(first.hour == second.hour) {
      if(second.minute > first.minute) {
        result = true;
      }
    }
    return result;
  }

  static int minutesFromNowToTimeOfDay(TimeOfDay deadline) {
    int result = -1;
    if(timesOfDayFirstIsSooner(deadline, TimeOfDay.now())) {
      result += (deadline.hour - TimeOfDay.now().hour) * 60;
      result += (deadline.minute - TimeOfDay.now().minute);
      if(TimeOfDay.now().minute > deadline.minute) {
        result -= 60;
      }
    }
    return result;
  }

  static int minutesFromNowToDateTime(DateTime deadline) {
    return deadline.difference(DateTime.now()).inMinutes;
  }

  static int sumTrueBooleans(List<bool> list) {
    int result = 0;
    for(int i = 0; i < list.length; i++) {
      if(list[i] == true) {
        result++;
      }
    }
    return result;
  }

  static int timesOfDayDifferenceInMinutes(TimeOfDay startTime, TimeOfDay endTime) {
    int result = 0;
    result = ((endTime.hour - startTime.hour - ((startTime.minute > endTime.minute) ? 1 : 0)) * 60) + (endTime.minute - startTime.minute);
    return result;
  }

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

  static String completeImageUrl(String url) {
    return '${Environment.storageUrl}$url';
  }
}