import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/data/datasources/auth_local_data_source.dart';
import '../../features/auth/data/datasources/auth_mock_data_source.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/controllers/session_controller.dart';
import '../../features/clients/data/datasources/clients_mock_data_source.dart';
import '../../features/clients/data/datasources/clients_remote_data_source.dart';
import '../../features/clients/data/repositories/clients_repository_impl.dart';
import '../../features/clients/domain/repositories/clients_repository.dart';
import '../../features/dashboard/data/datasources/dashboard_mock_data_source.dart';
import '../../features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import '../../features/dashboard/data/repositories/dashboard_repository_impl.dart';
import '../../features/dashboard/domain/repositories/dashboard_repository.dart';
import '../../features/trucks/data/datasources/trucks_mock_data_source.dart';
import '../../features/trucks/data/datasources/trucks_remote_data_source.dart';
import '../../features/trucks/data/repositories/trucks_repository_impl.dart';
import '../../features/trucks/domain/repositories/trucks_repository.dart';
import '../config/app_config.dart';
import '../network/api_client.dart';
import '../storage/token_storage.dart';

class AppContainer {
  final AppConfig config;
  final http.Client httpClient;
  final TokenStorage tokenStorage;
  final ApiClient apiClient;
  final AuthRepository authRepository;
  final DashboardRepository dashboardRepository;
  final ClientsRepository clientsRepository;
  final TrucksRepository trucksRepository;
  final SessionController sessionController;

  const AppContainer._({
    required this.config,
    required this.httpClient,
    required this.tokenStorage,
    required this.apiClient,
    required this.authRepository,
    required this.dashboardRepository,
    required this.clientsRepository,
    required this.trucksRepository,
    required this.sessionController,
  });

  static Future<AppContainer> bootstrap({
    AppConfig? config,
    SharedPreferences? preferences,
  }) async {
    final resolvedConfig = config ?? AppConfig.fromEnvironment();
    final prefs = preferences ?? await SharedPreferences.getInstance();
    final httpClient = http.Client();
    final tokenStorage = TokenStorage(prefs);
    final apiClient = ApiClient(
      httpClient: httpClient,
      tokenStorage: tokenStorage,
      config: resolvedConfig,
    );

    final authRepository = AuthRepositoryImpl(
      config: resolvedConfig,
      remoteDataSource: AuthRemoteDataSource(apiClient),
      mockDataSource: const AuthMockDataSource(),
      localDataSource: AuthLocalDataSource(tokenStorage),
    );

    final dashboardRepository = DashboardRepositoryImpl(
      config: resolvedConfig,
      remoteDataSource: DashboardRemoteDataSource(apiClient),
      mockDataSource: const DashboardMockDataSource(),
    );

    final clientsRepository = ClientsRepositoryImpl(
      config: resolvedConfig,
      remoteDataSource: ClientsRemoteDataSource(apiClient),
      mockDataSource: const ClientsMockDataSource(),
    );

    final trucksRepository = TrucksRepositoryImpl(
      config: resolvedConfig,
      remoteDataSource: TrucksRemoteDataSource(apiClient),
      mockDataSource: const TrucksMockDataSource(),
    );

    return AppContainer._(
      config: resolvedConfig,
      httpClient: httpClient,
      tokenStorage: tokenStorage,
      apiClient: apiClient,
      authRepository: authRepository,
      dashboardRepository: dashboardRepository,
      clientsRepository: clientsRepository,
      trucksRepository: trucksRepository,
      sessionController: SessionController(authRepository),
    );
  }

  String get dataSourceLabel => config.dataSourceLabel;

  void dispose() {
    sessionController.dispose();
    httpClient.close();
  }
}
