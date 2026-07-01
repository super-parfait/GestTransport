class FactorySiteOption {
  final String id;
  final String name;
  final String type;
  final int currentPrice;
  final String location;
  final String contact;

  const FactorySiteOption({
    required this.id,
    required this.name,
    required this.type,
    required this.currentPrice,
    required this.location,
    required this.contact,
  });

  factory FactorySiteOption.fromJson(Map<String, dynamic> json) {
    return FactorySiteOption(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      type: (json['type'] ?? 'AUTRE').toString(),
      currentPrice: _asInt(json['currentPrice']),
      location: (json['location'] ?? '').toString(),
      contact: (json['contact'] ?? '').toString(),
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
}
