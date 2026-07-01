import '../models/create_loading_request.dart';
import '../models/loading_record.dart';

class LoadingsMockDataSource {
  final List<LoadingRecord> _items = [
    LoadingRecord(
      id: 'mock-loading-1',
      date: DateTime(2026, 6, 30),
      type: 'SABLE',
      siteId: 'mock-site-banco',
      siteName: 'Carrière du Banco',
      siteType: 'CARRIERE',
      clientId: '1',
      clientName: 'KOUAME Eric',
      truckId: '1',
      truckRegistration: 'CI-1234-AB',
      driverId: 'mock-driver-1',
      driverName: 'KONAN Yao',
      voucherNumber: 'BON-2026-001',
      destination: 'Cocody, Abidjan',
      quantity: 15,
      tripsCount: 0,
      purchasePrice: 150000,
      salePrice: 180000,
      transportPrice: 25000,
      fuelExpense: 45000,
      roadFees: 12000,
      otherFees: 5000,
      amountToPay: 2725000,
      netMargin: 413000,
      proofUrl: '',
      status: 'VALIDE',
      createdAt: DateTime(2026, 6, 30, 9),
      updatedAt: DateTime(2026, 6, 30, 9),
    ),
    LoadingRecord(
      id: 'mock-loading-2',
      date: DateTime(2026, 6, 29),
      type: 'TRANSPORT',
      siteId: '',
      siteName: '',
      siteType: 'AUTRE',
      clientId: '4',
      clientName: 'DIALLO Travaux',
      truckId: '2',
      truckRegistration: 'CI-5678-CD',
      driverId: 'mock-driver-2',
      driverName: 'OUATTARA Issa',
      voucherNumber: 'TRP-2026-014',
      destination: 'Yopougon',
      quantity: 0,
      tripsCount: 2,
      purchasePrice: 0,
      salePrice: 0,
      transportPrice: 180000,
      fuelExpense: 60000,
      roadFees: 15000,
      otherFees: 0,
      amountToPay: 360000,
      netMargin: 285000,
      proofUrl: '',
      status: 'BROUILLON',
      createdAt: DateTime(2026, 6, 29, 15),
      updatedAt: DateTime(2026, 6, 29, 15),
    ),
  ];

