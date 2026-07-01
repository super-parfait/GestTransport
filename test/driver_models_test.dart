import 'package:flutter_test/flutter_test.dart';

import 'package:sand_gravel_app/features/drivers/data/models/driver_model.dart';
import 'package:sand_gravel_app/features/drivers/data/models/driver_upsert_request.dart';

void main() {
  test('driver upsert request serializes nullable fields correctly', () {
    const request = DriverUpsertRequest(
      name: '  KONAN Yao  ',
      phone: ' 0711223344 ',
      isActive: true,
      notes: ' Chauffeur principal ',
    );

    expect(request.toJson(), {
      'name': 'KONAN Yao',
      'phone': '0711223344',
      'isActive': true,
      'notes': 'Chauffeur principal',
    });
  });

  test('driver model parses backend payload', () {
    final driver = DriverModel.fromJson({
      'id': '0a3e5f32-402d-4b60-ade0-8961d3a3f6ba',
      'name': 'KONAN Yao',
      'phone': '0711223344',
      'isActive': true,
      'notes': 'Chauffeur principal',
      'createdAt': '2026-07-01T08:00:00.000Z',
      'updatedAt': '2026-07-01T09:00:00.000Z',
    });

    expect(driver.id, '0a3e5f32-402d-4b60-ade0-8961d3a3f6ba');
    expect(driver.name, 'KONAN Yao');
    expect(driver.phone, '0711223344');
    expect(driver.isActive, isTrue);
    expect(driver.notes, 'Chauffeur principal');
    expect(driver.updatedAt, DateTime.parse('2026-07-01T09:00:00.000Z'));
  });
}
