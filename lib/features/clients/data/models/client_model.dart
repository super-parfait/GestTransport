class ClientModel {
  final String id;
  final String name;
  final String phone;
  final String address;
  final double balance;
  final double totalCredit;
  final double totalPaid;
  final List<Map<String, dynamic>> loadings;
  final List<Map<String, dynamic>> payments;

  const ClientModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
    required this.balance,
    required this.totalCredit,
    required this.totalPaid,
    required this.loadings,
    required this.payments,
  });

  factory ClientModel.fromJson(Map<String, dynamic> json) {
    return ClientModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      address: (json['address'] ?? '').toString(),
      balance: _asDouble(json['balance']),
      totalCredit: _asDouble(json['total_credit'] ?? json['totalCredit']),
      totalPaid: _asDouble(json['total_paid'] ?? json['totalPaid']),
      loadings: _parseMapList(json['loadings']),
      payments: _parseMapList(json['payments']),
    );
  }

  bool get isDebtor => balance > 0;

  Map<String, dynamic> toPresentationMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'address': address,
      'balance': balance,
      'total_credit': totalCredit,
      'total_paid': totalPaid,
      'loadings': loadings,
      'payments': payments,
    };
  }

  static double _asDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    final normalized = value
        ?.toString()
        .replaceAll(RegExp(r'[^0-9,.-]'), '')
        .replaceAll(',', '.');
    return double.tryParse(normalized ?? '') ?? 0;
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
