import '../models/evaluation_result.dart';
import '../models/feature_flag.dart';
import 'intellitoggle_config.dart';

class IntellitoggleFlagDefinition {
  const IntellitoggleFlagDefinition(this.key, this.name);

  final String key;
  final String name;
}

class IntellitoggleService {
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

  Future<List<IntellitoggleFeatureFlag>> evaluateAll({
    bool forceRefreshToken = false,
  }) async {
    final now = DateTime.now();
    return [
      for (final definition in flagDefinitions)
        IntellitoggleFeatureFlag.fromEvaluation(
          key: definition.key,
          name: definition.name,
          result: IntellitoggleEvaluationResult(
            key: definition.key,
            enabled: false,
            evaluated: true,
            raw: const {'source': 'browser-demo-snapshot'},
          ),
          lastUpdated: now,
          description: 'Live evaluation is available in the CLI deep dive.',
        ),
    ];
  }

  Future<IntellitoggleEvaluationResult> evaluateFlag(
    String flagKey, {
    bool forceRefreshToken = false,
  }) async {
    return IntellitoggleEvaluationResult(
      key: flagKey,
      enabled: false,
      evaluated: true,
      raw: const {'source': 'browser-demo-snapshot'},
    );
  }

  Map<String, String> connectionInfo() {
    return {
      'environment': IntellitoggleConfig.environment,
      'projectId': IntellitoggleConfig.projectId,
    };
  }
}
