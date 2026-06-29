import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../core/network/api_service.dart';
import '../../client_payments/presentation/client_payment_screen.dart';
import '../../loadings/presentation/loading_screen.dart';

class ClientDetailScreen extends StatefulWidget {
  final Map<String, dynamic> client;
  const ClientDetailScreen({super.key, required this.client});

  @override
  State<ClientDetailScreen> createState() => _ClientDetailScreenState();
}

class _ClientDetailScreenState extends State<ClientDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  static const _tabs = ['Résumé', 'Chargements', 'Paiements'];

  @override
  void initState() { super.initState(); _tabController = TabController(length: _tabs.length, vsync: this); }
  @override
  void dispose() { _tabController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final c = widget.client;
    final balance = c['balance'] as double;
    final balColor = balance == 0 ? AppColors.success : balance > 3000000 ? AppColors.error : AppColors.warning;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: AppColors.primary,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [AppColors.primaryDark, AppColors.primary],
                    begin: Alignment.topLeft, end: Alignment.bottomRight),
                ),
                child: SafeArea(child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 46, 16, 0),
                  child: Row(children: [
                    Container(
                      width: 56, height: 56,
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                      child: Center(child: Text(
                        (c['name'] as String)[0].toUpperCase(),
                        style: AppTextStyles.headlineLarge.copyWith(color: Colors.white),
                      )),
                    ),
                    const SizedBox(width: 14),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(c['name'], style: AppTextStyles.headlineMedium.copyWith(color: Colors.white)),
                      const SizedBox(height: 4),
                      Text(c['phone'], style: AppTextStyles.bodyMedium.copyWith(color: Colors.white.withOpacity(0.8))),
                      Text(c['address'], style: AppTextStyles.bodySmall.copyWith(color: Colors.white.withOpacity(0.7))),
                    ])),
                    Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Text(AppData.fmtMoneyFull(balance),
                        style: AppTextStyles.headlineSmall.copyWith(color: Colors.white)),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: balColor, borderRadius: BorderRadius.circular(8)),
                        child: Text(balance == 0 ? 'À jour' : 'Débiteur',
                          style: AppTextStyles.bodySmall.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
                      ),
                    ]),
                  ]),
                )),
              ),
            ),
            bottom: TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white.withOpacity(0.5),
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              tabs: _tabs.map((t) => Tab(text: t)).toList(),
            ),
          ),
        ],
        body: TabBarView(controller: _tabController, children: [
          _SummaryTab(client: c),
          _LoadingsTab(loadings: c['loadings'] as List),
          _PaymentsTab(payments: c['payments'] as List),
        ]),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            Expanded(child: AppButton(
              label: 'Nouveau chargement',
              icon: Icons.add_box_rounded,
              variant: AppButtonVariant.outlined,
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ClientLoadingScreen())),
            )),
            const SizedBox(width: 10),
            Expanded(child: AppButton(
              label: 'Enregistrer paiement',
              icon: Icons.payments_rounded,
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ClientPaymentScreen(prefilledClient: c['name']))),
            )),
          ]),
        ),
      ),
    );
  }
}

class _SummaryTab extends StatelessWidget {
  final Map<String, dynamic> client;
  const _SummaryTab({required this.client});

  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.all(16), children: [
      AppSectionCard(title: 'Informations', icon: Icons.person_outline_rounded, children: [
        _row('Nom', client['name']),
        _row('Téléphone', client['phone']),
        _row('Adresse', client['address']),
      ]),
      const SizedBox(height: 14),
      AppSummaryCard(
        title: '📊 Compte client',
        color: AppColors.primary,
        rows: [
          AppSummaryRow(label: 'Total facturé', value: AppData.fmtMoneyFull(client['total_credit']), valueColor: AppColors.info),
          AppSummaryRow(label: 'Total réglé', value: AppData.fmtMoneyFull(client['total_paid']), valueColor: AppColors.success),
          const AppSummaryRow(label: '──────────────', value: ''),
          AppSummaryRow(
            label: 'Solde restant',
            value: AppData.fmtMoneyFull(client['balance']),
            valueColor: (client['balance'] as double) == 0 ? AppColors.success : AppColors.error,
            isBold: true,
          ),
        ],
      ),
    ]);
  }

  Widget _row(String l, String v) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(l, style: AppTextStyles.bodyMedium),
      Flexible(child: Text(v, style: AppTextStyles.titleMedium, textAlign: TextAlign.right)),
    ]),
  );
}

class _LoadingsTab extends StatelessWidget {
  final List loadings;
  const _LoadingsTab({required this.loadings});

  @override
  Widget build(BuildContext context) {
    if (loadings.isEmpty) return const AppEmptyState(icon: Icons.inventory_2_rounded, title: 'Aucun chargement');
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: loadings.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final l = loadings[i] as Map<String, dynamic>;
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 6)]),
          child: Row(children: [
            Container(padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: AppColors.infoSurface, borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.inventory_2_rounded, color: AppColors.info, size: 18)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(l['camion'], style: AppTextStyles.titleLarge),
              Text('${l['type']} · ${l['quantity']}', style: AppTextStyles.bodySmall),
              Text(l['date'], style: AppTextStyles.bodySmall),
            ])),
            Text(AppData.fmtMoneyFull((l['montant'] as num).toDouble()),
              style: AppTextStyles.titleMedium.copyWith(color: AppColors.info)),
          ]),
        );
      },
    );
  }
}

class _PaymentsTab extends StatelessWidget {
  final List payments;
  const _PaymentsTab({required this.payments});

  @override
  Widget build(BuildContext context) {
    if (payments.isEmpty) return const AppEmptyState(icon: Icons.payments_rounded, title: 'Aucun paiement');
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: payments.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final p = payments[i] as Map<String, dynamic>;
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 6)]),
          child: Row(children: [
            Container(padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: AppColors.successSurface, borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.payments_rounded, color: AppColors.success, size: 18)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(p['mode'], style: AppTextStyles.titleLarge),
              Text(p['date'], style: AppTextStyles.bodySmall),
            ])),
            Text(AppData.fmtMoneyFull((p['montant'] as num).toDouble()),
              style: AppTextStyles.titleMedium.copyWith(color: AppColors.success)),
          ]),
        );
      },
    );
  }
}
