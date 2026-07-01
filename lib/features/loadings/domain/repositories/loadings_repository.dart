import '../../data/models/create_loading_request.dart';
import '../../data/models/loading_record.dart';

abstract class LoadingsRepository {
  Future<List<LoadingRecord>> fetchLoadings();

  Future<String> uploadProof(String filePath);

  Future<LoadingRecord> createLoading(CreateLoadingRequest request);
}
