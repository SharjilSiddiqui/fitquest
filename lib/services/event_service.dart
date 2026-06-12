import 'dartstream_client_service.dart';
import 'package:flutter/foundation.dart';

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

      debugPrint("EVENT SENT: $eventType");
    } catch (e) {
      debugPrint("EVENT FAILED");
      debugPrint(e.toString());
    }
  }
}
