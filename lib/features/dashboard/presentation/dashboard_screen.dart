import 'package:flutter/material.dart';
import '../../../core/layout/app_breakpoints.dart';
import '../../../core/network/api_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../core/widgets/primary_section_app_bar.dart';
import 'controllers/dashboard_controller.dart';
import '../../charges/presentation/charges_screen.dart';
import '../../client_payments/presentation/client_payment_screen.dart';
import '../../loadings/presentation/loading_screen.dart';
import '../../revenues/presentation/revenue_screen.dart';
import '../../trucks/presentation/oil_change_screen.dart';

class DashboardScreen extends StatefulWidget {
  final DashboardController controller;
  final String dataSourceLabel;
  final VoidCallback? onLogout;

  const DashboardScreen({
    super.key,
    required this.controller,
    required this.dataSourceLabel,
    this.onLogout,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChange);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted &&
          widget.controller.overview == null &&
          !widget.controller.isLoading) {
        widget.controller.load();
      }
    });
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChange);
    super.dispose();
  }

  void _onControllerChange() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final overview = controller.overview;
    final data = overview?.toMap();
    final alerts = data?['alerts'] as List? ?? const [];

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: PrimarySectionAppBar(
        sectionTitle: 'Tableau de bord',
        actions: [
          IconButton(
              icon:
                  const Icon(Icons.notifications_rounded, color: Colors.white),
              onPressed: () {}),
          if (widget.onLogout != null)
            IconButton(
              icon: const Icon(Icons.logout_rounded, color: Colors.white),
              tooltip: 'Déconnexion',
              onPressed: widget.onLogout,
            ),
        ],
      ),
      body: controller.isLoading && overview == null
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : controller.errorMessage != null && overview == null
              ? AppEmptyState(
                  icon: Icons.cloud_off_rounded,
                  title: 'Chargement impossible',
                  subtitle: controller.errorMessage,
                  actionLabel: 'Réessayer',
                  onAction: controller.load,
                )
              : _buildContent(context, controller, data, alerts),
    );
  }

  Widget _buildContent(
    BuildContext context,
    DashboardController controller,
    Map<String, dynamic>? data,
    List alerts,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final pagePadding = AppBreakpoints.pagePadding(width);

        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: controller.load,
          child: ListView(
            padding: EdgeInsets.all(pagePadding),
            children: [
              _buildDateBanner(width, widget.dataSourceLabel),
              if (controller.errorMessage != null) ...[
                const SizedBox(height: 12),
                _buildSyncWarning(controller.errorMessage!),
              ],
              const SizedBox(height: 16),
              if (alerts.isNotEmpty) ...[
                _buildAlertsSection(alerts),
                const SizedBox(height: 16),
              ],
              Text('Résumé du jour', style: AppTextStyles.headlineSmall),
              const SizedBox(height: 12),
              data != null
                  ? _buildMetricsGrid(data, width)
                  : _buildNoDataPlaceholder(
                      icon: Icons.bar_chart_rounded,
                      message: 'Aucune activité enregistrée aujourd\'hui',
                    ),
              const SizedBox(height: 20),
              Text('Actions rapides', style: AppTextStyles.headlineSmall),
              const SizedBox(height: 12),
              _buildQuickActions(context),
              const SizedBox(height: 20),
              data != null
                  ? _buildFinanceSummary(data)
                  : _buildFinanceSummaryEmpty(),
              const SizedBox(height: 80),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNoDataPlaceholder({
    required IconData icon,
    required String message,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: AppColors.shadow, blurRadius: 6),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.textTertiary, size: 36),
          const SizedBox(height: 10),
          Text(
            message,
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDateBanner(double width, String sourceLabel) {
    final now = DateTime.now();
    final isCompact = AppBreakpoints.isCompact(width);
    const days = [
      'Lundi',
      'Mardi',
      'Mercredi',
      'Jeudi',
      'Vendredi',
      'Samedi',
      'Dimanche'
    ];
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
    final dayName = days[now.weekday - 1];
    final dateStr = '${now.day} ${months[now.month - 1]}. ${now.year}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: isCompact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded,
                        color: AppColors.primary, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text.rich(
                        TextSpan(children: [
                          TextSpan(
                              text: '$dayName, ',
                              style: AppTextStyles.titleMedium),
                          TextSpan(
                              text: dateStr,
                              style: AppTextStyles.titleMedium
                                  .copyWith(color: AppColors.primary)),
                        ]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _buildSourceBadge(sourceLabel),
              ],
            )
          : Row(
              children: [
                const Icon(Icons.calendar_today_rounded,
                    color: AppColors.primary, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text.rich(
                    TextSpan(children: [
                      TextSpan(
                          text: '$dayName, ', style: AppTextStyles.titleMedium),
                      TextSpan(
                          text: dateStr,
                          style: AppTextStyles.titleMedium
                              .copyWith(color: AppColors.primary)),
                    ]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 10),
                _buildSourceBadge(sourceLabel),
              ],
            ),
    );
  }

  Widget _buildSourceBadge(String sourceLabel) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: sourceLabel == 'API'
            ? AppColors.successSurface
            : AppColors.primarySurface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        sourceLabel,
        style: AppTextStyles.bodySmall.copyWith(
          color: sourceLabel == 'API' ? AppColors.success : AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSyncWarning(String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warningSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.sync_problem_rounded,
              color: AppColors.warning, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.warning),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsSection(List alerts) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.error.withOpacity(0.2), width: 1.5),
      ),
      child: Column(children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.errorSurface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Row(children: [
            const Icon(Icons.warning_amber_rounded,
                color: AppColors.error, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Alertes importantes',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.titleLarge.copyWith(
                  color: AppColors.error,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(10)),
              child: Text('${alerts.length}',
                  style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ]),
        ),
        ...alerts.asMap().entries.map((e) {
          final alert = e.value as Map<String, dynamic>;
          final isError = alert['type'] == 'error';
          final color = isError ? AppColors.error : AppColors.warning;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: e.key < alerts.length - 1
                  ? const Border(bottom: BorderSide(color: AppColors.divider))
                  : null,
            ),
            child: Row(children: [
              Container(
                  width: 8,
                  height: 8,
                  decoration:
                      BoxDecoration(color: color, shape: BoxShape.circle)),
              const SizedBox(width: 12),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(alert['message'],
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: AppColors.textPrimary)),
                    const SizedBox(height: 2),
                    Text(alert['time'], style: AppTextStyles.bodySmall),
                  ])),
              Icon(Icons.chevron_right_rounded, color: color, size: 18),
            ]),
          );
        }),
      ]),
    );
  }

  Widget _buildMetricsGrid(Map<String, dynamic> data, double width) {
    final metrics = [
      _Metric('Chargements', '${data['daily_loadings']} op.',
          Icons.inventory_2_rounded, AppColors.info),
      _Metric('Versements usine', '${data['factory_payments']} F',
          Icons.factory_rounded, AppColors.primary),
      _Metric('Règlements clients', '${data['client_payments']} F',
          Icons.payments_rounded, AppColors.success),
      _Metric('Dépenses du jour', '${data['daily_expenses']} F',
          Icons.trending_down_rounded, AppColors.error,
          isAlert: true),
      _Metric('Recettes du jour', '${data['daily_revenues']} F',
          Icons.trending_up_rounded, AppColors.success),
      _Metric('Clients débiteurs', '${data['debtor_clients']} clients',
          Icons.account_balance_wallet_rounded, AppColors.warning,
          isAlert: true),
      _Metric('Alertes camions', '${data['alert_trucks']} camions',
          Icons.local_shipping_rounded, AppColors.error,
          isAlert: true),
      _Metric('Docs expirés', '${data['expired_docs']} docs',
          Icons.description_rounded, AppColors.error,
          isAlert: true),
    ];

    final gridDelegate = AppBreakpoints.isCompact(width)
        ? SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: AppBreakpoints.dashboardMetricAspectRatio(width),
          )
        : SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 220,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: AppBreakpoints.dashboardMetricAspectRatio(width),
          );

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: gridDelegate,
      itemCount: metrics.length,
      itemBuilder: (_, i) {
        final m = metrics[i];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: m.isAlert ? m.color.withOpacity(0.06) : AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border:
                m.isAlert ? Border.all(color: m.color.withOpacity(0.25)) : null,
            boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 6)],
          ),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                    color: m.color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8)),
                child: Icon(m.icon, color: m.color, size: 18),
              ),
              if (m.isAlert) ...[
                const Spacer(),
                Icon(Icons.warning_rounded, color: m.color, size: 14)
              ],
            ]),
            const Spacer(),
            Text(m.value,
                style: AppTextStyles.headlineSmall.copyWith(color: m.color)),
            const SizedBox(height: 2),
            Text(m.title,
                style: AppTextStyles.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ]),
        );
      },
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      _Action(
          'Chargement',
          Icons.add_box_rounded,
          AppColors.info,
          () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const ClientLoadingScreen()))),
      _Action(
          'Règlement',
          Icons.payments_rounded,
          AppColors.success,
          () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const ClientPaymentScreen()))),
      _Action(
          'Dépense',
          Icons.money_off_rounded,
          AppColors.error,
          () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const ChargesScreen()))),
      _Action(
          'Recette',
          Icons.add_card_rounded,
          AppColors.primary,
          () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const RevenueScreen()))),
      _Action(
          'Vidange',
          Icons.oil_barrel_rounded,
          AppColors.warning,
          () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => OilChangeScreen(
                      truckPlate: AppData.trucks.first['plate'])))),
    ];

    return Container(
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
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tileWidth =
              AppBreakpoints.quickActionTileWidth(constraints.maxWidth);

          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: actions
                .map(
                  (action) => SizedBox(
                    width: tileWidth,
                    child: GestureDetector(
                      onTap: action.onTap,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: action.color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(action.icon,
                                color: action.color, size: 22),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            action.label,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodySmall.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
          );
        },
      ),
    );
  }

  Widget _buildFinanceSummary(Map<String, dynamic> data) {
    return AppSummaryCard(
      title: '💰 Bilan financier du jour',
      color: AppColors.primary,
      rows: [
        AppSummaryRow(
            label: 'Recettes du jour',
            value: '${data['daily_revenues']} F',
            valueColor: AppColors.success,
            isBold: true),
        AppSummaryRow(
            label: 'Dépenses du jour',
            value: '- ${data['daily_expenses']} F',
            valueColor: AppColors.error),
        AppSummaryRow(
            label: 'Versements usine',
            value: '- ${data['factory_payments']} F',
            valueColor: AppColors.error),
        AppSummaryRow(
            label: 'Règlements reçus',
            value: '+ ${data['client_payments']} F',
            valueColor: AppColors.success),
        const AppSummaryRow(label: '─────────────────', value: ''),
        AppSummaryRow(
            label: 'Solde net estimé',
            value: '250 000 F',
            valueColor: AppColors.primary,
            isBold: true),
      ],
    );
  }

  Widget _buildFinanceSummaryEmpty() {
    return AppSummaryCard(
      title: '💰 Bilan financier du jour',
      color: AppColors.primary,
      rows: [
        AppSummaryRow(
            label: 'Recettes du jour',
            value: '— F',
            valueColor: AppColors.textSecondary,
            isBold: true),
        AppSummaryRow(
            label: 'Dépenses du jour',
            value: '— F',
            valueColor: AppColors.textSecondary),
        AppSummaryRow(
            label: 'Versements usine',
            value: '— F',
            valueColor: AppColors.textSecondary),
        AppSummaryRow(
            label: 'Règlements reçus',
            value: '— F',
            valueColor: AppColors.textSecondary),
        const AppSummaryRow(label: '─────────────────', value: ''),
        AppSummaryRow(
            label: 'Solde net estimé',
            value: '— F',
            valueColor: AppColors.textSecondary,
            isBold: true),
      ],
    );
  }
}

class _Metric {
  final String title, value;
  final IconData icon;
  final Color color;
  final bool isAlert;
  _Metric(this.title, this.value, this.icon, this.color,
      {this.isAlert = false});
}

class _Action {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  _Action(this.label, this.icon, this.color, this.onTap);
}
