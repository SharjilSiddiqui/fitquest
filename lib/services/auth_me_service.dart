import 'dartstream_client_service.dart';

class AuthMeService {
  AuthMeService(this.dartStream);

  final DartStreamClientService dartStream;

  Future<Map<String, dynamic>> loadMe() async {
    return await dartStream.client.me(session: dartStream.requireSession);
  }

  Future<Map<String, dynamic>> updateDisplayName(String displayName) async {
    return await dartStream.client.auth.updateUser(
      dartStream.requireSession,
      displayName: displayName,
    );
  }
}
