import 'package:flutter/material.dart';
import 'package:wefood/components/components.dart';
import 'package:wefood/services/loading/loading_test.dart';

callRequestWithLoading({
  required BuildContext context,
  required Function request,
  required Function onSuccess,
  Function? onError,
  bool closePreviousPopup = false,
}) {
  if(closePreviousPopup == true) {
    Navigator.pop(context);
  }
  LoadingTest.instance().show(context: context);
  request().then((dynamic response) {
    onSuccess(response);
    LoadingTest.instance().hide();
  }).catchError((error, stackTrace) {
    if(onError != null) {
      onError(error);
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return WefoodPopup(
            context: context,
            title: 'Ha ocurrido un error',
            description: 'Por favor, inténtelo de nuevo más tarde. Si el error persiste, contacte con soporte.\n\n$error',
            cancelButtonTitle: 'OK',
          );
        }
      );
    }
    LoadingTest.instance().hide();
  });
}