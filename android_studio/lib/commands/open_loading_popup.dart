import 'package:flutter/material.dart';
import 'package:wefood/components/components.dart';

openLoadingPopup(BuildContext context) async {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.symmetric(
                vertical: 50,
              ),
              child: const LoadingIcon(),
            ),
          ],
        ),
      );
    }
  );
}