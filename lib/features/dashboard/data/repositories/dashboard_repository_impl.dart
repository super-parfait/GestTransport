import '../../../../core/config/app_config.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_mock_data_source.dart';
import '../datasources/dashboard_remote_data_source.dart';
import '../models/dashboard_overview.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final AppConfig _config;
  final DashboardRemoteDataSource _remoteDataSource;
  final DashboardMockDataSource _mockDataSource;

  const DashboardRepositoryImpl({
    required AppConfig config,
    required DashboardRemoteDataSource remoteDataSource,
    required DashboardMockDataSource mockDataSource,
  })  : _config = config,
        _remoteDataSource = remoteDataSource,
        _mockDataSource = mockDataSource;

  @override
  Future<DashboardOverview> fetchOverview() async {
    if (_config.useMockApi) {
      return _mockDataSource.fetchOverview();
    }

    try {
      return await _remoteDataSource.fetchOverview();
    } catch (_) {
      if (_config.fallbackToMockOnError) {
        return _mockDataSource.fetchOverview();
      }
      rethrow;
    }
  }
}
