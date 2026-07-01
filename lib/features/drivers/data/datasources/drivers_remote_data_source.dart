import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/driver_model.dart';
import '../models/driver_upsert_request.dart';

class DriversRemoteDataSource {
  final ApiClient _apiClient;

  const DriversRemoteDataSource(this._apiClient);

  Future<List<DriverModel>> fetchDrivers() {
    return _apiClient.get(
      ApiEndpoints.drivers,
      queryParameters: const {
        'limit': 100,
      },
      decoder: (data) {
        final list = _extractList(data);
        return list.map(DriverModel.fromJson).toList();
      },
    );
  }

  Future<DriverModel> createDriver(DriverUpsertRequest request) {
    return _apiClient.post(
      ApiEndpoints.drivers,
      body: request.toJson(),
      decoder: (data) => DriverModel.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<DriverModel> updateDriver(
    String driverId,
    DriverUpsertRequest request,
  ) {
    return _apiClient.patch(
      '${ApiEndpoints.drivers}/$driverId',
      body: request.toJson(),
      decoder: (data) => DriverModel.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<void> deleteDriver(String driverId) async {
    await _apiClient.delete<bool>(
      '${ApiEndpoints.drivers}/$driverId',
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
