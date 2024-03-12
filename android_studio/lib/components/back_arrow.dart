import 'package:flutter/material.dart';

class BackArrow extends StatefulWidget {

  const BackArrow({super.key});

  @override
  State<BackArrow> createState() => _BackArrowState();
}

class _BackArrowState extends State<BackArrow> {

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: const Color.fromRGBO(255, 255, 255, 0.666),
        ),
        margin: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
        padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.02),
        child: Icon(
            Icons.arrow_back,
          size: MediaQuery.of(context).size.width * 0.06,
        ),
      ),
      onTap: () => Navigator.pop(context, true),
    );
  }
}