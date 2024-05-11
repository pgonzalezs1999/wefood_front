import 'dart:async';

import 'package:flutter/material.dart';

void scrollToBottom({
  required ScrollController scrollController,
}) {
  Timer(
    const Duration(milliseconds: 100),
        () {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
    },
  );
}