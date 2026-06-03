import 'package:flutter/material.dart';

import '../state/session.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.session});

  final Session session;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final busy = widget.session.status == SessionStatus.signingIn;

    return Scaffold(
      appBar: AppBar(title: const Text('FitQuest')),
      body: Center(
        child: SizedBox(
          width: 400,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _email,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _password,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: busy
                      ? null
                      : () async {
                          await widget.session.signIn(
                            _email.text.trim(),
                            _password.text,
                          );
                        },

                  child: Text(busy ? 'Signing In...' : 'Sign In'),
                ),
                const SizedBox(height: 16),

                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RegisterScreen(session: widget.session),
                      ),
                    );
                  },
                  child: const Text('Create Account'),
                ),
                if (widget.session.errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    widget.session.errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
