import 'package:wefood/models/models.dart';

class CommentExpandedModel {
  CommentModel comment;
  UserModel user;

  CommentExpandedModel.empty():
    comment = CommentModel.empty(),
    user = UserModel.empty();

  CommentExpandedModel.fromJson(Map<String, dynamic> json):
    comment = (json['content'] != null) ? CommentModel.fromJson(json['content'] as Map<String, dynamic>) : CommentModel.empty(),
    user = (json['user'] != null) ? UserModel.fromJson(json['user'] as Map<String, dynamic>) : UserModel.empty();

  CommentExpandedModel.fromParameters({
    required CommentModel commentModel,
    required UserModel userModel,
  }):
    comment = commentModel,
    user = userModel;

  static void printInfo(CommentExpandedModel comment) {
    print('------------------------------');
    CommentModel.printInfo(comment.comment);
    UserModel.printInfo(comment.user);
    print('------------------------------');
  }
}