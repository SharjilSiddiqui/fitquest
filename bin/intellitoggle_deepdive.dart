// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

const _tokenUrl = String.fromEnvironment('INTELLITOGGLE_TOKEN_URL');
const _apiUrl = String.fromEnvironment('INTELLITOGGLE_API_URL');
const _clientId = String.fromEnvironment('INTELLITOGGLE_CLIENT_ID');
const _clientSecret = String.fromEnvironment('INTELLITOGGLE_CLIENT_SECRET');
const _tenantId = String.fromEnvironment('INTELLITOGGLE_TENANT_ID');
const _projectId = String.fromEnvironment('INTELLITOGGLE_PROJECT_ID');
const _environment = String.fromEnvironment('INTELLITOGGLE_ENVIRONMENT');

const _flagDefinitions = <String, String>{
  'double-xp': 'Double XP',
  'infinite-stamina': 'Infinite Stamina',
  'health-regen': 'Health Regen',
  'low-gravity': 'Low Gravity',
  'enemy-density': 'Enemy Density',
  'rare-loot': 'Rare Loot',
  'night-mode': 'Night Mode',
  'debug-hud': 'Debug HUD',
};

const _context = {
  'app': 'fitquest',
  'environment': _environment,
  'platform': 'flutter-web',
};

Future<void> main() async {
  _validateConfig();

  final client = http.Client();
  try {
    do {
      final token = await _requestToken(client);
      _printTokenDetails(token);
      await _evaluateFlags(client, token.accessToken);

      stdout.write('\nPress r then Enter to refresh, or Enter to exit: ');
    } while (stdin.readLineSync()?.trim().toLowerCase() == 'r');
  } finally {
    client.close();
  }
}

void _validateConfig() {
  final missing = <String>[
    if (_tokenUrl.isEmpty) 'INTELLITOGGLE_TOKEN_URL',
    if (_apiUrl.isEmpty) 'INTELLITOGGLE_API_URL',
    if (_clientId.isEmpty) 'INTELLITOGGLE_CLIENT_ID',
    if (_clientSecret.isEmpty) 'INTELLITOGGLE_CLIENT_SECRET',
    if (_tenantId.isEmpty) 'INTELLITOGGLE_TENANT_ID',
    if (_projectId.isEmpty) 'INTELLITOGGLE_PROJECT_ID',
    if (_environment.isEmpty) 'INTELLITOGGLE_ENVIRONMENT',
  ];

  if (missing.isNotEmpty) {
    throw StateError(
      'Missing required dart-define values: ${missing.join(', ')}',
    );
  }
}

Future<_Token> _requestToken(http.Client client) async {
  print('Requesting IntelliToggle OAuth token...');

  final basic = base64Encode(utf8.encode('$_clientId:$_clientSecret'));
  final response = await client.post(
    Uri.parse(_tokenUrl),
    headers: {
      'authorization': 'Basic $basic',
      'content-type': 'application/x-www-form-urlencoded',
    },
    body: const {'grant_type': 'client_credentials'},
  );

  if (response.statusCode < 200 || response.statusCode >= 300) {
    throw StateError('OAuth failed (${response.statusCode}): ${response.body}');
  }

  final decoded = jsonDecode(response.body);
  if (decoded is! Map<String, dynamic>) {
    throw StateError('OAuth returned an invalid response.');
  }

  final token = _Token.fromJson(decoded);
  if (token.accessToken.isEmpty) {
    throw StateError('OAuth did not return an access token.');
  }

  print('OAuth token acquired.');
  return token;
}

void _printTokenDetails(_Token token) {
  print('\n========== TOKEN ==========');
  print('Token type: ${token.tokenType}');
  print('Expires in: ${token.expiresIn} seconds');

  final claims = _decodeJwtPayload(token.accessToken);
  if (claims == null) {
    print('Access token is not a JWT or could not be decoded.');
  } else {
    print('\n========== JWT CLAIMS ==========');
    for (final entry in claims.entries) {
      print('${entry.key}: ${entry.value}');
    }
  }

  print('==========================\n');
}

Future<void> _evaluateFlags(http.Client client, String accessToken) async {
  print('Evaluating IntelliToggle flags...');
  print('Environment: $_environment');
  print('Project: $_projectId');

  for (final entry in _flagDefinitions.entries) {
    final result = await _evaluateFlag(client, accessToken, entry.key);
    final enabled = _enabled(result);
    final evaluated = result['evaluated'] != false && result['error'] == null;

    print(
      '${entry.value.padRight(18)} ${entry.key.padRight(18)} '
      '${enabled ? 'ON ' : 'OFF'} evaluated=$evaluated',
    );
  }
}

Future<Map<String, dynamic>> _evaluateFlag(
  http.Client client,
  String accessToken,
  String flagKey,
) async {
  final baseUrl = _apiUrl.endsWith('/')
      ? _apiUrl.substring(0, _apiUrl.length - 1)
      : _apiUrl;
  final uri = Uri.parse(
    '$baseUrl/api/v1/tenants/$_tenantId/projects/$_projectId/environments/$_environment/flags/$flagKey/evaluate',
  );

  final response = await client.post(
    uri,
    headers: {
      'authorization': 'Bearer $accessToken',
      'content-type': 'application/json',
    },
    body: jsonEncode({'context': _context}),
  );

  if (response.statusCode < 200 || response.statusCode >= 300) {
    throw StateError(
      'Evaluation failed for $flagKey (${response.statusCode}): '
      '${response.body}',
    );
  }

  final decoded = jsonDecode(response.body);
  if (decoded is! Map<String, dynamic>) {
    throw StateError('Evaluation returned invalid JSON for $flagKey.');
  }

  final nested = decoded['result'] ?? decoded['evaluation'] ?? decoded;
  if (nested is Map<String, dynamic>) {
    return nested;
  }

  throw StateError('Evaluation returned an invalid result for $flagKey.');
}

bool _enabled(Map<String, dynamic> json) {
  final value =
      json['value'] ??
      json['enabled'] ??
      json['isEnabled'] ??
      json['is_enabled'] ??
      json['on'];
  return value == true || value?.toString().toLowerCase() == 'true';
}

Map<String, dynamic>? _decodeJwtPayload(String token) {
  final parts = token.split('.');
  if (parts.length < 2) return null;

  try {
    final payload = base64Url.normalize(parts[1]);
    final decoded = utf8.decode(base64Url.decode(payload));
    final json = jsonDecode(decoded);
    return json is Map<String, dynamic> ? json : null;
  } catch (_) {
    return null;
  }
}

class _Token {
  const _Token({
    required this.accessToken,
    required this.tokenType,
    required this.expiresIn,
  });

  final String accessToken;
  final String tokenType;
  final int expiresIn;

  factory _Token.fromJson(Map<String, dynamic> json) {
    return _Token(
      accessToken: (json['access_token'] ?? json['accessToken'] ?? '')
          .toString(),
      tokenType: (json['token_type'] ?? json['tokenType'] ?? 'Bearer')
          .toString(),
      expiresIn:
          int.tryParse(
            (json['expires_in'] ?? json['expiresIn'] ?? 0).toString(),
          ) ??
          0,
    );
  }
}
