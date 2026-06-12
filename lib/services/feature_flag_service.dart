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
    print("========== FLAGS ==========");
    print(flags);
    print(flags.runtimeType);

    for (final f in flags) {
      print("----------------");
      print(f);
      print(f.runtimeType);
    }
    print("===========================");

    _activeFlags
      ..clear()
      ..addAll(flags.map(_activeFlagKey).whereType<String>());
  }

  bool enabled(String key) => _activeFlags.contains(key);

  List<String> activeFlags() => _activeFlags.toList(growable: false)..sort();

  String? _activeFlagKey(dynamic flag) {
    if (flag is! Map) return null;

    final enabled = flag["enabled"] == true || flag["status"] == "active";
    if (!enabled) return null;

    final key = (flag["key"] ?? flag["flag_key"] ?? flag["flagKey"] ?? "")
        .toString();
    return key.isEmpty ? null : key;
  }
}
