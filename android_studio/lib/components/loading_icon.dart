import 'package:flutter/material.dart';

class LoadingIcon extends StatelessWidget {
  const LoadingIcon({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(
        child: CircularProgressIndicator()
    );
  }
}