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
    final snapshot = await dartStream.client.experience.loadCloudSave(
      dartStream.requireSession,
      scope: scope,
      slotKey: slotKey,
    );

    if (snapshot == null) {
      return null;
    }

    final snapshotData = snapshot['snapshot'];

    if (snapshotData is! Map<String, dynamic>) {
      return null;
    }

    final payload = snapshotData['payload'];

    if (payload is Map<String, dynamic>) {
      final player = PlayerData.fromJson(payload);
      return player;
    }
    return null;
  }

  Future<void> savePlayer({
    required String userId,
    required String tenantId,
    required PlayerData player,
  }) async {
    await dartStream.client.experience.saveCloudSave(
      dartStream.requireSession,
      scope: scope,
      slotKey: slotKey,
      payload: player.toJson(),
    );
  }
}
