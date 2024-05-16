import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wefood/blocs/blocs.dart';
import 'package:wefood/components/components.dart';
import 'package:wefood/models/models.dart';
import 'package:wefood/services/auth/api/api.dart';
import 'package:wefood/types.dart';

class BusinessComments extends StatefulWidget {
  const BusinessComments({super.key});

  @override
  State<BusinessComments> createState() => _BusinessCommentsState();
}

class _BusinessCommentsState extends State<BusinessComments> {

  List<Comment> comments = [];
  LoadingStatus loadingComments = LoadingStatus.loading;
  double average = 0;

  _retrieveData() {
    Api.getCommentsFromBusiness(
      idBusiness: context.read<UserInfoCubit>().state.user.idBusiness!,
    ).then((List<CommentExpandedModel> response) {
      setState(() {
        comments = response.map((c) => Comment(
          comment: c,
        )).toList();
        loadingComments = LoadingStatus.successful;
      });
      if(comments.isNotEmpty) {
        double totalStars = 0;
        for(int i = 0; i < comments.length; i++) {
          if(comments[i].comment.comment.rate != null) {
            totalStars += comments[i].comment.comment.rate!;
          }
        }
        setState(() {
          average = totalStars / comments.length;
        });
      }
    }).onError((error, stackTrace) {
      setState(() {
        loadingComments = LoadingStatus.error;
      });
    });
  }

  @override
  void initState() {
    _retrieveData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WefoodScreen(
      body: <Widget>[
        const BackUpBar(
          title: 'Comentarios recibidos',
        ),
        if(loadingComments == LoadingStatus.error) const Text('Ha ocurrido un error'),
        if(loadingComments == LoadingStatus.loading) const LoadingIcon(),
        if(loadingComments == LoadingStatus.successful && comments.isEmpty) Container(
          padding: const EdgeInsets.all(20),
          width: double.infinity,
          child: Card(
            child: Container(
              padding: const EdgeInsets.all(20),
              child: const Text(
                'Todavía ningún cliente ha dejado comentarios sobre su negocio.',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        if(loadingComments == LoadingStatus.successful && comments.isNotEmpty) Column(
          children: comments,
        ),
        if(average > 0) Column(
          children: <Widget>[
            const Divider(
              height: 50,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Número de comentarios:  ',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  '${comments.length} ',
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Valoración media:  ',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  '$average ',
                ),
                const Icon(
                  Icons.star,
                  size: 15,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
