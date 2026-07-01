import 'package:flutter/material.dart';
import '../core/di/app_container.dart';
import '../core/layout/app_breakpoints.dart';
import '../core/layout/responsive_content.dart';
import '../core/theme/app_theme.dart';
import '../core/constants/app_constants.dart';
import 'clients/presentation/controllers/clients_controller.dart';
import 'dashboard/presentation/dashboard_screen.dart';
import 'dashboard/presentation/controllers/dashboard_controller.dart';
import 'trucks/presentation/trucks_screen.dart';
import 'trucks/presentation/controllers/trucks_controller.dart';
import 'clients/presentation/clients_screen.dart';
import 'reports/presentation/reports_screen.dart';
import 'operations_screen.dart';

class MainScaffold extends StatefulWidget {
  final AppContainer container;

  const MainScaffold({
    super.key,
    required this.container,
  });

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;
  late final DashboardController _dashboardController;
  late final TrucksController _trucksController;
  late final ClientsController _clientsController;

  final List<_NavItem> _navItems = [
    _NavItem(AppStrings.home, Icons.home_rounded, Icons.home_outlined),
    _NavItem(AppStrings.operations, Icons.receipt_long_rounded,
        Icons.receipt_long_outlined),
    _NavItem(AppStrings.trucks, Icons.local_shipping_rounded,
        Icons.local_shipping_outlined),
    _NavItem(AppStrings.clients, Icons.people_rounded, Icons.people_outlined),
    _NavItem(
        AppStrings.reports, Icons.bar_chart_rounded, Icons.bar_chart_outlined),
  ];

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _dashboardController = DashboardController(
      widget.container.dashboardRepository,
    )..load();
    _trucksController = TrucksController(
      widget.container.trucksRepository,
    )..load();
    _clientsController = ClientsController(
      widget.container.clientsRepository,
    )..load();

    _screens = [
      DashboardScreen(
        controller: _dashboardController,
        dataSourceLabel: widget.container.dataSourceLabel,
        loadingsRepository: widget.container.loadingsRepository,
        clientsRepository: widget.container.clientsRepository,
        driversRepository: widget.container.driversRepository,
        trucksRepository: widget.container.trucksRepository,
        factoryPaymentsRepository: widget.container.factoryPaymentsRepository,
        sitesRepository: widget.container.sitesRepository,
        userSession: widget.container.sessionController.session,
        onLogout: () => widget.container.sessionController.logout(),
      ),
      OperationsScreen(container: widget.container),
      TrucksScreen(
        controller: _trucksController,
        driversRepository: widget.container.driversRepository,
      ),
      ClientsScreen(
        controller: _clientsController,
        clientsRepository: widget.container.clientsRepository,
        driversRepository: widget.container.driversRepository,
        trucksRepository: widget.container.trucksRepository,
        sitesRepository: widget.container.sitesRepository,
        loadingsRepository: widget.container.loadingsRepository,
      ),
      const ReportsScreen(),
    ];
  }

  @override
  void dispose() {
    _dashboardController.dispose();
    _trucksController.dispose();
    _clientsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isCondensed = AppBreakpoints.useCondensedNavigation(width);
        final navPadding = AppBreakpoints.isCompact(width) ? 4.0 : 8.0;

        return Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowMedium,
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                ),
              ],
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: SafeArea(
              top: false,
              child: ResponsiveContent(
                maxWidth: AppBreakpoints.contentMaxWidth(width),
                shrinkWrapHeight: true,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: navPadding,
                    vertical: navPadding,
                  ),
                  child: Row(
                    children: List.generate(_navItems.length, (i) {
                      final item = _navItems[i];
                      final isSelected = _currentIndex == i;

                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: isCondensed ? 2 : 4,
                          ),
                          child: Tooltip(
                            message: item.label,
                            child: GestureDetector(
                              onTap: () => setState(() => _currentIndex = i),
                              behavior: HitTestBehavior.opaque,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: EdgeInsets.symmetric(
                                  horizontal: isCondensed ? 8 : 10,
                                  vertical: isCondensed ? 10 : 8,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primarySurface
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isSelected ? item.activeIcon : item.icon,
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.textTertiary,
                                      size: 24,
                                    ),
                                    if (!isCondensed || isSelected) ...[
                                      const SizedBox(height: 3),
                                      Text(
                                        item.label,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: isSelected
                                              ? AppColors.primary
                                              : AppColors.textTertiary,
                                          fontWeight: isSelected
                                              ? FontWeight.w600
                                              : FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _NavItem {
  final String label;
  final IconData activeIcon;
  final IconData icon;
  _NavItem(this.label, this.activeIcon, this.icon);
}
