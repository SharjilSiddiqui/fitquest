import 'package:flutter/foundation.dart';

import '../models/feature_flag.dart';
import '../services/intellitoggle_service.dart';

class IntellitoggleProvider extends ChangeNotifier {
  IntellitoggleProvider({IntellitoggleService? service})
    : _service = service ?? IntellitoggleService();

  final IntellitoggleService _service;

  bool loading = false;
  bool connected = false;
  String? errorMessage;
  DateTime? lastRefresh;
  List<IntellitoggleFeatureFlag> flags = const [];

  bool enabled(String key) {
    return flags.any((flag) => flag.key == key && flag.enabled);
  }

  Map<String, bool> activeMap() {
    return {for (final flag in flags) flag.key: flag.enabled};
  }

  String get environment {
    try {
      return _service.connectionInfo()['environment'] ?? 'unknown';
    } catch (_) {
      return 'unknown';
    }
  }

  String get projectId {
    try {
      return _service.connectionInfo()['projectId'] ?? 'unknown';
    } catch (_) {
      return 'unknown';
    }
  }

  Future<void> load({bool forceRefreshToken = false}) async {
    if (loading) {
      return;
    }

    loading = true;
    errorMessage = null;
    notifyListeners();

    try {
      flags = await _service.evaluateAll(forceRefreshToken: forceRefreshToken);
      connected = true;
      lastRefresh = DateTime.now();
    } catch (e) {
      connected = false;
      errorMessage = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
