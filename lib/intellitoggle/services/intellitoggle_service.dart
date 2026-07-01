import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/evaluation_result.dart';
import '../models/feature_flag.dart';
import 'intellitoggle_auth_service.dart';
import 'intellitoggle_config.dart';

class IntellitoggleFlagDefinition {
  const IntellitoggleFlagDefinition(this.key, this.name);

  final String key;
  final String name;
}

class IntellitoggleService {
  IntellitoggleService({
    IntellitoggleAuthService? authService,
    http.Client? httpClient,
  }) : _authService = authService ?? IntellitoggleAuthService(),
       _httpClient = httpClient ?? http.Client();

  static const flagDefinitions = [
    IntellitoggleFlagDefinition('double-xp', 'Double XP'),
    IntellitoggleFlagDefinition('infinite-stamina', 'Infinite Stamina'),
    IntellitoggleFlagDefinition('health-regen', 'Health Regen'),
    IntellitoggleFlagDefinition('low-gravity', 'Low Gravity'),
    IntellitoggleFlagDefinition('enemy-density', 'Enemy Density'),
    IntellitoggleFlagDefinition('rare-loot', 'Rare Loot'),
    IntellitoggleFlagDefinition('night-mode', 'Night Mode'),
    IntellitoggleFlagDefinition('debug-hud', 'Debug HUD'),
  ];

  final IntellitoggleAuthService _authService;
  final http.Client _httpClient;

  Future<List<IntellitoggleFeatureFlag>> evaluateAll({
    bool forceRefreshToken = false,
  }) async {
    // ignore: avoid_print
    print('[Intellitoggle] evaluateAll()');
    // ignore: avoid_print
    print('[Intellitoggle] Evaluating flags...');

    final now = DateTime.now();
    final results = <IntellitoggleFeatureFlag>[];

    for (final definition in flagDefinitions) {
      final result = await evaluateFlag(
        definition.key,
        forceRefreshToken: forceRefreshToken,
      );
      // ignore: avoid_print
      print('[Intellitoggle] ${definition.key} = ${result.enabled}');
      results.add(
        IntellitoggleFeatureFlag.fromEvaluation(
          key: definition.key,
          name: definition.name,
          result: result,
          lastUpdated: now,
        ),
      );
    }

    return results;
  }

  Future<IntellitoggleEvaluationResult> evaluateFlag(
    String flagKey, {
    bool forceRefreshToken = false,
  }) async {
    // ignore: avoid_print
    print('[Intellitoggle] evaluateFlag($flagKey)');
    // ignore: avoid_print
    print('[Intellitoggle] Evaluating $flagKey');

    final token = await _authService.bearerToken(
      forceRefresh: forceRefreshToken,
    );
    final apiUrl = IntellitoggleConfig.url('INTELLITOGGLE_API_URL');
    final tenantId = IntellitoggleConfig.value('INTELLITOGGLE_TENANT_ID');
    final projectId = IntellitoggleConfig.value('INTELLITOGGLE_PROJECT_ID');
    final environment = IntellitoggleConfig.value('INTELLITOGGLE_ENVIRONMENT');

    final uri = Uri.parse(
      '$apiUrl/api/v1/tenants/$tenantId/projects/$projectId/environments/$environment/flags/$flagKey/evaluate',
    );

    // ignore: avoid_print
    print('[Intellitoggle] Calling evaluate endpoint $uri');

    final response = await _httpClient.post(
      uri,
      headers: {
        'authorization': 'Bearer $token',
        'content-type': 'application/json',
      },
      body: jsonEncode({
        'context': {
          'app': 'fitquest',
          'environment': environment,
          'platform': 'flutter-web',
        },
      }),
    );

    // ignore: avoid_print
    print('[Intellitoggle] Evaluate response $flagKey ${response.statusCode}');

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError(
        'Intellitoggle evaluation failed for $flagKey (${response.statusCode}): ${response.body}',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) {
      final nested = decoded['result'] ?? decoded['evaluation'] ?? decoded;
      if (nested is Map<String, dynamic>) {
        return IntellitoggleEvaluationResult.fromJson(flagKey, nested);
      }
    }

    throw StateError('Invalid Intellitoggle evaluation response for $flagKey.');
  }

  Map<String, String> connectionInfo() {
    return {
      'environment': IntellitoggleConfig.value('INTELLITOGGLE_ENVIRONMENT'),
      'projectId': IntellitoggleConfig.value('INTELLITOGGLE_PROJECT_ID'),
    };
  }
}
