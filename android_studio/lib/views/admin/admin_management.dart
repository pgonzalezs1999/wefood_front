import 'package:flutter/material.dart';
import 'package:wefood/components/wefood_navigation_screen.dart';
import 'package:wefood/views/admin/validatable_businesses.dart';

class AdminManagement extends StatefulWidget {
  const AdminManagement({super.key});

  @override
  State<AdminManagement> createState() => _AdminManagementState();
}

class _AdminManagementState extends State<AdminManagement> {

  @override
  Widget build(BuildContext context) {
    return WefoodNavigationScreen(
      children: [
        Align(
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ValidatableBusinesses(),
                ),
              );
            },
            child: const Text('VALIDAR NUEVOS ESTABLECIMIENTOS'),
          ),
        ),
      ],
    );
  }
}