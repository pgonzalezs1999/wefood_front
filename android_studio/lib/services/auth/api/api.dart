import 'dart:io';
import 'package:flutter/material.dart';
import 'package:wefood/commands/custom_parsers.dart';
import 'package:wefood/models/models.dart';
import 'package:wefood/services/auth/middleware.dart';
import 'package:wefood/services/secure_storage.dart';
import 'package:wefood/types.dart';
import 'package:wefood/views/views.dart';
import 'dart:convert';

class Api {

  static List<AppException> handledErrors = [
    WefoodApiNotRespondingException(),
    WefoodUnauthorizedException(),
    WefoodBadRequestException(),
    WefoodFetchDataException(),
    WefoodDefaultException(),
  ];

  static _displayError({
    required BuildContext context,
    required dynamic error,
    String title = '',
    String description = '',
    String imageUrl = 'assets/images/logo.png',
  }) {
    title = error;
    FocusScope.of(context).unfocus();
    if(handledErrors.any((e) => e.runtimeType == error.runtimeType)) {
      title = error.titleMessage;
      description = error.descriptionMessage ?? '';
      imageUrl = error.imageUrl ?? '';
    } else if(error.runtimeType == String) {
      title = error;
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                margin: EdgeInsets.symmetric(
                  vertical: MediaQuery.of(context).size.height * 0.025,
                ),
                child: Image.asset(
                  imageUrl,
                  width: MediaQuery.of(context).size.width * 0.5,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.05,
                  vertical: MediaQuery.of(context).size.height * 0.025,
                ),
                child: Text(title),
              ),
              Text(description),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      },
    );
  }

  static Future<AuthModel?> login({
    required BuildContext context,
    required String username,
    required String password,
    Function()? onError,
  }) async {
    try {
      final response = await Middleware.endpoint(
        name: 'login',
        type: HttpType.post,
        body: {
          'username': username,
          'password': password,
        },
        needsAccessToken: false,
      );
      if(response['access_token'] == null) {
        if(onError != null) {
          onError();
        }
        _displayError(context: context, error: response['error']);
      } else {
        AuthModel authModel = AuthModel.fromParameters(
            response['access_token'],
            response['expires_in']
        );
        await UserSecureStorage().write(key: 'accessToken', value: authModel.accessToken!);
        await UserSecureStorage().writeDateTime(
            key: 'accessTokenExpiresAt',
            value: DateTime.now().add(Duration(seconds: authModel.expiresAt!))
        );
        await UserSecureStorage().write(key: 'username', value: username);
        await UserSecureStorage().write(key: 'password', value: password);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Home()),
        );
        return authModel;
      }
    } catch(error) {
      if(onError != null) {
        onError();
      }
      await UserSecureStorage().delete(key: 'accessToken');
      await UserSecureStorage().delete(key: 'accessTokenExpiresAt');
      await UserSecureStorage().delete(key: 'username');
      await UserSecureStorage().delete(key: 'password');
      _displayError(context: context, error: error);
    }
    return null;
  }

  static Future<UserModel> getProfile() async {
    try {
      final response = await Middleware.endpoint(
        name: 'getProfile',
        type: HttpType.get,
      );
      UserModel userModel = UserModel.fromJson(response['message']);
      return userModel;
    } catch(error) {
      throw Exception(error);
    }
  }

  static Future<BusinessExpandedModel> getSessionBusiness() async {
    try {
      final response = await Middleware.endpoint(
        name: 'getSessionBusiness',
        type: HttpType.get,
      );
      BusinessExpandedModel businessModel = BusinessExpandedModel.fromJson(response);
      return businessModel;
    } catch(error) {
      throw Exception(error);
    }
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
    } catch(error) {
      throw Exception(error);
    }
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
    } catch(error) {
      throw Exception(error);
    }
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
    } catch(error) {
      throw Exception(error);
    }
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
    } catch(error) {
      throw Exception(error);
    }
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
    } catch(error) {
      throw Exception(error);
    }
  }

  static Future<List<ProductExpandedModel>> getFavouriteItems() async {
    try {
      dynamic response = await Middleware.endpoint(
        name: 'getFavouriteItems',
        type: HttpType.get,
      );
      List<ProductExpandedModel> products = (response['products'] as List<dynamic>).map((product) => ProductExpandedModel.fromJson(product)).toList();
      return products;
    } catch(error) {
      throw Exception(error);
    }
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
    } catch(error) {
      throw Exception(error);
    }
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
    } catch(error) {
      throw Exception(error);
    }
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
    } catch(error) {
      throw Exception(error);
    }
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
    } catch(error) {
      throw Exception(error);
    }
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
    } catch(error) {
      throw Exception(error);
    }
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
    } catch(error) {
      throw Exception(error);
    }
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
    } catch(error) {
      throw Exception(error);
    }
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
    } catch(error) {
      throw Exception(error);
    }
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
    } catch(error) {
      throw Exception(error);
    }
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
    } catch(error) {
      throw Exception(error);
    }
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
    } catch(error) {
      throw Exception(error);
    }
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
    } catch(error) {
      throw Exception(error);
    }
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
      dynamic response = await Middleware.endpoint(
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
    } catch(error) {
      throw Exception(error);
    }
  }

  static logout() async {
    try {
      await Middleware.endpoint(
          name: 'logout',
          type: HttpType.get,
      );
    } catch(error) {
      throw Exception(error);
    }
  }

  static signOut() async {
    try {
      await Middleware.endpoint(
        name: 'signout',
        type: HttpType.post,
      );
    } catch(error) {
      throw Exception(error);
    }
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
    } catch(error) {
      throw Exception(error);
    }
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
    } catch(error) {
      throw Exception(error);
    }
  }

  static Future<BusinessProductsResumeModel> businessProductsResume() async {
    try {
      final response = await Middleware.endpoint(
        name: 'businessProductsResume',
        type: HttpType.get,
      );
      BusinessProductsResumeModel result = BusinessProductsResumeModel.fromJson(response);
      return result;
    } catch(error) {
      throw Exception(error);
    }
  }

  static Future<ProductModel> updateProduct({
    required int id,
    required double price,
    required int amount,
    required String? endingDate,
    required String startHour,
    required String endHour,
    required String vegetarian,
    required String vegan,
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
          'amount': amount.toString(),
          'ending_date': endingDate.toString(),
          'starting_hour': startHour.toString(),
          'ending_hour': endHour.toString(),
          'vegetarian': vegetarian.toString(),
          'vegan': vegan.toString(),
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
    } catch(error) {
      throw Exception(error);
    }
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
    } catch(error) {
      throw Exception(error);
    }
  }

  static Future<ProductModel> createProduct({
    required double price,
    required int amount,
    required String? endingDate,
    required String startHour,
    required String endHour,
    required String vegetarian,
    required String vegan,
    required String bakery,
    required String fresh,
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
          'amount': amount.toString(),
          'ending_date': endingDate.toString(),
          'starting_hour': startHour.toString(),
          'ending_hour': endHour.toString(),
          'vegetarian': vegetarian.toString(),
          'vegan': vegan.toString(),
          'bakery': bakery.toString(),
          'fresh': fresh.toString(),
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
    } catch(error) {
      throw Exception(error);
    }
  }

  static Future<List<BusinessExpandedModel>> getValidatableBusinesses() async {
    try {
      final response = await Middleware.endpoint(
        name: 'getValidatableBusinesses',
        type: HttpType.get,
      );
      List<BusinessExpandedModel> result = (response['results'] as List<dynamic>).map((business) => BusinessExpandedModel.fromJson(business)).toList();
      return result;
    } catch(error) {
      throw Exception(error);
    }
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
    } catch(error) {
      throw Exception(error);
    }
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
    } catch(error) {
      throw Exception(error);
    }
  }

  static Future<void> orderItem({
    required int idItem,
    required int amount,
  }) async {
    try {
      final response = await Middleware.endpoint(
          name: 'orderItem',
          type: HttpType.post,
          body: {
            'id_item': idItem.toString(),
            'amount': amount.toString(),
          }
      );
      if(response['message'] == null) {
        throw Exception('ERROR WHILE REFUSING BUSINESS');
      }
    } catch(error) {
      throw Exception(error);
    }
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
    } catch(error) {
      throw Exception(error);
    }
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
    } catch(error) {
      throw Exception(error);
    }
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
    } catch(error) {
      throw Exception(error);
    }
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
        throw Exception('ERROR WHILE GETTING PENDING ITEMS');
      }
    } catch(error) {
      throw Exception(error);
    }
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
      throw Exception(error);
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
    } catch(error) {
      throw Exception(error);
    }
  }

  static Future<List<ProductExpandedModel>> searchItemsByFilters({
    required double longitude,
    required double latitude,
    required double distance,
    required bool vegetarian,
    required bool vegan,
    required bool dessert,
    required bool junk,
    required double price,
    required TimeOfDay startingHour,
    required TimeOfDay endingHour,
    required bool onlyToday,
    required bool onlyAvailable,
  }) async {
    try {
      final response = await Middleware.endpoint(
        name: 'searchItemsByFilters',
        type: HttpType.post,
        body: {
          'longitude': longitude.toString(),
          'latitude': latitude.toString(),
          'distance': distance.toString(),
          'vegetarian': vegetarian ? "1" : "0",
          'vegan': vegan ? "1" : "0",
          'dessert': dessert ? "1" : "0",
          'junk': junk ? "1" : "0",
          'price': price.toString(),
          'starting_hour': CustomParsers.timeOfDayToSqlTimeString(startingHour),
          'ending_hour': CustomParsers.timeOfDayToSqlTimeString(endingHour),
          'only_today': onlyToday ? "1" : "0",
          'only_available': onlyAvailable ? "1" : "0",
        },
      );
      List<ProductExpandedModel> products = (response['items'] as List<dynamic>).map((product) => ProductExpandedModel.fromJson(product)).toList();
      return products;
    } catch(error) {
      throw Exception(error);
    }
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
    } catch(error) {
      throw Exception(error);
    }
  }
}