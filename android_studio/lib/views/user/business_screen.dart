import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wefood/blocs/blocs.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:wefood/commands/call_request.dart';
import 'package:wefood/components/components.dart';
import 'package:wefood/environment.dart';
import 'package:wefood/models/models.dart';
import 'package:wefood/services/auth/api.dart';
import 'package:wefood/types.dart';

class BusinessScreen extends StatefulWidget {

  final BusinessExpandedModel businessExpanded;

  const BusinessScreen({
    super.key,
    required this.businessExpanded,
  });

  @override
  State<BusinessScreen> createState() => _BusinessScreenState();
}

class _BusinessScreenState extends State<BusinessScreen> {

  Widget favouriteIcon = const Icon(Icons.favorite_outline);
  String? profileImageRoute;
  List<Comment> commentList = [];
  String newCommentMessage = '';
  double selectedRate = 3;
  bool hasCommented = false;
  LoadingStatus loadingFavourite = LoadingStatus.unset;

  List<DropdownMenuItem<double>> _rateOptions() {
    List<DropdownMenuItem<double>> amounts = [];
    for(double i = 5; i >= 1; i-=1) {
      amounts.add(
        DropdownMenuItem<double>(
          value: i,
          child: Row(
            children: <Widget>[
              Text(i.toStringAsFixed(0)),
              const SizedBox(
                width: 5,
              ),
              const Icon(
                Icons.star,
                size: 20,
              ),
            ],
          ),
        ),
      );
    }
    return amounts;
  }

  _onDeleteComment() {
    setState(() {
      hasCommented = false;
      commentList.removeWhere((i) => i.comment.user.id == context.read<UserInfoCubit>().state.user.id);
    });
  }

  _retrieveData() {
    setState(() {
      hasCommented = _hasCommented();
      commentList = widget.businessExpanded.business.comments!.map((CommentExpandedModel c) => Comment(
        comment: c,
        onDelete: _onDeleteComment
      )).toList().reversed.toList();
    });
  }

  bool _hasCommented() {
    bool result = false;
    if(widget.businessExpanded.business.comments != null) {
      if(widget.businessExpanded.business.comments!.isNotEmpty) {
        for(int i = 0; i < widget.businessExpanded.business.comments!.length; i++) {
          if(widget.businessExpanded.business.comments![i].user.id == context.read<UserInfoCubit>().state.user.id) {
            result = true;
          }
        }
      }
    }
    setState(() {
      hasCommented = result;
    });
    return result;
  }

  void _getProfileImage() async {
    try {
      Api.getImage(
        idUser: widget.businessExpanded.user.id!,
        meaning: 'profile',
      ).then((ImageModel imageModel) {
        setState(() {
          profileImageRoute = imageModel.route!;
        });
      });
    } catch(e) {
      if(kDebugMode) {
        print('No se ha podido cargar la imagen');
      }
    }
  }

