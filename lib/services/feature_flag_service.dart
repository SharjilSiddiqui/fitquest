import '../api/dartstream.dart';

class FeatureFlagService {
  FeatureFlagService(this.api);

  final DartstreamApi api;

  List<dynamic> flags = [];

  Future<void> load({required String tenantId}) async {
    final response = await api.featureFlags(tenantId: tenantId);

    print("============== FEATURE FLAGS ==============");
    print(response);
    print(response.runtimeType);

    if (response["flags"] is List) {
      flags = response["flags"];
    } else if (response["data"] is List) {
      flags = response["data"];
    } else {
      flags = [];
    }

    print(flags);
    print(flags.runtimeType);

    if (flags.isNotEmpty) {
      print(flags.first);
      print(flags.first.runtimeType);
    }

    print("===========================================");
  }

  bool enabled(String key) {
    for (final flag in flags) {
      if (flag is! Map) continue;

      final isEnabled = flag["enabled"] == true || flag["status"] == "active";

      if (!isEnabled) continue;

      final flagKey = (flag["key"] ?? flag["flag_key"] ?? flag["flagKey"] ?? "")
          .toString();

      if (flagKey == key) {
        return true;
      }
    }

    return false;
  }

  List<String> activeFlags() {
    final active = <String>[];

    for (final flag in flags) {
      if (flag is! Map) continue;

      final isEnabled = flag["enabled"] == true || flag["status"] == "active";

      if (!isEnabled) continue;

      final flagKey = (flag["key"] ?? flag["flag_key"] ?? flag["flagKey"] ?? "")
          .toString();

      if (flagKey.isNotEmpty) {
        active.add(flagKey);
      }
    }

    return active;
  }
}
