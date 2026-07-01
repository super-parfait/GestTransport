import 'package:flutter/material.dart';

import '../../../core/layout/app_breakpoints.dart';
import '../../../core/layout/responsive_content.dart';
import '../../../core/network/api_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../core/widgets/primary_section_app_bar.dart';
import '../../drivers/domain/repositories/drivers_repository.dart';
import '../../loadings/domain/repositories/loadings_repository.dart';
import '../../sites/domain/repositories/sites_repository.dart';
import '../../trucks/domain/repositories/trucks_repository.dart';
import '../data/models/client_model.dart';
import '../data/models/client_upsert_request.dart';
import '../domain/repositories/clients_repository.dart';
import 'client_detail_screen.dart';
import 'controllers/clients_controller.dart';

class ClientsScreen extends StatefulWidget {
  final ClientsController controller;
  final ClientsRepository clientsRepository;
  final DriversRepository driversRepository;
  final TrucksRepository trucksRepository;
  final SitesRepository sitesRepository;
  final LoadingsRepository loadingsRepository;

  const ClientsScreen({
    super.key,
    required this.controller,
    required this.clientsRepository,
    required this.driversRepository,
    required this.trucksRepository,
    required this.sitesRepository,
    required this.loadingsRepository,
  });

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  Future<void> _openEditor({ClientModel? initialClient}) async {
    final draft = await showModalBottomSheet<ClientUpsertRequest>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.92,
        child: _ClientEditorSheet(initialClient: initialClient),
      ),
    );

    if (!mounted || draft == null) {
      return;
    }

    final ok = initialClient == null
        ? await widget.controller.createClient(draft)
        : await widget.controller.updateClient(initialClient.id, draft);

    if (!mounted) {
      return;
    }

    if (!ok) {
      _showSnackBar(
        widget.controller.errorMessage ?? 'Opération impossible.',
        backgroundColor: AppColors.error,
      );
      return;
    }

    _showSnackBar(
      widget.controller.successMessage ?? 'Opération effectuée.',
      backgroundColor: AppColors.success,
    );
  }

  Future<void> _confirmDelete(ClientModel client) async {
    final confirmed = await AppConfirmDialog.show(
      context,
      title: 'Supprimer ce client ?',
      confirmLabel: 'Supprimer',
      confirmColor: AppColors.error,
      content: Text(
        'Le client "${client.name}" sera supprimé définitivement.',
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      onConfirm: () {},
    );

    if (confirmed != true || !mounted) {
      return;
    }

    final ok = await widget.controller.deleteClient(client.id);

    if (!mounted) {
      return;
    }

    if (!ok) {
      _showSnackBar(
        widget.controller.errorMessage ?? 'Suppression impossible.',
        backgroundColor: AppColors.error,
      );
      return;
    }

    _showSnackBar(
      widget.controller.successMessage ?? 'Client supprimé.',
      backgroundColor: AppColors.success,
    );
  }

  void _showSnackBar(String message, {required Color backgroundColor}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final clients = widget.controller.filteredClients;
        final legacyClientsCount = widget.controller.clients
            .where((client) => !client.hasUsableId)
            .length;
        final errorMessage = widget.controller.errorMessage;

        return AppLoadingOverlay(
          isLoading: widget.controller.isSaving,
          message: 'Sauvegarde en cours...',
          child: Scaffold(
            backgroundColor: AppColors.backgroundLight,
            appBar: PrimarySectionAppBar(
              sectionTitle: 'Clients',
              actions: [
                IconButton(
                  icon: const Icon(
                    Icons.person_add_rounded,
                    color: Colors.white,
                  ),
                  onPressed: () => _openEditor(),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton.extended(
              heroTag: 'clients_fab',
              onPressed: () => _openEditor(),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.person_add_alt_1_rounded),
              label: const Text('Ajouter'),
            ),
            body: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final pagePadding = AppBreakpoints.pagePadding(width);

                return Column(
                  children: [
                    Container(
                      color: AppColors.surface,
                      padding: EdgeInsets.all(pagePadding),
                      child: ResponsiveContent(
                        child: Column(
                          children: [
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
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
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
                                      AppData.fmtMoney(
                                        widget.controller.totalDebt,
                                      ),
                                      'Encours',
                                      AppColors.warning,
                                    ),
                                  ],
                                );
                              },
                            ),
                            if (legacyClientsCount > 0) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: AppColors.warning.withValues(
                                    alpha: 0.08,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: AppColors.warning.withValues(
                                      alpha: 0.20,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      Icons.info_outline_rounded,
                                      color: AppColors.warning,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        '$legacyClientsCount client(s) ont encore un ancien identifiant API. Ils restent visibles ici, mais ne pourront pas être utilisés dans un nouveau chargement tant qu’un client réel n’aura pas été créé.',
                                        style: AppTextStyles.bodyMedium,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            if (errorMessage != null &&
                                widget.controller.clients.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              _ClientErrorBanner(
                                message: errorMessage,
                                actionLabel: 'Réessayer',
                                onAction: widget.controller.load,
                              ),
                            ],
                          ],
                        ),
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
                                color: AppColors.primary,
                              ),
                            );
                          }

                          if (errorMessage != null &&
                              widget.controller.clients.isEmpty) {
                            return AppEmptyState(
                              icon: Icons.cloud_off_rounded,
                              title: 'Clients indisponibles',
                              subtitle: errorMessage,
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
                                  ? 'Ajouter un client'
                                  : null,
                              onAction: widget.controller.searchQuery.isEmpty
                                  ? () => _openEditor()
                                  : null,
                            );
                          }

                          return RefreshIndicator(
                            color: AppColors.primary,
                            onRefresh: widget.controller.load,
                            child: ResponsiveContent(
                              child: ListView.separated(
                                padding: EdgeInsets.fromLTRB(
                                  pagePadding,
                                  pagePadding,
                                  pagePadding,
                                  96,
                                ),
                                itemCount: clients.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 10),
                                itemBuilder: (_, index) => _ClientCard(
                                  client: clients[index],
                                  clientsRepository: widget.clientsRepository,
                                  driversRepository: widget.driversRepository,
                                  trucksRepository: widget.trucksRepository,
                                  sitesRepository: widget.sitesRepository,
                                  loadingsRepository: widget.loadingsRepository,
                                  onEdit: () => _openEditor(
                                    initialClient: clients[index],
                                  ),
                                  onDelete: () => _confirmDelete(
                                    clients[index],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
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
            color: color.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Text(
                value,
                textAlign: TextAlign.center,
                style: AppTextStyles.headlineSmall.copyWith(color: color),
              ),
              Text(label, style: AppTextStyles.bodySmall),
            ],
          ),
        ),
      );
}

class _ClientCard extends StatelessWidget {
  final ClientModel client;
  final ClientsRepository clientsRepository;
  final DriversRepository driversRepository;
  final TrucksRepository trucksRepository;
  final SitesRepository sitesRepository;
  final LoadingsRepository loadingsRepository;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ClientCard({
    required this.client,
    required this.clientsRepository,
    required this.driversRepository,
    required this.trucksRepository,
    required this.sitesRepository,
    required this.loadingsRepository,
    required this.onEdit,
    required this.onDelete,
  });

  Color get _color {
    final balance = client.balance;
    if (balance == 0) {
      return AppColors.success;
    }
    if (balance > 3000000) {
      return AppColors.error;
    }
    return AppColors.warning;
  }

  @override
  Widget build(BuildContext context) {
    final balance = client.balance;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ClientDetailScreen(
            client: client.toPresentationMap(),
            clientsRepository: clientsRepository,
            driversRepository: driversRepository,
            trucksRepository: trucksRepository,
            sitesRepository: sitesRepository,
            loadingsRepository: loadingsRepository,
          ),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(color: AppColors.shadow, blurRadius: 6),
          ],
          border: balance > 0
              ? Border.all(color: _color.withValues(alpha: 0.25))
              : null,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = AppBreakpoints.isCompact(constraints.maxWidth);

            return isCompact
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildAvatar(),
                          const SizedBox(width: 12),
                          Expanded(child: _buildIdentity()),
                          _buildMenu(),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              AppData.fmtMoneyFull(balance),
                              style: AppTextStyles.titleLarge.copyWith(
                                color: _color,
                              ),
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
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildAvatar(),
                      const SizedBox(width: 12),
                      Expanded(child: _buildIdentity()),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _buildMenu(),
                          const SizedBox(height: 6),
                          Text(
                            AppData.fmtMoneyFull(balance),
                            style: AppTextStyles.titleLarge.copyWith(
                              color: _color,
                            ),
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
                    ],
                  );
          },
        ),
      ),
    );
  }

  Widget _buildMenu() {
    return PopupMenuButton<_ClientAction>(
      icon: const Icon(
        Icons.more_vert_rounded,
        color: AppColors.textSecondary,
      ),
      onSelected: (action) {
        switch (action) {
          case _ClientAction.edit:
            onEdit();
            break;
          case _ClientAction.delete:
            onDelete();
            break;
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: _ClientAction.edit,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.edit_rounded),
            title: Text('Modifier'),
          ),
        ),
        PopupMenuItem(
          value: _ClientAction.delete,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.delete_outline_rounded),
            title: Text('Supprimer'),
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar() {
    final letter = client.name.trim().isEmpty
        ? '?'
        : client.name.trim().substring(0, 1).toUpperCase();

    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          letter,
          style: AppTextStyles.headlineMedium.copyWith(color: _color),
        ),
      ),
    );
  }

  Widget _buildIdentity() {
    final phone =
        client.phone.trim().isEmpty ? 'Aucun téléphone' : client.phone;

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
        Row(
          children: [
            const Icon(
              Icons.phone_rounded,
              size: 13,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                phone,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodySmall,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            if (!client.isActive)
              const AppStatusBadge(
                label: 'Inactif',
                status: BadgeStatus.neutral,
                small: true,
              ),
            if (!client.hasUsableId)
              const AppStatusBadge(
                label: 'UUID requis',
                status: BadgeStatus.warning,
                small: true,
              ),
          ],
        ),
      ],
    );
  }
}

