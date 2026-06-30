import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../models/evaluation_result.dart';
import '../models/feature_flag.dart';
import 'intellitoggle_auth_service.dart';

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
    final token = await _authService.bearerToken(
      forceRefresh: forceRefreshToken,
    );
    final apiUrl = _env('INTELLITOGGLE_API_URL');
    final tenantId = _env('INTELLITOGGLE_TENANT_ID');
    final projectId = _env('INTELLITOGGLE_PROJECT_ID');
    final environment = _env('INTELLITOGGLE_ENVIRONMENT');

    final uri = Uri.parse(
      '$apiUrl/api/v1/tenants/$tenantId/projects/$projectId/environments/$environment/flags/$flagKey/evaluate',
    );

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
      'environment': _env('INTELLITOGGLE_ENVIRONMENT'),
      'projectId': _env('INTELLITOGGLE_PROJECT_ID'),
    };
  }

  String _env(String key) {
    final value = dotenv.maybeGet(key)?.trim();
    if (value == null || value.isEmpty || value.startsWith('your_')) {
      throw StateError('Missing Intellitoggle environment value: $key');
    }
    return value.endsWith('/') ? value.substring(0, value.length - 1) : value;
  }
}
