import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/layout/app_breakpoints.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../core/widgets/primary_section_app_bar.dart';
import '../../auth/data/models/user_session.dart';
import '../../clients/domain/repositories/clients_repository.dart';
import '../../factory_payments/domain/repositories/factory_payments_repository.dart';
import '../../factory_payments/presentation/factory_payment_screen.dart';
import '../../loadings/domain/repositories/loadings_repository.dart';
import '../../sites/domain/repositories/sites_repository.dart';
import '../../sites/presentation/sites_management_screen.dart';
import '../../trucks/domain/repositories/trucks_repository.dart';
import 'controllers/dashboard_controller.dart';
import '../../charges/presentation/charges_screen.dart';
import '../../client_payments/presentation/client_payment_screen.dart';
import '../../loadings/presentation/loading_screen.dart';
import '../../revenues/presentation/revenue_screen.dart';
import '../data/models/dashboard_overview.dart';

class DashboardScreen extends StatefulWidget {
  final DashboardController controller;
  final String dataSourceLabel;
  final LoadingsRepository loadingsRepository;
  final ClientsRepository clientsRepository;
  final TrucksRepository trucksRepository;
  final FactoryPaymentsRepository factoryPaymentsRepository;
  final SitesRepository sitesRepository;
  final UserSession? userSession;
  final VoidCallback? onLogout;

  const DashboardScreen({
    super.key,
    required this.controller,
    required this.dataSourceLabel,
    required this.loadingsRepository,
    required this.clientsRepository,
    required this.trucksRepository,
    required this.factoryPaymentsRepository,
    required this.sitesRepository,
    this.userSession,
    this.onLogout,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final NumberFormat _moneyFormat = NumberFormat.decimalPattern('fr_FR');

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
    final alerts = overview?.alerts ?? const <DashboardAlert>[];

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
              : _buildContent(context, controller, overview, alerts),
    );
  }

