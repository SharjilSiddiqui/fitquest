class IntellitoggleTokenResponse {
  const IntellitoggleTokenResponse({
    required this.accessToken,
    required this.expiresAt,
    this.tokenType = 'Bearer',
  });

  final String accessToken;
  final String tokenType;
  final DateTime expiresAt;

  bool get expired =>
      DateTime.now().isAfter(expiresAt.subtract(const Duration(seconds: 30)));

  factory IntellitoggleTokenResponse.fromJson(Map<String, dynamic> json) {
    final expiresIn =
        _intValue(json['expires_in'] ?? json['expiresIn']) ?? 3600;
    return IntellitoggleTokenResponse(
      accessToken: json['access_token']?.toString() ?? '',
      tokenType: json['token_type']?.toString() ?? 'Bearer',
      expiresAt: DateTime.now().add(Duration(seconds: expiresIn)),
    );
  }

  static int? _intValue(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }
}
