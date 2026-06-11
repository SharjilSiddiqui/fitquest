import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get firebaseApiKey => dotenv.env['FIREBASE_API_KEY'] ?? '';
}
