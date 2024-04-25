class CountryModel {
  int? id;
  String? name;
  int? prefix;
  String? googleMapsName;

  CountryModel.empty();

  CountryModel.fromJson(Map<String, dynamic> json):
    id = json['id'] as int,
    name = json['name'] as String,
    prefix = json['prefix'] as int,
    googleMapsName = json['google_maps_name'];

  CountryModel.fromParameters(
    int newId,
    String newName,
    int newPrefix,
    String newGoogleMapsName,
  ):
    id = newId,
    name = newName,
    prefix = newPrefix,
    googleMapsName = newGoogleMapsName;

  static void printInfo(CountryModel country) {
    print('IMPRIMIENDO COUNTRY CON ID: ${country.id}');
    print('-> name: ${country.name}');
    print('-> prefix: ${country.prefix}');
    print('-> googleMapsName: ${country.googleMapsName}');
  }
}