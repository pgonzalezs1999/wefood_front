import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wefood/blocs/blocs.dart';
import 'package:wefood/components/components.dart';
import 'package:wefood/models/models.dart';
import 'package:wefood/services/auth/api/api.dart';

class Comment extends StatefulWidget {

  final CommentExpandedModel comment;
  final Function()? onModify;
  final Function()? onDelete;

  const Comment({
    super.key,
    required this.comment,
    this.onModify,
    this.onDelete,
  });

  @override
  State<Comment> createState() => _CommentState();
}

class _CommentState extends State<Comment> {

  _retrieveImage() {
    try {
      Api.getImage(
        idUser: widget.comment.user.id!,
        meaning: 'profile',
      ).then((ImageModel imageModel) {
        if(imageModel.route != null) {
          setState(() {
            image = ImageWithLoader.network(
              route: imageModel.route!,
              fit: BoxFit.cover,
            );
          });
        }
      });
    } catch(error) {
      if(kDebugMode) {
        print('No se ha podido cargar la imagen');
      }
    }
  }

  Image? image;

  @override
  void initState() {
    super.initState();
    _retrieveImage();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        top: 20,
      ),
      child: Row(
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: SizedBox.fromSize(
              size: Size.fromRadius(MediaQuery.of(context).size.width * 0.05),
              child: Container(
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
                  children: <Widget>[
                    Text(
                      widget.comment.user.username ?? 'Sin nombre',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    PrintStars(
                      rate: widget.comment.comment.rate!,
                    ),
                  ],
                ),
                Text('${widget.comment.comment.message}'),
              ],
            ),
          ),
          if(widget.comment.user.id == context.read<UserInfoCubit>().state.user.id) Row(
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
                              Api.deleteComment(
                                idBusiness: widget.comment.comment.idBusiness!,
                              ).then((_) {
                                Navigator.pop(context);
                                if(widget.onDelete != null) {
                                  widget.onDelete!();
                                }
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return WefoodPopup(
                                      context: context,
                                      title: '¡Comentario eliminado correctamente!',
                                      cancelButtonTitle: 'OK',
                                    );
                                  }
                                ).onError((error, stackTrace) {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return WefoodPopup(
                                        context: context,
                                        title: 'Ha ocurrido un error',
                                        description: 'Por favor, inténtelo de nuevo más tarde',
                                        cancelButtonTitle: 'OK',
                                      );
                                    }
                                  );
                                });
                              });
                            },
                          )
                        ],
                      );
                    }
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