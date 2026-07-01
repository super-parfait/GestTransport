import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/create_loading_request.dart';
import '../models/loading_record.dart';

class LoadingsRemoteDataSource {
  final ApiClient _apiClient;

  const LoadingsRemoteDataSource(this._apiClient);

  Future<List<LoadingRecord>> fetchLoadings() {
    return _apiClient.get(
      ApiEndpoints.loadings,
      queryParameters: const {
        'limit': 100,
      },
      decoder: (data) {
        final list = _extractList(data);
        return list.map(LoadingRecord.fromJson).toList();
      },
    );
  }

  Future<String> uploadProof(String filePath) {
    return _apiClient.uploadFile(
      ApiEndpoints.fileUpload,
      filePath: filePath,
      decoder: (data) {
        if (data is Map<String, dynamic>) {
          return (data['url'] ?? data['location'] ?? '').toString();
        }
        return '';
      },
    );
  }

  Future<LoadingRecord> createLoading(CreateLoadingRequest request) {
    return _apiClient.post(
      ApiEndpoints.loadings,
      body: request.toJson(),
      decoder: (data) => LoadingRecord.fromJson(data as Map<String, dynamic>),
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
