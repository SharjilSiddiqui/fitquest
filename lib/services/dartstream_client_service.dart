import 'package:dartstream_client/dartstream_client.dart';

import '../config.dart';

class DartStreamClientService {
  DartStreamClientService({DartStreamClient? client})
    : _baseClient =
          client ??
          DartStreamClient(
            config: DartStreamConfig.dev(
              firebaseApiKey: AppConfig.firebaseApiKey,
            ),
          );

  static final DartStreamClientService instance = DartStreamClientService();

  final DartStreamClient _baseClient;

  DartStreamConnection? _connection;

  DartStreamClient get client => _connection?.client ?? _baseClient;

  DartStreamSession? get session => _connection?.session;

  DartStreamSession get requireSession {
    final activeSession = session;
    if (activeSession == null) {
      throw StateError('No active DartStream session.');
    }
    return activeSession;
  }

  Future<DartStreamSession> signIn({
    required String email,
    required String password,
  }) async {
    _connection = await DartStreamClient.signIn(
      config: _baseClient.config,
      email: email,
      password: password,
    );
    return _connection!.session;
  }

  Future<DartStreamSession> signUp({
    required String email,
    required String password,
  }) async {
    _connection = await DartStreamClient.signUp(
      config: _baseClient.config,
      email: email,
      password: password,
    );
    return _connection!.session;
  }

  void clearSession() {
    _connection = null;
  }
}
