import 'package:wefood/models/user_model.dart';

import 'business_model.dart';

class BusinessExpandedModel {
  UserModel user;
  BusinessModel business;

  BusinessExpandedModel.empty():
    user = UserModel.empty(),
    business = BusinessModel.empty();

  BusinessExpandedModel.fromJson(Map<String, dynamic> json):
    user = UserModel.fromJson(json['user'] as Map<String, dynamic>),
    business = BusinessModel.fromJson(json['business'] as Map<String, dynamic>);

  static void printInfo(BusinessExpandedModel model) {
    print('------------------------------');
    UserModel.printInfo(model.user);
    BusinessModel.printInfo(model.business);
    print('------------------------------');
  }
}