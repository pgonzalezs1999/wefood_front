import 'package:flutter/material.dart';

class WefoodScreen extends StatefulWidget {
  final AppBar? appBar;
  final Widget child;

  const WefoodScreen({
    super.key,
    this.appBar,
    required this.child,
  });

  @override
  State<WefoodScreen> createState() => _WefoodScreenState();
}

class _WefoodScreenState extends State<WefoodScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.appBar,
      body: Container(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height,
        ),
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).size.height * 0.025,
          left: MediaQuery.of(context).size.width * 0.05,
          right: MediaQuery.of(context).size.width * 0.05,
        ),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: widget.child,
        ),
      ),
    );
  }
}