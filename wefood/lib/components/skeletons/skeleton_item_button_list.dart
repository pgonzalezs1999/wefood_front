import 'package:flutter/material.dart';
import 'package:wefood/components/components.dart';

class SkeletonItemButtonList extends StatelessWidget {

  final bool? horizontalScroll;

  const SkeletonItemButtonList({
    super.key,
    this.horizontalScroll = false,
  });

  @override
  Widget build(BuildContext context) {
    return (horizontalScroll == true)
    ? const SkeletonItemButton()
    : const Column(
      children: [
        SkeletonItemButton(),
        SkeletonItemButton(),
        SkeletonItemButton(),
      ],
    );
  }
}
