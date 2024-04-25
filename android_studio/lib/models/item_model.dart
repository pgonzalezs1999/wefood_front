class ItemModel {
  int? id;
  int? idProduct;
  DateTime? date;

  ItemModel.empty();

  ItemModel.fromJson(Map<String, dynamic> json):
    id = json['id'] as int?,
    idProduct = json['id_product'] as int?,
    date = _parseTime(json['date']);

  static DateTime? _parseTime(String? dateTime) { // Convertir HH:mm:ss a DateTime
    if(dateTime != null) {
      List<String> parts = dateTime.split(' ');
      List<String> date = parts[0].split('-');
      List<String> time = parts[1].split(':');
      return DateTime(int.parse(date[0]), int.parse(date[1]), int.parse(date[2]), int.parse(time[0]), int.parse(time[1]), int.parse(time[2]));
    } else {
      return null;
    }
  }

  static void printInfo(ItemModel item) {
    print('IMPRIMIENDO ITEM CON ID: ${item.id}');
    print('-> idProduct: ${item.idProduct}');
    print('-> date: ${item.date}');
  }
}