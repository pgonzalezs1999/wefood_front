// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/foundation.dart' show immutable;

typedef CloseLoadingScreen = bool Function();
typedef UpdateLoadingScreen = bool Function(String text);

@immutable
class LoadingTestController {
  final CloseLoadingScreen close; // to close our dialog
  final UpdateLoadingScreen update; // to update any text with in our dialog if needed

  const LoadingTestController({
    required this.close,
    required this.update,
  });
}