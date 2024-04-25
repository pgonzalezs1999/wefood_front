class OrderModel {
  int? id;
  int? idUser;
  DateTime? orderDate;
  DateTime? receptionDate;
  String? receptionMethod;
  int? amount;
  int? available;
  int? idBusiness;
  String? mealType;
  int? idPayment;
  int? idItem;

  OrderModel.empty();

  OrderModel.fromJson(Map<String, dynamic> json):
    id = json['id'] as int?,
    idUser = json['id_user'] as int?,
    orderDate = (json['order_date'] != null) ? DateTime.parse(json['order_date']) as DateTime? : null,
    receptionDate = (json['reception_date'] != null) ? DateTime.parse(json['reception_date']) as DateTime? : null,
    receptionMethod = json['reception_method'] as String?,
    amount = json['amount'] as int?,
    available = json['available'] as int?,
    idBusiness = json['id_business'] as int?,
    mealType = json['meal_type'] as String?,
    idPayment = json['id_payment'] as int?,
    idItem = json['id_item'] as int?;

  static void printInfo(OrderModel order) {
    print('IMPRIMIENDO BUSINESS CON ID: ${order.id}');
    print('-> idUser: ${order.idUser}');
    print('-> orderDate: ${order.orderDate}');
    print('-> receptionDate: ${order.receptionDate}');
    print('-> receptionMethod: ${order.receptionMethod}');
    print('-> amount: ${order.amount}');
    print('-> available: ${order.available}');
    print('-> idBusiness: ${order.idBusiness}');
    print('-> mealType: ${order.mealType}');
    print('-> idPayment: ${order.idPayment}');
    print('-> idItem: ${order.idItem}');
  }
}