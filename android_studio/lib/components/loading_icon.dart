import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoadingIcon extends StatelessWidget {

  final double? size;

  const LoadingIcon({
    super.key,
    this.size,
  });

  @override
  Widget build(BuildContext context) {

    double? containerSize = (size != null) ? size! * 0.555 : null;

    return SizedBox(
      height: containerSize,
      width: containerSize,
      child: const CircularProgressIndicator(
        strokeWidth: 1.5,
      ),
    );
  }
}