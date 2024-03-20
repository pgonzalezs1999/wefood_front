import 'package:wefood/models/user_model.dart';

import 'business_model.dart';

class BusinessExpandedModel {
  UserModel? user;
  BusinessModel business;

  BusinessExpandedModel.fromJson(Map<String, dynamic> json):
    user = UserModel.fromJson(json['user'] as Map<String, dynamic>),
    business = BusinessModel.fromJson(json['business'] as Map<String, dynamic>);
}