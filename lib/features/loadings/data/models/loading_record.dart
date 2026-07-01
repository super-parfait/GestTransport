class LoadingRecord {
  final String id;
  final DateTime date;
  final String type;
  final String siteId;
  final String siteName;
  final String siteType;
  final String clientId;
  final String clientName;
  final String truckId;
  final String truckRegistration;
  final String driverId;
  final String driverName;
  final String voucherNumber;
  final String destination;
  final double quantity;
  final int tripsCount;
  final int purchasePrice;
  final int salePrice;
  final int transportPrice;
  final int fuelExpense;
  final int roadFees;
  final int otherFees;
  final int amountToPay;
  final int netMargin;
  final String proofUrl;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const LoadingRecord({
    required this.id,
    required this.date,
    required this.type,
    required this.siteId,
    required this.siteName,
    required this.siteType,
    required this.clientId,
    required this.clientName,
    required this.truckId,
    required this.truckRegistration,
    required this.driverId,
    required this.driverName,
    required this.voucherNumber,
    required this.destination,
    required this.quantity,
    required this.tripsCount,
    required this.purchasePrice,
    required this.salePrice,
    required this.transportPrice,
    required this.fuelExpense,
    required this.roadFees,
    required this.otherFees,
    required this.amountToPay,
    required this.netMargin,
    required this.proofUrl,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LoadingRecord.fromJson(Map<String, dynamic> json) {
    final client = _asMap(json['client']);
    final site = _asMap(json['site']);
    final truck = _asMap(json['truck']);
    final driver = _asMap(json['driver']);

    return LoadingRecord(
      id: (json['id'] ?? '').toString(),
      date: _asDateTime(json['date']),
      type: (json['type'] ?? 'TRANSPORT').toString(),
      siteId: (json['siteId'] ?? site['id'] ?? '').toString(),
      siteName: (site['name'] ?? json['siteName'] ?? '').toString(),
      siteType: (site['type'] ?? json['siteType'] ?? 'AUTRE').toString(),
      clientId: (json['clientId'] ?? client['id'] ?? '').toString(),
      clientName: (client['name'] ?? json['clientName'] ?? '').toString(),
      truckId: (json['truckId'] ?? truck['id'] ?? '').toString(),
      truckRegistration: (truck['registration'] ??
              truck['plate'] ??
              json['truckRegistration'] ??
              '')
          .toString(),
      driverId: (json['driverId'] ?? driver['id'] ?? '').toString(),
      driverName: (driver['name'] ?? json['driverName'] ?? '').toString(),
      voucherNumber: (json['voucherNumber'] ?? '').toString(),
      destination: (json['destination'] ?? '').toString(),
      quantity: _asDouble(json['quantity']),
      tripsCount: _asInt(json['tripsCount']),
      purchasePrice: _asInt(json['purchasePrice']),
      salePrice: _asInt(json['salePrice']),
      transportPrice: _asInt(json['transportPrice']),
      fuelExpense: _asInt(json['fuelExpense']),
      roadFees: _asInt(json['roadFees']),
      otherFees: _asInt(json['otherFees']),
      amountToPay: _asInt(json['amountToPay']),
      netMargin: _asInt(json['netMargin']),
      proofUrl: (json['proofUrl'] ?? '').toString(),
      status: (json['status'] ?? 'VALIDE').toString(),
      createdAt: _asDateTime(json['createdAt']),
      updatedAt: _asDateTime(json['updatedAt']),
    );
  }

  bool get isMaterial =>
      type.trim().toUpperCase() == 'SABLE' ||
      type.trim().toUpperCase() == 'GRAVIER';

  static int _asInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.round();
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _asDouble(dynamic value) {
    if (value is double) {
      return value;
    }
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static DateTime _asDateTime(dynamic value) {
    if (value is DateTime) {
      return value;
    }

    return DateTime.tryParse(value?.toString() ?? '') ?? DateTime.now();
  }

  static Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return const <String, dynamic>{};
  }
}
