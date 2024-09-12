import 'package:flutter/material.dart';
import 'package:wefood/components/components.dart';

class SkeletonItemButton extends StatefulWidget {

  final bool? horizontalScroll;

  const SkeletonItemButton({
    super.key,
    this.horizontalScroll,
  });

  @override
  State<SkeletonItemButton> createState() => _SkeletonItemButtonState();
}

class _SkeletonItemButtonState extends State<SkeletonItemButton> with SingleTickerProviderStateMixin {
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
      begin: Colors.grey[350],
      end: Colors.grey[200],
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
          width: (widget.horizontalScroll == true)
            ? MediaQuery.of(context).size.width * 0.8
            : MediaQuery.of(context).size.width,
          margin: const EdgeInsets.only(
            top: 10,
          ),
          padding: (widget.horizontalScroll == true)
            ? const EdgeInsets.only(right: 10)
            : null,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            color: _colorAnimation.value,
            child: SizedBox(
              height: 145,
              child: Stack(
                alignment: Alignment.topCenter,
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: const SizedBox(
                      height: 145,
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.only(
                          top: 10,
                          left: 10,
                          right: 12,
                        ),
                      ),
                      ClipRect(
                        child: Container(
                          color: Colors.white.withOpacity(0.666),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          width: double.infinity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SkeletonText(
                                width: MediaQuery.of(context).size.width * 0.3,
                              ),
                              SkeletonText(
                                width: MediaQuery.of(context).size.width * 0.5,
                              ),
                              SkeletonText(
                                width: MediaQuery.of(context).size.width * 0.75,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }
    );
  }
}