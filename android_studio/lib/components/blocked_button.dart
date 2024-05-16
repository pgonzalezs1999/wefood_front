import 'package:flutter/material.dart';

class BlockedButton extends StatelessWidget {

  final String text;

  const BlockedButton({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999),
      ),
      child: IntrinsicWidth(
        child: Container(
          alignment: Alignment.center,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: Colors.blueGrey.withOpacity(0.333),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 22,
          ),
          child: Text(
            text,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.surface,
            ),
          ),
        ),
      ),
    );
  }
}
