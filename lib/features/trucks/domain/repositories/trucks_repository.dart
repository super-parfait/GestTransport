import '../../data/models/truck_model.dart';
import '../../data/models/truck_upsert_request.dart';

abstract class TrucksRepository {
  Future<List<TruckModel>> fetchTrucks();

  Future<TruckModel> createTruck(TruckUpsertRequest request);

  Future<TruckModel> updateTruck(String truckId, TruckUpsertRequest request);

  Future<void> deleteTruck(String truckId);
}
