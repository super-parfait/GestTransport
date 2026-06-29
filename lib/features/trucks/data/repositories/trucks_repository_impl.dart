import '../../../../core/config/app_config.dart';
import '../../domain/repositories/trucks_repository.dart';
import '../datasources/trucks_mock_data_source.dart';
import '../datasources/trucks_remote_data_source.dart';
import '../models/truck_model.dart';

class TrucksRepositoryImpl implements TrucksRepository {
  final AppConfig _config;
  final TrucksRemoteDataSource _remoteDataSource;
  final TrucksMockDataSource _mockDataSource;

  const TrucksRepositoryImpl({
    required AppConfig config,
    required TrucksRemoteDataSource remoteDataSource,
    required TrucksMockDataSource mockDataSource,
  })  : _config = config,
        _remoteDataSource = remoteDataSource,
        _mockDataSource = mockDataSource;

  @override
  Future<List<TruckModel>> fetchTrucks() async {
    if (_config.useMockApi) {
      return _mockDataSource.fetchTrucks();
    }

    try {
      return await _remoteDataSource.fetchTrucks();
    } catch (_) {
      if (_config.fallbackToMockOnError) {
        return _mockDataSource.fetchTrucks();
      }
      rethrow;
    }
  }
}
