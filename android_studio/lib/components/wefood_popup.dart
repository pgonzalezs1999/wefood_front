import 'package:flutter/material.dart';

class WefoodPopup extends StatefulWidget {

  final String title;
  final String? description;
  final Function()? onYes;
  final String? yesButtonTitle;
  final String? noButtonTitle;

  const WefoodPopup({
    super.key,
    required this.title,
    this.description,
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
      content: (widget.description != null) ? Text(widget.description!) : null,
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