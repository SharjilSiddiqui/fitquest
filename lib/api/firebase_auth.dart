import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config.dart';

class FirebaseAuthResult {
  FirebaseAuthResult({required this.idToken, required this.email});
  final String idToken;
  final String email;
}

class FirebaseAuthException implements Exception {
  FirebaseAuthException(this.message);
  final String message;
  @override
  String toString() => 'FirebaseAuthException: $message';
}

class FirebaseAuthRest {
  static const _signIn =
      'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword';

  static const _signUp =
      'https://identitytoolkit.googleapis.com/v1/accounts:signUp';

  static Future<FirebaseAuthResult> signIn(
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$_signIn?key=${AppConfig.firebaseApiKey}'),
      headers: const {'content-type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'returnSecureToken': true,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return FirebaseAuthResult(idToken: data['idToken'], email: email);
    }

    throw FirebaseAuthException(
      'sign-in failed (${response.statusCode}): ${_err(response.body)}',
    );
  }

  static Future<FirebaseAuthResult> signUp(
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$_signUp?key=${AppConfig.firebaseApiKey}'),
      headers: const {'content-type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'returnSecureToken': true,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return FirebaseAuthResult(idToken: data['idToken'], email: email);
    }

    throw FirebaseAuthException(
      'sign-up failed (${response.statusCode}): ${_err(response.body)}',
    );
  }

  static String _err(String body) {
    try {
      final decoded = jsonDecode(body);

      if (decoded is Map &&
          decoded['error'] is Map &&
          decoded['error']['message'] is String) {
        return decoded['error']['message'];
      }
    } catch (_) {}

    return body;
  }
}
