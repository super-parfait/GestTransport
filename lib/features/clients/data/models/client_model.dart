import '../../../../core/utils/uuid_utils.dart';

class ClientModel {
  final String id;
  final String name;
  final String phone;
  final String address;
  final bool isActive;
  final String notes;
  final double balance;
  final double totalCredit;
  final double totalPaid;
  final List<Map<String, dynamic>> loadings;
  final List<Map<String, dynamic>> payments;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ClientModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
    required this.isActive,
    required this.notes,
    required this.balance,
    required this.totalCredit,
    required this.totalPaid,
    required this.loadings,
    required this.payments,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ClientModel.fromJson(Map<String, dynamic> json) {
    return ClientModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      address: (json['address'] ?? '').toString(),
      isActive: _asBool(json['isActive'] ?? json['is_active'] ?? true),
      notes: (json['notes'] ?? '').toString(),
      balance: _asDouble(json['balance'] ?? json['currentBalance']),
      totalCredit: _asDouble(
        json['total_credit'] ??
            json['totalCredit'] ??
            json['openingBalance'] ??
            json['currentBalance'],
      ),
      totalPaid: _asDouble(json['total_paid'] ?? json['totalPaid']),
      loadings: _parseMapList(json['loadings']),
      payments: _parseMapList(json['payments']),
      createdAt: _asDateTime(json['createdAt'] ?? json['created_at']),
      updatedAt: _asDateTime(
        json['updatedAt'] ?? json['updated_at'] ?? json['createdAt'],
      ),
    );
  }

  bool get isDebtor => balance > 0;
  bool get hasUsableId => isUuid(id);

  Map<String, dynamic> toPresentationMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'address': address,
      'is_active': isActive,
      'notes': notes,
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

  static bool _asBool(dynamic value) {
    if (value is bool) {
      return value;
    }
    if (value is num) {
      return value != 0;
    }

    switch (value?.toString().trim().toLowerCase()) {
      case 'true':
      case '1':
      case 'yes':
      case 'on':
        return true;
      case 'false':
      case '0':
      case 'no':
      case 'off':
        return false;
      default:
        return false;
    }
  }

  static DateTime _asDateTime(dynamic value) {
    final parsed = DateTime.tryParse(value?.toString() ?? '');
    return parsed ?? DateTime.fromMillisecondsSinceEpoch(0);
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
