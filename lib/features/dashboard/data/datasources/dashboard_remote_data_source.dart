import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/dashboard_overview.dart';

class DashboardRemoteDataSource {
  final ApiClient _apiClient;

  const DashboardRemoteDataSource(this._apiClient);

  Future<DashboardOverview> fetchOverview() {
    return _apiClient.get(
      ApiEndpoints.dashboardOverview,
      decoder: (data) =>
          DashboardOverview.fromJson(data as Map<String, dynamic>),
    );
  }
}
