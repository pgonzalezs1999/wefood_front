import 'package:flutter/material.dart';

class ImageSlot extends StatefulWidget {

  final bool isMain;
  final Image? image;

  const ImageSlot({
    super.key,
    this.isMain = false,
    this.image,
  });

  @override
  State<ImageSlot> createState() => _ImageSlotState();
}

class _ImageSlotState extends State<ImageSlot> {
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