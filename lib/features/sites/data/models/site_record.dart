class SiteRecord {
  final String id;
  final String name;
  final String type;
  final String location;
  final String contact;
  final int currentPrice;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SiteRecord({
    required this.id,
    required this.name,
    required this.type,
    required this.location,
    required this.contact,
    required this.currentPrice,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SiteRecord.fromJson(Map<String, dynamic> json) {
    return SiteRecord(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      type: (json['type'] ?? 'AUTRE').toString(),
      location: (json['location'] ?? '').toString(),
      contact: (json['contact'] ?? '').toString(),
      currentPrice: _asInt(json['currentPrice']),
      notes: (json['notes'] ?? '').toString(),
      createdAt: _asDateTime(json['createdAt']),
      updatedAt: _asDateTime(json['updatedAt']),
    );
  }

  SiteRecord copyWith({
    String? id,
    String? name,
    String? type,
    String? location,
    String? contact,
    int? currentPrice,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SiteRecord(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      location: location ?? this.location,
      contact: contact ?? this.contact,
      currentPrice: currentPrice ?? this.currentPrice,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static int _asInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.round();
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static DateTime _asDateTime(dynamic value) {
    if (value is DateTime) {
      return value;
    }

    return DateTime.tryParse(value?.toString() ?? '') ?? DateTime.now();
  }
}
