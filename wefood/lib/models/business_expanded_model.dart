import 'package:flutter/widgets.dart';
import 'package:wefood/commands/utils.dart';
import 'package:wefood/models/models.dart';

class BusinessExpandedModel {
  UserModel user;
  BusinessModel business;
  Image? image;
  bool? isFavourite;
  int? favourites;
  int? totalOrders;
  bool? requesterHasBought;

  BusinessExpandedModel.empty():
    user = UserModel.empty(),
    business = BusinessModel.empty();

  BusinessExpandedModel.fromJson(Map<String, dynamic> json):
    user = (json['user'] != null) ? UserModel.fromJson(json['user'] as Map<String, dynamic>) : UserModel.empty(),
    business = (json['business'] != null) ? BusinessModel.fromJson(json['business'] as Map<String, dynamic>) : BusinessModel.empty(),
    isFavourite = ((json['is_favourite'] != null) ? Utils.controlBool(json['is_favourite']) as bool? : null),
    favourites = json['favourites'] as int?,
    totalOrders = json['total_orders'] as int?,
    requesterHasBought = Utils.controlBool(json['requester_has_bought']);

  BusinessExpandedModel.fromParameters({
    required BusinessModel businessModel,
    required UserModel userModel,
  }):
    user = userModel,
    business = businessModel;

  static void printInfo(BusinessExpandedModel model) {
    print('------------------------------');
    UserModel.printInfo(model.user);
    BusinessModel.printInfo(model.business);
    print('--------');
    print('-> isFavourite: ${model.isFavourite}');
    print('-> favourites: ${model.favourites}');
    print('-> totalOrders: ${model.totalOrders}');
    print('-> requesterHasBought: ${model.requesterHasBought}');
    print('------------------------------');
  }
}