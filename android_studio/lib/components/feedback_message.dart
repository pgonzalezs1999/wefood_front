import 'package:flutter/material.dart';

class FeedbackMessage extends StatefulWidget {

  final String message;
  final bool isError;

  const FeedbackMessage({
    super.key,
    required this.message,
    required this.isError,
  });

  @override
  State<FeedbackMessage> createState() => _FeedbackMessageState();
}

class _FeedbackMessageState extends State<FeedbackMessage> {

  @override
  Widget build(BuildContext context) {

    Color textColor = (widget.isError == true)
      ? (Theme.of(context).textTheme.displaySmall?.color ?? Theme.of(context).colorScheme.secondary)
      : Theme.of(context).colorScheme.primary;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(
          (widget.isError == true) ? Icons.dangerous : Icons.done,
          size: (Theme.of(context).textTheme.displaySmall?.fontSize != null) ? Theme.of(context).textTheme.displaySmall!.fontSize! * 1.25 : 10,
          color: textColor,
        ),
        const SizedBox(
          width: 5,
        ),
        Text(
          widget.message,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            color: textColor,
          ),
        )
      ],
    );
  }
}