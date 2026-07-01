import '../../../../core/network/api_service.dart';
import '../models/client_model.dart';
import '../models/client_upsert_request.dart';

class ClientsMockDataSource {
  static final List<Map<String, dynamic>> _clients = AppData.clients
      .map((client) => Map<String, dynamic>.from(client))
      .toList(growable: true);

  const ClientsMockDataSource();

  Future<List<ClientModel>> fetchClients() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return _clients.map(ClientModel.fromJson).toList();
  }

  Future<ClientModel> createClient(ClientUpsertRequest request) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));

    final now = DateTime.now().toUtc().toIso8601String();
    final created = {
      'id': 'mock-client-${DateTime.now().microsecondsSinceEpoch}',
      ...request.toJson(),
      'openingBalance': 0,
      'currentBalance': 0,
      'loadings': <Map<String, dynamic>>[],
      'payments': <Map<String, dynamic>>[],
      'createdAt': now,
      'updatedAt': now,
    };

    _clients.insert(0, created);
    return ClientModel.fromJson(created);
  }

  Future<ClientModel> updateClient(
    String clientId,
    ClientUpsertRequest request,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));

    final index = _clients.indexWhere(
      (client) => client['id']?.toString() == clientId,
    );
    if (index < 0) {
      throw StateError('Client introuvable');
    }

    final updated = {
      ..._clients[index],
      ...request.toJson(),
      'updatedAt': DateTime.now().toUtc().toIso8601String(),
    };
    _clients[index] = updated;
    return ClientModel.fromJson(updated);
  }

  Future<void> deleteClient(String clientId) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    _clients.removeWhere((client) => client['id']?.toString() == clientId);
  }
}
