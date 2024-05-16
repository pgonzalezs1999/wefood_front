import 'package:wefood/models/models.dart';

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

  static void printInfo(CommentExpandedModel comment) {
    print('------------------------------');
    CommentModel.printInfo(comment.comment);
    UserModel.printInfo(comment.user);
    ImageModel.printInfo(comment.image);
    print('------------------------------');
  }
}