class FactoryPaymentRecord {
  final String id;
  final String siteId;
  final String siteName;
  final String siteType;
  final DateTime date;
  final String payerName;
  final String voucherNumber;
  final String receiptNumber;
  final int amount;
  final int currentPrice;
  final int rebate;
  final double tonnage;
  final double quantity;
  final String proofUrl;
  final String status;
  final String createdByName;
  final DateTime createdAt;
  final DateTime updatedAt;

  const FactoryPaymentRecord({
    required this.id,
    required this.siteId,
    required this.siteName,
    required this.siteType,
    required this.date,
    required this.payerName,
    required this.voucherNumber,
    required this.receiptNumber,
    required this.amount,
    required this.currentPrice,
    required this.rebate,
    required this.tonnage,
    required this.quantity,
    required this.proofUrl,
    required this.status,
    required this.createdByName,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FactoryPaymentRecord.fromJson(Map<String, dynamic> json) {
    final site = _asMap(json['site']);
    final createdBy = _asMap(json['createdBy']);

    return FactoryPaymentRecord(
      id: (json['id'] ?? '').toString(),
      siteId: (json['siteId'] ?? '').toString(),
      siteName: (site['name'] ?? json['siteName'] ?? '').toString(),
      siteType: (site['type'] ?? json['siteType'] ?? 'AUTRE').toString(),
      date: _asDateTime(json['date']),
      payerName: (json['payerName'] ?? '').toString(),
      voucherNumber: (json['voucherNumber'] ?? '').toString(),
      receiptNumber: (json['receiptNumber'] ?? '').toString(),
      amount: _asInt(json['amount']),
      currentPrice: _asInt(json['currentPrice']),
      rebate: _asInt(json['rebate']),
      tonnage: _asDouble(json['tonnage']),
      quantity: _asDouble(json['quantity']),
      proofUrl: (json['proofUrl'] ?? '').toString(),
      status: (json['status'] ?? 'VALIDE').toString(),
      createdByName: (createdBy['name'] ?? '').toString(),
      createdAt: _asDateTime(json['createdAt']),
      updatedAt: _asDateTime(json['updatedAt']),
    );
  }

  FactoryPaymentRecord copyWith({
    String? id,
    String? siteId,
    String? siteName,
    String? siteType,
    DateTime? date,
    String? payerName,
    String? voucherNumber,
    String? receiptNumber,
    int? amount,
    int? currentPrice,
    int? rebate,
    double? tonnage,
    double? quantity,
    String? proofUrl,
    String? status,
    String? createdByName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FactoryPaymentRecord(
      id: id ?? this.id,
      siteId: siteId ?? this.siteId,
      siteName: siteName ?? this.siteName,
      siteType: siteType ?? this.siteType,
      date: date ?? this.date,
      payerName: payerName ?? this.payerName,
      voucherNumber: voucherNumber ?? this.voucherNumber,
      receiptNumber: receiptNumber ?? this.receiptNumber,
      amount: amount ?? this.amount,
      currentPrice: currentPrice ?? this.currentPrice,
      rebate: rebate ?? this.rebate,
      tonnage: tonnage ?? this.tonnage,
      quantity: quantity ?? this.quantity,
      proofUrl: proofUrl ?? this.proofUrl,
      status: status ?? this.status,
      createdByName: createdByName ?? this.createdByName,
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
