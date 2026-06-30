import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../core/network/api_service.dart';
import '../../../core/widgets/primary_section_app_bar.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});
  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  int _selectedTab = 0;
  static const _tabs = ['Journalier', 'Hebdo', 'Opérations'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: const PrimarySectionAppBar(sectionTitle: 'Rapports'),
      body: Column(children: [
        // Onglets
        Container(
          color: AppColors.surface,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
              children: List.generate(_tabs.length, (i) {
            final sel = _selectedTab == i;
            return GestureDetector(
              onTap: () => setState(() => _selectedTab = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.only(right: 10),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: sel ? AppColors.primary : AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(_tabs[i],
                    style: AppTextStyles.bodySmall.copyWith(
                      color: sel ? Colors.white : AppColors.textSecondary,
                      fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                    )),
              ),
            );
          })),
        ),
        const Divider(height: 1),
        Expanded(
            child: IndexedStack(index: _selectedTab, children: const [
          _DailyReport(),
          _WeeklyReport(),
          _OperationsLog(),
        ])),
      ]),
    );
  }
}

// ── Rapport journalier ────────────────────────────────────────────────────────
class _DailyReport extends StatelessWidget {
  const _DailyReport();

  @override
  Widget build(BuildContext context) {
    final data = AppData.dashboard;
    final now = DateTime.now();
    const months = [
      'janv',
      'févr',
      'mars',
      'avr',
      'mai',
      'juin',
      'juil',
      'août',
      'sept',
      'oct',
      'nov',
      'déc'
    ];

    return ListView(padding: const EdgeInsets.all(16), children: [
      Row(children: [
        const Icon(Icons.today_rounded, color: AppColors.primary, size: 18),
        const SizedBox(width: 8),
        Text('${now.day} ${months[now.month - 1]}. ${now.year}',
            style: AppTextStyles.titleLarge.copyWith(color: AppColors.primary)),
      ]),
      const SizedBox(height: 16),
      AppSummaryCard(
        title: '📊 Activité du jour',
        color: AppColors.info,
        rows: [
          AppSummaryRow(
              label: 'Chargements effectués',
              value: '${data['daily_loadings']} opérations',
              valueColor: AppColors.info),
          AppSummaryRow(
              label: 'Clients débiteurs',
              value: '${data['debtor_clients']} clients',
              valueColor: AppColors.warning),
          AppSummaryRow(
              label: 'Camions en alerte',
              value: '${data['alert_trucks']} camions',
              valueColor: AppColors.error),
          AppSummaryRow(
              label: 'Documents expirés',
              value: '${data['expired_docs']} documents',
              valueColor: AppColors.error),
        ],
      ),
      const SizedBox(height: 14),
      AppSummaryCard(
        title: '💰 Bilan financier',
        color: AppColors.success,
        rows: [
          AppSummaryRow(
              label: 'Recettes du jour',
              value: '${data['daily_revenues']} F',
              valueColor: AppColors.success,
              isBold: true),
          AppSummaryRow(
              label: 'Versements usine',
              value: '- ${data['factory_payments']} F',
              valueColor: AppColors.error),
          AppSummaryRow(
              label: 'Dépenses',
              value: '- ${data['daily_expenses']} F',
              valueColor: AppColors.error),
          AppSummaryRow(
              label: 'Règlements reçus',
              value: '+ ${data['client_payments']} F',
              valueColor: AppColors.success),
          const AppSummaryRow(label: '──────────────────', value: ''),
          AppSummaryRow(
              label: 'Solde net estimé',
              value: '250 000 F',
              valueColor: AppColors.primary,
              isBold: true),
        ],
      ),
      const SizedBox(height: 14),
      AppButton(
          label: 'Exporter PDF',
          icon: Icons.picture_as_pdf_rounded,
          variant: AppButtonVariant.outlined,
          onPressed: () {}),
    ]);
  }
}

// ── Rapport hebdomadaire ──────────────────────────────────────────────────────
class _WeeklyReport extends StatelessWidget {
  const _WeeklyReport();

