import 'package:flutter/material.dart';
import 'package:wefood/components/wefood_navigation_screen.dart';

class AdminManagement extends StatefulWidget {
  const AdminManagement({super.key});

  @override
  State<AdminManagement> createState() => _AdminManagementState();
}

class _AdminManagementState extends State<AdminManagement> {

  @override
  Widget build(BuildContext context) {
    return const WefoodNavigationScreen(
      children: [
        Text('Admin management'),
      ],
    );
  }
}