import 'package:flutter/foundation.dart';
import 'package:dartstream_client/dartstream_client.dart';

import '../models/player_data.dart';
import 'dartstream_client_service.dart';

class CloudSaveService {
  static const String slotKey = 'fitquest';
  static const DartStreamScope scope = DartStreamScope(projectId: 'fitquest');

  final DartStreamClientService dartStream;

  CloudSaveService(this.dartStream);

  Future<PlayerData?> loadPlayer({
    required String userId,
    required String tenantId,
  }) async {
    debugPrint(
      'CloudSaveService.loadPlayer userId=$userId tenantId=$tenantId slotKey=$slotKey',
    );
    final snapshot = await dartStream.client.experience.loadCloudSave(
      dartStream.requireSession,
      scope: scope,
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
    final resp = await dartStream.client.experience.saveCloudSave(
      dartStream.requireSession,
      scope: scope,
      slotKey: slotKey,
      payload: player.toJson(),
    );
    debugPrint('CloudSaveService.savePlayer response=$resp');
  }
}
