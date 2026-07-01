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
import '../../features/drivers/data/datasources/drivers_mock_data_source.dart';
import '../../features/drivers/data/datasources/drivers_remote_data_source.dart';
import '../../features/drivers/data/repositories/drivers_repository_impl.dart';
import '../../features/drivers/domain/repositories/drivers_repository.dart';
import '../../features/factory_payments/data/datasources/factory_payments_mock_data_source.dart';
import '../../features/factory_payments/data/datasources/factory_payments_remote_data_source.dart';
import '../../features/factory_payments/data/repositories/factory_payments_repository_impl.dart';
import '../../features/factory_payments/domain/repositories/factory_payments_repository.dart';
import '../../features/loadings/data/datasources/loadings_mock_data_source.dart';
import '../../features/loadings/data/datasources/loadings_remote_data_source.dart';
import '../../features/loadings/data/repositories/loadings_repository_impl.dart';
import '../../features/loadings/domain/repositories/loadings_repository.dart';
import '../../features/sites/data/datasources/sites_mock_data_source.dart';
import '../../features/sites/data/datasources/sites_remote_data_source.dart';
import '../../features/sites/data/repositories/sites_repository_impl.dart';
import '../../features/sites/domain/repositories/sites_repository.dart';
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
  final DriversRepository driversRepository;
  final TrucksRepository trucksRepository;
  final LoadingsRepository loadingsRepository;
  final FactoryPaymentsRepository factoryPaymentsRepository;
  final SitesRepository sitesRepository;
  final SessionController sessionController;

  const AppContainer._({
    required this.config,
    required this.httpClient,
    required this.tokenStorage,
    required this.apiClient,
    required this.authRepository,
    required this.dashboardRepository,
    required this.clientsRepository,
    required this.driversRepository,
    required this.trucksRepository,
    required this.loadingsRepository,
    required this.factoryPaymentsRepository,
    required this.sitesRepository,
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

    final driversRepository = DriversRepositoryImpl(
      config: resolvedConfig,
      remoteDataSource: DriversRemoteDataSource(apiClient),
      mockDataSource: const DriversMockDataSource(),
    );

    final trucksRepository = TrucksRepositoryImpl(
      config: resolvedConfig,
      remoteDataSource: TrucksRemoteDataSource(apiClient),
      mockDataSource: const TrucksMockDataSource(),
    );

    final loadingsRepository = LoadingsRepositoryImpl(
      config: resolvedConfig,
      remoteDataSource: LoadingsRemoteDataSource(apiClient),
      mockDataSource: LoadingsMockDataSource(),
    );

    final factoryPaymentsRepository = FactoryPaymentsRepositoryImpl(
      config: resolvedConfig,
      remoteDataSource: FactoryPaymentsRemoteDataSource(apiClient),
      mockDataSource: FactoryPaymentsMockDataSource(),
    );

    final sitesRepository = SitesRepositoryImpl(
      config: resolvedConfig,
      remoteDataSource: SitesRemoteDataSource(apiClient),
      mockDataSource: SitesMockDataSource(),
    );

    return AppContainer._(
      config: resolvedConfig,
      httpClient: httpClient,
      tokenStorage: tokenStorage,
      apiClient: apiClient,
      authRepository: authRepository,
      dashboardRepository: dashboardRepository,
      clientsRepository: clientsRepository,
      driversRepository: driversRepository,
      trucksRepository: trucksRepository,
      loadingsRepository: loadingsRepository,
      factoryPaymentsRepository: factoryPaymentsRepository,
      sitesRepository: sitesRepository,
      sessionController: SessionController(authRepository),
    );
  }

  String get dataSourceLabel => config.dataSourceLabel;

  void dispose() {
    sessionController.dispose();
    httpClient.close();
  }
}