  @override
  Widget build(BuildContext context) {
    final w = AppData.weeklyStats;
    final byType = w['by_type'] as Map<String, dynamic>;
    final total = byType.values.fold<int>(0, (s, v) => s + (v as int));

    return ListView(padding: const EdgeInsets.all(16), children: [
      AppSummaryCard(
        title: '📈 Activité hebdomadaire',
        color: AppColors.info,
        rows: [
          AppSummaryRow(
              label: 'Total chargements',
              value: '${w['total_loadings']} op.',
              valueColor: AppColors.info,
              isBold: true),
          ...byType.entries.map((e) => AppSummaryRow(
                label: '  • ${e.key}',
                value:
                    '${e.value} (${((e.value as int) / total * 100).toStringAsFixed(0)}%)',
                valueColor: AppColors.textSecondary,
              )),
        ],
      ),
      const SizedBox(height: 14),
      AppSummaryCard(
        title: '💰 Bilan hebdomadaire',
        color: AppColors.success,
        rows: [
          AppSummaryRow(
              label: 'Total recettes',
              value: '${w['total_revenues']} F',
              valueColor: AppColors.success,
              isBold: true),
          AppSummaryRow(
              label: 'Versements usine',
              value: '- ${w['total_factory']} F',
              valueColor: AppColors.error),
          AppSummaryRow(
              label: 'Dépenses totales',
              value: '- ${w['total_expenses']} F',
              valueColor: AppColors.error),
          AppSummaryRow(
              label: 'Règlements clients',
              value: '+ ${w['total_client_payments']} F',
              valueColor: AppColors.success),
          const AppSummaryRow(label: '──────────────────', value: ''),
          AppSummaryRow(
              label: 'Solde net semaine',
              value: '${w['net_balance']} F',
              valueColor: AppColors.primary,
              isBold: true),
        ],
      ),
      const SizedBox(height: 14),
      // Graphe simple par type
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 6)],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Répartition par type', style: AppTextStyles.headlineSmall),
          const SizedBox(height: 14),
          ...byType.entries.map((e) {
            final pct = (e.value as int) / total;
            final color = e.key == 'Sable'
                ? AppColors.warning
                : e.key == 'Gravier'
                    ? AppColors.info
                    : AppColors.primary;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(e.key,
                              style: AppTextStyles.bodyMedium
                                  .copyWith(fontWeight: FontWeight.w500)),
                          Text(
                              '${e.value} (${(pct * 100).toStringAsFixed(0)}%)',
                              style: AppTextStyles.bodySmall),
                        ]),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: pct,
                        minHeight: 8,
                        backgroundColor: color.withOpacity(0.15),
                        valueColor: AlwaysStoppedAnimation(color),
                      ),
                    ),
                  ]),
            );
          }),
        ]),
      ),
      const SizedBox(height: 14),
      AppButton(
          label: 'Exporter PDF',
          icon: Icons.picture_as_pdf_rounded,
          variant: AppButtonVariant.outlined,
          onPressed: () {}),
    ]);
  }
}

// ── Journal des opérations ────────────────────────────────────────────────────
class _OperationsLog extends StatelessWidget {
  const _OperationsLog();

  @override
  Widget build(BuildContext context) {
    final ops = AppData.recentOperations;
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: ops.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final op = ops[i];
        final color = switch (op['color']) {
          'success' => AppColors.success,
          'error' => AppColors.error,
          'warning' => AppColors.warning,
          _ => AppColors.info,
        };
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 6)],
          ),
          child: Row(children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10)),
              child: Center(
                  child: Text(_typeIcon(op['type']),
                      style: const TextStyle(fontSize: 18))),
            ),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Row(children: [
                    AppStatusBadge(
                        label: op['type'],
                        status: _badgeStatus(op['color']),
                        small: true),
                    const Spacer(),
                    Text(op['date'], style: AppTextStyles.bodySmall),
                  ]),
                  const SizedBox(height: 4),
                  Text(op['description'],
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.textPrimary)),
                ])),
            const SizedBox(width: 10),
            Text(op['montant'],
                style: AppTextStyles.titleMedium.copyWith(
                  color: (op['montant'] as String).startsWith('+')
                      ? AppColors.success
                      : AppColors.error,
                )),
          ]),
        );
      },
    );
  }

  String _typeIcon(String type) => switch (type) {
        'Chargement' => '📦',
        'Règlement' => '💳',
        'Dépense' => '🔧',
        'Versement' => '🏭',
        'Entretien' => '⚙️',
        'Recette' => '💰',
        _ => '📋',
      };

  BadgeStatus _badgeStatus(String color) => switch (color) {
        'success' => BadgeStatus.success,
        'error' => BadgeStatus.error,
        'warning' => BadgeStatus.warning,
        _ => BadgeStatus.info,
      };
}
