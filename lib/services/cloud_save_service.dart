import 'package:flutter/foundation.dart';

import '../api/dartstream.dart';
import '../models/player_data.dart';

class CloudSaveService {
  static const String slotKey = 'fitquest';

  final DartstreamApi api;

  CloudSaveService(this.api);

  Future<PlayerData?> loadPlayer({
    required String userId,
    required String tenantId,
  }) async {
    debugPrint(
      'CloudSaveService.loadPlayer userId=$userId tenantId=$tenantId slotKey=$slotKey',
    );
    final snapshot = await api.loadSnapshot(
      userId: userId,
      tenantId: tenantId,
      slotKey: slotKey,
    );

    if (snapshot == null) {
      debugPrint('CloudSaveService.loadPlayer snapshot=null');
      return null;
    }

    debugPrint('CloudSaveService.loadPlayer snapshot=$snapshot');

final snapshotData = snapshot['snapshot'];

if (snapshotData is! Map<String, dynamic>) {
  debugPrint('CloudSaveService.loadPlayer snapshotData invalid');
  return null;
}

final payload = snapshotData['payload'];

debugPrint(
  'CloudSaveService.loadPlayer payloadType=${payload.runtimeType} payload=$payload',
);

    if (payload is Map<String, dynamic>) {
      final player = PlayerData.fromJson(payload);
      debugPrint(
        'CloudSaveService.loadPlayer parsedPlayer='
        'heroClass=${player.heroClass} level=${player.level} xp=${player.xp}',
      );
      return player;
    }

    debugPrint('CloudSaveService.loadPlayer returning null (payload not map)');
    return null;
  }

  Future<void> savePlayer({
    required String userId,
    required String tenantId,
    required PlayerData player,
  }) async {
    debugPrint(
      'CloudSaveService.savePlayer userId=$userId tenantId=$tenantId slotKey=$slotKey',
    );
    final resp = await api.saveSnapshot(
      userId: userId,
      tenantId: tenantId,
      slotKey: slotKey,
      payload: player.toJson(),
    );
    debugPrint('CloudSaveService.savePlayer response=$resp');
  }
}
