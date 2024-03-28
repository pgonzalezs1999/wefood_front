import 'package:wefood/models/comment_expanded_model.dart';

class BusinessModel {
  int? id;
  int? idCountry;
  String? taxId;
  String? description;
  String? name;
  double? longitude;
  double? latitude;
  int? idBreakFastProduct;
  int? idLunchProduct;
  int? idDinnerProduct;
  String? directions;
  int? isValidated;
  double? rate;
  List<CommentExpandedModel>? comments;

  BusinessModel.fromJson(Map<String, dynamic> json):
    id = json['id'] as int?,
    idCountry = json['id_country'] as int?,
    taxId = json['tax_id'] as String?,
    description = json['description'] as String?,
    name = json['name'] as String?,
    longitude = (json['longitude'])?.toDouble(),
    latitude = (json['latitude'])?.toDouble(),
    idBreakFastProduct = json['id_breakfast_products'] as int?,
    idLunchProduct = json['id_lunch_products'] as int?,
    idDinnerProduct = json['id_dinner_products'] as int?,
    directions = json['directions'] as String?,
    isValidated = json['is_validated'] as int?,
    rate = (json['rate'])?.toDouble(),
    comments = json['comments'] != null
      ? List<CommentExpandedModel>.from((json['comments'] as List<dynamic>).map((comment) => CommentExpandedModel.fromJson(comment as Map<String, dynamic>)))
      : null;
}