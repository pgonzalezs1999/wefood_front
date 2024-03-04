class UserModel {
  final int id;
  final String username;
  final String? realName;
  final String? realSurname;
  final String email;
  final int? phone;
  final int? phonePrefix;
  final int? sex;
  final int emailVerified;
  final int isAdmin;

  UserModel.fromJson(Map<String, dynamic> json):
    id = json['id'] as int,
    username = json['username'] as String,
    realName = json['real_name'] as String?,
    realSurname = json['real_surname'] as String?,
    email = json['email'] as String,
    phone = json['phone'] as int?,
    phonePrefix = json['phone_prefix'] as int?,
    sex = json['sex'] as int?,
    emailVerified = json['email_verified'] as int,
    isAdmin = json['is_admin'] as int;
}