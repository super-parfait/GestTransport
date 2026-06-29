import '../../../../core/network/api_service.dart';
import '../models/truck_model.dart';

class TrucksMockDataSource {
  const TrucksMockDataSource();

  Future<List<TruckModel>> fetchTrucks() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return AppData.trucks.map(TruckModel.fromJson).toList();
  }
}
