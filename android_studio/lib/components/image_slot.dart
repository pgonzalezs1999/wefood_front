import 'package:flutter/material.dart';

class ImageSlot extends StatefulWidget {

  final Image? image;
  final double? height;
  final double? width;
  final int? i;
  final Function() onTap;

  const ImageSlot({
    super.key,
    this.image,
    this.height,
    this.width,
    this.i,
    required this.onTap,
  });

  @override
  State<ImageSlot> createState() => _ImageSlotState();
}

class _ImageSlotState extends State<ImageSlot> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        widget.onTap();
      },
      child: Stack(
        alignment: Alignment.bottomRight,
        children: <Widget>[
          (widget.image == null)
            ? Container(
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.66),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.add,
                color: Colors.white,
                size: widget.height,
              ),
            )
            : SizedBox(
              width: widget.width,
              height: widget.height,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: widget.image!,
              ),
            ),
          if(widget.i != null) Container(
            margin: const EdgeInsets.all(5),
            height: 18,
            width: 18,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border.all(
                width: 0.5,
                color: Theme.of(context).colorScheme.primary,
              ),
              borderRadius: BorderRadius.circular(9999),
            ),
            child: Text(
              '${widget.i}',
              style: const TextStyle(
                fontSize: 10, // TODO deshardcodear este estilo
              ),
            ),
          ),
        ],
      ),
    );
  }
}