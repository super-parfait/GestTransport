import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/site_record.dart';
import '../models/site_upsert_request.dart';

class SitesRemoteDataSource {
  final ApiClient _apiClient;

  const SitesRemoteDataSource(this._apiClient);

  Future<List<SiteRecord>> fetchSites() {
    return _apiClient.get(
      ApiEndpoints.sites,
      queryParameters: const {
        'limit': 100,
      },
      decoder: (data) {
        final list = _extractList(data);
        return list.map(SiteRecord.fromJson).toList();
      },
    );
  }

  Future<SiteRecord> createSite(SiteUpsertRequest request) {
    return _apiClient.post(
      ApiEndpoints.sites,
      body: request.toJson(),
      decoder: (data) => SiteRecord.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<SiteRecord> updateSite(String siteId, SiteUpsertRequest request) {
    return _apiClient.patch(
      '${ApiEndpoints.sites}/$siteId',
      body: request.toJson(),
      decoder: (data) => SiteRecord.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<void> deleteSite(String siteId) async {
    await _apiClient.delete<bool>(
      '${ApiEndpoints.sites}/$siteId',
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
