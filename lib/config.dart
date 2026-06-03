import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get firebaseApiKey => dotenv.env['FIREBASE_API_KEY'] ?? '';

  static String get authHost => dotenv.env['AUTH_HOST'] ?? '';

  static String get platformHost => dotenv.env['PLATFORM_HOST'] ?? '';

  static String get experienceHost => dotenv.env['EXPERIENCE_HOST'] ?? '';

  static String get reactiveHost => dotenv.env['REACTIVE_HOST'] ?? '';
}
