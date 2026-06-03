import 'package:flutter/material.dart';

import '../state/session.dart';
import '../widgets/auth_widgets.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, required this.session});

  final Session session;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();
  String? _localError;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final busy = widget.session.status == SessionStatus.signingIn;

    return AuthScaffold(
      children: [
        const AuthHeader(
          title: 'Create Your Hero',
          subtitle: 'Begin your fitness adventure',
        ),
        const SizedBox(height: 24),
        AuthPanel(
          children: [
            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _password,
              decoration: const InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock),
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _confirmPassword,
              decoration: const InputDecoration(
                labelText: 'Confirm Password',
                prefixIcon: Icon(Icons.verified_user),
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            AuthActionButton(
              onPressed: busy
                  ? null
                  : () async {
                      if (_password.text != _confirmPassword.text) {
                        setState(() => _localError = 'Passwords do not match.');
                        return;
                      }

                      setState(() => _localError = null);
                      await widget.session.signUp(
                        _email.text.trim(),
                        _password.text,
                      );
                    },
              icon: Icons.person_add,
              label: busy ? 'Creating...' : 'Register',
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Already have account? Login'),
            ),
            if (_localError != null || widget.session.errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                _localError ?? widget.session.errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
