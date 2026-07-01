import '../../../../core/config/app_config.dart';
import '../../domain/repositories/sites_repository.dart';
import '../datasources/sites_mock_data_source.dart';
import '../datasources/sites_remote_data_source.dart';
import '../models/site_record.dart';
import '../models/site_upsert_request.dart';

class SitesRepositoryImpl implements SitesRepository {
  final AppConfig _config;
  final SitesRemoteDataSource _remoteDataSource;
  final SitesMockDataSource _mockDataSource;

  const SitesRepositoryImpl({
    required AppConfig config,
    required SitesRemoteDataSource remoteDataSource,
    required SitesMockDataSource mockDataSource,
  })  : _config = config,
        _remoteDataSource = remoteDataSource,
        _mockDataSource = mockDataSource;

  @override
  Future<List<SiteRecord>> fetchSites() async {
    if (_config.useMockApi) {
      return _mockDataSource.fetchSites();
    }

    try {
      return await _remoteDataSource.fetchSites();
    } catch (_) {
      if (_config.fallbackToMockOnError) {
        return _mockDataSource.fetchSites();
      }
      rethrow;
    }
  }

  @override
  Future<SiteRecord> createSite(SiteUpsertRequest request) async {
    if (_config.useMockApi) {
      return _mockDataSource.createSite(request);
    }

    try {
      return await _remoteDataSource.createSite(request);
    } catch (_) {
      if (_config.fallbackToMockOnError) {
        return _mockDataSource.createSite(request);
      }
      rethrow;
    }
  }

  @override
  Future<SiteRecord> updateSite(
    String siteId,
    SiteUpsertRequest request,
  ) async {
    if (_config.useMockApi) {
      return _mockDataSource.updateSite(siteId, request);
    }

    try {
      return await _remoteDataSource.updateSite(siteId, request);
    } catch (_) {
      if (_config.fallbackToMockOnError) {
        return _mockDataSource.updateSite(siteId, request);
      }
      rethrow;
    }
  }

  @override
  Future<void> deleteSite(String siteId) async {
    if (_config.useMockApi) {
      return _mockDataSource.deleteSite(siteId);
    }

    try {
      await _remoteDataSource.deleteSite(siteId);
    } catch (_) {
      if (_config.fallbackToMockOnError) {
        return _mockDataSource.deleteSite(siteId);
      }
      rethrow;
    }
  }
}