  Widget _buildContent(
    BuildContext context,
    DashboardController controller,
    DashboardOverview? overview,
    List<DashboardAlert> alerts,
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
              if (widget.userSession != null) ...[
                const SizedBox(height: 12),
                _buildConnectedUserOverview(widget.userSession!),
              ],
              if (controller.errorMessage != null) ...[
                const SizedBox(height: 12),
                _buildSyncWarning(controller.errorMessage!),
              ],
              const SizedBox(height: 16),
              if (overview != null && overview.hasAlerts) ...[
                _buildAlertsSection(alerts),
                const SizedBox(height: 16),
              ],
              Text('Résumé du jour', style: AppTextStyles.headlineSmall),
              const SizedBox(height: 12),
              overview != null
                  ? _buildMetricsGrid(overview, width)
                  : _buildNoDataPlaceholder(
                      icon: Icons.bar_chart_rounded,
                      message: 'Aucune activité enregistrée aujourd\'hui',
                    ),
              const SizedBox(height: 20),
              Text('Actions rapides', style: AppTextStyles.headlineSmall),
              const SizedBox(height: 12),
              _buildQuickActions(context),
              const SizedBox(height: 20),
              overview != null
                  ? _buildFinanceSummary(overview)
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

  Widget _buildConnectedUserOverview(UserSession session) {
    final roleLabel = _formatRole(session.role);
    final email = session.email.trim();
    final initials = _buildInitials(session.fullName);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              initials,
              style: AppTextStyles.titleLarge.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.headlineSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  session.identifier,
                  style: AppTextStyles.bodyMedium,
                ),
                if (email.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  roleLabel,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                session.isActive ? 'Compte actif' : 'Compte inactif',
                style: AppTextStyles.bodySmall.copyWith(
                  color:
                      session.isActive ? AppColors.success : AppColors.warning,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatRole(String role) {
    final normalized = role.trim().toUpperCase();
    if (normalized.isEmpty) {
      return 'Compte';
    }

    return AppStrings.userRoleLabels[normalized] ?? normalized;
  }

  String _buildInitials(String fullName) {
    final parts = fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .toList();

    if (parts.isEmpty) {
      return 'U';
    }

    return parts.map((part) => part[0].toUpperCase()).join();
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
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.25)),
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

  Widget _buildAlertsSection(List<DashboardAlert> alerts) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.error.withValues(alpha: 0.2),
          width: 1.5,
        ),
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
          final alert = e.value;
          final isError = alert.type.trim().toLowerCase() == 'error';
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
                    Text(alert.message,
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: AppColors.textPrimary)),
                    const SizedBox(height: 2),
                    Text(alert.time, style: AppTextStyles.bodySmall),
                  ])),
              Icon(Icons.chevron_right_rounded, color: color, size: 18),
            ]),
          );
        }),
      ]),
    );
  }

  Widget _buildMetricsGrid(DashboardOverview overview, double width) {
    final metrics = [
      _Metric('Chargements', '${overview.dailyLoadings} op.',
          Icons.inventory_2_rounded, AppColors.info),
      _Metric('Versements usine', _formatMoney(overview.factoryPaymentsAmount),
          Icons.factory_rounded, AppColors.primary),
      _Metric('Règlements clients', _formatMoney(overview.clientPaymentsAmount),
          Icons.payments_rounded, AppColors.success),
      _Metric('Dépenses du jour', _formatMoney(overview.dailyExpensesAmount),
          Icons.trending_down_rounded, AppColors.error,
          isAlert: true),
      _Metric('Recettes du jour', _formatMoney(overview.dailyRevenuesAmount),
          Icons.trending_up_rounded, AppColors.success),
      _Metric('Clients débiteurs', '${overview.debtorClients} clients',
          Icons.account_balance_wallet_rounded, AppColors.warning,
          isAlert: true),
      _Metric('Alertes camions', '${overview.alertTrucks} camions',
          Icons.local_shipping_rounded, AppColors.error,
          isAlert: true),
      _Metric('Docs expirés', '${overview.expiredDocs} docs',
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
            color:
                m.isAlert ? m.color.withValues(alpha: 0.06) : AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: m.isAlert
                ? Border.all(color: m.color.withValues(alpha: 0.25))
                : null,
            boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 6)],
          ),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                    color: m.color.withValues(alpha: 0.12),
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
          () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => ClientLoadingScreen(
                        loadingsRepository: widget.loadingsRepository,
                        clientsRepository: widget.clientsRepository,
                        trucksRepository: widget.trucksRepository,
                        sitesRepository: widget.sitesRepository,
                      )))),
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
          'Versement usine',
          Icons.factory_rounded,
          AppColors.accent,
          () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => FactoryPaymentScreen(
                        repository: widget.factoryPaymentsRepository,
                      )))),
      _Action(
          'Sites & usines',
          Icons.location_city_rounded,
          AppColors.warning,
          () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => SitesManagementScreen(
                        repository: widget.sitesRepository,
                        session: widget.userSession,
                      )))),
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
                              color: action.color.withValues(alpha: 0.1),
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

  Widget _buildFinanceSummary(DashboardOverview overview) {
    final netAmount = overview.estimatedNetAmount;
    final netColor = netAmount >= 0 ? AppColors.primary : AppColors.error;
    final netPrefix = netAmount > 0 ? '+ ' : '';

    return AppSummaryCard(
      title: '💰 Bilan financier du jour',
      color: AppColors.primary,
      rows: [
        AppSummaryRow(
            label: 'Recettes du jour',
            value: _formatMoney(overview.dailyRevenuesAmount),
            valueColor: AppColors.success,
            isBold: true),
        AppSummaryRow(
            label: 'Dépenses du jour',
            value: '- ${_formatMoney(overview.dailyExpensesAmount)}',
            valueColor: AppColors.error),
        AppSummaryRow(
            label: 'Versements usine',
            value: '- ${_formatMoney(overview.factoryPaymentsAmount)}',
            valueColor: AppColors.error),
        AppSummaryRow(
            label: 'Règlements reçus',
            value: '+ ${_formatMoney(overview.clientPaymentsAmount)}',
            valueColor: AppColors.success),
        const AppSummaryRow(label: '─────────────────', value: ''),
        AppSummaryRow(
            label: 'Solde net estimé',
            value: '$netPrefix${_formatSignedMoney(netAmount)}',
            valueColor: netColor,
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

  String _formatMoney(int amount) {
    return '${_moneyFormat.format(amount)} ${AppConstants.currencySymbol}';
  }

  String _formatSignedMoney(int amount) {
    final absolute = amount.abs();
    return '${_moneyFormat.format(absolute)} ${AppConstants.currencySymbol}';
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
