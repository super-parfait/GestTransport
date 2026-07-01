class DriverUpsertRequest {
  final String name;
  final String phone;
  final bool isActive;
  final String notes;

  const DriverUpsertRequest({
    required this.name,
    required this.phone,
    required this.isActive,
    required this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name.trim(),
      'phone': _nullable(phone),
      'isActive': isActive,
      'notes': _nullable(notes),
    };
  }

  static String? _nullable(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
