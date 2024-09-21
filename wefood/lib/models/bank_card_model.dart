import 'package:flutter/foundation.dart';

class BankCardModel {
  String? ownerName;
  int? cardNumber;
  int? expirationMonth;
  int? expirationYear;

  BankCardModel.empty();

  BankCardModel.fromJson(Map<String, dynamic> json) {
    ownerName = json['owner_name'] as String?;
    cardNumber = _toInt(json['card_number'] as int?);
    expirationMonth = _toInt(json['expiration_month'] as int?);
    expirationYear = _toInt(json['expiration_year'] as int?);
  }

  static void printInfo(BankCardModel bankCard) {
    if(kDebugMode) {
      print('IMPRIMIENDO BANK_CARD:');
      print('-> ownerName: ${bankCard.ownerName}');
      print('-> cardNumber: ${bankCard.cardNumber}');
      print('-> expirationMonth: ${bankCard.expirationMonth}');
      print('-> expirationYear: ${bankCard.expirationYear}');
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