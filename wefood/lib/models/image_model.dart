import 'package:wefood/environment.dart';

class ImageModel {
  int? id;
  String? route;
  int? idUser;
  String? meaning;

  ImageModel.empty();

  ImageModel.fromJson(Map<String, dynamic> json) {
    id = json['id'] as int?;
    route = json['image'] as String?;
    idUser = int.tryParse('${json['id_user']}');
    meaning = json['meaning'] as String?;
    if(route != null) {
      route = '${Environment.storageUrl}$route';
    }
  }

  static void printInfo(ImageModel image) {
    print('IMPRIMIENDO IMAGE CON ID: ${image.id}');
    print('-> image: ${image.route}');
    print('-> idUser: ${image.idUser}');
    print('-> meaning: ${image.meaning}');
  }
}