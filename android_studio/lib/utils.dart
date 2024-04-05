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

  static String displayDateTime(DateTime dateTime) {
    List<String> monthNames = [ 'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio', 'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre' ];
    return '${dateTime.day} de ${monthNames[dateTime.month]} del ${dateTime.year}';
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

  static String productTypeToString(ProductType type) {
    String result;
    if(type == ProductType.breakfast) {
      result = 'desayunos';
    } else if(type == ProductType.lunch) {
      result = 'almuerzos';
    } else if(type == ProductType.dinner){
      result = 'cenas';
    } else {
      throw Exception('Unhandled productType on Utils.productTypeToChar');
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
}