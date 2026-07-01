import '../../../../core/config/app_config.dart';
import '../../domain/repositories/loadings_repository.dart';
import '../datasources/loadings_mock_data_source.dart';
import '../datasources/loadings_remote_data_source.dart';
import '../models/create_loading_request.dart';
import '../models/loading_record.dart';

class LoadingsRepositoryImpl implements LoadingsRepository {
  final AppConfig _config;
  final LoadingsRemoteDataSource _remoteDataSource;
  final LoadingsMockDataSource _mockDataSource;

  const LoadingsRepositoryImpl({
    required AppConfig config,
    required LoadingsRemoteDataSource remoteDataSource,
    required LoadingsMockDataSource mockDataSource,
  })  : _config = config,
        _remoteDataSource = remoteDataSource,
        _mockDataSource = mockDataSource;

  @override
  Future<List<LoadingRecord>> fetchLoadings() async {
    if (_config.useMockApi) {
      return _mockDataSource.fetchLoadings();
    }

    try {
      return await _remoteDataSource.fetchLoadings();
    } catch (_) {
      if (_config.fallbackToMockOnError) {
        return _mockDataSource.fetchLoadings();
      }
      rethrow;
    }
  }

  @override
  Future<String> uploadProof(String filePath) async {
    if (_config.useMockApi) {
      return _mockDataSource.uploadProof(filePath);
    }

    try {
      return await _remoteDataSource.uploadProof(filePath);
    } catch (_) {
      if (_config.fallbackToMockOnError) {
        return _mockDataSource.uploadProof(filePath);
      }
      rethrow;
    }
  }

  @override
  Future<LoadingRecord> createLoading(CreateLoadingRequest request) async {
    if (_config.useMockApi) {
      return _mockDataSource.createLoading(request);
    }

    try {
      return await _remoteDataSource.createLoading(request);
    } catch (_) {
      if (_config.fallbackToMockOnError) {
        return _mockDataSource.createLoading(request);
      }
      rethrow;
    }
  }
}
