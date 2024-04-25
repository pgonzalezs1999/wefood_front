import 'package:wefood/commands/utils.dart';

class ProductModel {
  int? id;
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
  String? type;

  ProductModel.empty();

  ProductModel.fromJson(Map<String, dynamic> json):
    id = int.tryParse('${json['id']}'),
    price = double.tryParse('${json['price']}'),
    amount = int.tryParse('${json['amount']}'),
    endingDate = (json['ending_date'] != null) ? DateTime.parse(json['ending_date']) as DateTime? : null,
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
    workingOnSunday = Utils.controlBool(json['working_on_sunday']) as bool?,
    type = json['type'] as String?;

  static DateTime? _parseTime(String? time) { // Convert HH:mm:ss to DateTime
    if(time != null) {
      DateTime result = DateTime.now();
      List<String> parts = time.split(':');
      result = result.copyWith(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
      return result;
    } else {
      return null;
    }
  }

  static void printInfo(ProductModel product) {
    print('IMPRIMIENDO PRODUCT CON ID: ${product.id}');
    print('-> price: ${product.price}');
    print('-> amount: ${product.amount}');
    print('-> endingDate: ${product.endingDate}');
    print('-> startingHour: ${product.startingHour}');
    print('-> endingHour: ${product.endingHour}');
    print('-> fresh: ${product.fresh}');
    print('-> bakery: ${product.bakery}');
    print('-> vegetarian: ${product.vegetarian}');
    print('-> vegan: ${product.vegan}');
    print('-> workingOnMonday: ${product.workingOnMonday}');
    print('-> workingOnTuesday: ${product.workingOnTuesday}');
    print('-> workingOnWednesday: ${product.workingOnWednesday}');
    print('-> workingOnThursday: ${product.workingOnThursday}');
    print('-> workingOnFriday: ${product.workingOnFriday}');
    print('-> workingOnSaturday: ${product.workingOnSaturday}');
    print('-> workingOnSunday: ${product.workingOnSunday}');
    print('-> type: ${product.type}');
  }
}