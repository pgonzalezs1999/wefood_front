class OrderModel {
  int? id;
  int? idUser;
  DateTime? orderDate;
  DateTime? receptionDate;
  int? receptionMethod;
  int? amount;
  int? available;
  int? idBusiness;
  String? mealType;
  int? idPayment;
  int? idItem;

  OrderModel.fromJson(Map<String, dynamic> json):
    id = json['id'] as int?,
    idUser = json['id_user'] as int?,
    orderDate = json['order_date'] as DateTime?,
    receptionDate = json['reception_date'] as DateTime?,
    receptionMethod = json['reception_method'] as int?,
    amount = json['amount'] as int?,
    available = json['available'] as int?,
    idBusiness = json['id_business'] as int?,
    mealType = json['meal_type'] as String?,
    idPayment = json['id_payment'] as int?,
    idItem = json['id_item'] as int?;
}