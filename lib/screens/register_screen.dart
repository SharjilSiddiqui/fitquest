import 'package:flutter/material.dart';

import '../state/session.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, required this.session});

  final Session session;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final busy = widget.session.status == SessionStatus.signingIn;

    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
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
                          await widget.session.signUp(
                            _email.text.trim(),
                            _password.text,
                          );
                        },
                  child: Text(busy ? 'Creating...' : 'Create Account'),
                ),

                const SizedBox(height: 12),

                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Already have an account? Sign In'),
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
