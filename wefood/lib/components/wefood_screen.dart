import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wefood/commands/wefood_show_dialog.dart';
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
  final ScrollController? controller;
  final bool preventScrolling;
  final Widget? floatingActionButton;

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
    this.controller,
    this.preventScrolling = false,
    this.floatingActionButton,
  });

  @override
  State<WefoodScreen> createState() => _WefoodScreenState();
}

class _WefoodScreenState extends State<WefoodScreen> {
  void _onPopInvoked(bool param) {
    if(widget.canPop == false) {
      FocusScope.of(context).unfocus();
      wefoodShowDialog(
        context: context,
        title: '¿Cerrar WeFood?',
        actions: <TextButton>[
          TextButton(
            onPressed: () {
              SystemChannels.platform.invokeMethod('SystemNavigator.pop');
            },
            child: const Text('SÍ'),
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Column(
      mainAxisAlignment: widget.bodyMainAxisAlignment,
      crossAxisAlignment: widget.bodyCrossAxisAlignment,
      children: <Widget>[
        if(widget.title != null) Row(
          children: <Widget>[
            if(widget.ignoreHorizontalPadding == true) const SizedBox(
              width: 20,
            ),
            Expanded(
              child: BackUpBar(
                title: widget.title!,
              ),
            ),
          ],
        ),
        if(widget.title != null) const SizedBox(
          height: 20,
        ),
      ] + widget.body + [
        SizedBox(
          height: (widget.ignoreVerticalPadding == true) ? 0 : MediaQuery.of(context).size.height * 0.5,
        ),
      ],
    );

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
          child: (widget.preventScrolling == true)
            ? content
            : SingleChildScrollView(
              controller: widget.controller,
              physics: const AlwaysScrollableScrollPhysics(),
              child: content
            ),
        ),
        bottomNavigationBar: widget.bottomNavigationBar,
        floatingActionButton: widget.floatingActionButton,
      ),
    );
  }
}