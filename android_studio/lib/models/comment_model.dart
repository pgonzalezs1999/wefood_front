class CommentModel {
  int? id;
  int? idUser;
  double? rate;
  String? message;
  int? idBusiness;

  CommentModel.empty();

  CommentModel.fromJson(Map<String, dynamic> json) {
    id = _toInt(json['id'] as int?);
    idUser = _toInt(json['id_user'] as int?);
    rate = _toDouble(json['rate']);
    message = json['message'] as String?;
    idBusiness = _toInt(json['id_business'] as int?);
  }

  static void printInfo(CommentModel comment) {
    print('IMPRIMIENDO COMMENT CON ID: ${comment.id}');
    print('-> idUser: ${comment.idUser}');
    print('-> rate: ${comment.rate}');
    print('-> message: ${comment.message}');
    print('-> idBusiness: ${comment.idBusiness}');
  }

  double? _toDouble(dynamic value) {
    if(value is double) {
      return value;
    } else if(value is String) {
      return double.tryParse(value);
    } else if(value is int) {
      return value.toDouble();
    } else {
      return null;
    }
  }

  int? _toInt(dynamic value) {
    if(value is int) {
      return value;
    } else if(value is String) {
      return int.tryParse(value);
    } else {
      return null;
    }
  }
}