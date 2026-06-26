// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

Future<void> main() async {
  final clientId = Platform.environment['OAUTH2_CLIENT_ID']!;
  final clientSecret = Platform.environment['OAUTH2_CLIENT_SECRET']!;

  final billingHost =
      Platform.environment['API_BILLING'] ??
      'https://dev-apibilling.dartstream.io';

  final basic = base64Encode(utf8.encode('$clientId:$clientSecret'));

  print('Requesting OAuth2 access token...\n');

  final response = await http.post(
    Uri.parse('$billingHost/api/v1/oauth2/token'),
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