  Future<List<LoadingRecord>> fetchLoadings() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return _sortedLoadings();
  }

  Future<String> uploadProof(String filePath) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final fileName = filePath.split('/').last;
    return 'https://mock.transpogest.local/uploads/$fileName';
  }

  Future<LoadingRecord> createLoading(CreateLoadingRequest request) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final now = DateTime.now();
    final truckMeta = _truckMeta(request.truckId);
    final driverMeta = _driverMeta(
      request.driverId,
      fallbackTruckId: request.truckId,
    );
    final siteMeta = _siteMeta(request.siteId);
    final clientName = _clientNames[request.clientId] ?? 'Client';
    final calculated = _calculate(request);

    final item = LoadingRecord(
      id: 'mock-loading-${now.microsecondsSinceEpoch}',
      date: request.date,
      type: request.type,
      siteId: request.siteId ?? '',
      siteName: siteMeta['name'] ?? '',
      siteType: siteMeta['type'] ?? 'AUTRE',
      clientId: request.clientId,
      clientName: clientName,
      truckId: request.truckId ?? '',
      truckRegistration: truckMeta['registration'] ?? '',
      driverId: request.driverId ?? driverMeta['id'] ?? '',
      driverName: driverMeta['name'] ?? '',
      voucherNumber: request.voucherNumber?.trim() ?? '',
      destination: request.destination?.trim() ?? '',
      quantity: request.quantity ?? 0,
      tripsCount: request.tripsCount ?? 0,
      purchasePrice: request.purchasePrice ?? 0,
      salePrice: request.salePrice ?? 0,
      transportPrice: request.transportPrice ?? 0,
      fuelExpense: request.fuelExpense,
      roadFees: request.roadFees,
      otherFees: request.otherFees,
      amountToPay: calculated.$1,
      netMargin: calculated.$2,
      proofUrl: request.proofUrl?.trim() ?? '',
      status: request.status,
      createdAt: now,
      updatedAt: now,
    );

    _items.add(item);
    return item;
  }

  List<LoadingRecord> _sortedLoadings() {
    final sorted = List<LoadingRecord>.from(_items);
    sorted.sort((a, b) {
      final byDate = b.date.compareTo(a.date);
      if (byDate != 0) {
        return byDate;
      }
      return b.createdAt.compareTo(a.createdAt);
    });
    return sorted;
  }

  (int, int) _calculate(CreateLoadingRequest request) {
    final fuel = request.fuelExpense;
    final road = request.roadFees;
    final other = request.otherFees;
    final transport = request.transportPrice ?? 0;
    final type = request.type.trim().toUpperCase();

    if (type == 'SABLE' || type == 'GRAVIER') {
      final quantity = request.quantity ?? 0;
      final purchasePrice = request.purchasePrice ?? 0;
      final salePrice = request.salePrice ?? 0;
      final amountToPay = (quantity * salePrice).round() + transport;
      final purchaseTotal = (quantity * purchasePrice).round();
      final netMargin = amountToPay - purchaseTotal - fuel - road - other;
      return (amountToPay, netMargin);
    }

    final tripsCount = request.tripsCount ?? 0;
    final amountToPay = tripsCount * transport;
    final netMargin = amountToPay - fuel - road - other;
    return (amountToPay, netMargin);
  }

  Map<String, String> _truckMeta(String? truckId) {
    if (truckId == null || truckId.trim().isEmpty) {
      return const {'registration': ''};
    }
    return _trucks[truckId] ?? const {'registration': ''};
  }

  Map<String, String> _driverMeta(
    String? driverId, {
    String? fallbackTruckId,
  }) {
    if (driverId != null && driverId.trim().isNotEmpty) {
      return _drivers[driverId] ?? const {'id': '', 'name': ''};
    }

    if (fallbackTruckId != null && fallbackTruckId.trim().isNotEmpty) {
      final fallbackId = 'mock-driver-$fallbackTruckId';
      return _drivers[fallbackId] ?? const {'id': '', 'name': ''};
    }

    return const {'id': '', 'name': ''};
  }

  Map<String, String> _siteMeta(String? siteId) {
    if (siteId == null || siteId.trim().isEmpty) {
      return const {'name': '', 'type': 'AUTRE'};
    }
    return _sites[siteId] ?? const {'name': '', 'type': 'AUTRE'};
  }

  static const Map<String, String> _clientNames = {
    '1': 'KOUAME Eric',
    '2': 'BTP SERVICES SARL',
    '3': 'TOURE Construction',
    '4': 'DIALLO Travaux',
    '5': 'ENTREPRISE GNAGNE',
  };

  static const Map<String, Map<String, String>> _trucks = {
    '1': {'registration': 'CI-1234-AB'},
    '2': {'registration': 'CI-5678-CD'},
    '3': {'registration': 'CI-9012-EF'},
    '4': {'registration': 'CI-3456-GH'},
    '5': {'registration': 'CI-7890-IJ'},
  };

  static const Map<String, Map<String, String>> _drivers = {
    'mock-driver-1': {'id': 'mock-driver-1', 'name': 'KONAN Yao'},
    'mock-driver-2': {'id': 'mock-driver-2', 'name': 'OUATTARA Issa'},
    'mock-driver-3': {'id': 'mock-driver-3', 'name': 'BAMBA Mamadou'},
    'mock-driver-4': {'id': 'mock-driver-4', 'name': 'COULIBALY Drissa'},
    'mock-driver-5': {'id': 'mock-driver-5', 'name': 'KONE Seydou'},
  };

  static const Map<String, Map<String, String>> _sites = {
    'mock-site-banco': {'name': 'Carrière du Banco', 'type': 'CARRIERE'},
    'mock-site-cadera': {'name': 'CADERAC', 'type': 'USINE'},
  };
}
