import 'evaluation_result.dart';

class IntellitoggleFeatureFlag {
  const IntellitoggleFeatureFlag({
    required this.key,
    required this.name,
    required this.enabled,
    required this.evaluated,
    required this.lastUpdated,
    this.description,
  });

  final String key;
  final String name;
  final bool enabled;
  final bool evaluated;
  final DateTime lastUpdated;
  final String? description;

  factory IntellitoggleFeatureFlag.fromEvaluation({
    required String key,
    required String name,
    required IntellitoggleEvaluationResult result,
    DateTime? lastUpdated,
  }) {
    return IntellitoggleFeatureFlag(
      key: key,
      name: name,
      enabled: result.enabled,
      evaluated: result.evaluated,
      lastUpdated: lastUpdated ?? DateTime.now(),
    );
  }
}
