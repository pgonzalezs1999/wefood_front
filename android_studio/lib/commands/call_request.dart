import 'package:flutter/material.dart';
import 'package:wefood/services/loading/loading_test.dart';

callRequestWithLoading({
  required BuildContext context,
  required Function request,
  required Function onSuccess,
  required Function onError,
  bool closePreviousPopup = false,
}) {
  if(closePreviousPopup == true) {
    Navigator.pop(context);
  }
  LoadingTest.instance().show(context: context);
  request().then((dynamic response) {
    LoadingTest.instance().hide();
    onSuccess(response);
  }).catchError((error, stackTrace) {
    LoadingTest.instance().hide();
    onError();
  });
}