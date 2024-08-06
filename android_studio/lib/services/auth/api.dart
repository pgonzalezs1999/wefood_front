import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:wefood/commands/clear_data.dart';
import 'package:wefood/commands/utils.dart';
import 'package:wefood/models/models.dart';
import 'package:wefood/services/auth/middleware.dart';
import 'package:wefood/types.dart';
import 'dart:convert';

class Api {
  static Future<AuthModel> login({
    required BuildContext context,
    required String username,
    required String password,
  }) async {
    try {
      dynamic response = await Middleware.endpoint(
        name: 'login',
        type: HttpType.post,
        body: {
          'username': username,
          'password': password,
        },
        needsAccessToken: false,
      );
      AuthModel authModel = AuthModel.fromJson(response);
      return authModel;
    } catch(error) { rethrow; }
  }

  static Future<String> logout() async {
    try {
      dynamic response = await Middleware.endpoint(
        name: 'logout',
        type: HttpType.get,
      );
      return response['message'];
    } catch(error) { rethrow; }
  }

  static Future signOut(BuildContext context) async {
    try {
      Middleware.endpoint(
        name: 'signout',
        type: HttpType.post,
      ).then((_) {
        clearData(context);
      });
    } catch(error) { rethrow; }
  }

  static Future<UserModel> getProfile() async {
    try {
      final response = await Middleware.endpoint(
        name: 'getProfile',
        type: HttpType.get,
      );
      UserModel userModel = UserModel.fromJson(response['message']);
      return userModel;
    } catch(error) { rethrow; }
  }

  static Future<BusinessExpandedModel> getSessionBusiness() async {
    try {
      final response = await Middleware.endpoint(
        name: 'getSessionBusiness',
        type: HttpType.get,
      );
      BusinessExpandedModel businessModel = BusinessExpandedModel.fromJson(response);
      return businessModel;
    } catch(error) { rethrow; }
  }

  static updateUsername({
    required String username,
  }) async {
    try {
      dynamic response = await Middleware.endpoint(
          name: 'updateUsername',
          type: HttpType.post,
          body: {
            'username': username,
          }
      );
      return response;
    } catch(error) { rethrow; }
  }

  static updateRealName({
    required String name,
    required String surname,
  }) async {
    try {
      dynamic response = await Middleware.endpoint(
        name: 'updateRealName',
        type: HttpType.post,
        body: {
          'real_name': name,
          'real_surname': surname,
        }
      );
      return response;
    } catch(error) { rethrow; }
  }

  static updateBusinessName({
    required String name,
  }) async {
    try {
      dynamic response = await Middleware.endpoint(
          name: 'updateBusinessName',
          type: HttpType.post,
          body: {
            'name': name.toString(),
          }
      );
      return response;
    } catch(error) { rethrow; }
  }

  static updateBusinessDescription({
    required String description,
  }) async {
    try {
      dynamic response = await Middleware.endpoint(
          name: 'updateBusinessDescription',
          type: HttpType.post,
          body: {
            'description': description.toString(),
          }
      );
      return response;
    } catch(error) { rethrow; }
  }

  static updateBusinessDirections({
    required String directions,
    required String country,
    required double longitude,
    required double latitude,
  }) async {
    try {
      dynamic response = await Middleware.endpoint(
          name: 'updateBusinessDirections',
          type: HttpType.post,
          body: {
            'directions': directions.toString(),
            'country': country.toString(),
            'longitude': longitude.toString(),
            'latitude': latitude.toString(),
          }
      );
      return response;
    } catch(error) { rethrow; }
  }

  static Future<List<ProductExpandedModel>> getFavouriteItems() async {
    try {
      dynamic response = await Middleware.endpoint(
        name: 'getFavouriteItems',
        type: HttpType.get,
      );
      List<ProductExpandedModel> products = (response['products'] as List<dynamic>).map((product) => ProductExpandedModel.fromJson(product)).toList();
      return products;
    } catch(error) { rethrow; }
  }

