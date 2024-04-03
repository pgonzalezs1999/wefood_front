import 'package:wefood/utils.dart';

class ProductModel {
  int id;
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
    price = (json['price']).toDouble(),
    amount = json['amount'] as int?,
    endingDate = json['ending_date'] as DateTime?,
    startingHour = _parseTime(json['starting_hour']),
    endingHour = _parseTime(json['ending_hour']),
    vegetarian = Utils.controlBool(json['vegetarian']) as bool?,
    vegan = Utils.controlBool(json['vegan']) as bool?,
    bakery = Utils.controlBool(json['bakery']) as bool?,
    fresh = Utils.controlBool(json['fresh']) as bool?,
    workingOnMonday = Utils.controlBool(json['working_on_monday']) as bool?,
    workingOnTuesday = Utils.controlBool(json['working_on_tuesday']) as bool?,
    workingOnWednesday = Utils.controlBool(json['working_on_wednesday']) as bool?,
    workingOnThursday = Utils.controlBool(json['working_on_thursday']) as bool?,
    workingOnFriday = Utils.controlBool(json['working_on_friday']) as bool?,
    workingOnSaturday = Utils.controlBool(json['working_on_saturday']) as bool?,
    workingOnSunday = Utils.controlBool(json['working_on_sunday']) as bool?;

  static DateTime? _parseTime(String? time) { // Convertir HH:mm:ss a DateTime
    if(time != null) {
      List<String> parts = time.split(':');
      return DateTime(0, 1, 1, int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
    } else {
      return null;
    }
  }
}