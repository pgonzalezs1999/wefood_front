import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wefood/components/components.dart';
import 'package:wefood/environment.dart';

class WefoodScreen extends StatefulWidget {
  final String? title;
  final List<Widget> body;
  final Widget? bottomNavigationBar;
  final bool? canPop;
  final Function(bool)? onPopInvoked;
  final bool ignoreHorizontalPadding;
  final bool ignoreVerticalPadding;
  final MainAxisAlignment bodyMainAxisAlignment;
  final CrossAxisAlignment bodyCrossAxisAlignment;

  const WefoodScreen({
    super.key,
    this.title,
    required this.body,
    this.bottomNavigationBar,
    this.canPop,
    this.onPopInvoked,
    this.ignoreHorizontalPadding = false,
    this.ignoreVerticalPadding = false,
    this.bodyMainAxisAlignment = MainAxisAlignment.start,
    this.bodyCrossAxisAlignment = CrossAxisAlignment.start,
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
            child: Column(
              mainAxisAlignment: widget.bodyMainAxisAlignment,
              crossAxisAlignment: widget.bodyCrossAxisAlignment,
              children: <Widget>[
                if(widget.title != null) BackUpBar(
                  title: widget.title!,
                ),
                if(widget.title != null) const SizedBox(
                  height: 20,
                ),
              ]+ widget.body +[
                const SizedBox(
                  height: 25,
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: widget.bottomNavigationBar,
      ),
    );
  }
}