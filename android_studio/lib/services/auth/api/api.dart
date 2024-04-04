import 'package:flutter/material.dart';
import 'package:wefood/models/auth_model.dart';
import 'package:wefood/models/business_expanded_model.dart';
import 'package:wefood/models/business_products_resume_model.dart';
import 'package:wefood/models/country_model.dart';
import 'package:wefood/models/exceptions.dart';
import 'package:wefood/models/favourite_model.dart';
import 'package:wefood/models/product_expanded_model.dart';
import 'package:wefood/models/product_model.dart';
import 'package:wefood/models/user_model.dart';
import 'package:wefood/services/auth/middleware.dart';
import 'package:wefood/services/secure_storage.dart';
import 'package:wefood/types.dart';
import 'package:wefood/views/home.dart';

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
    String imageUrl = 'assets/images/salmon.jpg',
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

  static Future<List<ProductExpandedModel>> getFavouriteProducts() async {
    try {
      dynamic response = await Middleware.endpoint(
        name: 'getFavouriteProducts',
        type: HttpType.get,
      );
      List<ProductExpandedModel> products = (response['products'] as List<dynamic>).map((product) => ProductExpandedModel.fromJson(product)).toList();
      return products;
    } catch(error) {
      throw Exception(error);
    }
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
      List<ProductExpandedModel> products = (response['products'] as List<dynamic>).map((product) => ProductExpandedModel.fromJson(product)).toList();
      return products;
    } catch(error) {
      throw Exception(error);
    }
  }

  static Future<List<ProductExpandedModel>> getRecommendedProducts({
    required double longitude,
    required double latitude,
  }) async {
    try {
      dynamic response = await Middleware.endpoint(
          name: 'getRecommendedProducts',
          type: HttpType.post,
          body: {
            'longitude': longitude.toString(),
            'latitude': latitude.toString(),
          }
      );
      List<ProductExpandedModel> products = (response['products'] as List<dynamic>).map((product) => ProductExpandedModel.fromJson(product)).toList();
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
    required String bakery,
    required String fresh,
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
          'bakery': bakery.toString(),
          'fresh': fresh.toString(),
          'working_on_monday': workingOnMonday.toString(),
          'working_on_tuesday': workingOnTuesday.toString(),
          'working_on_wednesday': workingOnWednesday.toString(),
          'working_on_thursday': workingOnThursday.toString(),
          'working_on_friday': workingOnFriday.toString(),
          'working_on_saturday': workingOnSaturday.toString(),
          'working_on_sunday': workingOnSunday.toString(),
        },
      );
      print('RESPONSE DEL API.UPDATE_PRODUCT: $response');
      ProductModel result = ProductModel.fromJson(response['product']);
      return result;
    } catch(error) {
      print('ERROR DEL API.UPDATE_PRODUCT: $error');
      throw Exception(error);
    }
  }
}