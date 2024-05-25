import 'package:wefood/models/models.dart';
import 'package:wefood/commands/utils.dart';

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

  static void printInfo(ProductExpandedModel product) {
    print('------------------------------');
    ProductModel.printInfo(product.product);
    ItemModel.printInfo(product.item);
    OrderModel.printInfo(product.order);
    UserModel.printInfo(product.user);
    BusinessModel.printInfo(product.business);
    ImageModel.printInfo(product.image);
    print('--------');
    print('-> isFavourite: ${product.isFavourite}');
    print('-> favourites: ${product.favourites}');
    print('-> available: ${product.available}');
    print('------------------------------');
  }
}