  static Future<List<ProductExpandedModel>> getNearbyBusinesses({
    required double longitude,
    required double latitude,
  }) async {
    try {
      dynamic response = await Middleware.endpoint(
          name: 'getNearbyBusinesses',
          type: HttpType.post,
          body: {
            'longitude': longitude.toString(),
            'latitude': latitude.toString(),
          }
      );
      List<ProductExpandedModel> products = (response['items'] as List<dynamic>).map((product) => ProductExpandedModel.fromJson(product)).toList();
      return products;
    } catch(error) { rethrow; }
  }

  static Future<List<ProductExpandedModel>> getNearbyItems({
    required double longitude,
    required double latitude,
  }) async {
    try {
      dynamic response = await Middleware.endpoint(
        name: 'getNearbyItems',
        type: HttpType.post,
        body: {
          'longitude': longitude.toString(),
          'latitude': latitude.toString(),
        }
      );
      List<ProductExpandedModel> products = (response['items'] as List<dynamic>).map((product) => ProductExpandedModel.fromJson(product)).toList();
      return products;
    } catch(error) { rethrow; }
  }

  static Future<List<ProductExpandedModel>> getRecommendedItems({
    required double longitude,
    required double latitude,
  }) async {
    try {
      dynamic response = await Middleware.endpoint(
          name: 'getRecommendedItems',
          type: HttpType.post,
          body: {
            'longitude': longitude.toString(),
            'latitude': latitude.toString(),
          }
      );
      List<ProductExpandedModel> products = (response['items'] as List<dynamic>).map((product) => ProductExpandedModel.fromJson(product)).toList();
      return products;
    } catch(error) { rethrow; }
  }

  static Future<ProductExpandedModel> getProduct({
    required int id,
  }) async {
    try {
      dynamic response = await Middleware.endpoint(
        name: 'getProduct/$id',
        type: HttpType.get,
      );
      ProductExpandedModel product = ProductExpandedModel.fromJson(response);
      return product;
    } catch(error) { rethrow; }
  }

  static Future<ProductExpandedModel> getItem({
    required int id,
  }) async {
    try {
      dynamic response = await Middleware.endpoint(
        name: 'getItem/$id',
        type: HttpType.get,
      );
      ProductExpandedModel product = ProductExpandedModel.fromJson(response);
      return product;
    } catch(error) { rethrow; }
  }

  static Future<FavouriteModel> addFavourite({
    required int idBusiness,
  }) async {
    try {
      dynamic response = await Middleware.endpoint(
        name: 'addFavourite',
        type: HttpType.post,
        body: {
          'id_business': idBusiness.toString(),
        }
      );
      FavouriteModel favourite = FavouriteModel.fromJson(response);
      return favourite;
    } catch(error) { rethrow; }
  }

  static Future<FavouriteModel> removeFavourite({
    required int idBusiness,
  }) async {
    try {
      dynamic response = await Middleware.endpoint(
        name: 'removeFavourite',
        type: HttpType.post,
        body: {
          'id_business': idBusiness.toString(),
        }
      );
      FavouriteModel favourite = FavouriteModel.fromJson(response['favourite']);
      return favourite;
    } catch(error) { rethrow; }
  }

  static Future<bool> checkUsernameAvailability({
    required String username,
  }) async {
    try {
      dynamic response = await Middleware.endpoint(
        name: 'checkUsernameAvailability',
        type: HttpType.post,
        body: {
          'username': username,
        }
      );
      return response['availability'];
    } catch(error) { rethrow; }
  }

  static Future<bool> checkEmailAvailability({
    required String email,
  }) async {
    try {
      dynamic response = await Middleware.endpoint(
        name: 'checkEmailAvailability',
        type: HttpType.post,
        body: {
          'email': email.toString(),
        }
      );
      return response['availability'];
    } catch(error) { rethrow; }
  }

  static Future<bool> checkPhoneAvailability({
    required String phone,
  }) async {
    try {
      dynamic response = await Middleware.endpoint(
        name: 'checkPhoneAvailability',
        type: HttpType.post,
        body: {
          'phone': phone.toString(),
        }
      );
      return response['availability'];
    } catch(error) { rethrow; }
  }

