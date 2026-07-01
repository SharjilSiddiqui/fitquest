import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/token_response.dart';
import 'intellitoggle_config.dart';

class IntellitoggleAuthService {
  IntellitoggleAuthService({http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;
  IntellitoggleTokenResponse? _cachedToken;

  Future<String> bearerToken({bool forceRefresh = false}) async {
    // ignore: avoid_print
    print('[Intellitoggle] bearerToken()');

    final cachedToken = _cachedToken;
    if (!forceRefresh && cachedToken != null && !cachedToken.expired) {
      // ignore: avoid_print
      print('[Intellitoggle] Using cached OAuth token');
      return cachedToken.accessToken;
    }

    final tokenUrl = IntellitoggleConfig.value('INTELLITOGGLE_TOKEN_URL');
    final clientId = IntellitoggleConfig.value('INTELLITOGGLE_CLIENT_ID');
    final clientSecret = IntellitoggleConfig.value(
      'INTELLITOGGLE_CLIENT_SECRET',
    );

    final basic = base64Encode(utf8.encode('$clientId:$clientSecret'));

    // ignore: avoid_print
    print('[Intellitoggle] Requesting OAuth token...');
    // ignore: avoid_print
    print('[Intellitoggle] Calling OAuth endpoint $tokenUrl');

    final response = await _httpClient.post(
      Uri.parse(tokenUrl),
      headers: {
        'authorization': 'Basic $basic',
        'content-type': 'application/x-www-form-urlencoded',
      },
      body: const {'grant_type': 'client_credentials'},
    );

    // ignore: avoid_print
    print('[Intellitoggle] OAuth response ${response.statusCode}');

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
    print('[Intellitoggle] OAuth success');
    return token.accessToken;
  }
}
