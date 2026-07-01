import 'package:flutter_test/flutter_test.dart';

import 'package:sand_gravel_app/features/loadings/data/models/create_loading_request.dart';
import 'package:sand_gravel_app/features/loadings/data/models/loading_record.dart';

void main() {
  test('create loading request serializes the backend payload correctly', () {
    final request = CreateLoadingRequest(
      date: DateTime.utc(2026, 7, 1),
      type: 'sable',
      clientId: 'client-1',
      siteId: 'site-1',
      truckId: 'truck-1',
      driverId: 'driver-1',
      voucherNumber: ' BON-001 ',
      destination: ' Cocody ',
      quantity: 18.5,
      purchasePrice: 150000,
      salePrice: 180000,
      transportPrice: 20000,
      fuelExpense: 45000,
      roadFees: 12000,
      otherFees: 3000,
      status: 'valide',
    );

    expect(request.toJson(), {
      'date': '2026-07-01T00:00:00.000Z',
      'type': 'SABLE',
      'clientId': 'client-1',
      'siteId': 'site-1',
      'truckId': 'truck-1',
      'driverId': 'driver-1',
      'voucherNumber': 'BON-001',
      'destination': 'Cocody',
      'quantity': 18.5,
      'tripsCount': null,
      'purchasePrice': 150000,
      'salePrice': 180000,
      'transportPrice': 20000,
      'fuelExpense': 45000,
      'roadFees': 12000,
      'otherFees': 3000,
      'proofUrl': null,
      'status': 'VALIDE',
    });
  });

  test('loading record parses nested relations from the API response', () {
    final record = LoadingRecord.fromJson({
      'id': 'loading-1',
      'date': '2026-07-01T00:00:00.000Z',
      'type': 'TRANSPORT',
      'clientId': 'client-1',
      'truckId': 'truck-1',
      'driverId': 'driver-1',
      'voucherNumber': 'TRP-001',
      'destination': 'Yopougon',
      'tripsCount': 3,
      'transportPrice': 120000,
      'fuelExpense': 25000,
      'roadFees': 5000,
      'otherFees': 2000,
      'amountToPay': 360000,
      'netMargin': 328000,
      'status': 'VALIDE',
      'createdAt': '2026-07-01T08:00:00.000Z',
      'updatedAt': '2026-07-01T08:00:00.000Z',
      'client': {
        'id': 'client-1',
        'name': 'KOUAME Eric',
      },
      'truck': {
        'id': 'truck-1',
        'registration': 'CI-1234-AB',
      },
      'driver': {
        'id': 'driver-1',
        'name': 'KONAN Yao',
      },
    });

    expect(record.clientName, 'KOUAME Eric');
    expect(record.truckRegistration, 'CI-1234-AB');
    expect(record.driverName, 'KONAN Yao');
    expect(record.tripsCount, 3);
    expect(record.quantity, 0);
    expect(record.amountToPay, 360000);
    expect(record.netMargin, 328000);
    expect(record.isMaterial, isFalse);
  });
}