  static Future<bool> checkTaxIdAvailability({
    required String taxId,
  }) async {
    try {
      dynamic response = await Middleware.endpoint(
          name: 'checkTaxIdAvailability',
          type: HttpType.post,
          body: {
            'tax_id': taxId.toString(),
          }
      );
      return response['availability'];
    } catch(error) { rethrow; }
  }

  static Future<List<CountryModel>> getAllCountries() async {
    try {
      dynamic response = await Middleware.endpoint(
        name: 'getAllCountries',
        type: HttpType.get,
        needsAccessToken: false,
      );
      List<CountryModel> countries = (response['message'] as List<dynamic>).map((country) => CountryModel.fromJson(country)).toList();
      return countries;
    } catch(error) { rethrow; }
  }

  static Future<UserModel> signIn({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      dynamic response = await Middleware.endpoint(
        name: 'signIn',
        type: HttpType.post,
        body: {
          'username': username.toString(),
          'email': email.toString(),
          'password': password.toString(),
        }
      );
      return UserModel.fromJson(response['user']);
    } catch(error) { rethrow; }
  }

  static Future createBusiness({
    required String email,
    required String password,
    required int phonePrefix,
    required int phone,
    required String businessName,
    required String businessDescription,
    required String taxId,
    required String directions,
    required String country,
    required double longitude,
    required double latitude,
  }) async {
    try {
      await Middleware.endpoint(
        name: 'createBusiness',
        type: HttpType.post,
        body: {
          'email': email.toString(),
          'password': password.toString(),
          'phone_prefix': phonePrefix.toString(),
          'phone': phone.toString(),
          'name': businessName.toString(),
          'description': businessDescription.toString(),
          'tax_id': taxId.toString(),
          'directions': directions.toString(),
          'country': country.toString(),
          'longitude': longitude.toString(),
          'latitude': latitude.toString(),
        }
      );
    } catch(error) { rethrow; }
  }

  static Future<bool> checkValidity({
    required String username,
  }) async {
    try {
      dynamic response = await Middleware.endpoint(
        name: 'checkValidity',
        type: HttpType.post,
        body: {
          'username': username.toString(),
        },
      );
      bool validity = (response['validity'] == 1 || response['validity'] == '1' || response['validity'] == true);
      return validity;
    } catch(error) { rethrow; }
  }

  static Future cancelValidation({
    required String username,
  }) async {
    try {
      dynamic response = await Middleware.endpoint(
        name: 'cancelValidation',
        type: HttpType.post,
        body: {
          'username': username.toString(),
        },
      );
      if(response['message'] == null) {
        throw Exception(response['error']);
      }
    } catch(error) { rethrow; }
  }

  static Future<BusinessProductsResumeModel> getBusinessProductsResume() async {
    try {
      final response = await Middleware.endpoint(
        name: 'businessProductsResume',
        type: HttpType.get,
      );
      BusinessProductsResumeModel result = BusinessProductsResumeModel.fromJson(response);
      return result;
    } catch(error) { rethrow; }
  }

  static Future<ProductModel> updateProduct({
    required int id,
    required double price,
    required double originalPrice,
    required int amount,
    required String? endingDate,
    required String startHour,
    required String endHour,
    required String vegetarian,
    required String mediterranean,
    required String junk,
    required String dessert,
    required String workingOnMonday,
    required String workingOnTuesday,
    required String workingOnWednesday,
    required String workingOnThursday,
    required String workingOnFriday,
    required String workingOnSaturday,
    required String workingOnSunday,
  }) async {
    try {
      final response = await Middleware.endpoint(
        name: 'updateProduct',
        type: HttpType.post,
        body: {
          'id': id.toString(),
          'price': price.toString(),
          'original_price': originalPrice.toString(),
          'amount': amount.toString(),
          'ending_date': endingDate.toString(),
          'starting_hour': startHour.toString(),
          'ending_hour': endHour.toString(),
          'vegetarian': vegetarian.toString(),
          'mediterranean': mediterranean.toString(),
          'junk': junk.toString(),
          'dessert': dessert.toString(),
          'working_on_monday': workingOnMonday.toString(),
          'working_on_tuesday': workingOnTuesday.toString(),
          'working_on_wednesday': workingOnWednesday.toString(),
          'working_on_thursday': workingOnThursday.toString(),
          'working_on_friday': workingOnFriday.toString(),
          'working_on_saturday': workingOnSaturday.toString(),
          'working_on_sunday': workingOnSunday.toString(),
        },
      );
      ProductModel result = ProductModel.fromJson(response['product']);
      return result;
    } catch(error) { rethrow; }
  }

