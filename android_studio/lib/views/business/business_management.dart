import 'package:flutter/material.dart';
import 'package:wefood/components/wefood_navigation_screen.dart';

class BusinessManagement extends StatefulWidget {
  const BusinessManagement({super.key});

  @override
  State<BusinessManagement> createState() => _BusinessManagementState();
}

class _BusinessManagementState extends State<BusinessManagement> {

  @override
  Widget build(BuildContext context) {
    return const WefoodNavigationScreen(
      children: [
        Text('Business management'),
      ],
    );
  }
}