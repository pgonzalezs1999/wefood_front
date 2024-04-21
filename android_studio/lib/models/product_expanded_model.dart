import 'package:wefood/models/models.dart';
import 'package:wefood/commands/utils.dart';

class ProductExpandedModel {
  ProductModel? product;
  ItemModel? item;
  OrderModel? order;
  BusinessModel? business;
  UserModel? user;
  bool? isFavourite;
  int? favourites;
  int? available;

  ProductExpandedModel.empty();

  ProductExpandedModel.fromJson(Map<String, dynamic> json) :
    product = json['product'] != null ? ProductModel.fromJson(json['product'] as Map<String, dynamic>) : null,
    item = json['item'] != null ? ItemModel.fromJson(json['item'] as Map<String, dynamic>) : null,
    order = json['order'] != null ? OrderModel.fromJson(json['order'] as Map<String, dynamic>) : null,
    business = json['business'] != null ? BusinessModel.fromJson(json['business'] as Map<String, dynamic>) : null,
    user = json['user'] != null ? UserModel.fromJson(json['user'] as Map<String, dynamic>) : null,
    isFavourite = Utils.controlBool(json['is_favourite']) as bool?,
    favourites = json['favourites'] as int?,
    available = json['available'] as int?;
}