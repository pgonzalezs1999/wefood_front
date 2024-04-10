import 'package:flutter/material.dart';

class WefoodNavigationScreen extends StatefulWidget {
  final List<Widget> children;

  const WefoodNavigationScreen({
    super.key,
    required this.children,
  });

  @override
  State<WefoodNavigationScreen> createState() => _WefoodNavigationScreenState();
}

class _WefoodNavigationScreenState extends State<WefoodNavigationScreen> {

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: (MediaQuery.of(context).size.height - MediaQuery.of(context).viewPadding.top) * 0.9, // Because navigationBar have height = 0.075
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: widget.children,
        ),
      ),
    );
  }
}