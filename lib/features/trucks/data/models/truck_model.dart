class TruckModel {
  final String id;
  final String plate;
  final String driver;
  final String phone;
  final String status;
  final int km;
  final List<String> alerts;
  final String assuranceExpiry;
  final String visiteExpiry;
  final String patenteExpiry;
  final List<Map<String, dynamic>> loadings;
  final List<Map<String, dynamic>> expenses;
  final List<Map<String, dynamic>> maintenances;
  final List<Map<String, dynamic>> oilChanges;
  final List<Map<String, dynamic>> revenues;

  const TruckModel({
    required this.id,
    required this.plate,
    required this.driver,
    required this.phone,
    required this.status,
    required this.km,
    required this.alerts,
    required this.assuranceExpiry,
    required this.visiteExpiry,
    required this.patenteExpiry,
    required this.loadings,
    required this.expenses,
    required this.maintenances,
    required this.oilChanges,
    required this.revenues,
  });

  factory TruckModel.fromJson(Map<String, dynamic> json) {
    return TruckModel(
      id: (json['id'] ?? '').toString(),
      plate: (json['plate'] ?? '').toString(),
      driver: (json['driver'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      status: (json['status'] ?? 'available').toString(),
      km: _asInt(json['km']),
      alerts: _parseStringList(json['alerts']),
      assuranceExpiry: (json['assurance_expiry'] ?? '').toString(),
      visiteExpiry: (json['visite_expiry'] ?? '').toString(),
      patenteExpiry: (json['patente_expiry'] ?? '').toString(),
      loadings: _parseMapList(json['loadings']),
      expenses: _parseMapList(json['expenses']),
      maintenances: _parseMapList(json['maintenances']),
      oilChanges: _parseMapList(json['oil_changes'] ?? json['oilChanges']),
      revenues: _parseMapList(json['revenues']),
    );
  }

  bool get hasAlerts => alerts.isNotEmpty;

  Map<String, dynamic> toPresentationMap() {
    return {
      'id': id,
      'plate': plate,
      'driver': driver,
      'phone': phone,
      'status': status,
      'km': km,
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
}
