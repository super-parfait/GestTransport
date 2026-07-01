class TruckUpsertRequest {
  final String registration;
  final String brand;
  final String model;
  final String status;
  final int currentKm;
  final String? driverId;
  final String notes;

  const TruckUpsertRequest({
    required this.registration,
    required this.brand,
    required this.model,
    required this.status,
    required this.currentKm,
    this.driverId,
    required this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'registration': registration.trim(),
      'brand': _nullable(brand),
      'model': _nullable(model),
      'status': status.trim().toUpperCase(),
      'currentKm': currentKm,
      'driverId': _nullable(driverId),
      'notes': _nullable(notes),
    };
  }

  static String? _nullable(String? value) {
    final trimmed = value?.trim() ?? '';
    return trimmed.isEmpty ? null : trimmed;
  }
}
