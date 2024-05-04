import 'dart:io';

import 'package:flutter/material.dart';

class WefoodPopup extends StatefulWidget {

  final BuildContext context;
  final File? image;
  final String title;
  final String? description;
  final Widget? content;
  final String? cancelButtonTitle;
  final Function()? cancelButtonBehaviour;
  final List<TextButton>? actions;

  const WefoodPopup({
    super.key,
    required this.context,
    this.image,
    required this.title,
    this.description,
    this.content,
    this.cancelButtonTitle,
    this.cancelButtonBehaviour,
    this.actions,
  });

  @override
  State<WefoodPopup> createState() => _WefoodPopupState();
}

class _WefoodPopupState extends State<WefoodPopup> {

  @override
  Widget build(BuildContext _) {
    return StatefulBuilder(builder: (_, StateSetter setState) {
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
              style: Theme.of(context).textTheme.titleMedium,
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
              ? () => widget.cancelButtonBehaviour!()
              : () => Navigator.of(context).pop(),
            child: Text(widget.cancelButtonTitle ?? 'NO'),
          ),
        ] + (widget.actions ?? []),
      );
    });
  }
}