import 'package:flutter/material.dart';
import 'package:wefood/models/comment_expanded_model.dart';

class Comment extends StatefulWidget {

  final CommentExpandedModel comment;

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
    return Container(
      margin: const EdgeInsets.only(
        top: 20,
      ),
      child: Wrap(
        spacing: 10,
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: SizedBox.fromSize(
              size: Size.fromRadius(MediaQuery.of(context).size.width * 0.05),
              child: Image.asset(
                'assets/images/logo.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(widget.comment.user?.username ?? 'Sin nombre'),
              Text(widget.comment.content.message ?? 'Sin rate'),
            ],
          ),
        ],
      ),
    );
  }
}