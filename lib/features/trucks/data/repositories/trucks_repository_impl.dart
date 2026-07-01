import '../../../../core/config/app_config.dart';
import '../../domain/repositories/trucks_repository.dart';
import '../datasources/trucks_mock_data_source.dart';
import '../datasources/trucks_remote_data_source.dart';
import '../models/truck_model.dart';
import '../models/truck_upsert_request.dart';

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

  @override
  Future<TruckModel> createTruck(TruckUpsertRequest request) async {
    if (_config.useMockApi) {
      return _mockDataSource.createTruck(request);
    }

    try {
      return await _remoteDataSource.createTruck(request);
    } catch (_) {
      if (_config.fallbackToMockOnError) {
        return _mockDataSource.createTruck(request);
      }
      rethrow;
    }
  }

  @override
  Future<TruckModel> updateTruck(
    String truckId,
    TruckUpsertRequest request,
  ) async {
    if (_config.useMockApi) {
      return _mockDataSource.updateTruck(truckId, request);
    }

    try {
      return await _remoteDataSource.updateTruck(truckId, request);
    } catch (_) {
      if (_config.fallbackToMockOnError) {
        return _mockDataSource.updateTruck(truckId, request);
      }
      rethrow;
    }
  }

  @override
  Future<void> deleteTruck(String truckId) async {
    if (_config.useMockApi) {
      return _mockDataSource.deleteTruck(truckId);
    }

    try {
      await _remoteDataSource.deleteTruck(truckId);
    } catch (_) {
      if (_config.fallbackToMockOnError) {
        return _mockDataSource.deleteTruck(truckId);
      }
      rethrow;
    }
  }
}
