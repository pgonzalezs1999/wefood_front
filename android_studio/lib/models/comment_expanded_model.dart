import 'package:wefood/models/comment_model.dart';
import 'package:wefood/models/user_model.dart';

class CommentExpandedModel {
  CommentModel content;
  UserModel? user;

  CommentExpandedModel.fromJson(Map<String, dynamic> json):
    content = CommentModel.fromJson(json['content'] as Map<String, dynamic>),
    user = UserModel.fromJson(json['user'] as Map<String, dynamic>);
}