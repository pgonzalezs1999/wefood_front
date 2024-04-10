import 'package:flutter/material.dart';

class WefoodPopup extends StatefulWidget {

  final String title;
  final String? description;
  Widget? content;
  final Function()? onYes;
  final String? yesButtonTitle;
  final String? noButtonTitle;

  WefoodPopup({
    super.key,
    required this.title,
    this.description,
    this.content,
    this.onYes,
    this.yesButtonTitle,
    this.noButtonTitle,
  });

  @override
  State<WefoodPopup> createState() => _WefoodPopupState();
}

class _WefoodPopupState extends State<WefoodPopup> {

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if(widget.description != null) Text(widget.description!),
          if(widget.content != null) widget.content!,
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(widget.yesButtonTitle ?? 'NO'),
        ),
        TextButton(
          onPressed: widget.onYes,
          child: Text(widget.yesButtonTitle ?? 'SÍ'),
        ),
      ],
    );
  }
}