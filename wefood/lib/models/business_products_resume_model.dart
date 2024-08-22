import 'package:wefood/models/models.dart';

class BusinessProductsResumeModel {
  ProductModel? breakfast;
  ProductModel? lunch;
  ProductModel? dinner;

  BusinessProductsResumeModel.fromJson(Map<String, dynamic> json):
    breakfast = (json['breakfast'] != null) ? ProductModel.fromJson(json['breakfast'] as Map<String, dynamic>) as ProductModel? : null,
    lunch = (json['lunch'] != null) ? ProductModel.fromJson(json['lunch'] as Map<String, dynamic>) as ProductModel? : null,
    dinner = (json['dinner'] != null) ? ProductModel.fromJson(json['dinner'] as Map<String, dynamic>) as ProductModel? : null;
}