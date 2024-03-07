import 'package:wefood/models/business_model.dart';
import 'package:wefood/models/item_model.dart';
import 'package:wefood/models/product_model.dart';

class ProductExpandedModel {
  ProductModel product;
  ItemModel? item;
  BusinessModel? business;
  bool? isFavourite;
  int? available;

  ProductExpandedModel.fromJson(Map<String, dynamic> json) :
    product = ProductModel.fromJson(json['product'] as Map<String, dynamic>),
    item = json['item'] != null ? ItemModel.fromJson(json['item'] as Map<String, dynamic>) : null,
    business = json['business'] != null ? BusinessModel.fromJson(json['business'] as Map<String, dynamic>) : null,
    isFavourite = json['favourite'] != null ? (json['favourite'] == true || json['favourite'] == 1 || json['favourite'] == 'true') : null,
    available = json['available'] as int?;
}