import '../../data/models/driver_model.dart';
import '../../data/models/driver_upsert_request.dart';

abstract class DriversRepository {
  Future<List<DriverModel>> fetchDrivers();

  Future<DriverModel> createDriver(DriverUpsertRequest request);

  Future<DriverModel> updateDriver(
      String driverId, DriverUpsertRequest request);

  Future<void> deleteDriver(String driverId);
}
