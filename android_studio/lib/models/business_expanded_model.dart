import 'package:flutter/widgets.dart';
import 'package:wefood/models/models.dart';

class BusinessExpandedModel {
  UserModel user;
  BusinessModel business;
  Image? image;

  BusinessExpandedModel.empty():
    user = UserModel.empty(),
    business = BusinessModel.empty();

  BusinessExpandedModel.fromJson(Map<String, dynamic> json):
    user = (json['user'] != null) ? UserModel.fromJson(json['user'] as Map<String, dynamic>) : UserModel.empty(),
    business = (json['business'] != null) ? BusinessModel.fromJson(json['business'] as Map<String, dynamic>) : BusinessModel.empty();

  static void printInfo(BusinessExpandedModel model) {
    print('------------------------------');
    UserModel.printInfo(model.user);
    BusinessModel.printInfo(model.business);
    print('------------------------------');
  }
}