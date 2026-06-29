import 'package:flutter/material.dart';
import '../../../core/layout/app_breakpoints.dart';
import '../../../core/layout/responsive_content.dart';
import '../../../core/network/api_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_widgets.dart';
import '../data/models/truck_model.dart';
import 'truck_detail_screen.dart';
import 'controllers/trucks_controller.dart';

class TrucksScreen extends StatelessWidget {
  final TrucksController controller;

  const TrucksScreen({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final trucks = controller.trucks;

        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          appBar: AppBar(
            title: const Text('Camions'),
            backgroundColor: AppColors.surface,
            actions: [
              IconButton(
                  icon: const Icon(Icons.add_rounded, color: AppColors.primary),
                  onPressed: () {}),
            ],
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final pagePadding = AppBreakpoints.pagePadding(width);

              if (controller.isLoading && trucks.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }

              if (controller.errorMessage != null && trucks.isEmpty) {
                return AppEmptyState(
                  icon: Icons.cloud_off_rounded,
                  title: 'Camions indisponibles',
                  subtitle: controller.errorMessage,
                  actionLabel: 'Réessayer',
                  onAction: controller.load,
                );
              }

              if (trucks.isEmpty) {
                return AppEmptyState(
                  icon: Icons.local_shipping_rounded,
                  title: 'Aucun camion disponible',
                  actionLabel: 'Actualiser',
                  onAction: controller.load,
                );
              }

              return RefreshIndicator(
                color: AppColors.primary,
                onRefresh: controller.load,
                child: ResponsiveContent(
                  child: ListView(
                    padding: EdgeInsets.all(pagePadding),
                    children: [
                      LayoutBuilder(
                        builder: (context, statConstraints) {
                          final tileWidth = AppBreakpoints.statTileWidth(
                            statConstraints.maxWidth,
                            spacing: 10,
                          );

                          return Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              _stat(
                                tileWidth,
                                '${trucks.length}',
                                'Total',
                                AppColors.info,
                                Icons.local_shipping_rounded,
                              ),
                              _stat(
                                tileWidth,
                                '${controller.activeCount}',
                                'En service',
                                AppColors.success,
                                Icons.check_circle_rounded,
                              ),
                              _stat(
                                tileWidth,
                                '${controller.alertsCount}',
                                'Alertes',
                                AppColors.error,
                                Icons.warning_rounded,
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Flotte de camions',
                        style: AppTextStyles.headlineSmall,
                      ),
                      const SizedBox(height: 12),
                      ...trucks.map((truck) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _TruckCard(truck: truck),
                          )),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _stat(
    double width,
    String value,
    String label,
    Color color,
    IconData icon,
  ) {
    return SizedBox(
      width: width,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 6)],
        ),
        child: Row(children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.headlineMedium.copyWith(color: color),
                ),
                Text(label, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

class _TruckCard extends StatelessWidget {
  final TruckModel truck;
  const _TruckCard({required this.truck});

  @override
  Widget build(BuildContext context) {
    final status = truck.status;
    final alerts = truck.alerts;
    final (color, badge) = _statusData(status);

    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) =>
                  TruckDetailScreen(truck: truck.toPresentationMap()))),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: AppColors.shadow,
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
          border: alerts.isNotEmpty
              ? Border.all(
                  color: _alertColor(alerts).withOpacity(0.3), width: 1.5)
              : null,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = AppBreakpoints.isCompact(constraints.maxWidth);

            return Column(children: [
              if (isCompact)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      _buildTruckIcon(color),
                      const SizedBox(width: 12),
                      Expanded(child: _buildIdentity()),
                    ]),
                    const SizedBox(height: 10),
                    AppStatusBadge(
                      label: AppData.truckStatusLabels[status] ?? status,
                      status: badge,
                    ),
                  ],
                )
              else
                Row(children: [
                  _buildTruckIcon(color),
                  const SizedBox(width: 12),
                  Expanded(child: _buildIdentity()),
                  AppStatusBadge(
                    label: AppData.truckStatusLabels[status] ?? status,
                    status: badge,
                  ),
                ]),
              if (alerts.isNotEmpty) ...[
                const SizedBox(height: 10),
                const Divider(color: AppColors.divider),
                const SizedBox(height: 4),
                ...alerts.map((a) => _AlertRow(alert: a)),
              ],
              const SizedBox(height: 8),
              Row(children: [
                const Icon(
                  Icons.speed_rounded,
                  size: 14,
                  color: AppColors.textTertiary,
                ),
                const SizedBox(width: 4),
                Text(_fmtKm(truck.km), style: AppTextStyles.bodySmall),
                const Spacer(),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: AppColors.textTertiary,
                ),
              ]),
            ]);
          },
        ),
      ),
    );
  }

  Widget _buildTruckIcon(Color color) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(Icons.local_shipping_rounded, color: color, size: 26),
    );
  }

  Widget _buildIdentity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          truck.plate,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.headlineSmall.copyWith(letterSpacing: 1.5),
        ),
        const SizedBox(height: 2),
        Row(children: [
          const Icon(
            Icons.person_outline_rounded,
            size: 14,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              truck.driver,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodyMedium,
            ),
          ),
        ]),
      ],
    );
  }

  String _fmtKm(int v) {
    final n = v;
    return '${n.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]} ')} km';
  }

  (Color, BadgeStatus) _statusData(String s) => switch (s) {
        'active' => (AppColors.success, BadgeStatus.success),
        'traveling' => (AppColors.primary, BadgeStatus.success),
        'available' => (AppColors.info, BadgeStatus.info),
        'maintenance' => (AppColors.warning, BadgeStatus.warning),
        'breakdown' => (AppColors.error, BadgeStatus.error),
        _ => (AppColors.textSecondary, BadgeStatus.neutral),
      };

  Color _alertColor(List<String> a) => (a.contains('assurance_expired') ||
          a.contains('visite_expired') ||
          a.contains('breakdown'))
      ? AppColors.error
      : AppColors.warning;
}

class _AlertRow extends StatelessWidget {
  final String alert;
  const _AlertRow({required this.alert});

  static const _msgs = {
    'assurance_expired': ('Assurance expirée', AppColors.error),
    'oil_change_soon': ('Vidange bientôt', AppColors.warning),
    'visite_expired': ('Visite technique expirée', AppColors.error),
    'breakdown': ('Camion en panne', AppColors.error),
  };

  @override
  Widget build(BuildContext context) {
    final d = _msgs[alert];
    if (d == null) return const SizedBox.shrink();
    final (msg, color) = d;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(children: [
        Icon(Icons.warning_rounded, size: 14, color: color),
        const SizedBox(width: 6),
        Text(msg,
            style: AppTextStyles.bodySmall
                .copyWith(color: color, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}
