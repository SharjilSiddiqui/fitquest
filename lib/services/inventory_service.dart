import 'dartstream_client_service.dart';
import 'package:dartstream_client/dartstream_client.dart';

class InventoryService {
  InventoryService(this.dartStream);

  final DartStreamClientService dartStream;

  Future<List<dynamic>> loadInventory() {
    return dartStream.client.inventoryItems(
      dartStream.requireSession,
      scope: const DartStreamScope(projectId: 'fitquest'),
    );
  }
}