  static Future<void> deleteProduct({
    required String type,
  }) async {
    try {
      final response = await Middleware.endpoint(
        name: 'deleteProduct',
        type: HttpType.post,
        body: {
          'type': type.toString(),
        }
      );
      if(response['message'] == null) {
        throw Exception();
      }
    } catch(error) { rethrow; }
  }

  static Future<ProductModel> createProduct({
    required double price,
    required double originalPrice,
    required int amount,
    required String? endingDate,
    required String startHour,
    required String endHour,
    required String vegetarian,
    required String mediterranean,
    required String dessert,
    required String junk,
    required String workingOnMonday,
    required String workingOnTuesday,
    required String workingOnWednesday,
    required String workingOnThursday,
    required String workingOnFriday,
    required String workingOnSaturday,
    required String workingOnSunday,
    required String type,
  }) async {
    try {
      final response = await Middleware.endpoint(
        name: 'createProduct',
        type: HttpType.post,
        body: {
          'price': price.toString(),
          'original_price': originalPrice.toString(),
          'amount': amount.toString(),
          'ending_date': endingDate.toString(),
          'starting_hour': startHour.toString(),
          'ending_hour': endHour.toString(),
          'vegetarian': vegetarian.toString(),
          'mediterranean': mediterranean.toString(),
          'dessert': dessert.toString(),
          'junk': junk.toString(),
          'working_on_monday': workingOnMonday.toString(),
          'working_on_tuesday': workingOnTuesday.toString(),
          'working_on_wednesday': workingOnWednesday.toString(),
          'working_on_thursday': workingOnThursday.toString(),
          'working_on_friday': workingOnFriday.toString(),
          'working_on_saturday': workingOnSaturday.toString(),
          'working_on_sunday': workingOnSunday.toString(),
          'type': type.toString(),
        },
      );
      ProductModel result = ProductModel.fromJson(response['product']);
      return result;
    } catch(error) { rethrow; }
  }

  static Future<List<BusinessExpandedModel>> getValidatableBusinesses() async {
    try {
      final response = await Middleware.endpoint(
        name: 'getValidatableBusinesses',
        type: HttpType.get,
      );
      List<BusinessExpandedModel> result = (response['results'] as List<dynamic>).map((business) => BusinessExpandedModel.fromJson(business)).toList();
      return result;
    } catch(error) { rethrow; }
  }

  static Future<void> validateBusiness({
    required int id,
  }) async {
    try {
      final response = await Middleware.endpoint(
        name: 'validateBusiness',
        type: HttpType.post,
        body: {
          'id': id.toString(),
        }
      );
      if(response['message'] != null) {
      } else {
        throw Exception('ERROR WHILE VALIDATING BUSINESS');
      }
    } catch(error) { rethrow; }
  }

  static Future<void> refuseBusiness({
    required int id,
  }) async {
    try {
      final response = await Middleware.endpoint(
          name: 'refuseBusiness',
          type: HttpType.post,
          body: {
            'id': id.toString(),
          }
      );
      if(response['message'] == null) {
        throw Exception('ERROR WHILE REFUSING BUSINESS');
      }
    } catch(error) { rethrow; }
  }

  static Future<List<ProductExpandedModel>> getPendingOrdersCustomer() async {
    try {
      final response = await Middleware.endpoint(
          name: 'getPendingOrdersCustomer',
          type: HttpType.get,
      );
      if(response['results'] == null) {
        throw Exception('ERROR WHILE GETTING PENDING ITEMS');
      }
      List<ProductExpandedModel> result = (response['results'] as List<dynamic>).map((product) => ProductExpandedModel.fromJson(product)).toList();
      return result;
    } catch(error) { rethrow; }
  }

