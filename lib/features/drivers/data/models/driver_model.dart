import '../../../../core/utils/uuid_utils.dart';

class DriverModel {
  final String id;
  final String name;
  final String phone;
  final bool isActive;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DriverModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.isActive,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DriverModel.fromJson(Map<String, dynamic> json) {
    return DriverModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      isActive: _asBool(json['isActive'] ?? json['is_active'] ?? true),
      notes: (json['notes'] ?? '').toString(),
      createdAt: _asDateTime(json['createdAt'] ?? json['created_at']),
      updatedAt: _asDateTime(
        json['updatedAt'] ?? json['updated_at'] ?? json['createdAt'],
      ),
    );
  }

  Map<String, dynamic> toPresentationMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'is_active': isActive,
      'notes': notes,
    };
  }

  bool get hasUsableId => isUuid(id);

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
}
