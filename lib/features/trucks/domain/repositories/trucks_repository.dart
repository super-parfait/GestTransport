import '../../data/models/truck_model.dart';

abstract class TrucksRepository {
  Future<List<TruckModel>> fetchTrucks();
}
