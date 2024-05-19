import 'package:flutter/material.dart';
import 'package:wefood/components/components.dart';

class WefoodLoadingPopup extends StatefulWidget {

  const WefoodLoadingPopup({
    super.key,
  });

  @override
  State<WefoodLoadingPopup> createState() => _WefoodLoadingPopupState();
}

class _WefoodLoadingPopupState extends State<WefoodLoadingPopup> {

  @override
  Widget build(BuildContext _) {
    return PopScope(
      canPop: false,
      onPopInvoked: (_) {},
      child: AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.symmetric(
                vertical: 50,
              ),
              child: const LoadingIcon(),
            ),
          ],
        ),
      ),
    );
  }
}