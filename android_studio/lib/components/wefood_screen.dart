import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WefoodScreen extends StatefulWidget {
  final AppBar? appBar;
  final Widget body;
  final BottomNavigationBar? bottomNavigationBar;
  final bool? canPop;
  final Function(bool)? onPopInvoked;

  const WefoodScreen({
    super.key,
    this.appBar,
    required this.body,
    this.bottomNavigationBar,
    this.canPop,
    this.onPopInvoked,
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
            top: MediaQuery.of(context).size.height * 0.05,
            left: MediaQuery.of(context).size.width * 0.05,
            right: MediaQuery.of(context).size.width * 0.05,
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