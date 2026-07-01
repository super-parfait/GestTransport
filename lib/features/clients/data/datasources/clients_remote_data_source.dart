import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/client_model.dart';
import '../models/client_upsert_request.dart';

class ClientsRemoteDataSource {
  final ApiClient _apiClient;

  const ClientsRemoteDataSource(this._apiClient);

  Future<List<ClientModel>> fetchClients() {
    return _apiClient.get(
      ApiEndpoints.clients,
      queryParameters: const {
        'limit': 100,
      },
      decoder: (data) {
        final list = _extractList(data);
        return list.map(ClientModel.fromJson).toList();
      },
    );
  }

  Future<ClientModel> createClient(ClientUpsertRequest request) {
    return _apiClient.post(
      ApiEndpoints.clients,
      body: request.toJson(),
      decoder: (data) => ClientModel.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<ClientModel> updateClient(
    String clientId,
    ClientUpsertRequest request,
  ) {
    return _apiClient.patch(
      '${ApiEndpoints.clients}/$clientId',
      body: request.toJson(),
      decoder: (data) => ClientModel.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<void> deleteClient(String clientId) async {
    await _apiClient.delete<bool>(
      '${ApiEndpoints.clients}/$clientId',
      decoder: (_) => true,
    );
  }

  List<Map<String, dynamic>> _extractList(dynamic data) {
    if (data is List) {
      return data
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }

    if (data is Map<String, dynamic> && data['items'] is List) {
      return (data['items'] as List)
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }

    return const [];
  }
}
