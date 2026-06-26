import 'dartstream_client_service.dart';

class FeatureFlagService {
  FeatureFlagService(this.dartStream);

  final DartStreamClientService dartStream;

  final Set<String> _activeFlags = <String>{};

  List<String> get flags => activeFlags();

  Future<void> load({String? tenantId}) async {
    final flags = await dartStream.client.platform.listFeatureFlags(
      dartStream.requireSession,
    );

    _activeFlags
      ..clear()
      ..addAll(flags.map(_activeFlagKey).whereType<String>());
  }

  bool enabled(String key) => _activeFlags.contains(key);

  List<String> activeFlags() => _activeFlags.toList(growable: false)..sort();

  String? _activeFlagKey(dynamic flag) {
    if (flag is! Map) return null;

    final status = flag["status"]?.toString().toLowerCase();
    final enabled =
        flag["enabled"] == true ||
        flag["isEnabled"] == true ||
        flag["is_enabled"] == true ||
        status == "active" ||
        status == "enabled";
    if (!enabled) return null;

    final key =
        (flag["key"] ??
                flag["flag_key"] ??
                flag["flagKey"] ??
                flag["name"] ??
                "")
            .toString();
    return key.isEmpty ? null : key;
  }
}
