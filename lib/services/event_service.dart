import 'dartstream_client_service.dart';

class EventService {
  EventService(this.dartStream);

  final DartStreamClientService dartStream;

  Future<void> track(String eventType, Map<String, dynamic> payload) async {
    try {
      await dartStream.client.reactive.trackEvent(
        dartStream.requireSession,
        eventType: eventType,
        payload: payload,
      );
    } catch (_) {}
  }
}
