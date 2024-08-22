import 'package:wefood/commands/utils.dart';

class ProductModel {
  int? id;
  int? businessId;
  String? type;
  double? price;
  double? originalPrice;
  int? amount;
  DateTime? endingDate;
  DateTime? startingHour;
  DateTime? endingHour;
  bool? vegetarian;
  bool? mediterranean;
  bool? dessert;
  bool? junk;
  bool? workingOnMonday;
  bool? workingOnTuesday;
  bool? workingOnWednesday;
  bool? workingOnThursday;
  bool? workingOnFriday;
  bool? workingOnSaturday;
  bool? workingOnSunday;

  ProductModel.empty();

  ProductModel.fromJson(Map<String, dynamic> json):
    id = int.tryParse('${json['id']}'),
    businessId = int.tryParse('${json['id_business']}'),
    type = json['product_type'] as String?,
    price = double.tryParse('${json['price']}'),
    originalPrice = double.tryParse('${json['original_price']}'),
    amount = int.tryParse('${json['amount']}'),
    endingDate = (json['ending_date'] != null) ? DateTime.parse(json['ending_date']) as DateTime? : null,
    startingHour = _parseTime(json['starting_hour']),
    endingHour = _parseTime(json['ending_hour']),
    vegetarian = Utils.controlBool(json['vegetarian']) as bool?,
    mediterranean = Utils.controlBool(json['mediterranean']) as bool?,
    dessert = Utils.controlBool(json['dessert']) as bool?,
    junk = Utils.controlBool(json['junk']) as bool?,
    workingOnMonday = Utils.controlBool(json['working_on_monday']) as bool?,
    workingOnTuesday = Utils.controlBool(json['working_on_tuesday']) as bool?,
    workingOnWednesday = Utils.controlBool(json['working_on_wednesday']) as bool?,
    workingOnThursday = Utils.controlBool(json['working_on_thursday']) as bool?,
    workingOnFriday = Utils.controlBool(json['working_on_friday']) as bool?,
    workingOnSaturday = Utils.controlBool(json['working_on_saturday']) as bool?,
    workingOnSunday = Utils.controlBool(json['working_on_sunday']) as bool?;

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
    print('-> businessId: ${product.businessId}');
    print('-> type: ${product.type}');
    print('-> price: ${product.price}');
    print('-> originalPrice: ${product.originalPrice}');
    print('-> amount: ${product.amount}');
    print('-> endingDate: ${product.endingDate}');
    print('-> startingHour: ${product.startingHour}');
    print('-> endingHour: ${product.endingHour}');
    print('-> dessert: ${product.dessert}');
    print('-> junk: ${product.junk}');
    print('-> vegetarian: ${product.vegetarian}');
    print('-> mediterranean: ${product.mediterranean}');
    print('-> workingOnMonday: ${product.workingOnMonday}');
    print('-> workingOnTuesday: ${product.workingOnTuesday}');
    print('-> workingOnWednesday: ${product.workingOnWednesday}');
    print('-> workingOnThursday: ${product.workingOnThursday}');
    print('-> workingOnFriday: ${product.workingOnFriday}');
    print('-> workingOnSaturday: ${product.workingOnSaturday}');
    print('-> workingOnSunday: ${product.workingOnSunday}');
  }
}