import 'package:wefood/commands/utils.dart';
import 'package:wefood/environment.dart';
import 'package:flutter/widgets.dart';

double? _toDouble(dynamic value) {
  if(value is double) {
    return value;
  } else if(value is String) {
    return double.tryParse(value);
  } else if(value is int) {
    return value.toDouble();
  } else {
    return null;
  }
}

int? _toInt(dynamic value) {
  if(value is int) {
    return value;
  } else if(value is String) {
    return int.tryParse(value);
  } else {
    return null;
  }
}

DateTime? _parseDateTime(String? time) { // Convert HH:mm:ss to DateTime
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

DateTime? _parseTime(String? dateTime) { // Convertir HH:mm:ss a DateTime
  if(dateTime != null) {
    List<String> parts = dateTime.split(' ');
    List<String> date = parts[0].split('-');
    List<String> time = parts[1].split(':');
    return DateTime(int.parse(date[0]), int.parse(date[1]), int.parse(date[2]), int.parse(time[0]), int.parse(time[1]), int.parse(time[2]));
  } else {
    return null;
  }
}

class BusinessModel {
  int? id;
  int? idCountry;
  String? taxId;
  String? description;
  String? name;
  double? longitude;
  double? latitude;
  int? idBreakFastProduct;
  int? idLunchProduct;
  int? idDinnerProduct;
  String? directions;
  int? isValidated;
  double? rate;
  String? bankOwnerName;
  String? bankName;
  String? bankAccountType;
  String? bankAccount;
  String? interbankAccount;
  List<CommentExpandedModel>? comments;
  DateTime? createdAt;
  String? deletedAt;

  BusinessModel.empty();

  BusinessModel.fromJson(Map<String, dynamic> json):
    id = json['id'] as int?,
    idCountry = json['id_country'] as int?,
    taxId = json['tax_id'] as String?,
    description = json['description'] as String?,
    name = json['name'] as String?,
    longitude = (json['longitude'])?.toDouble(),
    latitude = (json['latitude'])?.toDouble(),
    idBreakFastProduct = json['id_breakfast_products'] as int?,
    idLunchProduct = json['id_lunch_products'] as int?,
    idDinnerProduct = json['id_dinner_products'] as int?,
    directions = json['directions'] as String?,
    isValidated = json['is_validated'] as int?,
    rate = (json['rate'])?.toDouble(),
    bankOwnerName = json['bank_owner_name'] as String?,
    bankName = json['bank_name'] as String?,
    bankAccountType = json['bank_account_type'] as String?,
    bankAccount = json['bank_account'] as String?,
    interbankAccount = json['interbank_account'] as String?,
    comments = json['comments'] != null
      ? List<CommentExpandedModel>.from((json['comments'] as List<dynamic>).map((comment) => CommentExpandedModel.fromJson(comment as Map<String, dynamic>)))
      : null,
    createdAt = (json['created_at'] != null) ? DateTime.parse(json['created_at']) as DateTime? : null,
    deletedAt = json['deleted_at'] as String?;
}

class BusinessExpandedModel {
  UserModel user;
  BusinessModel business;
  Image? image;
  bool? isFavourite;
  int? favourites;
  int? totalOrders;
  bool? requesterHasBought;

  BusinessExpandedModel.empty():
    user = UserModel.empty(),
    business = BusinessModel.empty();

  BusinessExpandedModel.fromJson(Map<String, dynamic> json):
    user = (json['user'] != null) ? UserModel.fromJson(json['user'] as Map<String, dynamic>) : UserModel.empty(),
    business = (json['business'] != null) ? BusinessModel.fromJson(json['business'] as Map<String, dynamic>) : BusinessModel.empty(),
    isFavourite = ((json['is_favourite'] != null) ? Utils.controlBool(json['is_favourite']) as bool? : null),
    favourites = json['favourites'] as int?,
    totalOrders = json['total_orders'] as int?,
    requesterHasBought = Utils.controlBool(json['requester_has_bought']);

  BusinessExpandedModel.fromParameters({
    required BusinessModel businessModel,
    required UserModel userModel,
  }):
    user = userModel,
    business = businessModel;
}

class UserModel {
  int? id;
  String? realName;
  String? realSurname;
  String? username;
  String? email;
  bool? emailVerified;
  bool? isAdmin;
  int? phone;
  int? phonePrefix;
  int? sex;
  double? lastLongitude;
  double? lastLatitude;
  DateTime? lastLoginDate;
  int? idBusiness;
  int? businessVerified;

  UserModel.empty();

  UserModel.fromJson(Map<String, dynamic> json):
    id = json['id'] as int?,
    realName = json['real_name'] as String?,
    realSurname = json['real_surname'] as String?,
    username = json['username'] as String?,
    email = json['email'] as String?,
    emailVerified = json['email_verified'] != null ? (json['email_verified'] == 'true' || json['email_verified'] == true || json['email_verified'] == 1) : null,
    isAdmin = json['is_admin'] != null ? (json['is_admin'] == 'true' || json['is_admin'] == true || json['is_admin'] == 1) : null,
    phone = json['phone'] as int?,
    phonePrefix = json['phone_prefix'] as int?,
    sex = json['sex'] as int?,
    lastLongitude = json['last_longitude'] as double?,
    lastLatitude = json['last_latitude'] as double?,
    lastLoginDate = json['last_login_date'] as DateTime?,
    idBusiness = json['id_business'] as int?,
    businessVerified = json['business_verified'] as int?;
}

class AuthModel {
  final String? accessToken;
  final int? expiresAt;
  final String? error;

  AuthModel.fromJson(Map<String, dynamic> json):
    accessToken = json['access_token'] as String?,
    expiresAt = json['expires_in'] as int?,
    error = json['error'] as String?;

  AuthModel.empty():
    accessToken = null,
    expiresAt = null,
    error = null;

  AuthModel.fromParameters(String? newAccessToken, int? newExpiresAt):
    accessToken = newAccessToken,
    expiresAt = newExpiresAt,
    error = null;
}

class RetributionModel {
  int? id;
  DateTime? date;
  int? idBusiness;
  double? amount;
  String? transferId;
  int? status;

  RetributionModel.empty();

  RetributionModel.fromJson(Map<String, dynamic> json) {
    id = _toInt(json['id'] as int?);
    date = _parseTime(json['date']);
    idBusiness = _toInt(json['id_business'] as int?);
    amount = _toDouble(json['amount']);
    transferId = json['transfer_id'] as String?;
    status = _toInt(json['status'] as int?) ?? 0;
  }
}

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
}

