// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:http/http.dart' as http;

const _clientId = String.fromEnvironment('OAUTH2_CLIENT_ID');
const _clientSecret = String.fromEnvironment('OAUTH2_CLIENT_SECRET');
const _billingHost = String.fromEnvironment(
  'API_BILLING',
  defaultValue: 'https://dev-apibilling.dartstream.io',
);

Future<void> main() async {
  if (_clientId.isEmpty || _clientSecret.isEmpty) {
    throw StateError(
      'Missing OAUTH2_CLIENT_ID or OAUTH2_CLIENT_SECRET dart-define.',
    );
  }

  final basic = base64Encode(utf8.encode('$_clientId:$_clientSecret'));

  print('Requesting OAuth2 access token...\n');

  final response = await http.post(
    Uri.parse('$_billingHost/api/v1/oauth2/token'),
    headers: {
      'authorization': 'Basic $basic',
      'content-type': 'application/x-www-form-urlencoded',
    },
    body: {'grant_type': 'client_credentials'},
  );

  print('Status: ${response.statusCode}');
  print('');
  print(response.body);

  final json = jsonDecode(response.body);

  final accessToken = json['access_token'] as String;

  dumpJwtClaims(accessToken);
}

void dumpJwtClaims(String jwt) {
  final parts = jwt.split('.');

  if (parts.length != 3) {
    print('Invalid JWT');
    return;
  }

  var payload = parts[1].replaceAll('-', '+').replaceAll('_', '/');

  while (payload.length % 4 != 0) {
    payload += '=';
  }

  final claims =
      jsonDecode(utf8.decode(base64Decode(payload))) as Map<String, dynamic>;

  print('\n========== JWT CLAIMS ==========');

  for (final entry in claims.entries) {
    print('${entry.key}: ${entry.value}');
  }

  print('===============================\n');
}
