import 'package:flutter/material.dart';

class SkeletonText extends StatefulWidget {

  final double? width;

  const SkeletonText({
    super.key,
    this.width,
  });

  @override
  State<SkeletonText> createState() => _SkeletonTextState();
}

class _SkeletonTextState extends State<SkeletonText> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 10,
      width: widget.width ?? MediaQuery.of(context).size.width,
      margin: const EdgeInsets.symmetric(
        vertical: 5,
      ),
      padding: const EdgeInsets.symmetric(
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: const BorderRadius.all(Radius.circular(999)),
      ),
    );
  }
}