  @override
  void initState() {
    _getProfileImage();
    _retrieveData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WefoodScreen(
      ignoreHorizontalPadding: true,
      ignoreVerticalPadding: true,
      body: [
        Column(
          children: [
            Stack(
              children: <Widget>[
                if(profileImageRoute != null) SizedBox(
                  height: MediaQuery.of(context).size.height * 0.25,
                  child: (profileImageRoute != null)
                    ? ImageWithLoader.network(
                      route: profileImageRoute!,
                      width: MediaQuery.of(context).size.width,
                      fit: BoxFit.cover,
                    )
                    : Image.asset(
                      'assets/images/logo.png',
                      width: MediaQuery.of(context).size.width,
                      fit: BoxFit.cover,
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).viewPadding.top,
                  ),
                  height: MediaQuery.of(context).size.height * 0.25,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          const BackArrow(
                            whiteBackground: true,
                          ),
                          GestureDetector(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(999),
                                color: const Color.fromRGBO(255, 255, 255, 0.8),
                              ),
                              margin: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
                              padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.02),
                              child: (loadingFavourite == LoadingStatus.loading)
                                ? ReducedLoadingIcon(
                                  customMargin: MediaQuery.of(context).size.width * 0.016,
                                )
                                : (widget.businessExpanded.isFavourite == true)
                                  ? const Icon(Icons.favorite)
                                  : const Icon(Icons.favorite_outline),
                            ),
                            onTap: () async {
                              if(loadingFavourite != LoadingStatus.loading) {
                                setState(() {
                                  loadingFavourite = LoadingStatus.loading;
                                });
                                try {
                                  if(widget.businessExpanded.isFavourite == true) {
                                    Api.removeFavourite(idBusiness: widget.businessExpanded.business.id!).then((_) {
                                      setState(() {
                                        loadingFavourite = LoadingStatus.successful;
                                        widget.businessExpanded.isFavourite = false;
                                      });
                                    });
                                  } else {
                                    Api.addFavourite(idBusiness: widget.businessExpanded.business.id!).then((_) {
                                      setState(() {
                                        loadingFavourite = LoadingStatus.successful;
                                        widget.businessExpanded.isFavourite = true;
                                      });
                                    });
                                  }
                                } catch(e) {
                                  loadingFavourite = LoadingStatus.error;
                                }
                              }
                            },
                          ),
                        ],
                      ),
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Color.fromRGBO(0, 0, 0, 0.75)],
                          ),
                        ),
                        child: Container(
                          padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).size.height * 0.025,
                          ),
                          alignment: Alignment.bottomCenter,
                          width: double.infinity,
                          height: MediaQuery.of(context).size.height * 0.1,
                          child: Text(
                            widget.businessExpanded.business.name ?? '',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Theme.of(context).colorScheme.surface,
                            )
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Container(
              margin: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * Environment.defaultHorizontalMargin,
                vertical: MediaQuery.of(context).size.width * Environment.defaultHorizontalMargin,
              ),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if(widget.businessExpanded.business.description != null) Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Text>[
                      Text(
                        'Acerca de ${widget.businessExpanded.business.name}:',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(widget.businessExpanded.business.description!),
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.025),
                  if(widget.businessExpanded.totalOrders != null) Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Text(
                            'Pedidos completados: ',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text('${widget.businessExpanded.totalOrders}  '),
                        ],
                      ),
                    ],
                  ),
                  if(widget.businessExpanded.business.rate != null) if(widget.businessExpanded.business.rate! > 0) Column(
                    children: <Widget>[
                      SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                      Row(
                        children: <Widget>[
                          Text(
                            'Valoración: ',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text('${widget.businessExpanded.business.rate?.toStringAsFixed(1)}  '),
                          PrintStars(rate: widget.businessExpanded.business.rate!),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Flexible(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Ubicación: ',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Flexible(
                              child: Text('${widget.businessExpanded.business.directions}'),
                            ),
                          ],
                        ),
                      ),
                      Card(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                          ),
                          padding: const EdgeInsets.all(10),
                          child: GestureDetector(
                            child: const Icon(Icons.location_pin),
                            onTap: () {
                              MapsLauncher.launchQuery(widget.businessExpanded.business.directions ?? '');
                            },
                          ),
                        ),
                      )
                    ],
                  ),
                  const Divider(
                    height: 50,
                  ),
                  if(widget.businessExpanded.requesterHasBought == true && hasCommented == false) const SizedBox(),
                  if(widget.businessExpanded.requesterHasBought == true && hasCommented == false) Text(
                    'Tu opinión es muy importante para nosotros',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if(widget.businessExpanded.requesterHasBought == true && hasCommented == false) const SizedBox(
                    height: 10,
                  ),
                  if(widget.businessExpanded.requesterHasBought == true && hasCommented == false) WefoodInput(
                    labelText: 'Añadir comentario',
                    onChanged: (String value) {
                      setState(() {
                        newCommentMessage = value;
                      });
                    },
                    feedbackWidget: (newCommentMessage.isNotEmpty)
                      ? FeedbackMessage(
                        message: '${(newCommentMessage.length > 750) ? 'Demasiado largo:' : ''} ${newCommentMessage.length} / 750',
                        isError: (newCommentMessage.length > 750),
                      )
                      : null,
                  ),
                  if(widget.businessExpanded.requesterHasBought == true && hasCommented == false) const SizedBox(
                    height: 10,
                  ),
                  if(widget.businessExpanded.requesterHasBought == true && hasCommented == false) Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      DropdownButton<double>(
                        value: selectedRate,
                        items: _rateOptions(),
                        onChanged: (value) {
                          setState(() {
                            selectedRate = value!;
                          });
                        },
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      if(newCommentMessage.length <= 750) IconButton(
                        icon: const Icon(
                          Icons.send,
                        ),
                        onPressed: () {
                          callRequestWithLoading(
                            context: context,
                            request: () async {
                              return await Api.addComment(
                                idBusiness: widget.businessExpanded.business.id!,
                                message: (newCommentMessage != '') ? newCommentMessage : null,
                                rate: selectedRate,
                              );
                            },
                            onSuccess: (_) {
                              CommentModel newComment = CommentModel.empty();
                              newComment.message = newCommentMessage;
                              newComment.rate = selectedRate;
                              newComment.idBusiness = widget.businessExpanded.business.id!;
                              CommentExpandedModel newCommentExpanded = CommentExpandedModel.fromParameters(
                                userModel: context.read<UserInfoCubit>().state.user,
                                commentModel: newComment,
                              );
                              setState(() {
                                newCommentMessage = '';
                                widget.businessExpanded.business.comments?.add(newCommentExpanded);
                                hasCommented = true;
                              });
                              Api.getCommentsFromBusiness(
                                idBusiness: widget.businessExpanded.business.id!,
                              ).then((List<CommentExpandedModel> comments) {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return WefoodPopup(
                                      context: context,
                                      title: '¡Comentario añadido correctamente!',
                                      cancelButtonTitle: 'OK',
                                    );
                                  }
                                );
                                setState(() {
                                  commentList = comments.map((CommentExpandedModel c) => Comment(
                                    comment: c,
                                    onDelete: _onDeleteComment,
                                  )).toList().reversed.toList();
                                });
                              });
                            },
                          );
                        },
                      ),
                    ],
                  ),
                  if(widget.businessExpanded.requesterHasBought == true && hasCommented == false) const SizedBox(
                    height: 10,
                  ),
                  Text(
                    '¿Qué opinan otros compradores?',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if(widget.businessExpanded.business.comments!.isNotEmpty) Column(
                    children: commentList,
                  ),
                  if(widget.businessExpanded.business.comments!.isEmpty) Column(
                    children: <Widget>[
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        'Aún nadie ha dejado ningún comentario. ¡${(hasCommented == true) ? 'Prueba el producto y sé' : 'Sé'} el primero en comentar tu experiencia!',
                        style: const TextStyle(
                          color: Colors.grey, // TODO deshardcodear este estilo
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}