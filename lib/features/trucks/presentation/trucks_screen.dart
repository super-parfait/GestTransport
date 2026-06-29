import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../core/network/api_service.dart';
import 'truck_detail_screen.dart';

class TrucksScreen extends StatelessWidget {
  const TrucksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final trucks = AppData.trucks;
    final active = trucks.where((t) => t['status'] == 'active' || t['status'] == 'traveling').length;
    final alerts = trucks.where((t) => (t['alerts'] as List).isNotEmpty).length;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Camions'),
        backgroundColor: AppColors.surface,
        actions: [
          IconButton(icon: const Icon(Icons.add_rounded, color: AppColors.primary), onPressed: () {}),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(children: [
            _stat('${trucks.length}', 'Total', AppColors.info, Icons.local_shipping_rounded),
            const SizedBox(width: 10),
            _stat('$active', 'En service', AppColors.success, Icons.check_circle_rounded),
            const SizedBox(width: 10),
            _stat('$alerts', 'Alertes', AppColors.error, Icons.warning_rounded),
          ]),
          const SizedBox(height: 16),
          Text('Flotte de camions', style: AppTextStyles.headlineSmall),
          const SizedBox(height: 12),
          ...trucks.map((t) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _TruckCard(truck: t),
          )),
        ],
      ),
    );
  }

  Widget _stat(String value, String label, Color color, IconData icon) {
    return Expanded(
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
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(value, style: AppTextStyles.headlineMedium.copyWith(color: color)),
            Text(label, style: AppTextStyles.bodySmall),
          ]),
        ]),
      ),
    );
  }
}

class _TruckCard extends StatelessWidget {
  final Map<String, dynamic> truck;
  const _TruckCard({required this.truck});

  @override
  Widget build(BuildContext context) {
    final status = truck['status'] as String;
    final alerts = truck['alerts'] as List;
    final (color, badge) = _statusData(status);

    return GestureDetector(
      onTap: () => Navigator.push(context,
        MaterialPageRoute(builder: (_) => TruckDetailScreen(truck: truck))),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: const Offset(0, 2))],
          border: alerts.isNotEmpty
              ? Border.all(color: _alertColor(alerts).withOpacity(0.3), width: 1.5) : null,
        ),
        child: Column(children: [
          Row(children: [
            Container(
              width: 50, height: 50,
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(Icons.local_shipping_rounded, color: color, size: 26),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(truck['plate'], style: AppTextStyles.headlineSmall.copyWith(letterSpacing: 1.5)),
              const SizedBox(height: 2),
              Row(children: [
                const Icon(Icons.person_outline_rounded, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(truck['driver'], style: AppTextStyles.bodyMedium),
              ]),
            ])),
            AppStatusBadge(label: AppData.truckStatusLabels[status] ?? status, status: badge),
          ]),
          if (alerts.isNotEmpty) ...[
            const SizedBox(height: 10),
            const Divider(color: AppColors.divider),
            const SizedBox(height: 4),
            ...alerts.map((a) => _AlertRow(alert: a as String)),
          ],
          const SizedBox(height: 8),
          Row(children: [
            const Icon(Icons.speed_rounded, size: 14, color: AppColors.textTertiary),
            const SizedBox(width: 4),
            Text(_fmtKm(truck['km']), style: AppTextStyles.bodySmall),
            const Spacer(),
            const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textTertiary),
          ]),
        ]),
      ),
    );
  }

  String _fmtKm(dynamic v) {
    final n = v is int ? v : (v as double).toInt();
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

  Color _alertColor(List a) => (a.contains('assurance_expired') || a.contains('visite_expired') || a.contains('breakdown'))
      ? AppColors.error : AppColors.warning;
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
        Text(msg, style: AppTextStyles.bodySmall.copyWith(color: color, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}
