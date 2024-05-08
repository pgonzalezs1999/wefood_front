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
            onChanged: (value) => widget.onChanged(),
          ),
        ),
        Text(widget.title),
      ],
    );
  }
}

class _ImageSlot extends StatefulWidget {

  final bool isMain;
  final Image? image;

  const _ImageSlot({
    this.isMain = false,
    this.image,
  });

  @override
  State<_ImageSlot> createState() => _ImageSlotState();
}

class _ImageSlotState extends State<_ImageSlot> {
  @override
  Widget build(BuildContext context) {
    final double size = MediaQuery.of(context).size.width * (widget.isMain ? 0.25 : 0.1);

    return (widget.image == null)
      ? Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.66),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          Icons.add,
          color: Colors.white,
          size: size * 0.75,
        ),
      )
      : SizedBox(
        width: size,
        height: size,
        child: ClipRRect(
          borderRadius: (widget.isMain) ? BorderRadius.circular(15) : BorderRadius.circular(10),
          child: widget.image!,
        ),
      );
  }
}