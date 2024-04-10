import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wefood/environment.dart';

class WefoodScreen extends StatefulWidget {
  final AppBar? appBar;
  final Widget body;
  final Widget? bottomNavigationBar;
  final bool? canPop;
  final Function(bool)? onPopInvoked;
  final bool ignoreHorizontalPadding;
  final bool ignoreVerticalPadding;

  const WefoodScreen({
    super.key,
    this.appBar,
    required this.body,
    this.bottomNavigationBar,
    this.canPop,
    this.onPopInvoked,
    this.ignoreHorizontalPadding = false,
    this.ignoreVerticalPadding = false
  });

  @override
  State<WefoodScreen> createState() => _WefoodScreenState();
}

class _WefoodScreenState extends State<WefoodScreen> {
  void _onPopInvoked(bool param) {
    if(widget.canPop == false) {
      FocusScope.of(context).unfocus();
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('¿Cerrar WeFood?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () {
                  SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                },
                child: const Text('Sí'),
              ),
            ],
          );
        }
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: _onPopInvoked,
      canPop: widget.canPop ?? true,
      child: Scaffold(
        appBar: widget.appBar,
        body: Container(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          padding: EdgeInsets.only(
            top: widget.ignoreVerticalPadding ? 0 : MediaQuery.of(context).size.height * Environment.defaultVerticalMargin,
            left: widget.ignoreHorizontalPadding ? 0 : MediaQuery.of(context).size.width * Environment.defaultHorizontalMargin,
            right: widget.ignoreHorizontalPadding ? 0 : MediaQuery.of(context).size.width * Environment.defaultHorizontalMargin,
          ),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: widget.body,
          ),
        ),
        bottomNavigationBar: widget.bottomNavigationBar,
      ),
    );
  }
}