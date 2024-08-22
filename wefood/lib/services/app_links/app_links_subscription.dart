import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/cupertino.dart';

class AppLinksSubscription {

  static late AppLinks appLinks;
  static StreamSubscription<Uri>? subscription;
  static Uri? uri;
  static void Function(Uri)? onAppLinkReceived;

  static Future<void> start() async {
    appLinks = AppLinks();
    subscription = appLinks.uriLinkStream.listen((Uri listened) {
      if(listened.path.contains('changePassword')) {
        debugPrint('APP_LINK_REDIRECT_SCREEN CHANGED TO "changePassword"');
        uri = listened;
        if(onAppLinkReceived != null) {
          onAppLinkReceived!(listened);
        }
      }
    });
  }

  static void cancel() {
    subscription?.cancel();
  }

  static Uri? getUri() {
    return uri;
  }

  static void setOnAppLinkReceivedCallback(void Function(Uri) callback) {
    onAppLinkReceived = callback;
  }
}