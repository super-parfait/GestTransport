import '../models/driver_model.dart';
import '../models/driver_upsert_request.dart';

class DriversMockDataSource {
  static final List<Map<String, dynamic>> _drivers = [
    {
      'id': 'mock-driver-1',
      'name': 'KONAN Yao',
      'phone': '0711223344',
      'isActive': true,
      'notes': 'Chauffeur principal',
      'createdAt': '2026-07-01T08:00:00.000Z',
      'updatedAt': '2026-07-01T08:00:00.000Z',
    },
    {
      'id': 'mock-driver-2',
      'name': 'OUATTARA Issa',
      'phone': '0522334455',
      'isActive': true,
      'notes': '',
      'createdAt': '2026-07-01T08:00:00.000Z',
      'updatedAt': '2026-07-01T08:00:00.000Z',
    },
    {
      'id': 'mock-driver-3',
      'name': 'BAMBA Mamadou',
      'phone': '0133445566',
      'isActive': false,
      'notes': 'En pause',
      'createdAt': '2026-07-01T08:00:00.000Z',
      'updatedAt': '2026-07-01T08:00:00.000Z',
    },
  ];

  const DriversMockDataSource();

  static Map<String, dynamic>? findDriverMap(String driverId) {
    for (final driver in _drivers) {
      if (driver['id']?.toString() == driverId) {
        return Map<String, dynamic>.from(driver);
      }
    }

    return null;
  }

  Future<List<DriverModel>> fetchDrivers() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return _drivers.map(DriverModel.fromJson).toList();
  }

  Future<DriverModel> createDriver(DriverUpsertRequest request) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));

    final now = DateTime.now().toUtc().toIso8601String();
    final created = {
      'id': 'mock-driver-${DateTime.now().microsecondsSinceEpoch}',
      ...request.toJson(),
      'createdAt': now,
      'updatedAt': now,
    };

    _drivers.insert(0, created);
    return DriverModel.fromJson(created);
  }

  Future<DriverModel> updateDriver(
    String driverId,
    DriverUpsertRequest request,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));

    final index = _drivers.indexWhere(
      (driver) => driver['id']?.toString() == driverId,
    );
    if (index < 0) {
      throw StateError('Chauffeur introuvable');
    }

    final updated = {
      ..._drivers[index],
      ...request.toJson(),
      'updatedAt': DateTime.now().toUtc().toIso8601String(),
    };
    _drivers[index] = updated;
    return DriverModel.fromJson(updated);
  }

  Future<void> deleteDriver(String driverId) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    _drivers.removeWhere((driver) => driver['id']?.toString() == driverId);
  }
}