  static Future<List<OrderModel>> getPendingOrdersBusiness() async {
    try {
      final response = await Middleware.endpoint(
        name: 'getPendingOrdersBusiness',
        type: HttpType.get,
      );
      if(response['orders'] == null) {
        throw Exception('ERROR WHILE GETTING PENDING ITEMS');
      }
      List<OrderModel> result = (response['orders'] as List<dynamic>).map((order) => OrderModel.fromJson(order)).toList();
      return result;
    } catch(error) { rethrow; }
  }

  static Future<void> completeOrderCustomer({
    required int idOrder,
  }) async {
    try {
      final response = await Middleware.endpoint(
        name: 'completeOrderCustomer',
        type: HttpType.post,
        body: {
          'id_order': idOrder.toString(),
        }
      );
      if(response['message'] == null) {
        throw Exception('ERROR WHILE GETTING PENDING ITEMS');
      }
    } catch(error) { rethrow; }
  }

  static Future<void> completeOrderBusiness({
    required int idOrder,
  }) async {
    try {
      final response = await Middleware.endpoint(
          name: 'completeOrderBusiness',
          type: HttpType.post,
          body: {
            'id_order': idOrder.toString(),
          }
      );
      if(response['message'] == null) {
        throw Exception();
      }
    } catch(error) { rethrow; }
  }

  static Future<ImageModel> getImage({
    required int idUser,
    required String meaning,
  }) async {
    try {
      final response = await Middleware.endpoint(
        name: 'getImage',
        type: HttpType.post,
        body: {
          'id_user': idUser.toString(),
          'meaning': meaning.toString(),
        }
      );
      ImageModel imageModel = ImageModel.fromJson(response['image']);
      return imageModel;
    } catch(error) {
      return ImageModel.empty();
    }
  }

  static Future<ImageModel> uploadImage({
    required int idUser,
    required String meaning,
    required File file,
  }) async {
    try {
      final response = await Middleware.endpoint(
        name: 'uploadImage',
        type: HttpType.multipartPost,
        body: {
          'id_user': idUser.toString(),
          'meaning': meaning.toString(),
        },
        file: file,
      );
      final responseBody = jsonDecode(response.body);
      ImageModel imageModel = ImageModel.fromJson(responseBody['image']);
      return imageModel;
    } catch(error) { rethrow; }
  }

  static Future<List<ProductExpandedModel>> searchItemsByFilters({
    required double longitude,
    required double latitude,
    required double distance,
    required Filters filters
  }) async {
    try {
      final response = await Middleware.endpoint(
        name: 'searchItemsByFilters',
        type: HttpType.post,
        body: {
          'longitude': longitude.toString(),
          'latitude': latitude.toString(),
          'distance': distance.toString(),
          'vegetarian': filters.vegetarian ? "1" : "0",
          'mediterranean': filters.mediterranean ? "1" : "0",
          'dessert': filters.dessert ? "1" : "0",
          'junk': filters.junk ? "1" : "0",
          'price': (filters.maximumPrice ?? 99999).toString(),
          'starting_hour': Utils.timeOfDayToSqlTimeString(filters.startTime ?? const TimeOfDay(hour: 0, minute: 0)),
          'ending_hour': Utils.timeOfDayToSqlTimeString(filters.endTime ?? const TimeOfDay(hour: 23, minute: 59)),
          'only_today': filters.onlyToday ? "1" : "0",
          'only_available': filters.onlyAvailable ? "1" : "0",
        },
      );
      List<ProductExpandedModel> products = (response['items'] as List<dynamic>).map((product) => ProductExpandedModel.fromJson(product)).toList();
      return products;
    } catch(error) { rethrow; }
  }

  static Future<List<ProductExpandedModel>> searchItemsByText({
    required String text,
  }) async {
    try {
      final response = await Middleware.endpoint(
        name: 'searchItemsByText',
        type: HttpType.post,
        body: {
          'text': text,
        },
      );
      List<ProductExpandedModel> products = (response['items'] as List<dynamic>).map((product) => ProductExpandedModel.fromJson(product)).toList();
      return products;
    } catch(error) { rethrow; }
  }

  static removeImage({
    required int idUser,
    required String meaning,
  }) async {
    try {
      await Middleware.endpoint(
        name: 'removeImage',
        type: HttpType.post,
        body: {
          'id_user': idUser.toString(),
          'meaning': meaning.toString(),
        },
      );
    } catch(error) { rethrow; }
  }

