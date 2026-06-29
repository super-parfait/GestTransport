import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_widgets.dart';

class TruckDocumentsScreen extends StatelessWidget {
  final Map<String, dynamic> truck;
  const TruckDocumentsScreen({super.key, required this.truck});

  @override
  Widget build(BuildContext context) {
    final docs = [
      _Doc('Assurance', Icons.security_rounded, truck['assurance_expiry'] as String),
      _Doc('Visite technique', Icons.fact_check_rounded, truck['visite_expiry'] as String),
      _Doc('Patente', Icons.receipt_long_rounded, truck['patente_expiry'] as String),
    ];

    return ListView(padding: const EdgeInsets.all(16), children: [
      Text('Documents du ${truck['plate']}', style: AppTextStyles.headlineSmall),
      const SizedBox(height: 12),
      ...docs.map((d) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _DocCard(doc: d),
      )),
      const SizedBox(height: 8),
      AppButton(label: 'Renouveler un document', icon: Icons.upload_file_rounded, onPressed: () {}),
    ]);
  }
}

class _DocCard extends StatelessWidget {
  final _Doc doc;
  const _DocCard({required this.doc});

  @override
  Widget build(BuildContext context) {
    final status = _computeStatus(doc.expiry);
    final (color, label, badgeStatus) = switch (status) {
      'expired' => (AppColors.error, 'Expiré', BadgeStatus.error),
      'soon' => (AppColors.warning, 'Expire bientôt', BadgeStatus.warning),
      _ => (AppColors.success, 'Valide', BadgeStatus.success),
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.25), width: 1.5),
        boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 6)],
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
          child: Icon(doc.icon, color: color, size: 24),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(doc.title, style: AppTextStyles.titleLarge),
          const SizedBox(height: 4),
          Row(children: [
            const Icon(Icons.calendar_today_rounded, size: 13, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Text('Expire le ${doc.expiry}', style: AppTextStyles.bodySmall),
          ]),
        ])),
        AppStatusBadge(label: label, status: badgeStatus),
      ]),
    );
  }

  String _computeStatus(String expiry) {
    try {
      final parts = expiry.split('/');
      final date = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
      final now = DateTime.now();
      if (date.isBefore(now)) return 'expired';
      if (date.difference(now).inDays < 30) return 'soon';
      return 'valid';
    } catch (_) { return 'valid'; }
  }
}

class _Doc {
  final String title, expiry;
  final IconData icon;
  _Doc(this.title, this.icon, this.expiry);
}
