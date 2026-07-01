class CreateLoadingRequest {
  final DateTime date;
  final String type;
  final String clientId;
  final String? siteId;
  final String? truckId;
  final String? driverId;
  final String? voucherNumber;
  final String? destination;
  final double? quantity;
  final int? tripsCount;
  final int? purchasePrice;
  final int? salePrice;
  final int? transportPrice;
  final int fuelExpense;
  final int roadFees;
  final int otherFees;
  final String? proofUrl;
  final String status;

  const CreateLoadingRequest({
    required this.date,
    required this.type,
    required this.clientId,
    this.siteId,
    this.truckId,
    this.driverId,
    this.voucherNumber,
    this.destination,
    this.quantity,
    this.tripsCount,
    this.purchasePrice,
    this.salePrice,
    this.transportPrice,
    this.fuelExpense = 0,
    this.roadFees = 0,
    this.otherFees = 0,
    this.proofUrl,
    required this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'type': type.trim().toUpperCase(),
      'clientId': clientId.trim(),
      'siteId': _nullable(siteId),
      'truckId': _nullable(truckId),
      'driverId': _nullable(driverId),
      'voucherNumber': _nullable(voucherNumber),
      'destination': _nullable(destination),
      'quantity': quantity,
      'tripsCount': tripsCount,
      'purchasePrice': purchasePrice,
      'salePrice': salePrice,
      'transportPrice': transportPrice,
      'fuelExpense': fuelExpense,
      'roadFees': roadFees,
      'otherFees': otherFees,
      'proofUrl': _nullable(proofUrl),
      'status': status.trim().toUpperCase(),
    };
  }

  static String? _nullable(String? value) {
    final trimmed = value?.trim() ?? '';
    return trimmed.isEmpty ? null : trimmed;
  }
}