class BusinessProductsResumeModel {
  ProductModel? breakfast;
  ProductModel? lunch;
  ProductModel? dinner;

  BusinessProductsResumeModel.fromJson(Map<String, dynamic> json):
    breakfast = (json['breakfast'] != null) ? ProductModel.fromJson(json['breakfast'] as Map<String, dynamic>) as ProductModel? : null,
    lunch = (json['lunch'] != null) ? ProductModel.fromJson(json['lunch'] as Map<String, dynamic>) as ProductModel? : null,
    dinner = (json['dinner'] != null) ? ProductModel.fromJson(json['dinner'] as Map<String, dynamic>) as ProductModel? : null;
}

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
    startingHour = _parseDateTime(json['starting_hour']),
    endingHour = _parseDateTime(json['ending_hour']),
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
}

class ProductExpandedModel {
  ProductModel product;
  ItemModel item;
  OrderModel order;
  BusinessModel business;
  UserModel user;
  bool? isFavourite;
  int? favourites;
  int? available;
  ImageModel image;

  ProductExpandedModel.empty():
    product = ProductModel.empty(),
    item = ItemModel.empty(),
    order = OrderModel.empty(),
    business = BusinessModel.empty(),
    user = UserModel.empty(),
    image = ImageModel.empty();

  ProductExpandedModel.fromJson(Map<String, dynamic> json) :
    product = (json['product'] != null) ? ProductModel.fromJson(json['product'] as Map<String, dynamic>) : ProductModel.empty(),
    item = (json['item'] != null) ? ItemModel.fromJson(json['item'] as Map<String, dynamic>) : ItemModel.empty(),
    order = (json['order'] != null) ? OrderModel.fromJson(json['order'] as Map<String, dynamic>) : OrderModel.empty(),
    business = (json['business'] != null) ? BusinessModel.fromJson(json['business'] as Map<String, dynamic>) : BusinessModel.empty(),
    user = (json['user'] != null) ? UserModel.fromJson(json['user'] as Map<String, dynamic>) : UserModel.empty(),
    isFavourite = ((json['is_favourite'] != null) ? Utils.controlBool(json['is_favourite']) as bool? : null),
    favourites = json['favourites'] as int?,
    available = json['available'] as int?,
    image = (json['image'] != null) ? ImageModel.fromJson(json['image'] as Map<String, dynamic>) : ImageModel.empty();

