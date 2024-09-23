import 'package:flutter/material.dart';

class WefoodPopup extends StatefulWidget {

  final BuildContext context;
  final Image? image;
  final String? title;
  final String? description;
  final Widget? content;
  final String? cancelButtonTitle;
  final Function()? cancelButtonBehaviour;
  final List<TextButton>? actions;

  const WefoodPopup({
    super.key,
    required this.context,
    this.image,
    this.title,
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
  Widget build(BuildContext context) {
    return AlertDialog(
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
              child: (widget.image != null)
                  ? widget.image!
                  : const Image(
                image: AssetImage('assets/images/logo.png'),
              ),
            ),
            if(widget.title != null) Text(
              widget.title!,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            if(widget.title != null) const SizedBox(
              height: 20,
            ),
            if(widget.description != null) Text(
              widget.description!,
              textAlign: TextAlign.center,
            ),
            if(widget.content != null) widget.content!,
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: (widget.cancelButtonBehaviour != null)
            ? () => widget.cancelButtonBehaviour!()
            : () => Navigator.pop(context),
          child: Text(widget.cancelButtonTitle ?? 'NO'),
        ),
      ] + (widget.actions ?? []),
    );
  }
}