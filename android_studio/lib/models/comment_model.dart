class CommentModel {
  int? id;
  int? idUser;
  double? rate;
  String? message;
  int? idBusiness;

  CommentModel.empty();

  CommentModel.fromJson(Map<String, dynamic> json):
    id = json['id'] as int?,
    idUser = json['id_user'] as int?,
    rate = (json['rate'])?.toDouble(),
    message = json['message'] as String?,
    idBusiness = json['id_business'] as int?;

  static void printInfo(CommentModel comment) {
    print('IMPRIMIENDO COMMENT CON ID: ${comment.id}');
    print('-> idUser: ${comment.idUser}');
    print('-> rate: ${comment.rate}');
    print('-> message: ${comment.message}');
    print('-> idBusiness: ${comment.idBusiness}');
  }
}