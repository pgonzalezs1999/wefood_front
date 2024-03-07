class CommentModel {
  int? id;
  int? idUser;
  double? rate;
  String? message;
  int? idBusiness;

  CommentModel.fromJson(Map<String, dynamic> json):
    id = json['id'] as int?,
    idUser = json['id_user'] as int?,
    rate = (json['rate'])?.toDouble(),
    message = json['message'] as String?,
    idBusiness = json['id_business'] as int?;
}