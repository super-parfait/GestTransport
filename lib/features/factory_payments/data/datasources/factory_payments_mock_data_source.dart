import '../models/create_factory_payment_request.dart';
import '../models/factory_payment_record.dart';
import '../models/factory_site_option.dart';

class FactoryPaymentsMockDataSource {
  FactoryPaymentsMockDataSource();

  final List<FactorySiteOption> _sites = const [
    FactorySiteOption(
      id: 'mock-site-banco',
      name: 'Carrière du Banco',
      type: 'CARRIERE',
      currentPrice: 150000,
      location: 'Yopougon, Abidjan',
      contact: '',
    ),
    FactorySiteOption(
      id: 'mock-site-cadera',
      name: 'CADERAC',
      type: 'USINE',
      currentPrice: 250000,
      location: 'Vridi, Abidjan',
      contact: '',
    ),
  ];

  late final List<FactoryPaymentRecord> _payments = [
    FactoryPaymentRecord(
      id: 'mock-factory-payment-1',
      siteId: 'mock-site-cadera',
      siteName: 'CADERAC',
      siteType: 'USINE',
      date: DateTime(2026, 6, 30),
      payerName: 'Konan Yao',
      voucherNumber: 'BON-2026-001',
      receiptNumber: '',
      amount: 1000000,
      currentPrice: 250000,
      rebate: 0,
      tonnage: 4,
      quantity: 0,
      proofUrl: '',
      status: 'VALIDE',
      createdByName: 'Manager Demo',
      createdAt: DateTime(2026, 6, 30, 10),
      updatedAt: DateTime(2026, 6, 30, 10),
    ),
    FactoryPaymentRecord(
      id: 'mock-factory-payment-2',
      siteId: 'mock-site-banco',
      siteName: 'Carrière du Banco',
      siteType: 'CARRIERE',
      date: DateTime(2026, 6, 29),
      payerName: 'Yao Brou',
      voucherNumber: 'BON-2026-002',
      receiptNumber: '',
      amount: 1500000,
      currentPrice: 150000,
      rebate: 50000,
      tonnage: 10,
      quantity: 0,
      proofUrl: 'https://demo.transpogest.local/uploads/mock-proof.jpg',
      status: 'BROUILLON',
      createdByName: 'Manager Demo',
      createdAt: DateTime(2026, 6, 29, 11),
      updatedAt: DateTime(2026, 6, 29, 11),
    ),
  ];

  Future<List<FactorySiteOption>> fetchSites() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));

    return List<FactorySiteOption>.from(_sites);
  }

  Future<List<FactoryPaymentRecord>> fetchPayments() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return _sortedPayments();
  }

  Future<FactoryPaymentRecord> updatePayment(
    String paymentId,
    CreateFactoryPaymentRequest request,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));

    final index = _payments.indexWhere((payment) => payment.id == paymentId);
    if (index < 0) {
      throw StateError('Versement introuvable');
    }

    final site = _sites.firstWhere(
      (item) => item.id == request.siteId,
      orElse: () => const FactorySiteOption(
        id: '',
        name: 'Site',
        type: 'AUTRE',
        currentPrice: 0,
        location: '',
        contact: '',
      ),
    );

    final current = _payments[index];
    final updated = current.copyWith(
      siteId: request.siteId,
      siteName: site.name,
      siteType: site.type,
      date: request.date,
      payerName: request.payerName,
      voucherNumber: request.voucherNumber,
      amount: request.amount,
      currentPrice: request.currentPrice,
      rebate: request.rebate,
      tonnage: request.tonnage,
      proofUrl: request.proofUrl ?? current.proofUrl,
      status: request.status,
      updatedAt: DateTime.now(),
    );

    _payments[index] = updated;
    return updated;
  }

  Future<void> deletePayment(String paymentId) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    _payments.removeWhere((payment) => payment.id == paymentId);
  }

  Future<String> uploadProof(String filePath) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return 'https://demo.transpogest.local/uploads/mock-proof.jpg';
  }

  Future<FactoryPaymentRecord> createPayment(
    CreateFactoryPaymentRequest request,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));

    final site = _sites.firstWhere(
      (item) => item.id == request.siteId,
      orElse: () => const FactorySiteOption(
        id: '',
        name: 'Site',
        type: 'AUTRE',
        currentPrice: 0,
        location: '',
        contact: '',
      ),
    );

    final payment = FactoryPaymentRecord(
      id: 'mock-factory-payment-${DateTime.now().microsecondsSinceEpoch}',
      siteId: request.siteId,
      siteName: site.name,
      siteType: site.type,
      date: request.date,
      payerName: request.payerName,
      voucherNumber: request.voucherNumber,
      receiptNumber: '',
      amount: request.amount,
      currentPrice: request.currentPrice,
      rebate: request.rebate,
      tonnage: request.tonnage,
      quantity: 0,
      proofUrl: request.proofUrl ?? '',
      status: request.status,
      createdByName: 'Utilisateur démo',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _payments.add(payment);
    return payment;
  }

  List<FactoryPaymentRecord> _sortedPayments() {
    final cloned = List<FactoryPaymentRecord>.from(_payments);
    cloned.sort((a, b) {
      final byDate = b.date.compareTo(a.date);
      if (byDate != 0) {
        return byDate;
      }
      return b.createdAt.compareTo(a.createdAt);
    });
    return cloned;
  }
}
