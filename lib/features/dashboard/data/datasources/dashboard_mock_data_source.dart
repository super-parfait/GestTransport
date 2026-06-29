import '../../../../core/network/api_service.dart';
import '../models/dashboard_overview.dart';

class DashboardMockDataSource {
  const DashboardMockDataSource();

  Future<DashboardOverview> fetchOverview() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return DashboardOverview.fromJson(AppData.dashboard);
  }
}
