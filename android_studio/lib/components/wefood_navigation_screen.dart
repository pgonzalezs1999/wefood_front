import 'package:flutter/material.dart';

class WefoodNavigationScreen extends StatefulWidget {
  final Widget body;

  const WefoodNavigationScreen({
    super.key,
    required this.body,
  });

  @override
  State<WefoodNavigationScreen> createState() => _WefoodNavigationScreenState();
}

class _WefoodNavigationScreenState extends State<WefoodNavigationScreen> {

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        minHeight: MediaQuery.of(context).size.height,
      ),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: widget.body,
      ),
    );
  }
}