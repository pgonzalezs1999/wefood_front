class CountryModel {
  int id;
  String name;
  int prefix;

  CountryModel.fromJson(Map<String, dynamic> json):
    id = json['id'] as int,
    name = json['name'] as String,
    prefix = json['prefix'] as int;

  CountryModel.fromParameters(
    int newId,
    String newName,
    int newPrefix
  ):
    id = newId,
    name = newName,
    prefix = newPrefix;
}