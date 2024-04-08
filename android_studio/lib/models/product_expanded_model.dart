import 'package:wefood/models/business_model.dart';
import 'package:wefood/models/item_model.dart';
import 'package:wefood/models/product_model.dart';
import 'package:wefood/commands/utils.dart';

class ProductExpandedModel {
  ProductModel? product;
  ItemModel? item;
  BusinessModel? business;
  bool? isFavourite;
  int? favourites;
  int? available;

  ProductExpandedModel.fromJson(Map<String, dynamic> json) :
    product = json['product'] != null ? ProductModel.fromJson(json['product'] as Map<String, dynamic>) : null,
    item = json['item'] != null ? ItemModel.fromJson(json['item'] as Map<String, dynamic>) : null,
    business = json['business'] != null ? BusinessModel.fromJson(json['business'] as Map<String, dynamic>) : null,
    isFavourite = Utils.controlBool(json['is_favourite']) as bool?,
    favourites = json['favourites'] as int?,
    available = json['available'] as int?;
}