import 'package:flutter_test/flutter_test.dart';

import 'package:sand_gravel_app/features/trucks/data/models/truck_model.dart';
import 'package:sand_gravel_app/features/trucks/data/models/truck_upsert_request.dart';

void main() {
  test('truck upsert request serializes the backend payload correctly', () {
    const request = TruckUpsertRequest(
      registration: ' AA-856-AX ',
      brand: ' Mercedes ',
      model: ' Actros 2653 ',
      status: 'disponible',
      currentKm: 125430,
      driverId: ' 8b4efb5f-1f31-44c1-965f-37d28e0fbd4d ',
      notes: ' Camion principal ',
    );

    expect(request.toJson(), {
      'registration': 'AA-856-AX',
      'brand': 'Mercedes',
      'model': 'Actros 2653',
      'status': 'DISPONIBLE',
      'currentKm': 125430,
      'driverId': '8b4efb5f-1f31-44c1-965f-37d28e0fbd4d',
      'notes': 'Camion principal',
    });
  });

  test('truck model parses backend fields used by the mobile app', () {
    final truck = TruckModel.fromJson({
      'id': 'af9b2b97-0e93-4c7a-993d-d773742b4f02',
      'registration': 'AA-856-AX',
      'brand': 'Mercedes',
      'model': 'Actros 2653',
      'status': 'ACTIF',
      'currentKm': 125430,
      'driverId': 'seed-driver-konan',
      'notes': 'Camion principal',
      'createdAt': '2026-07-01T08:00:00.000Z',
      'updatedAt': '2026-07-01T09:00:00.000Z',
      'driver': {
        'id': 'seed-driver-konan',
        'name': 'KONAN Yao',
        'phone': '0711223344',
      },
    });

    expect(truck.plate, 'AA-856-AX');
    expect(truck.brand, 'Mercedes');
    expect(truck.model, 'Actros 2653');
    expect(truck.status, 'ACTIF');
    expect(truck.km, 125430);
    expect(truck.driver, 'KONAN Yao');
    expect(truck.phone, '0711223344');
    expect(truck.notes, 'Camion principal');
    expect(truck.updatedAt, DateTime.parse('2026-07-01T09:00:00.000Z'));
  });
}
