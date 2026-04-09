import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';

class LoginSignupScreen extends StatefulWidget {
  const LoginSignupScreen({super.key});

  @override
  State<LoginSignupScreen> createState() => _LoginSignupScreenState();
}

class _LoginSignupScreenState extends State<LoginSignupScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _username = TextEditingController();
  bool _signup = false;
  bool _busy = false;
  static final RegExp _specialCharRegex = RegExp(r'[!@#$%^&*(),.?":{}|<>_\-\[\]\\\/+=`~;]');

  @override
  Widget build(BuildContext context) {
    final app = context.read<AppState>();
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _form,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_signup ? 'Create Account' : 'Hello there!', style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 16),
                    if (_signup)
                      TextFormField(
                        controller: _username,
                        decoration: const InputDecoration(labelText: 'Username'),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter username' : null,
                      ),
                    TextFormField(
                      controller: _email,
                      decoration: const InputDecoration(labelText: 'Email'),
                      validator: (v) {
                        final email = v?.trim() ?? '';
                        return RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email) ? null : 'Enter valid email';
                      },
                    ),
                    TextFormField(
                      controller: _password,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'Password'),
                      validator: (v) {
                        final value = v ?? '';
                        if (value.length < 8) return 'Password must be at least 8 characters';
                        if (!_specialCharRegex.hasMatch(value)) return 'Password must include 1 special character';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _busy
                          ? null
                          : () async {
                              if (!_form.currentState!.validate()) return;
                              setState(() => _busy = true);
                              try {
                                if (_signup) {
                                  await app.signUp(
                                    username: _username.text.trim(),
                                    email: _email.text.trim(),
                                    password: _password.text,
                                  );
                                } else {
                                  await app.signIn(_email.text.trim(), _password.text);
                                }
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                                }
                              } finally {
                                if (mounted) setState(() => _busy = false);
                              }
                            },
                      child: Text(_signup ? 'Sign up' : 'Login'),
                    ),
                    TextButton(
                      onPressed: () => setState(() => _signup = !_signup),
                      child: Text(_signup ? 'Have an account? Login' : 'No account? Sign up'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
