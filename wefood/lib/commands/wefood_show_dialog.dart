import 'package:flutter/material.dart';

wefoodShowDialog({
  required BuildContext context,
  Image? image,
  String? title,
  String? description,
  Widget? content,
  String? cancelButtonTitle,
  Function()? cancelButtonBehaviour,
  List<TextButton>? actions,
  Function? onClose,
}) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      content: Container(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.1,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              margin: EdgeInsets.symmetric(
                vertical: MediaQuery.of(context).size.height * 0.05,
              ),
              child: (image != null)
                ? image
                : const Image(
                  image: AssetImage('assets/images/logo.png'),
                ),
            ),
            if(title != null) Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            if(title != null) const SizedBox(
              height: 20,
            ),
            if(description != null) Text(
              description,
              textAlign: TextAlign.center,
            ),
            if(content != null) content,
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: (cancelButtonBehaviour != null)
            ? () => cancelButtonBehaviour()
            : () => Navigator.pop(context),
          child: Text(cancelButtonTitle ?? 'NO'),
        ),
      ] + (actions ?? []),
    ),
  ).then((onClose != null) ? onClose() : (value) { });
}