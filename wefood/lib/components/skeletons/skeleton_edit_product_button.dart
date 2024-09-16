import 'package:flutter/material.dart';
import 'package:wefood/components/components.dart';

class SkeletonEditProductButton extends StatefulWidget {

  const SkeletonEditProductButton({
    super.key,
  });

  @override
  State<SkeletonEditProductButton> createState() => _SkeletonEditProductButtonState();
}

class _SkeletonEditProductButtonState extends State<SkeletonEditProductButton> {

  @override
  Widget build(BuildContext context) {
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
              /*Container(
                color: Theme.of(context).colorScheme.surfaceContainer,
                width: double.infinity,
                height: 100,
                // height: double.infinity,
              ),*/
              Image.asset(
                'assets/images/logo.png',
                fit: BoxFit.fitWidth,
                width: MediaQuery.of(context).size.width * 0.5,
              ),
              Container(
                color: Colors.white.withOpacity(0.9),
                width: double.infinity,
                height: double.infinity,
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
                      const Expanded(
                        child: SkeletonText()
                      ),
                      const SizedBox(
                        width: 50,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary,
                            width: 0.5,
                          ),
                          borderRadius: BorderRadius.circular(9999999),
                          color: Theme.of(context).colorScheme.surface.withOpacity(0.75),
                        ),
                        height: 80,
                        width: 80,
                        child: const Icon(
                          Icons.edit,
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
}