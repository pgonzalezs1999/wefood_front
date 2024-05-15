import 'package:flutter/material.dart';

class PrintStars extends StatefulWidget {

  final double rate;

  const PrintStars({
    super.key,
    required this.rate,
  });

  @override
  State<PrintStars> createState() => _PrintStarsState();
}

class _PrintStarsState extends State<PrintStars> {

  Icon _chooseStarIcon({
    required double rate,
    required double step
  }) {
    IconData iconData = Icons.star_half;
    if(rate > step + 0.2) {
      iconData = Icons.star;
    } else if(rate < step - 0.2) {
      iconData = Icons.star_outline;
    }
    return Icon(
      iconData,
      size: 20,
      color: (widget.rate >= 2.5) ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.secondary,
    );
  }

  List<Widget> _printStars(double rate) {
    List<Widget> result = [];
    result.add(_chooseStarIcon(rate: rate, step: 0.5));
    result.add(_chooseStarIcon(rate: rate, step: 1.5));
    result.add(_chooseStarIcon(rate: rate, step: 2.5));
    result.add(_chooseStarIcon(rate: rate, step: 3.5));
    result.add(_chooseStarIcon(rate: rate, step: 4.5));
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _printStars(widget.rate),
    );
  }
}
