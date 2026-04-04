// PROFILE SCREEN
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class ProfileScreen extends StatelessWidget {
  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(radius: 40),
        SizedBox(height: 10),
        Text(_auth.currentUser?.email ?? ''),
        SizedBox(height: 20),
        CircularProgressIndicator(value: 0.6),
      ],
    );
  }

}