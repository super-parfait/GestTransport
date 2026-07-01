import '../../data/models/create_factory_payment_request.dart';
import '../../data/models/factory_payment_record.dart';
import '../../data/models/factory_site_option.dart';

abstract class FactoryPaymentsRepository {
  Future<List<FactorySiteOption>> fetchSites();

  Future<List<FactoryPaymentRecord>> fetchPayments();

  Future<FactoryPaymentRecord> updatePayment(
    String paymentId,
    CreateFactoryPaymentRequest request,
  );

  Future<void> deletePayment(String paymentId);

  Future<String> uploadProof(String filePath);

  Future<FactoryPaymentRecord> createPayment(
    CreateFactoryPaymentRequest request,
  );
}