  static Future getOrderHistoryCustomer() async {
    try {
      final response = await Middleware.endpoint(
        name: 'getOrderHistoryCustomer',
        type: HttpType.get,
      );
      List<ProductExpandedModel> orders = (response['orders'] as List<dynamic>).map((product) => ProductExpandedModel.fromJson(product)).toList();
      return orders;
    } catch(error) { rethrow; }
  }

  static Future<BusinessExpandedModel> getBusiness({
    required int idBusiness
  }) async {
    try {
      final response = await Middleware.endpoint(
        name: 'getBusiness',
        type: HttpType.post,
        body: {
          'id_business': idBusiness.toString(),
        }
      );
      BusinessExpandedModel business = BusinessExpandedModel.fromJson(response);
      return business;
    } catch(error) { rethrow; }
  }

  static Future addComment({
    required int idBusiness,
    required String? message,
    required double rate,
  }) async {
    try {
      Map<String, dynamic> body = {
        'id_business': idBusiness.toString(),
        'rate': rate.toString(),
      };
      if(message != null) {
        body['message'] = message;
      }
      await Middleware.endpoint(
        name: 'addComment',
        type: HttpType.post,
        body: body,
      );
    } catch(error) { rethrow; }
  }

  static Future<List<CommentExpandedModel>> getCommentsFromBusiness({
    required int idBusiness,
  }) async {
    try {
      final response = await Middleware.endpoint(
        name: 'getCommentsFromBusiness',
        type: HttpType.post,
        body: {
          'id_business': idBusiness.toString(),
        }
      );
      List<CommentExpandedModel> comments = (response['comments'] as List<dynamic>).map((comment) => CommentExpandedModel.fromJson(comment)).toList();
      return comments;
    } catch(error) { rethrow; }
  }

  static Future deleteComment({
    required int idBusiness,
  }) async {
    try {
      await Middleware.endpoint(
        name: 'deleteComment',
        type: HttpType.post,
        body: {
          'id_business': idBusiness.toString(),
        }
      );
    } catch(error) { rethrow; }
  }

  static Future<String> openpayPayment({
    required int idItem,
    required double price,
    required int amount,
    required String holderName,
    required int cardNumber,
    required int expirationYear,
    required int expirationMonth,
    required int cvv2,
  }) async {
    try {
      dynamic response = await Middleware.endpoint(
        name: 'openpayPayment',
        type: HttpType.post,
        body: {
          'price': price.toString(),
          'holder_name': holderName,
          'card_number': cardNumber.toString(),
          'expiration_year': expirationYear.toString(),
          'expiration_month': expirationMonth.toString(),
          'cvv2': cvv2.toString(),
          'id_item': idItem.toString(),
          'amount': amount.toString(),
        },
      );
      String status = '';
      print('------------ RESPONSE DEL API.PAYMENT: ---------------');
      print(response);
      print('------------------------------------------------------');
      if(response['status'] != null) {
        status = response['status'].toString();
      } else if(response['error'] != null) {
        status = response['details']['description'].toString();
      } else if(response['error_code'] != null) {
        status = response['error_code'].toString();
      } else {
        status = response['non-existing-field-just-to-throw-an-error'];
      }
      return status;
    } catch(error) {
      rethrow;
    }
  }

  static Future<RetributionModel> createRetribution() async {
    try {
      final response = await Middleware.endpoint(
        name: 'createRetribution',
        type: HttpType.post,
      );
      RetributionModel result = RetributionModel.fromJson(response['retribution']);
      return result;
    } catch(error) { rethrow; }
  }

  static Future<List<RetributionModel>> getRetributionsFromBusiness({
    required int id,
  }) async {
    try {
      final response = await Middleware.endpoint(
        name: 'getRetributionsFromBusiness/$id',
        type: HttpType.get,
      );
      print(response['retributions']);
      List<RetributionModel> result = (response['retributions'] as List<dynamic>).map((ret) => RetributionModel.fromJson(ret)).toList();
      return result;
    } catch(error) { rethrow; }
  }
}