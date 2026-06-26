import 'package:dartstream_client/dartstream_client.dart';

import '../models/player_data.dart';
import 'dartstream_client_service.dart';

class CloudSaveService {
  static const String slotKey = 'fitquest';
  static const DartStreamScope scope = DartStreamScope(projectId: 'fitquest');

  final DartStreamClientService dartStream;

  CloudSaveService(this.dartStream);

  Future<CloudPersistenceInfo> loadPersistenceInfo() async {
    final snapshot = await _loadSnapshot();
    return CloudPersistenceInfo.fromSnapshot(snapshot);
  }

  Future<PlayerData?> loadPlayer({
    required String userId,
    required String tenantId,
  }) async {
    final snapshot = await _loadSnapshot();

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

  Future<CloudPersistenceInfo> savePlayer({
    required String userId,
    required String tenantId,
    required PlayerData player,
  }) async {
    final response = await dartStream.client.experience.saveCloudSave(
      dartStream.requireSession,
      scope: scope,
      slotKey: slotKey,
      payload: player.toJson(),
    );

    return CloudPersistenceInfo.fromSnapshot(response);
  }

  Future<Map<String, dynamic>?> _loadSnapshot() {
    return dartStream.client.experience.loadCloudSave(
      dartStream.requireSession,
      scope: scope,
      slotKey: slotKey,
    );
  }
}

class CloudPersistenceInfo {
  const CloudPersistenceInfo({
    required this.connected,
    required this.provider,
    required this.snapshotStatus,
    required this.projectId,
    required this.slotKey,
    this.lastSync,
  });

  final bool connected;
  final String provider;
  final String snapshotStatus;
  final String projectId;
  final String slotKey;
  final DateTime? lastSync;

  factory CloudPersistenceInfo.connected() {
    return CloudPersistenceInfo(
      connected: true,
      provider: 'DartStream Cloud Save',
      snapshotStatus: 'Connected',
      projectId: CloudSaveService.scope.projectId,
      slotKey: CloudSaveService.slotKey,
    );
  }

  factory CloudPersistenceInfo.fromSnapshot(Map<String, dynamic>? response) {
    if (response == null) {
      return CloudPersistenceInfo.connected();
    }

    final snapshot = response['snapshot'];
    final snapshotMap = snapshot is Map<String, dynamic> ? snapshot : response;

    return CloudPersistenceInfo(
      connected: true,
      provider: 'DartStream Cloud Save',
      snapshotStatus: 'Synced',
      projectId: _stringValue(snapshotMap, const [
        'projectId',
        'project_id',
      ], fallback: CloudSaveService.scope.projectId),
      slotKey: _stringValue(snapshotMap, const [
        'slotKey',
        'slot_key',
      ], fallback: CloudSaveService.slotKey),
      lastSync: _dateValue(snapshotMap, const [
        'updatedAt',
        'updated_at',
        'lastSync',
        'last_sync',
        'savedAt',
        'saved_at',
        'createdAt',
        'created_at',
      ]),
    );
  }

  static String _stringValue(
    Map<String, dynamic> source,
    List<String> keys, {
    required String fallback,
  }) {
    for (final key in keys) {
      final value = source[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }
    return fallback;
  }

  static DateTime? _dateValue(Map<String, dynamic> source, List<String> keys) {
    for (final key in keys) {
      final value = source[key];
      if (value is String) {
        return DateTime.tryParse(value)?.toLocal();
      }
    }
    return null;
  }
}
