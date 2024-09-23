import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wefood/blocs/blocs.dart';
import 'package:wefood/commands/call_request.dart';
import 'package:wefood/components/components.dart';
import 'package:wefood/models/models.dart';
import 'package:wefood/services/auth/api.dart';

class Comment extends StatefulWidget {

  final CommentExpandedModel comment;
  final bool deletable;
  final Function()? onModify;
  final Function()? onDelete;

  const Comment({
    super.key,
    required this.comment,
    this.deletable = true,
    this.onModify,
    this.onDelete,
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: SizedBox.fromSize(
              size: Size.fromRadius(MediaQuery.of(context).size.width * 0.05),
              child: (widget.comment.image.route != null)
                ? ImageWithLoader.network(
                  route: widget.comment.image.route!,
                  fit: BoxFit.cover,
                )
                : Container(
                color: Theme.of(context).colorScheme.surfaceContainer,
                child: const Icon(
                  Icons.person,
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      widget.comment.user.username ?? '[Username]',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    PrintStars(
                      rate: widget.comment.comment.rate!,
                    ),
                  ],
                ),
                if(widget.comment.comment.message != null) Text('${widget.comment.comment.message}'),
              ],
            ),
          ),
          if(widget.comment.user.id == context.read<UserInfoCubit>().state.user.id && widget.deletable == true) Row(
            children: <Widget>[
              const SizedBox(
                width: 20,
              ),
              GestureDetector(
                child: const Icon(
                  Icons.delete,
                ),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return WefoodPopup(
                        context: context,
                        title: '¿Eliminar comentario?',
                        actions: <TextButton>[
                          TextButton(
                            child: const Text('SÍ'),
                            onPressed: () {
                              callRequestWithLoading(
                                context: context,
                                request: () async {
                                  return await Api.deleteComment(
                                    idBusiness: widget.comment.comment.idBusiness!,
                                  );
                                },
                                onSuccess: (_) {
                                  if(widget.onDelete != null) {
                                    widget.onDelete!();
                                  }
                                  Navigator.of(context).pop();
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return WefoodPopup(
                                        context: context,
                                        title: '¡Comentario eliminado correctamente!',
                                        cancelButtonTitle: 'OK',
                                      );
                                    }
                                  );
                                },
                              );
                            },
                          )
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}