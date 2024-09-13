import 'package:flutter/material.dart';
import 'package:wefood/components/components.dart';

class SkeletonEditProductButton extends StatefulWidget {

  const SkeletonEditProductButton({
    super.key,
  });

  @override
  State<SkeletonEditProductButton> createState() => _SkeletonEditProductButtonState();
}

class _SkeletonEditProductButtonState extends State<SkeletonEditProductButton> with SingleTickerProviderStateMixin {
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
      begin: Colors.grey[50],
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
        return SizedBox(
          height: 150,
          width: MediaQuery.of(context).size.width,
          child: Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  Container(
                    color: _colorAnimation.value,
                  ),
                  ClipRect(
                    child: Container(
                      height: double.infinity,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 35,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          SkeletonText(
                            width: MediaQuery.of(context).size.width * 0.333,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Theme.of(context).colorScheme.primary,
                                width: 0.5,
                              ),
                              borderRadius: BorderRadius.circular(9999999),
                              color: Theme.of(context).colorScheme.surface.withOpacity(0.333),
                            ),
                            height: 80,
                            width: 80,
                            child: const Icon(
                              Icons.hourglass_empty,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      }
    );
  }
}