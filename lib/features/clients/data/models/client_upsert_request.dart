import 'client_model.dart';

class ClientUpsertRequest {
  final String name;
  final String phone;
  final String address;
  final bool isActive;
  final String notes;

  const ClientUpsertRequest({
    required this.name,
    required this.phone,
    required this.address,
    required this.isActive,
    required this.notes,
  });

  factory ClientUpsertRequest.fromClient(ClientModel client) {
    return ClientUpsertRequest(
      name: client.name,
      phone: client.phone,
      address: client.address,
      isActive: client.isActive,
      notes: client.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name.trim(),
      'phone': _nullable(phone),
      'address': _nullable(address),
      'isActive': isActive,
      'notes': _nullable(notes),
    };
  }

  static String? _nullable(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
