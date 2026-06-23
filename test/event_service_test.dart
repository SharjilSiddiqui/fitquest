import 'dart:convert';

import 'package:dartstream_client/dartstream_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('trackEvent sends expected payload', () async {
    final client = DartStreamClient(
      config: DartStreamConfig.dev(),
      httpClient: MockClient((request) async {
        expect(request.method, 'POST');

        expect(request.url.path, '/api/v1/reactive/events/log');

        final body = jsonDecode(request.body);

        expect(body['event_type'], 'quest_completed');

        expect(body['payload']['xp'], 50);

        return http.Response(jsonEncode({'success': true}), 200);
      }),
    );

    const session = DartStreamSession(
      idToken: 'token',
      userId: 'user',
      tenantId: 'tenant',
      raw: {},
    );

    await client.reactive.trackEvent(
      session,
      eventType: 'quest_completed',
      payload: {'xp': 50},
    );
  });
}
