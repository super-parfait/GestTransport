import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../core/constants/app_constants.dart';
import '../core/widgets/app_widgets.dart';
import 'dashboard/presentation/dashboard_screen.dart';
import 'trucks/presentation/trucks_screen.dart';
import 'clients/presentation/clients_screen.dart';
import 'reports/presentation/reports_screen.dart';
import 'operations_screen.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  final List<_NavItem> _navItems = [
    _NavItem(AppStrings.home, Icons.home_rounded, Icons.home_outlined),
    _NavItem(AppStrings.operations, Icons.receipt_long_rounded, Icons.receipt_long_outlined),
    _NavItem(AppStrings.trucks, Icons.local_shipping_rounded, Icons.local_shipping_outlined),
    _NavItem(AppStrings.clients, Icons.people_rounded, Icons.people_outlined),
    _NavItem(AppStrings.reports, Icons.bar_chart_rounded, Icons.bar_chart_outlined),
  ];

  final List<Widget> _screens = [
    const DashboardScreen(),
    const OperationsScreen(),
    const TrucksScreen(),
    const ClientsScreen(),
    const ReportsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [BoxShadow(color: AppColors.shadowMedium, blurRadius: 16, offset: const Offset(0, -4))],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_navItems.length, (i) {
                final item = _navItems[i];
                final isSelected = _currentIndex == i;
                return GestureDetector(
                  onTap: () => setState(() => _currentIndex = i),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primarySurface : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isSelected ? item.activeIcon : item.icon,
                          color: isSelected ? AppColors.primary : AppColors.textTertiary,
                          size: 24,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          item.label,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: isSelected ? AppColors.primary : AppColors.textTertiary,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final String label;
  final IconData activeIcon;
  final IconData icon;
  _NavItem(this.label, this.activeIcon, this.icon);
}
