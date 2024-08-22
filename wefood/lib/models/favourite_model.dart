import 'package:flutter/foundation.dart';

class FavouriteModel {
  int? id;
  int? idUser;
  int? idBusiness;

  FavouriteModel.empty();

  FavouriteModel.fromJson(Map<String, dynamic> json):
    id = json['id'] as int?,
    idUser = json['id_user'] as int?,
    idBusiness = json['id_business'] as int?;

  static void printInfo(FavouriteModel favourite) {
    if(kDebugMode) {
      print('IMPRIMIENDO FAVOURITE CON ID: ${favourite.id}');
      print('-> idUser: ${favourite.idUser}');
      print('-> idBusiness: ${favourite.idBusiness}');
    }
  }
}