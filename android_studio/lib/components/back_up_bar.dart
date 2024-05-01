import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wefood/components/components.dart';

class BackUpBar extends StatefulWidget {

  final String title;

  const BackUpBar({
    super.key,
    required this.title,
  });

  @override
  State<BackUpBar> createState() => _BackUpBarState();
}

class _BackUpBarState extends State<BackUpBar> {

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        const BackArrow(
          margin: EdgeInsets.only(
            right: 5,
          ),
        ),
        Expanded(
          child: Text(
            widget.title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
      ],
    );
  }
}