import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/create_factory_payment_request.dart';
import '../models/factory_payment_record.dart';
import '../models/factory_site_option.dart';
import '../models/uploaded_file_result.dart';

class FactoryPaymentsRemoteDataSource {
  final ApiClient _apiClient;

  const FactoryPaymentsRemoteDataSource(this._apiClient);

  Future<List<FactorySiteOption>> fetchSites() {
    return _apiClient.get(
      ApiEndpoints.sites,
      queryParameters: const {
        'limit': 100,
        'type': 'CARRIERE,USINE',
      },
      decoder: (data) {
        final list = _extractList(data);
        return list.map(FactorySiteOption.fromJson).toList();
      },
    );
  }

  Future<List<FactoryPaymentRecord>> fetchPayments() {
    return _apiClient.get(
      ApiEndpoints.factoryPayments,
      queryParameters: const {
        'limit': 100,
      },
      decoder: (data) {
        final list = _extractList(data);
        return list.map(FactoryPaymentRecord.fromJson).toList();
      },
    );
  }

  Future<FactoryPaymentRecord> updatePayment(
    String paymentId,
    CreateFactoryPaymentRequest request,
  ) {
    return _apiClient.patch(
      '${ApiEndpoints.factoryPayments}/$paymentId',
      body: request.toJson(),
      decoder: (data) =>
          FactoryPaymentRecord.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<void> deletePayment(String paymentId) async {
    await _apiClient.delete<bool>(
      '${ApiEndpoints.factoryPayments}/$paymentId',
      decoder: (_) => true,
    );
  }

  Future<String> uploadProof(String filePath) {
    return _apiClient.uploadFile(
      ApiEndpoints.fileUpload,
      filePath: filePath,
      decoder: (data) {
        final json = data is Map<String, dynamic>
            ? data
            : Map<String, dynamic>.from(data as Map);
        return UploadedFileResult.fromJson(json).url;
      },
    );
  }

  Future<FactoryPaymentRecord> createPayment(
    CreateFactoryPaymentRequest request,
  ) {
    return _apiClient.post(
      ApiEndpoints.factoryPayments,
      body: request.toJson(),
      decoder: (data) =>
          FactoryPaymentRecord.fromJson(data as Map<String, dynamic>),
    );
  }

  List<Map<String, dynamic>> _extractList(dynamic data) {
    if (data is List) {
      return data
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }

    if (data is Map<String, dynamic> && data['items'] is List) {
      return (data['items'] as List)
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }

    return const [];
  }
}
