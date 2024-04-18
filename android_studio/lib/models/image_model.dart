class ImageModel {
  int? id;
  String? image;
  int? idUser;
  String? meaning;

  ImageModel.empty():
    id = null,
    image = null,
    idUser = null,
    meaning = null;

  ImageModel.fromJson(Map<String, dynamic> json):
    id = json['id'] as int?,
    image = json['image'] as String?,
    idUser = json['id_user'] as int?,
    meaning = json['image'] as String?;

  static void printInfo(ImageModel product) {
    print('IMPRIMIENDO IMAGE CON ID: ${product.id}');
    print('-> image: ${product.image}');
    print('-> idUser: ${product.idUser}');
    print('-> meaning: ${product.meaning}');
  }
}