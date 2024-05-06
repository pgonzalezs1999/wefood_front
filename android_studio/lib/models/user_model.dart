import 'package:flutter/widgets.dart';

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

  static void printInfo(UserModel user) {
    print('IMPRIMIENDO USER CON ID: ${user.id}');
    print('-> realName: ${user.realName}');
    print('-> realSurname: ${user.realSurname}');
    print('-> username: ${user.username}');
    print('-> email: ${user.email}');
    print('-> emailVerified: ${user.emailVerified}');
    print('-> isAdmin: ${user.isAdmin}');
    print('-> phone: ${user.phone}');
    print('-> phonePrefix: ${user.phonePrefix}');
    print('-> sex: ${user.sex}');
    print('-> lastLongitude: ${user.lastLongitude}');
    print('-> lastLatitude: ${user.lastLatitude}');
    print('-> lastLoginDate: ${user.lastLoginDate}');
    print('-> idBusiness: ${user.idBusiness}');
    print('-> businessVerified: ${user.businessVerified}');
  }
}