import '../../../../core/config/app_config.dart';
import '../../domain/repositories/clients_repository.dart';
import '../datasources/clients_mock_data_source.dart';
import '../datasources/clients_remote_data_source.dart';
import '../models/client_model.dart';

class ClientsRepositoryImpl implements ClientsRepository {
  final AppConfig _config;
  final ClientsRemoteDataSource _remoteDataSource;
  final ClientsMockDataSource _mockDataSource;

  const ClientsRepositoryImpl({
    required AppConfig config,
    required ClientsRemoteDataSource remoteDataSource,
    required ClientsMockDataSource mockDataSource,
  })  : _config = config,
        _remoteDataSource = remoteDataSource,
        _mockDataSource = mockDataSource;

  @override
  Future<List<ClientModel>> fetchClients() async {
    if (_config.useMockApi) {
      return _mockDataSource.fetchClients();
    }

    try {
      return await _remoteDataSource.fetchClients();
    } catch (_) {
      if (_config.fallbackToMockOnError) {
        return _mockDataSource.fetchClients();
      }
      rethrow;
    }
  }
}
