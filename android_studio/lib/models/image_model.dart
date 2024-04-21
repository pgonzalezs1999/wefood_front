import 'package:wefood/environment.dart';

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

  ImageModel.fromJson(Map<String, dynamic> json) {
    id = json['id'] as int?;
    image = json['image'] as String?;
    idUser = int.tryParse('${json['id_user']}');
    meaning = json['meaning'] as String?;
    if(image != null) {
      image = '${Environment.storageUrl}$image';
    }
  }

  static void printInfo(ImageModel image) {
    print('IMPRIMIENDO IMAGE CON ID: ${image.id}');
    print('-> image: ${image.image}');
    print('-> idUser: ${image.idUser}');
    print('-> meaning: ${image.meaning}');
  }
}