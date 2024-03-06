class ExploreModel {
  final int id;
  final bool vegetarian;
  final bool vegan;
  final bool bakery;
  final bool fresh;
  final String title;
  final double rate;
  final double price;
  final String? currency;
  final DateTime? day;
  final DateTime startTime;
  final DateTime endTime;
  final int? amount;
  final bool isFavourite;

  ExploreModel.fromJson(Map<String, dynamic> json):
    id = json['business']['id'] as int,
    vegetarian = (json['vegetarian'] == 1),
    vegan = (json['vegan'] == 1),
    bakery = (json['bakery'] == 1),
    fresh = (json['fresh'] == 1),
    title = json['business']['name'] as String,
    rate = (json['business']['rate']).toDouble(),
    price = (json['price']).toDouble(),
    currency = 'Sol/.', // TODO falta
    day = null, // TODO falta // TODO no implementado para favoritos
    startTime = _parseTime(json['starting_hour']),
    endTime = _parseTime(json['ending_hour']),
    amount = null, // TODO falta // TODO no implementado para favoritos
    isFavourite = json['favourite'] ?? false; // TODO falta

  static DateTime _parseTime(String time) { // Convertir HH:mm:ss a DateTime
    List<String> parts = time.split(':');
    return DateTime(0, 1, 1, int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
  }
}