import 'package:dartstream_client/dartstream_client.dart';

class DartstreamClientService {
  DartstreamClientService._();

  static final DartstreamClient client = DartStreamClient(
    config: DartStreamConfig.dev(
      firebaseApiKey: const String.fromEnvironment(
        'FIREBASE_API_KEY',
        defaultValue: '',
      ),
    ),
  );
}