  ProductExpandedModel.fromParameters({
    required UserModel newUser,
    required BusinessModel newBusiness,
    required ProductModel newProduct,
    required ItemModel newItem,
    required OrderModel newOrder,
    required ImageModel newImage,
  }):
    user = newUser,
    business = newBusiness,
    product = newProduct,
    item = newItem,
    order = newOrder,
    image = newImage;
}

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
}


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
}

class ImageModel {
  int? id;
  String? route;
  int? idUser;
  String? meaning;

  ImageModel.empty();

  ImageModel.fromJson(Map<String, dynamic> json) {
    id = json['id'] as int?;
    route = json['image'] as String?;
    idUser = int.tryParse('${json['id_user']}');
    meaning = json['meaning'] as String?;
    if(route != null) {
      route = '${Environment.storageUrl}$route';
    }
  }
}

class HttpErrorResponseModel implements Exception {
  final String code;
  final String message;

  HttpErrorResponseModel(this.code, this.message);

  HttpErrorResponseModel.fromJson(Map<String, dynamic> json) :
    code = json['code'],
    message = json['message'];
}

class FavouriteModel {
  int? id;
  int? idUser;
  int? idBusiness;

  FavouriteModel.empty();

  FavouriteModel.fromJson(Map<String, dynamic> json):
    id = json['id'] as int?,
    idUser = json['id_user'] as int?,
    idBusiness = json['id_business'] as int?;
}

class CommentModel {
  int? id;
  int? idUser;
  double? rate;
  String? message;
  int? idBusiness;

  CommentModel.empty();

  CommentModel.fromJson(Map<String, dynamic> json) {
    id = _toInt(json['id'] as int?);
    idUser = _toInt(json['id_user'] as int?);
    rate = _toDouble(json['rate']);
    message = json['message'] as String?;
    idBusiness = _toInt(json['id_business'] as int?);
  }
}

class CommentExpandedModel {
  CommentModel comment;
  UserModel user;
  ImageModel image;

  CommentExpandedModel.empty():
    comment = CommentModel.empty(),
    user = UserModel.empty(),
    image = ImageModel.empty();

  CommentExpandedModel.fromJson(Map<String, dynamic> json):
    comment = (json['content'] != null) ? CommentModel.fromJson(json['content'] as Map<String, dynamic>) : CommentModel.empty(),
    user = (json['user'] != null) ? UserModel.fromJson(json['user'] as Map<String, dynamic>) : UserModel.empty(),
    image = (json['image'] != null) ? ImageModel.fromJson(json['image'] as Map<String, dynamic>) : ImageModel.empty();

  CommentExpandedModel.fromParameters({
    required CommentModel commentModel,
    required UserModel userModel,
  }):
    comment = commentModel,
    user = userModel,
    image = ImageModel.empty();
}

class BankCardModel {
  String? ownerName;
  int? cardNumber;
  int? expirationMonth;
  int? expirationYear;

  BankCardModel.empty();

  BankCardModel.fromJson(Map<String, dynamic> json) {
    ownerName = json['owner_name'] as String?;
    cardNumber = _toInt(json['card_number'] as int?);
    expirationMonth = _toInt(json['expiration_month'] as int?);
    expirationYear = _toInt(json['expiration_year'] as int?);
  }
}

class AppException implements Exception {
  final String? titleMessage;
  final String? descriptionMessage;
  final String imageUrl;

  AppException({
    this.titleMessage,
    this.descriptionMessage,
    this.imageUrl = 'assets/images/logo.png',
  });
}

class WefoodBadRequestException extends AppException {
  WefoodBadRequestException(): super(
    titleMessage: 'Bad request',
    descriptionMessage: 'Poner algo más bonito aquí',
  );
}

class WefoodFetchDataException extends AppException {
  WefoodFetchDataException(): super(
    titleMessage: '¡No hay internet!',
    descriptionMessage: 'No podemos encontrar tu comida favorita sin conexión a internet...',
  );
}

class WefoodApiNotRespondingException extends AppException {
  WefoodApiNotRespondingException(): super(
    titleMessage: 'No ha sido posible conectar con el servidor',
    descriptionMessage: 'Por favor, inténtelo de nuevo más tarde',
  );
}

class WefoodUnauthorizedException extends AppException {
  WefoodUnauthorizedException(): super(
    titleMessage: 'Usuario o contraseña incorrectos',
  );
}

class WefoodDefaultException extends AppException {
  WefoodDefaultException(): super(
    titleMessage: '¡Algo ha ido mal!',
    descriptionMessage: 'Si el error persiste, contacte con soporte técnico',
  );
}