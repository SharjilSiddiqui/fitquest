import 'package:flutter/material.dart';

import '../state/session.dart';
import '../widgets/auth_widgets.dart';
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
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final busy = widget.session.status == SessionStatus.signingIn;

    return AuthScaffold(
      children: [
        const AuthHeader(
          title: 'Welcome Back Hero',
          subtitle: 'Continue your fitness adventure',
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
            const SizedBox(height: 20),
            AuthActionButton(
              onPressed: busy
                  ? null
                  : () async {
                      await widget.session.signIn(
                        _email.text.trim(),
                        _password.text,
                      );
                    },
              icon: Icons.login,
              label: busy ? 'Logging In...' : 'Login',
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: null,
              icon: const Icon(Icons.g_mobiledata),
              label: const Text('Google Sign-In'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RegisterScreen(session: widget.session),
                  ),
                );
              },
              child: const Text('Register'),
            ),
            if (widget.session.errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                widget.session.errorMessage!,
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
