import 'package:flutter/material.dart';
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
  }) {
    String? result;
    if(type != null) {
      if(type == 'B') {
        result = isCapitalized ? 'Desayunos' : 'desayunos';
      } else if(type == 'L') {
        result = isCapitalized ? 'Almuerzos' : 'almuerzos';
      } else if(type == 'D'){
        result = isCapitalized ? 'Cenas' : 'cenas';
      } else {
        throw Exception('Unhandled productType on Utils.productTypeToChar');
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
}