class _ClientErrorBanner extends StatelessWidget {
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _ClientErrorBanner({
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.errorSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.error.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: AppColors.error,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(width: 10),
            TextButton(
              onPressed: onAction,
              child: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}

class _ClientEditorSheet extends StatefulWidget {
  final ClientModel? initialClient;

  const _ClientEditorSheet({
    this.initialClient,
  });

  @override
  State<_ClientEditorSheet> createState() => _ClientEditorSheetState();
}

class _ClientEditorSheetState extends State<_ClientEditorSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _notesCtrl;

  late bool _isActive;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialClient;
    _nameCtrl = TextEditingController(text: initial?.name ?? '');
    _phoneCtrl = TextEditingController(text: initial?.phone ?? '');
    _addressCtrl = TextEditingController(text: initial?.address ?? '');
    _notesCtrl = TextEditingController(text: initial?.notes ?? '');
    _isActive = initial?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    Navigator.of(context).pop(
      ClientUpsertRequest(
        name: _nameCtrl.text,
        phone: _phoneCtrl.text,
        address: _addressCtrl.text,
        isActive: _isActive,
        notes: _notesCtrl.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets;
    final isEditing = widget.initialClient != null;

    return SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.backgroundLight,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: AnimatedPadding(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: EdgeInsets.only(bottom: viewInsets.bottom),
          child: Form(
            key: _formKey,
            child: SafeArea(
              child: ListView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                children: [
                  Center(
                    child: Container(
                      width: 46,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.divider,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isEditing ? 'Modifier le client' : 'Ajouter un client',
                    style: AppTextStyles.headlineLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Créez un client réel pour l’utiliser dans les chargements et le suivi des paiements.',
                    style: AppTextStyles.bodyMedium,
                  ),
                  const SizedBox(height: 20),
                  AppSectionCard(
                    title: 'Informations générales',
                    icon: Icons.person_outline_rounded,
                    iconColor: AppColors.primary,
                    children: [
                      AppTextField(
                        label: 'Nom du client',
                        hint: 'Ex: KOUAME Eric',
                        controller: _nameCtrl,
                        required: true,
                        validator: (value) {
                          if ((value ?? '').trim().isEmpty) {
                            return 'Entrez le nom du client';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        label: 'Téléphone',
                        hint: 'Ex: 0700112233',
                        controller: _phoneCtrl,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        label: 'Adresse',
                        hint: 'Quartier, ville...',
                        controller: _addressCtrl,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  AppSectionCard(
                    title: 'Statut & notes',
                    icon: Icons.assignment_rounded,
                    iconColor: AppColors.success,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: SwitchListTile.adaptive(
                          value: _isActive,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                          activeColor: AppColors.primary,
                          title: Text(
                            'Client actif',
                            style: AppTextStyles.titleMedium,
                          ),
                          subtitle: Text(
                            _isActive
                                ? 'Ce client peut être utilisé dans les opérations.'
                                : 'Le client reste visible mais peut être marqué comme inactif.',
                            style: AppTextStyles.bodySmall,
                          ),
                          onChanged: (value) {
                            setState(() => _isActive = value);
                          },
                        ),
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        label: 'Notes',
                        hint: 'Observations utiles',
                        controller: _notesCtrl,
                        maxLines: 3,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          label: 'Annuler',
                          variant: AppButtonVariant.ghost,
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppButton(
                          label: isEditing ? 'Mettre à jour' : 'Enregistrer',
                          icon: isEditing
                              ? Icons.edit_rounded
                              : Icons.person_add_alt_1_rounded,
                          onPressed: _submit,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum _ClientAction {
  edit,
  delete,
}
