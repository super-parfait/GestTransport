import '../../../../core/config/app_config.dart';
import '../../domain/repositories/drivers_repository.dart';
import '../datasources/drivers_mock_data_source.dart';
import '../datasources/drivers_remote_data_source.dart';
import '../models/driver_model.dart';
import '../models/driver_upsert_request.dart';

class DriversRepositoryImpl implements DriversRepository {
  final AppConfig _config;
  final DriversRemoteDataSource _remoteDataSource;
  final DriversMockDataSource _mockDataSource;

  const DriversRepositoryImpl({
    required AppConfig config,
    required DriversRemoteDataSource remoteDataSource,
    required DriversMockDataSource mockDataSource,
  })  : _config = config,
        _remoteDataSource = remoteDataSource,
        _mockDataSource = mockDataSource;

  @override
  Future<List<DriverModel>> fetchDrivers() async {
    if (_config.useMockApi) {
      return _mockDataSource.fetchDrivers();
    }

    try {
      return await _remoteDataSource.fetchDrivers();
    } catch (_) {
      if (_config.fallbackToMockOnError) {
        return _mockDataSource.fetchDrivers();
      }
      rethrow;
    }
  }

  @override
  Future<DriverModel> createDriver(DriverUpsertRequest request) async {
    if (_config.useMockApi) {
      return _mockDataSource.createDriver(request);
    }

    try {
      return await _remoteDataSource.createDriver(request);
    } catch (_) {
      if (_config.fallbackToMockOnError) {
        return _mockDataSource.createDriver(request);
      }
      rethrow;
    }
  }

  @override
  Future<DriverModel> updateDriver(
    String driverId,
    DriverUpsertRequest request,
  ) async {
    if (_config.useMockApi) {
      return _mockDataSource.updateDriver(driverId, request);
    }

    try {
      return await _remoteDataSource.updateDriver(driverId, request);
    } catch (_) {
      if (_config.fallbackToMockOnError) {
        return _mockDataSource.updateDriver(driverId, request);
      }
      rethrow;
    }
  }

  @override
  Future<void> deleteDriver(String driverId) async {
    if (_config.useMockApi) {
      return _mockDataSource.deleteDriver(driverId);
    }

    try {
      await _remoteDataSource.deleteDriver(driverId);
    } catch (_) {
      if (_config.fallbackToMockOnError) {
        return _mockDataSource.deleteDriver(driverId);
      }
      rethrow;
    }
  }
}
