import '../../data/models/client_model.dart';

abstract class ClientsRepository {
  Future<List<ClientModel>> fetchClients();
}
