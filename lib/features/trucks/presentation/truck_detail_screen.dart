import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../core/network/api_service.dart';
import 'oil_change_screen.dart';
import 'truck_documents_screen.dart';

class TruckDetailScreen extends StatefulWidget {
  final Map<String, dynamic> truck;
  const TruckDetailScreen({super.key, required this.truck});

  @override
  State<TruckDetailScreen> createState() => _TruckDetailScreenState();
}

class _TruckDetailScreenState extends State<TruckDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  static const _tabs = [
    'Résumé',
    'Chargements',
    'Dépenses',
    'Entretiens',
    'Vidanges',
    'Documents',
    'Recettes'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final truck = widget.truck;
    final alerts = truck['alerts'] as List;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            expandedHeight: 170,
            pinned: true,
            backgroundColor: AppColors.primary,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primaryDark, AppColors.primary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                    child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 48, 16, 0),
                  child: Row(children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.local_shipping_rounded,
                          color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text(truck['plate'],
                              style: AppTextStyles.headlineLarge.copyWith(
                                  color: Colors.white, letterSpacing: 2)),
                          Text(truck['driver'],
                              style: AppTextStyles.bodyMedium.copyWith(
                                  color: Colors.white.withOpacity(0.8))),
                          const SizedBox(height: 2),
                          Text(truck['phone'],
                              style: AppTextStyles.bodySmall.copyWith(
                                  color: Colors.white.withOpacity(0.7))),
                        ])),
                    if (alerts.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: BorderRadius.circular(10)),
                        child: Row(children: [
                          const Icon(Icons.warning_rounded,
                              color: Colors.white, size: 14),
                          const SizedBox(width: 4),
                          Text('${alerts.length} alerte(s)',
                              style: AppTextStyles.bodySmall.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600)),
                        ]),
                      ),
                  ]),
                )),
              ),
            ),
            bottom: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white.withOpacity(0.5),
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              labelStyle: AppTextStyles.titleMedium,
              tabs: _tabs.map((t) => Tab(text: t)).toList(),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _SummaryTab(truck: truck),
            _LoadingsTab(loadings: truck['loadings'] as List),
            _ExpensesTab(expenses: truck['expenses'] as List),
            _MaintenanceTab(maintenances: truck['maintenances'] as List),
            OilChangeScreen(
                truckPlate: truck['plate'],
                oilChanges: truck['oil_changes'] as List),
            TruckDocumentsScreen(truck: truck),
            _RevenuesTab(revenues: truck['revenues'] as List),
          ],
        ),
      ),
    );
  }
}

// ── Résumé ────────────────────────────────────────────────────────────────────
class _SummaryTab extends StatelessWidget {
  final Map<String, dynamic> truck;
  const _SummaryTab({required this.truck});

  @override
  Widget build(BuildContext context) {
    final alerts = truck['alerts'] as List;
    final statusLabel =
        AppData.truckStatusLabels[truck['status']] ?? truck['status'];
    final km = truck['km'] as int;
    final fmtKm = km.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]} ');

    // Calculer totaux depuis les données
    final revenues = (truck['revenues'] as List).fold<double>(0, (s, r) {
      final v = (r['montant'] as String).replaceAll(RegExp(r'[^0-9]'), '');
      return s + (double.tryParse(v) ?? 0);
    });
    final expenses = (truck['expenses'] as List).fold<double>(0, (s, e) {
      return s + ((e['montant'] as num? ?? 0).toDouble());
    });

    return ListView(padding: const EdgeInsets.all(16), children: [
      AppSectionCard(
          title: 'Informations camion',
          icon: Icons.info_outline_rounded,
          children: [
            _row('Immatriculation', truck['plate']),
            _row('Chauffeur', truck['driver']),
            _row('Téléphone', truck['phone']),
            _row('Kilométrage', '$fmtKm km'),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Statut', style: AppTextStyles.bodyMedium),
              AppStatusBadge(
                label: statusLabel,
                status: _statusBadge(truck['status']),
              ),
            ]),
          ]),
      const SizedBox(height: 14),
      AppSectionCard(
          title: 'Documents',
          icon: Icons.description_outlined,
          children: [
            _row('Assurance', truck['assurance_expiry']),
            _row('Visite technique', truck['visite_expiry']),
            _row('Patente', truck['patente_expiry']),
          ]),
      const SizedBox(height: 14),
      AppSummaryCard(
        title: '💰 Performance financière',
        color: AppColors.success,
        rows: [
          AppSummaryRow(
              label: 'Total recettes',
              value: AppData.fmtMoneyFull(revenues),
              valueColor: AppColors.success),
          AppSummaryRow(
              label: 'Total dépenses',
              value: AppData.fmtMoneyFull(expenses),
              valueColor: AppColors.error),
          AppSummaryRow(
              label: 'Bilan estimé',
              value: AppData.fmtMoneyFull(revenues - expenses),
              valueColor: AppColors.primary,
              isBold: true),
        ],
      ),
      if (alerts.isNotEmpty) ...[
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.errorSurface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.error.withOpacity(0.3)),
          ),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Icon(Icons.warning_rounded,
                  color: AppColors.error, size: 18),
              const SizedBox(width: 8),
              Text('Alertes actives',
                  style: AppTextStyles.titleLarge
                      .copyWith(color: AppColors.error)),
            ]),
            const SizedBox(height: 8),
            ...alerts.map((a) => Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(children: [
                    const Icon(Icons.circle, size: 6, color: AppColors.error),
                    const SizedBox(width: 8),
                    Text(_alertLabel(a.toString()),
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: AppColors.error)),
                  ]),
                )),
          ]),
        ),
      ],
    ]);
  }

  Widget _row(String l, String v) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(l, style: AppTextStyles.bodyMedium),
          Text(v, style: AppTextStyles.titleMedium),
        ]),
      );

  BadgeStatus _statusBadge(String s) => switch (s) {
        'active' || 'traveling' => BadgeStatus.success,
        'available' => BadgeStatus.info,
        'maintenance' => BadgeStatus.warning,
        _ => BadgeStatus.error,
      };

  String _alertLabel(String a) => switch (a) {
        'assurance_expired' => 'Assurance expirée',
        'oil_change_soon' => 'Vidange à faire bientôt',
        'visite_expired' => 'Visite technique expirée',
        'breakdown' => 'Camion en panne',
        _ => a,
      };
}

