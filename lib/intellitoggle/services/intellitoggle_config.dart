import 'package:flutter_dotenv/flutter_dotenv.dart';

class IntellitoggleConfig {
  static String value(String key) {
    // ignore: avoid_print
    print('[Intellitoggle] Reading $key');

    final dotenvValue = _dotenvValue(key);
    final dartDefineValue = _dartDefineValue(key);
    final value = (dotenvValue == null || dotenvValue.isEmpty)
        ? dartDefineValue
        : dotenvValue;

    if (value == null || value.trim().isEmpty || value.startsWith('your_')) {
      throw StateError('Missing Intellitoggle environment value: $key');
    }

    return value.trim();
  }

  static String url(String key) {
    final value = IntellitoggleConfig.value(key);
    return value.endsWith('/') ? value.substring(0, value.length - 1) : value;
  }

  static String? _dotenvValue(String key) {
    try {
      return dotenv.maybeGet(key)?.trim();
    } catch (e) {
      // ignore: avoid_print
      print('[Intellitoggle] dotenv lookup failed for $key: $e');
      return null;
    }
  }

  static String? _dartDefineValue(String key) {
    return switch (key) {
      'INTELLITOGGLE_TOKEN_URL' => const String.fromEnvironment(
        'INTELLITOGGLE_TOKEN_URL',
      ),
      'INTELLITOGGLE_API_URL' => const String.fromEnvironment(
        'INTELLITOGGLE_API_URL',
      ),
      'INTELLITOGGLE_CLIENT_ID' => const String.fromEnvironment(
        'INTELLITOGGLE_CLIENT_ID',
      ),
      'INTELLITOGGLE_CLIENT_SECRET' => const String.fromEnvironment(
        'INTELLITOGGLE_CLIENT_SECRET',
      ),
      'INTELLITOGGLE_TENANT_ID' => const String.fromEnvironment(
        'INTELLITOGGLE_TENANT_ID',
      ),
      'INTELLITOGGLE_PROJECT_ID' => const String.fromEnvironment(
        'INTELLITOGGLE_PROJECT_ID',
      ),
      'INTELLITOGGLE_ENVIRONMENT' => const String.fromEnvironment(
        'INTELLITOGGLE_ENVIRONMENT',
      ),
      _ => null,
    };
  }
}
