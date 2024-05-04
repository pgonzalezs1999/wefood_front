import 'package:flutter/material.dart';

class LoadingIcon extends StatelessWidget {

  final double? size;
  final double? strokeWidth;

  const LoadingIcon({
    super.key,
    this.size,
    this.strokeWidth,
  });

  @override
  Widget build(BuildContext context) {

    double? containerSize = (size != null) ? size! * 0.555 : null;

    return SizedBox(
      height: containerSize,
      width: containerSize,
      child: CircularProgressIndicator(
        strokeWidth: (strokeWidth != null) ? strokeWidth! : 4,
      ),
    );
  }
}

class ReducedLoadingIcon extends StatelessWidget {
  const ReducedLoadingIcon({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(15),
      child: LoadingIcon(
        size: Theme.of(context).textTheme.displaySmall?.fontSize,
        strokeWidth: 1.5,
      ),
    );
  }
}