import 'package:dartstream_client/dartstream_client.dart';

import '../config.dart';

class DartStreamClientService {
  DartStreamClientService._();

  static final DartStreamClientService instance = DartStreamClientService._();

  final DartStreamClient client = DartStreamClient(
    config: DartStreamConfig.dev(firebaseApiKey: AppConfig.firebaseApiKey),
  );

  DartStreamSession? _session;

  DartStreamSession? get session => _session;

  DartStreamSession get requireSession {
    final activeSession = _session;
    if (activeSession == null) {
      throw StateError('No active DartStream session.');
    }
    return activeSession;
  }

  Future<DartStreamSession> signIn({
    required String email,
    required String password,
  }) async {
    final firebaseSession = await client.auth.signInWithEmailPassword(
      email: email,
      password: password,
    );
    return _onboard(firebaseSession);
  }

  Future<DartStreamSession> signUp({
    required String email,
    required String password,
  }) async {
    final firebaseSession = await client.auth.createEmailPasswordSession(
      email: email,
      password: password,
    );
    return _onboard(firebaseSession);
  }

  Future<DartStreamSession> _onboard(
    DartStreamFirebaseSession firebaseSession,
  ) async {
    _session = await client.auth.onboardFirebaseSession(firebaseSession);
    return _session!;
  }

  void clearSession() {
    _session = null;
  }
}
