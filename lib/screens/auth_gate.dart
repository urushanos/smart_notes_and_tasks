import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import 'login_signup_screen.dart';

class AuthGate extends StatelessWidget {
  final Widget authenticated;
  const AuthGate({super.key, required this.authenticated});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    if (app.loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (app.currentAuthUser == null) {
      return const LoginSignupScreen();
    }
    return authenticated;
  }
}