// ── Chargements ───────────────────────────────────────────────────────────────
class _LoadingsTab extends StatelessWidget {
  final List loadings;
  const _LoadingsTab({required this.loadings});

  @override
  Widget build(BuildContext context) {
    if (loadings.isEmpty) {
      return const AppEmptyState(
          icon: Icons.inventory_2_rounded,
          title: 'Aucun chargement',
          subtitle: 'Les chargements de ce camion apparaîtront ici.');
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: loadings.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final l = loadings[i] as Map<String, dynamic>;
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 6)],
          ),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: AppColors.infoSurface,
                  borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.inventory_2_rounded,
                  color: AppColors.info, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(l['client'], style: AppTextStyles.titleLarge),
                  Row(children: [
                    Text(l['type'],
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.info)),
                    const Text(' · ',
                        style: TextStyle(color: AppColors.textTertiary)),
                    Text(l['quantity'], style: AppTextStyles.bodySmall),
                  ]),
                  Text(l['date'], style: AppTextStyles.bodySmall),
                ])),
            Text(l['montant'],
                style: AppTextStyles.titleMedium
                    .copyWith(color: AppColors.success)),
          ]),
        );
      },
    );
  }
}

// ── Dépenses ──────────────────────────────────────────────────────────────────
class _ExpensesTab extends StatelessWidget {
  final List expenses;
  const _ExpensesTab({required this.expenses});

  @override
  Widget build(BuildContext context) {
    if (expenses.isEmpty) {
      return const AppEmptyState(
          icon: Icons.receipt_rounded,
          title: 'Aucune dépense',
          subtitle: 'Les dépenses de ce camion apparaîtront ici.');
    }
    final total = expenses.fold<double>(
        0, (s, e) => s + ((e['montant'] as num? ?? 0).toDouble()));
    return ListView(padding: const EdgeInsets.all(16), children: [
      Container(
        padding: const EdgeInsets.all(14),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.errorSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.error.withOpacity(0.2)),
        ),
        child: Row(children: [
          const Icon(Icons.trending_down_rounded,
              color: AppColors.error, size: 22),
          const SizedBox(width: 10),
          Text('Total dépenses', style: AppTextStyles.titleLarge),
          const Spacer(),
          Text(AppData.fmtMoneyFull(total),
              style:
                  AppTextStyles.headlineSmall.copyWith(color: AppColors.error)),
        ]),
      ),
      ...expenses.map((e) {
        final exp = e as Map<String, dynamic>;
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 6)],
          ),
          child: Row(children: [
            const Icon(Icons.receipt_rounded,
                color: AppColors.textSecondary, size: 20),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(exp['type'], style: AppTextStyles.titleLarge),
                  Text(exp['date'], style: AppTextStyles.bodySmall),
                ])),
            Text('${exp['montant']} F',
                style:
                    AppTextStyles.titleMedium.copyWith(color: AppColors.error)),
          ]),
        );
      }),
    ]);
  }
}

// ── Entretiens ────────────────────────────────────────────────────────────────
class _MaintenanceTab extends StatelessWidget {
  final List maintenances;
  const _MaintenanceTab({required this.maintenances});

  @override
  Widget build(BuildContext context) {
    if (maintenances.isEmpty) {
      return const AppEmptyState(
          icon: Icons.build_rounded,
          title: 'Aucun entretien',
          subtitle: 'Les entretiens de ce camion apparaîtront ici.');
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: maintenances.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final m = maintenances[i] as Map<String, dynamic>;
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 6)],
          ),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: AppColors.warningSurface,
                  borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.build_rounded,
                  color: AppColors.warning, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(m['type'], style: AppTextStyles.titleLarge),
                  Text(m['garage'], style: AppTextStyles.bodySmall),
                  Text(m['date'], style: AppTextStyles.bodySmall),
                ])),
            Text('${m['montant']} F',
                style: AppTextStyles.titleMedium
                    .copyWith(color: AppColors.warning)),
          ]),
        );
      },
    );
  }
}

// ── Recettes ──────────────────────────────────────────────────────────────────
class _RevenuesTab extends StatelessWidget {
  final List revenues;
  const _RevenuesTab({required this.revenues});

  @override
  Widget build(BuildContext context) {
    if (revenues.isEmpty) {
      return const AppEmptyState(
          icon: Icons.add_card_rounded,
          title: 'Aucune recette',
          subtitle: 'Les recettes de ce camion apparaîtront ici.');
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: revenues.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final r = revenues[i] as Map<String, dynamic>;
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 6)],
          ),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: AppColors.successSurface,
                  borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.add_card_rounded,
                  color: AppColors.success, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(r['client'], style: AppTextStyles.titleLarge),
                  Text('${r['voyages']} voyage(s)',
                      style: AppTextStyles.bodySmall),
                  Text(r['date'], style: AppTextStyles.bodySmall),
                ])),
            Text(r['montant'],
                style: AppTextStyles.titleMedium
                    .copyWith(color: AppColors.success)),
          ]),
        );
      },
    );
  }
}
