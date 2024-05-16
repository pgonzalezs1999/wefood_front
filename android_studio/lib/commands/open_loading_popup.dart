import 'package:flutter/material.dart';
import 'package:wefood/components/components.dart';

openLoadingPopup(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return PopScope(
        canPop: false,
        onPopInvoked: (_) {},
        child: AlertDialog(
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
        ),
      );
    }
  );
}