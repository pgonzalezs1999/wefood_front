import 'package:flutter/material.dart';
import 'package:wefood/components/skeletons/skeleton_text.dart';

class SkeletonRetribution extends StatefulWidget {

  final bool isFirst;

  const SkeletonRetribution({
    super.key,
    this.isFirst = false,
  });

  @override
  State<SkeletonRetribution> createState() => _SkeletonRetributionState();
}

class _SkeletonRetributionState extends State<SkeletonRetribution> with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _colorAnimation = ColorTween(
      begin: Colors.white,
      end: Colors.grey[100],
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            color: _colorAnimation.value,
            border: Border(
              top: (!widget.isFirst) ?
              const BorderSide(
                width: 0.25,
              ) : BorderSide.none,
            ),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 15,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SkeletonText(
                width: MediaQuery.of(context).size.width * 0.75,
              ),
              const SizedBox(
                height: 6,
              ),
              SkeletonText(
                width: MediaQuery.of(context).size.width * 0.333,
              ),
              const SizedBox(
                height: 6,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  SkeletonText(
                    width: MediaQuery.of(context).size.width * 0.25,
                  ),
                  SkeletonText(
                    width: MediaQuery.of(context).size.width * 0.2,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
