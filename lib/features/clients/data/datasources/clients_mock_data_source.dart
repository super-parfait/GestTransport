import '../../../../core/network/api_service.dart';
import '../models/client_model.dart';

class ClientsMockDataSource {
  const ClientsMockDataSource();

  Future<List<ClientModel>> fetchClients() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return AppData.clients.map(ClientModel.fromJson).toList();
  }
}
