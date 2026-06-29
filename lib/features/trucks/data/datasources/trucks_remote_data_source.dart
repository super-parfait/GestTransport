import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/truck_model.dart';

class TrucksRemoteDataSource {
  final ApiClient _apiClient;

  const TrucksRemoteDataSource(this._apiClient);

  Future<List<TruckModel>> fetchTrucks() {
    return _apiClient.get(
      ApiEndpoints.trucks,
      decoder: (data) {
        final list = _extractList(data);
        return list.map(TruckModel.fromJson).toList();
      },
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
