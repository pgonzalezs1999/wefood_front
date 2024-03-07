class ProductModel {
  int id;
  String? description;
  double? price;
  int? amount;
  DateTime? endingDate;
  DateTime? startingHour;
  DateTime? endingHour;
  bool? vegetarian;
  bool? vegan;
  bool? bakery;
  bool? fresh;
  bool? workingOnMonday;
  bool? workingOnTuesday;
  bool? workingOnWednesday;
  bool? workingOnThursday;
  bool? workingOnFriday;
  bool? workingOnSaturday;
  bool? workingOnSunday;

  ProductModel.fromJson(Map<String, dynamic> json):
    id = json['id'] as int,
    description = json['description'] as String?,
    price = (json['price']).toDouble(),
    amount = json['amount'] as int?,
    endingDate = json['ending_date'] as DateTime?,
    startingHour = _parseTime(json['starting_hour']),
    endingHour = _parseTime(json['ending_hour']),
    vegetarian = (json['vegetarian'] == 1),
    vegan = (json['vegan'] == 1),
    bakery = (json['bakery'] == 1),
    fresh = (json['fresh'] == 1),
    workingOnMonday = (json['working_on_monday'] == 1),
    workingOnTuesday = (json['working_on_tuesday'] == 1),
    workingOnWednesday = (json['working_on_wednesday'] == 1),
    workingOnThursday = (json['working_on_thursday'] == 1),
    workingOnFriday = (json['working_on_friday'] == 1),
    workingOnSaturday = (json['working_on_saturday'] == 1),
    workingOnSunday = (json['working_on_sunday'] == 1);

  static DateTime? _parseTime(String? time) { // Convertir HH:mm:ss a DateTime
    if(time != null) {
      List<String> parts = time.split(':');
      return DateTime(0, 1, 1, int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
    } else {
      return null;
    }
  }
}