class TruckModel {
  final String id;
  final String plate;
  final String brand;
  final String model;
  final String driverId;
  final String driver;
  final String phone;
  final String status;
  final int km;
  final String notes;
  final List<String> alerts;
  final String assuranceExpiry;
  final String visiteExpiry;
  final String patenteExpiry;
  final List<Map<String, dynamic>> loadings;
  final List<Map<String, dynamic>> expenses;
  final List<Map<String, dynamic>> maintenances;
  final List<Map<String, dynamic>> oilChanges;
  final List<Map<String, dynamic>> revenues;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TruckModel({
    required this.id,
    required this.plate,
    required this.brand,
    required this.model,
    required this.driverId,
    required this.driver,
    required this.phone,
    required this.status,
    required this.km,
    required this.notes,
    required this.alerts,
    required this.assuranceExpiry,
    required this.visiteExpiry,
    required this.patenteExpiry,
    required this.loadings,
    required this.expenses,
    required this.maintenances,
    required this.oilChanges,
    required this.revenues,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TruckModel.fromJson(Map<String, dynamic> json) {
    final driver = _asMap(json['driver']);

    return TruckModel(
      id: (json['id'] ?? '').toString(),
      plate: (json['plate'] ?? json['registration'] ?? '').toString(),
      brand: (json['brand'] ?? '').toString(),
      model: (json['model'] ?? '').toString(),
      driverId: (json['driverId'] ?? driver['id'] ?? '').toString(),
      driver: (json['driver'] is String ? json['driver'] : driver['name'] ?? '')
          .toString(),
      phone: (json['phone'] ?? driver['phone'] ?? '').toString(),
      status: (json['status'] ?? 'DISPONIBLE').toString(),
      km: _asInt(json['km'] ?? json['currentKm']),
      notes: (json['notes'] ?? '').toString(),
      alerts: _parseStringList(json['alerts']),
      assuranceExpiry: (json['assurance_expiry'] ?? '').toString(),
      visiteExpiry: (json['visite_expiry'] ?? '').toString(),
      patenteExpiry: (json['patente_expiry'] ?? '').toString(),
      loadings: _parseMapList(json['loadings']),
      expenses: _parseMapList(json['expenses']),
      maintenances: _parseMapList(json['maintenances']),
      oilChanges: _parseMapList(json['oil_changes'] ?? json['oilChanges']),
      revenues: _parseMapList(json['revenues']),
      createdAt: _asDateTime(json['createdAt'] ?? json['created_at']),
      updatedAt: _asDateTime(
        json['updatedAt'] ?? json['updated_at'] ?? json['createdAt'],
      ),
    );
  }

  bool get hasAlerts => alerts.isNotEmpty;

  Map<String, dynamic> toPresentationMap() {
    return {
      'id': id,
      'plate': plate,
      'brand': brand,
      'model': model,
      'driver_id': driverId,
      'driver': driver,
      'phone': phone,
      'status': status,
      'km': km,
      'notes': notes,
      'alerts': alerts,
      'assurance_expiry': assuranceExpiry,
      'visite_expiry': visiteExpiry,
      'patente_expiry': patenteExpiry,
      'loadings': loadings,
      'expenses': expenses,
      'maintenances': maintenances,
      'oil_changes': oilChanges,
      'revenues': revenues,
    };
  }

  static int _asInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is double) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static List<String> _parseStringList(dynamic value) {
    if (value is! List) {
      return const [];
    }

    return value.map((item) => item.toString()).toList();
  }

  static List<Map<String, dynamic>> _parseMapList(dynamic value) {
    if (value is! List) {
      return const [];
    }

    return value
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  static DateTime _asDateTime(dynamic value) {
    final parsed = DateTime.tryParse(value?.toString() ?? '');
    return parsed ?? DateTime.fromMillisecondsSinceEpoch(0);
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
