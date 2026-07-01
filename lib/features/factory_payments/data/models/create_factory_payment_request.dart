class CreateFactoryPaymentRequest {
  final String siteId;
  final DateTime date;
  final String payerName;
  final String voucherNumber;
  final int amount;
  final int currentPrice;
  final int rebate;
  final double tonnage;
  final String? proofUrl;
  final String status;

  const CreateFactoryPaymentRequest({
    required this.siteId,
    required this.date,
    required this.payerName,
    required this.voucherNumber,
    required this.amount,
    required this.currentPrice,
    required this.rebate,
    required this.tonnage,
    this.proofUrl,
    required this.status,
  });

  CreateFactoryPaymentRequest copyWith({
    String? siteId,
    DateTime? date,
    String? payerName,
    String? voucherNumber,
    int? amount,
    int? currentPrice,
    int? rebate,
    double? tonnage,
    String? proofUrl,
    String? status,
  }) {
    return CreateFactoryPaymentRequest(
      siteId: siteId ?? this.siteId,
      date: date ?? this.date,
      payerName: payerName ?? this.payerName,
      voucherNumber: voucherNumber ?? this.voucherNumber,
      amount: amount ?? this.amount,
      currentPrice: currentPrice ?? this.currentPrice,
      rebate: rebate ?? this.rebate,
      tonnage: tonnage ?? this.tonnage,
      proofUrl: proofUrl ?? this.proofUrl,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'siteId': siteId,
      'date': date.toIso8601String(),
      'payerName': payerName.trim(),
      'voucherNumber': voucherNumber.trim(),
      'amount': amount,
      'currentPrice': currentPrice,
      'rebate': rebate,
      'tonnage': tonnage,
      if (proofUrl != null && proofUrl!.trim().isNotEmpty)
        'proofUrl': proofUrl!.trim(),
      'status': status.trim(),
    };
  }
}
