import 'package:flutter/material.dart';
import 'package:wefood/components/wefood_navigation_screen.dart';

class BusinessProfile extends StatefulWidget {
  const BusinessProfile({super.key});

  @override
  State<BusinessProfile> createState() => _BusinessProfileState();
}

class _BusinessProfileState extends State<BusinessProfile> {

  @override
  Widget build(BuildContext context) {
    return const WefoodNavigationScreen(
      children: [
        Text('Business profile'),
      ],
    );
  }
}