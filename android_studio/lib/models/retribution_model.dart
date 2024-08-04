import 'package:flutter/foundation.dart';

class RetributionModel {
  int? id;
  DateTime? date;
  int? idBusiness;
  double? amount;
  String? transferId;
  int? status;

  RetributionModel.empty();

  RetributionModel.fromJson(Map<String, dynamic> json) {
    id = _toInt(json['id'] as int?);
    date = _parseTime(json['date']);
    idBusiness = _toInt(json['id_business'] as int?);
    amount = _toDouble(json['amount']);
    transferId = json['transfer_id'] as String?;
    status = _toInt(json['status'] as int?) ?? 0;
  }

  static void printInfo(RetributionModel retribution) {
    if(kDebugMode) {
      print('IMPRIMIENDO COMMENT CON ID: ${retribution.id}');
      print('-> date: ${retribution.date}');
      print('-> idBusiness: ${retribution.idBusiness}');
      print('-> amount: ${retribution.amount}');
      print('-> transferId: ${retribution.transferId}');
      print('-> status: ${retribution.status}');
    }
  }

  static DateTime? _parseTime(String? dateTime) { // Convertir HH:mm:ss a DateTime
    if(dateTime != null) {
      List<String> parts = dateTime.split(' ');
      List<String> date = parts[0].split('-');
      List<String> time = parts[1].split(':');
      return DateTime(int.parse(date[0]), int.parse(date[1]), int.parse(date[2]), int.parse(time[0]), int.parse(time[1]), int.parse(time[2]));
    } else {
      return null;
    }
  }

  double? _toDouble(dynamic value) {
    if(value is double) {
      return value;
    } else if(value is String) {
      return double.tryParse(value);
    } else if(value is int) {
      return value.toDouble();
    } else {
      return null;
    }
  }

  int? _toInt(dynamic value) {
    if(value is int) {
      return value;
    } else if(value is String) {
      return int.tryParse(value);
    } else {
      return null;
    }
  }
}