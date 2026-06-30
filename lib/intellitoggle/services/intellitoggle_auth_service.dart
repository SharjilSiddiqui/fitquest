import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../models/token_response.dart';

class IntellitoggleAuthService {
  IntellitoggleAuthService({http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;
  IntellitoggleTokenResponse? _cachedToken;

  Future<String> bearerToken({bool forceRefresh = false}) async {
    final cachedToken = _cachedToken;
    if (!forceRefresh && cachedToken != null && !cachedToken.expired) {
      return cachedToken.accessToken;
    }

    final tokenUrl = _env('INTELLITOGGLE_TOKEN_URL');
    final clientId = _env('INTELLITOGGLE_CLIENT_ID');
    final clientSecret = _env('INTELLITOGGLE_CLIENT_SECRET');

    final basic = base64Encode(utf8.encode('$clientId:$clientSecret'));

    final response = await _httpClient.post(
      Uri.parse(tokenUrl),
      headers: {
        'authorization': 'Basic $basic',
        'content-type': 'application/x-www-form-urlencoded',
      },
      body: const {'grant_type': 'client_credentials'},
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError(
        'Intellitoggle OAuth failed (${response.statusCode}): ${response.body}',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw StateError('Intellitoggle OAuth returned an invalid response.');
    }

    final token = IntellitoggleTokenResponse.fromJson(decoded);
    if (token.accessToken.isEmpty) {
      throw StateError('Intellitoggle OAuth did not return an access token.');
    }

    _cachedToken = token;
    // ignore: avoid_print
    print('[Intellitoggle] OAuth token acquired');
    return token.accessToken;
  }

  String _env(String key) {
    final value = dotenv.maybeGet(key)?.trim();
    if (value == null || value.isEmpty || value.startsWith('your_')) {
      throw StateError('Missing Intellitoggle environment value: $key');
    }
    return value;
  }
}
