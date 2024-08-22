import 'package:flutter/material.dart';

class FeedbackMessage extends StatelessWidget {

  final String message;
  final bool isError;
  final bool? isCentered;

  const FeedbackMessage({
    super.key,
    required this.message,
    required this.isError,
    this.isCentered,
  });

  @override
  Widget build(BuildContext context) {

    Color textColor = (isError == true)
      ? (Theme.of(context).textTheme.displaySmall?.color ?? Theme.of(context).colorScheme.secondary)
      : Theme.of(context).colorScheme.primary;

    return Container(
      width: double.infinity,
      alignment: (isCentered == true) ? Alignment.center : null,
      margin: const EdgeInsets.only(
        top: 15,
      ),
      child: Row(
        mainAxisAlignment: (isCentered == true) ? (MainAxisAlignment.center) : MainAxisAlignment.start,
        crossAxisAlignment: (isCentered == true) ? (CrossAxisAlignment.center) : CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            (isError == true) ? Icons.dangerous : Icons.done,
            size: (Theme.of(context).textTheme.displaySmall?.fontSize != null) ? Theme.of(context).textTheme.displaySmall!.fontSize! * 1.25 : 10,
            color: textColor,
          ),
          const SizedBox(
            width: 5,
          ),
          Flexible(
            child: Text(
              message,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: textColor,
                overflow: TextOverflow.clip,
              ),
            ),
          ),
        ],
      ),
    );
  }
}