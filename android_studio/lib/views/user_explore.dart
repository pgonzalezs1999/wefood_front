import 'package:flutter/material.dart';
import 'package:wefood/components/wefood_navigation_screen.dart';

class UserExplore extends StatefulWidget {
  const UserExplore({super.key});

  @override
  State<UserExplore> createState() => _UserExploreState();
}

class _UserExploreState extends State<UserExplore> {

  @override
  Widget build(BuildContext context) {
    return const WefoodNavigationScreen(
      body: Center(
        child: Text('User explore'),
      ),
    );
  }
}