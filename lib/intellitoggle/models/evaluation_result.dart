class IntellitoggleEvaluationResult {
  const IntellitoggleEvaluationResult({
    required this.key,
    required this.enabled,
    required this.evaluated,
    this.variant,
    this.raw = const {},
  });

  final String key;
  final bool enabled;
  final bool evaluated;
  final String? variant;
  final Map<String, dynamic> raw;

  factory IntellitoggleEvaluationResult.fromJson(
    String fallbackKey,
    Map<String, dynamic> json,
  ) {
    final value =
        json['value'] ??
        json['enabled'] ??
        json['isEnabled'] ??
        json['is_enabled'] ??
        json['on'];

    return IntellitoggleEvaluationResult(
      key: (json['key'] ?? json['flagKey'] ?? json['flag_key'] ?? fallbackKey)
          .toString(),
      enabled: value == true || value?.toString().toLowerCase() == 'true',
      evaluated:
          json['evaluated'] != false && json['error'] == null && value != null,
      variant: json['variant']?.toString(),
      raw: json,
    );
  }
}
