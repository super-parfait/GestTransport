import 'package:flutter_test/flutter_test.dart';

import 'package:sand_gravel_app/features/clients/data/models/client_model.dart';
import 'package:sand_gravel_app/features/clients/data/models/client_upsert_request.dart';

void main() {
  test('client upsert request serializes nullable fields correctly', () {
    const request = ClientUpsertRequest(
      name: '  KOUAME Eric  ',
      phone: ' 0700112233 ',
      address: ' Cocody ',
      isActive: true,
      notes: '  Bon payeur ',
    );

    expect(request.toJson(), {
      'name': 'KOUAME Eric',
      'phone': '0700112233',
      'address': 'Cocody',
      'isActive': true,
      'notes': 'Bon payeur',
    });
  });

  test('client model detects UUID-compatible ids', () {
    final validClient = ClientModel.fromJson({
      'id': '0a3e5f32-402d-4b60-ade0-8961d3a3f6ba',
      'name': 'Client API',
      'phone': '0700112233',
      'address': 'Abidjan',
      'currentBalance': 0,
      'isActive': true,
      'notes': null,
      'createdAt': '2026-07-01T08:00:00.000Z',
      'updatedAt': '2026-07-01T08:00:00.000Z',
    });
    final legacyClient = ClientModel.fromJson({
      'id': 'seed-client-kouame',
      'name': 'Client legacy',
      'phone': '0700112233',
      'address': 'Abidjan',
      'currentBalance': 0,
      'isActive': true,
      'notes': null,
      'createdAt': '2026-07-01T08:00:00.000Z',
      'updatedAt': '2026-07-01T08:00:00.000Z',
    });

    expect(validClient.hasUsableId, isTrue);
    expect(legacyClient.hasUsableId, isFalse);
  });
}
