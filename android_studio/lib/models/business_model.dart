import 'package:wefood/models/comment_model.dart';

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
  bool? isValidated;
  double? rate;
  List<CommentModel>? comments;

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
    isValidated = (json['is_validated'] == 1),
    rate = (json['rate'])?.toDouble(),
    comments = json['comments'] != null
      ? List<CommentModel>.from((json['comments'] as List<dynamic>).map((comment) => CommentModel.fromJson(comment as Map<String, dynamic>)))
      : null;
}