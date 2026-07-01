import '../../../../core/network/api_service.dart';
import '../../../drivers/data/datasources/drivers_mock_data_source.dart';
import '../models/truck_model.dart';
import '../models/truck_upsert_request.dart';

class TrucksMockDataSource {
  static final List<Map<String, dynamic>> _trucks = AppData.trucks
      .map((truck) => Map<String, dynamic>.from(truck))
      .toList(growable: true);

  const TrucksMockDataSource();

  Future<List<TruckModel>> fetchTrucks() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return _trucks.map(TruckModel.fromJson).toList();
  }

  Future<TruckModel> createTruck(TruckUpsertRequest request) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));

    final now = DateTime.now().toUtc().toIso8601String();
    final driver = _resolveDriverSnapshot(request.driverId);
    final created = {
      'id': 'mock-truck-${DateTime.now().microsecondsSinceEpoch}',
      'registration': request.registration.trim(),
      'brand': request.brand.trim(),
      'model': request.model.trim(),
      'status': request.status.trim().toUpperCase(),
      'currentKm': request.currentKm,
      'notes': request.notes.trim(),
      'driverId': request.driverId,
      'driver': driver['name'] ?? '',
      'phone': driver['phone'] ?? '',
      'alerts': <String>[],
      'loadings': <Map<String, dynamic>>[],
      'expenses': <Map<String, dynamic>>[],
      'maintenances': <Map<String, dynamic>>[],
      'oilChanges': <Map<String, dynamic>>[],
      'revenues': <Map<String, dynamic>>[],
      'createdAt': now,
      'updatedAt': now,
    };

    _trucks.insert(0, created);
    return TruckModel.fromJson(created);
  }

  Future<TruckModel> updateTruck(
    String truckId,
    TruckUpsertRequest request,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));

    final index =
        _trucks.indexWhere((truck) => truck['id']?.toString() == truckId);
    if (index < 0) {
      throw StateError('Camion introuvable');
    }

    final driver = _resolveDriverSnapshot(request.driverId);
    final updated = {
      ..._trucks[index],
      ...request.toJson(),
      'driver': driver['name'] ?? '',
      'phone': driver['phone'] ?? '',
      'updatedAt': DateTime.now().toUtc().toIso8601String(),
    };

    _trucks[index] = updated;
    return TruckModel.fromJson(updated);
  }

  Future<void> deleteTruck(String truckId) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    _trucks.removeWhere((truck) => truck['id']?.toString() == truckId);
  }

  Map<String, String> _resolveDriverSnapshot(String? driverId) {
    final normalized = driverId?.trim() ?? '';
    if (normalized.isEmpty) {
      return const {'name': '', 'phone': ''};
    }

    final driver = DriversMockDataSource.findDriverMap(normalized);
    if (driver == null) {
      return const {'name': '', 'phone': ''};
    }

    return {
      'name': driver['name']?.toString() ?? '',
      'phone': driver['phone']?.toString() ?? '',
    };
  }
}
