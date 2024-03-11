class FavouriteModel {
  int? id;
  int? idUser;
  int? idBusiness;

  FavouriteModel.fromJson(Map<String, dynamic> json):
    id = json['id'] as int?,
    idUser = json['id_user'] as int?,
    idBusiness = json['id_business'] as int?;
}