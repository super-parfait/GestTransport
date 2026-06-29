import 'package:flutter/material.dart';
import '../../../core/layout/app_breakpoints.dart';
import '../../../core/layout/responsive_content.dart';
import '../../../core/network/api_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_widgets.dart';
import '../data/models/client_model.dart';
import 'client_detail_screen.dart';
import 'controllers/clients_controller.dart';

class ClientsScreen extends StatefulWidget {
  final ClientsController controller;

  const ClientsScreen({
    super.key,
    required this.controller,
  });

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final clients = widget.controller.filteredClients;

        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          appBar: AppBar(
            title: const Text('Clients'),
            backgroundColor: AppColors.surface,
            actions: [
              IconButton(
                  icon: const Icon(Icons.person_add_rounded,
                      color: AppColors.primary),
                  onPressed: () {}),
            ],
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final pagePadding = AppBreakpoints.pagePadding(width);

              return Column(children: [
                Container(
                  color: AppColors.surface,
                  padding: EdgeInsets.all(pagePadding),
                  child: ResponsiveContent(
                    child: Column(children: [
                      TextField(
                        onChanged: widget.controller.setSearchQuery,
                        decoration: InputDecoration(
                          hintText: 'Rechercher un client...',
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            color: AppColors.textSecondary,
                          ),
                          filled: true,
                          fillColor: AppColors.surfaceVariant,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 12),
                      LayoutBuilder(
                        builder: (context, headerConstraints) {
                          final tileWidth = AppBreakpoints.statTileWidth(
                            headerConstraints.maxWidth,
                          );

                          return Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _pill(
                                tileWidth,
                                '${clients.length}',
                                'Clients',
                                AppColors.primary,
                              ),
                              _pill(
                                tileWidth,
                                '${widget.controller.debtorCount}',
                                'Débiteurs',
                                AppColors.error,
                              ),
                              _pill(
                                tileWidth,
                                AppData.fmtMoney(widget.controller.totalDebt),
                                'Encours',
                                AppColors.warning,
                              ),
                            ],
                          );
                        },
                      ),
                    ]),
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: Builder(
                    builder: (_) {
                      if (widget.controller.isLoading &&
                          widget.controller.clients.isEmpty) {
                        return const Center(
                          child: CircularProgressIndicator(
                              color: AppColors.primary),
                        );
                      }

                      if (widget.controller.errorMessage != null &&
                          widget.controller.clients.isEmpty) {
                        return AppEmptyState(
                          icon: Icons.cloud_off_rounded,
                          title: 'Clients indisponibles',
                          subtitle: widget.controller.errorMessage,
                          actionLabel: 'Réessayer',
                          onAction: widget.controller.load,
                        );
                      }

                      if (clients.isEmpty) {
                        return AppEmptyState(
                          icon: Icons.people_rounded,
                          title: 'Aucun client trouvé',
                          subtitle: widget.controller.searchQuery.isEmpty
                              ? 'Les clients apparaîtront ici.'
                              : 'Modifiez votre recherche.',
                          actionLabel: widget.controller.searchQuery.isEmpty
                              ? 'Actualiser'
                              : null,
                          onAction: widget.controller.searchQuery.isEmpty
                              ? widget.controller.load
                              : null,
                        );
                      }

                      return RefreshIndicator(
                        color: AppColors.primary,
                        onRefresh: widget.controller.load,
                        child: ResponsiveContent(
                          child: ListView.separated(
                            padding: EdgeInsets.all(pagePadding),
                            itemCount: clients.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemBuilder: (_, i) =>
                                _ClientCard(client: clients[i]),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ]);
            },
          ),
        );
      },
    );
  }

  Widget _pill(double width, String value, String label, Color color) =>
      SizedBox(
        width: width,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(children: [
            Text(
              value,
              textAlign: TextAlign.center,
              style: AppTextStyles.headlineSmall.copyWith(color: color),
            ),
            Text(label, style: AppTextStyles.bodySmall),
          ]),
        ),
      );
}

class _ClientCard extends StatelessWidget {
  final ClientModel client;
  const _ClientCard({required this.client});

  Color get _color {
    final b = client.balance;
    if (b == 0) return AppColors.success;
    if (b > 3000000) return AppColors.error;
    return AppColors.warning;
  }

  @override
  Widget build(BuildContext context) {
    final balance = client.balance;
    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) =>
                  ClientDetailScreen(client: client.toPresentationMap()))),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 6)],
          border:
              balance > 0 ? Border.all(color: _color.withOpacity(0.25)) : null,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = AppBreakpoints.isCompact(constraints.maxWidth);

            return isCompact
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        _buildAvatar(),
                        const SizedBox(width: 12),
                        Expanded(child: _buildIdentity()),
                      ]),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              AppData.fmtMoneyFull(balance),
                              style: AppTextStyles.titleLarge
                                  .copyWith(color: _color),
                            ),
                          ),
                          AppStatusBadge(
                            label: balance == 0 ? 'À jour' : 'Débiteur',
                            status: balance == 0
                                ? BadgeStatus.success
                                : balance > 3000000
                                    ? BadgeStatus.error
                                    : BadgeStatus.warning,
                            small: true,
                          ),
                        ],
                      ),
                    ],
                  )
                : Row(children: [
                    _buildAvatar(),
                    const SizedBox(width: 12),
                    Expanded(child: _buildIdentity()),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          AppData.fmtMoneyFull(balance),
                          style:
                              AppTextStyles.titleLarge.copyWith(color: _color),
                        ),
                        const SizedBox(height: 4),
                        AppStatusBadge(
                          label: balance == 0 ? 'À jour' : 'Débiteur',
                          status: balance == 0
                              ? BadgeStatus.success
                              : balance > 3000000
                                  ? BadgeStatus.error
                                  : BadgeStatus.warning,
                          small: true,
                        ),
                      ],
                    ),
                  ]);
          },
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
          color: _color.withOpacity(0.12), shape: BoxShape.circle),
      child: Center(
        child: Text(
          client.name[0].toUpperCase(),
          style: AppTextStyles.headlineMedium.copyWith(color: _color),
        ),
      ),
    );
  }

  Widget _buildIdentity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          client.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.titleLarge,
        ),
        const SizedBox(height: 2),
        Row(children: [
          const Icon(
            Icons.phone_rounded,
            size: 13,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              client.phone,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodySmall,
            ),
          ),
        ]),
      ],
    );
  }
}
