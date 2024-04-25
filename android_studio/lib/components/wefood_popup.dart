import 'dart:io';

import 'package:flutter/material.dart';

class WefoodDialog extends StatefulWidget {

  final File? image;
  final String title;
  final String? description;
  Widget? content;
  final String? cancelButtonTitle;
  final Function()? cancelButtonBehaviour;
  final List<TextButton>? actions;

  WefoodDialog({
    super.key,
    this.image,
    required this.title,
    this.description,
    this.content,
    this.cancelButtonTitle,
    this.cancelButtonBehaviour,
    this.actions,
  });

  @override
  State<WefoodDialog> createState() => _WefoodDialogState();
}

class _WefoodDialogState extends State<WefoodDialog> {

  @override
  Widget build(BuildContext context) {

    List<TextButton> actions = (widget.actions != null) ? widget.actions! : List.empty();

    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            margin: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.1,
              vertical: MediaQuery.of(context).size.height * 0.05,
            ),
            child: Image(
              image: (widget.image != null)
                ? FileImage(widget.image!)
                : const AssetImage('assets/images/logo.png'),
            ),
          ),
          Text(
            widget.title,
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 20,
          ),
          if(widget.description != null) Text(
            widget.description!,
            textAlign: TextAlign.center,
          ),
          if(widget.content != null) widget.content!,
        ],
      ),
      actions: [
        TextButton(
          onPressed: (widget.cancelButtonBehaviour != null)
            ? () {
              widget.cancelButtonBehaviour!();
            }
            : () {
            Navigator.of(context).pop();
          },
          child: Text(widget.cancelButtonTitle ?? 'NO'),
        ),
      ] + actions,
    );
  }
}

class WefoodPopup {
  static Future<void> show({
    required BuildContext context,
    File? image,
    required  String title,
    String? description,
    Widget? content,
    String? cancelButtonTitle,
    Function()? cancelButtonBehaviour,
    List<TextButton>? actions,
  }) async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return WefoodDialog(
          image: image,
          title: title,
          description: description,
          content: content,
          cancelButtonTitle: cancelButtonTitle,
          cancelButtonBehaviour: cancelButtonBehaviour,
          actions: actions,
        );
      }
    );
  }
}