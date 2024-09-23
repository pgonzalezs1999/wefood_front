import 'package:flutter/material.dart';
import 'package:wefood/commands/wefood_show_dialog.dart';
import 'package:wefood/services/loading/loading_modern.dart';

callRequestWithLoading({
  required BuildContext context,
  required Function request,
  required Function onSuccess,
  Function? onError,
  bool closePreviousPopup = false,
}) {
  if(closePreviousPopup == true) {
    Navigator.of(context).pop();
  }
  LoadingModern.instance().show(context: context);
  request().then((dynamic response) {
    onSuccess(response);
    LoadingModern.instance().hide();
  }).catchError((error, stackTrace) {
    if(onError != null) {
      onError(error);
      LoadingModern.instance().hide();
    } else {
      wefoodShowDialog(
        context: context,
        title: 'Ha ocurrido un error',
        description: 'Por favor, inténtelo de nuevo más tarde. Si el error persiste, contacte con soporte.\n\n', // $error',
        cancelButtonTitle: 'OK',
      );
      LoadingModern.instance().hide();
    }
  });
}