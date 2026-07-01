import '../../../../core/config/app_config.dart';
import '../../domain/repositories/factory_payments_repository.dart';
import '../datasources/factory_payments_mock_data_source.dart';
import '../datasources/factory_payments_remote_data_source.dart';
import '../models/create_factory_payment_request.dart';
import '../models/factory_payment_record.dart';
import '../models/factory_site_option.dart';

class FactoryPaymentsRepositoryImpl implements FactoryPaymentsRepository {
  final AppConfig _config;
  final FactoryPaymentsRemoteDataSource _remoteDataSource;
  final FactoryPaymentsMockDataSource _mockDataSource;

  const FactoryPaymentsRepositoryImpl({
    required AppConfig config,
    required FactoryPaymentsRemoteDataSource remoteDataSource,
    required FactoryPaymentsMockDataSource mockDataSource,
  })  : _config = config,
        _remoteDataSource = remoteDataSource,
        _mockDataSource = mockDataSource;

  @override
  Future<List<FactorySiteOption>> fetchSites() async {
    if (_config.useMockApi) {
      return _mockDataSource.fetchSites();
    }

    try {
      return await _remoteDataSource.fetchSites();
    } catch (_) {
      if (_config.fallbackToMockOnError) {
        return _mockDataSource.fetchSites();
      }
      rethrow;
    }
  }

  @override
  Future<List<FactoryPaymentRecord>> fetchPayments() async {
    if (_config.useMockApi) {
      return _mockDataSource.fetchPayments();
    }

    try {
      return await _remoteDataSource.fetchPayments();
    } catch (_) {
      if (_config.fallbackToMockOnError) {
        return _mockDataSource.fetchPayments();
      }
      rethrow;
    }
  }

  @override
  Future<FactoryPaymentRecord> updatePayment(
    String paymentId,
    CreateFactoryPaymentRequest request,
  ) async {
    if (_config.useMockApi) {
      return _mockDataSource.updatePayment(paymentId, request);
    }

    try {
      return await _remoteDataSource.updatePayment(paymentId, request);
    } catch (_) {
      if (_config.fallbackToMockOnError) {
        return _mockDataSource.updatePayment(paymentId, request);
      }
      rethrow;
    }
  }

  @override
  Future<void> deletePayment(String paymentId) async {
    if (_config.useMockApi) {
      return _mockDataSource.deletePayment(paymentId);
    }

    try {
      await _remoteDataSource.deletePayment(paymentId);
    } catch (_) {
      if (_config.fallbackToMockOnError) {
        return _mockDataSource.deletePayment(paymentId);
      }
      rethrow;
    }
  }

  @override
  Future<String> uploadProof(String filePath) async {
    if (_config.useMockApi) {
      return _mockDataSource.uploadProof(filePath);
    }

    try {
      return await _remoteDataSource.uploadProof(filePath);
    } catch (_) {
      if (_config.fallbackToMockOnError) {
        return _mockDataSource.uploadProof(filePath);
      }
      rethrow;
    }
  }

  @override
  Future<FactoryPaymentRecord> createPayment(
    CreateFactoryPaymentRequest request,
  ) async {
    if (_config.useMockApi) {
      return _mockDataSource.createPayment(request);
    }

    try {
      return await _remoteDataSource.createPayment(request);
    } catch (_) {
      if (_config.fallbackToMockOnError) {
        return _mockDataSource.createPayment(request);
      }
      rethrow;
    }
  }
}
