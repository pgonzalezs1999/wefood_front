import 'dart:async';
import 'package:flutter/material.dart';
import 'package:wefood/services/loading/loading_test_controller.dart';

class LoadingTest {
  LoadingTest._shareInstance();
  static final LoadingTest _shared = LoadingTest._shareInstance();
  factory LoadingTest.instance() => _shared;

  LoadingTestController? _controller;

  void show({
    required BuildContext context,
    String text = 'Loading',
  }) {
    if(_controller?.update(text) ?? false) {
      return;
    } else {
      _controller = showOverlay(
        context: context,
        text: text
      );
    }
  }

  void hide() {
    _controller?.close();
    _controller = null;
  }

  LoadingTestController? showOverlay({
    required BuildContext context,
    required String text,
  }) {
    final textController = StreamController<String>();
    textController.add(text);
    final state = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    final overlay = OverlayEntry(
      builder: (context) {
        return Material(
          color: Colors.black.withAlpha(150),
          child: Center(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: size.width * 0.8,
                maxHeight: size.width * 0.8,
                minWidth: size.width * 0.5,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 10),
                    const CircularProgressIndicator(),
                    const SizedBox(height: 10),
                    StreamBuilder(
                      stream: textController.stream,
                      builder: (context, snapshot) {
                        if(snapshot.hasData) {
                          return Text(
                            snapshot.requireData,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black),
                          );
                        } else {
                          return Container();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    state.insert(overlay);

    return LoadingTestController(
      close: () {
        textController.close();
        overlay.remove();
        return true;
      },
      update: (String text) {
        textController.add(text);
        return true;
      },
    );
  }
}