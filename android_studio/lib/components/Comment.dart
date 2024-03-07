import 'package:flutter/material.dart';
import 'package:wefood/components/product_tag.dart';
import 'package:wefood/models/comment_model.dart';
import 'package:wefood/views/product.dart';

class Comment extends StatefulWidget {

  final CommentModel comment;

  const Comment({
    super.key,
    required this.comment,
  });

  @override
  State<Comment> createState() => _CommentState();
}

class _CommentState extends State<Comment> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: SizedBox.fromSize(
            size: Size.fromRadius(MediaQuery.of(context).size.width * 0.05),
            child: Image.asset('assets/images/logo.jpg'),
          ),
        ),
        Column(
          children: <Widget>[
            Text('${widget.comment.idUser ?? 0}'),
            Text(widget.comment.message ?? '0'),
          ],
        ),
      ],
    );
  }
}