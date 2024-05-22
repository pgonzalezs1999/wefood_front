import 'package:flutter/material.dart';

class CheckBoxRow extends StatefulWidget {

  final String title;
  final bool value;
  final Function() onChanged;

  const CheckBoxRow({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  State<CheckBoxRow> createState() => _CheckBoxState();
}

class _CheckBoxState extends State<CheckBoxRow> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 30,
          height: 30,
          margin: const EdgeInsets.only(
            right: 10,
          ),
          child: Checkbox(
            value: widget.value,
            onChanged: (value) {
              FocusScope.of(context).unfocus();
              widget.onChanged();
            },
          ),
        ),
        Text(widget.title),
      ],
    );
  }
}