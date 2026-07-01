import '../../data/models/client_model.dart';
import '../../data/models/client_upsert_request.dart';

abstract class ClientsRepository {
  Future<List<ClientModel>> fetchClients();

  Future<ClientModel> createClient(ClientUpsertRequest request);

  Future<ClientModel> updateClient(
      String clientId, ClientUpsertRequest request);

  Future<void> deleteClient(String clientId);
}
