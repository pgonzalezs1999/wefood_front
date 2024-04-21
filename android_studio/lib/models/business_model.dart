import 'package:wefood/models/models.dart';

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
  DateTime? createdAt;
  List<CommentExpandedModel>? comments;

  BusinessModel.empty():
    id = null,
    idCountry = null,
    taxId = null,
    description = null,
    name = null,
    longitude = null,
    latitude = null,
    idBreakFastProduct = null,
    idLunchProduct = null,
    idDinnerProduct = null,
    directions = null,
    isValidated = null,
    rate = null,
    createdAt = null,
    comments = null;

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
    createdAt = (json['created_at'] != null) ? DateTime.parse(json['created_at']) as DateTime? : null,
    comments = json['comments'] != null
      ? List<CommentExpandedModel>.from((json['comments'] as List<dynamic>).map((comment) => CommentExpandedModel.fromJson(comment as Map<String, dynamic>)))
      : null;

  static void printInfo(BusinessModel business) {
    print('IMPRIMIENDO BUSINESS CON ID: ${business.id}');
    print('-> idCountry: ${business.idCountry}');
    print('-> taxId: ${business.taxId}');
    print('-> description: ${business.description}');
    print('-> name: ${business.name}');
    print('-> longitude: ${business.longitude}');
    print('-> latitude: ${business.latitude}');
    print('-> idBreakFastProduct: ${business.idBreakFastProduct}');
    print('-> idLunchProduct: ${business.idLunchProduct}');
    print('-> idDinnerProduct: ${business.idDinnerProduct}');
    print('-> directions: ${business.directions}');
    print('-> isValidated: ${business.isValidated}');
    print('-> rate: ${business.rate}');
    print('-> createdAt: ${business.createdAt}');
    print('-> comments: ${business.comments}');
  }
}