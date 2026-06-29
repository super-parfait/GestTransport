import '../../data/models/dashboard_overview.dart';

abstract class DashboardRepository {
  Future<DashboardOverview> fetchOverview();
}
