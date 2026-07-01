import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../auth/data/models/user_session.dart';
import '../data/models/site_record.dart';
import '../data/models/site_upsert_request.dart';
import '../domain/repositories/sites_repository.dart';
import 'controllers/sites_management_controller.dart';

class SitesManagementScreen extends StatefulWidget {
  final SitesRepository repository;
  final UserSession? session;

  const SitesManagementScreen({
    super.key,
    required this.repository,
    required this.session,
  });

  @override
  State<SitesManagementScreen> createState() => _SitesManagementScreenState();
}

class _SitesManagementScreenState extends State<SitesManagementScreen> {
  late final SitesManagementController _controller;
  final NumberFormat _moneyFormat = NumberFormat.decimalPattern('fr_FR');

  @override
  void initState() {
    super.initState();
    _controller = SitesManagementController(widget.repository)..loadSites();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _canManageSites {
    final role = widget.session?.role.trim().toUpperCase();
    return role == 'ADMIN' || role == 'MANAGER';
  }

  Future<void> _openEditor({SiteRecord? initialSite}) async {
    final draft = await showModalBottomSheet<SiteUpsertRequest>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.92,
        child: _SiteEditorSheet(
          initialSite: initialSite,
        ),
      ),
    );

    if (!mounted || draft == null) {
      return;
    }

    final ok = initialSite == null
        ? await _controller.createSite(draft)
        : await _controller.updateSite(initialSite.id, draft);

    if (!mounted || !ok) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_controller.successMessage ?? 'Opération effectuée.'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _confirmDelete(SiteRecord site) async {
    final confirmed = await AppConfirmDialog.show(
      context,
      title: 'Supprimer ce site ?',
      confirmLabel: 'Supprimer',
      confirmColor: AppColors.error,
      content: Text(
        'Le site "${site.name}" sera supprimé définitivement.',
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      onConfirm: () {},
    );

    if (confirmed != true || !mounted) {
      return;
    }

    final ok = await _controller.deleteSite(site.id);

    if (!mounted || !ok) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_controller.successMessage ?? 'Site supprimé.'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final errorMessage = _controller.errorMessage;
        final sites = _controller.sites;

        return AppLoadingOverlay(
          isLoading: _controller.isSaving,
          message: 'Sauvegarde en cours...',
          child: Scaffold(
            backgroundColor: AppColors.backgroundLight,
            appBar: AppBar(
              title: const Text('Sites & usines'),
              actions: [
                if (_canManageSites)
                  IconButton(
                    tooltip: 'Ajouter un site',
                    onPressed: () => _openEditor(),
                    icon: const Icon(Icons.add_rounded),
                  ),
              ],
            ),
            floatingActionButton: _canManageSites
                ? FloatingActionButton.extended(
                    onPressed: () => _openEditor(),
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    icon: const Icon(Icons.add_business_rounded),
                    label: const Text('Ajouter'),
                  )
                : null,
            body: RefreshIndicator(
              onRefresh: _controller.loadSites,
              color: AppColors.primary,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  AppSectionCard(
                    title: 'Gestion des sites',
                    icon: Icons.location_city_rounded,
                    iconColor: AppColors.accent,
                    children: [
                      Text(
                        'Retrouve ici les carrières, usines et autres sites accessibles à ton compte.',
                        style: AppTextStyles.bodyMedium,
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          AppStatusBadge(
                            label: _roleLabel(widget.session?.role),
                            status: _canManageSites
                                ? BadgeStatus.success
                                : BadgeStatus.info,
                          ),
                          AppStatusBadge(
                            label: '${sites.length} site(s)',
                            status: BadgeStatus.neutral,
                          ),
                        ],
                      ),
                      if (!_canManageSites) ...[
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.infoSurface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.info.withValues(alpha: 0.18),
                            ),
                          ),
                          child: Text(
                            'Votre rôle peut consulter les sites affectés, mais seul un propriétaire ou un administrateur peut en ajouter, modifier ou supprimer.',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.info,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.errorSurface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.error.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline_rounded,
                            color: AppColors.error,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              errorMessage,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (_controller.isLoading && sites.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 48),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  else if (sites.isEmpty)
                    AppEmptyState(
                      icon: Icons.factory_outlined,
                      title: 'Aucun site disponible',
                      subtitle: _canManageSites
                          ? 'Commencez par ajouter votre première carrière ou usine.'
                          : 'Aucun site n’est encore affecté à ce compte.',
                      actionLabel: _canManageSites ? 'Ajouter un site' : null,
                      onAction: _canManageSites ? () => _openEditor() : null,
                    )
                  else
                    ...sites.map(
                      (site) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _SiteCard(
                          site: site,
                          canManage: _canManageSites,
                          priceLabel:
                              '${_moneyFormat.format(site.currentPrice)} ${AppConstants.currency}',
                          onEdit: () => _openEditor(initialSite: site),
                          onDelete: () => _confirmDelete(site),
                        ),
                      ),
                    ),
                  const SizedBox(height: 96),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _roleLabel(String? role) {
    final normalized = role?.trim().toUpperCase() ?? 'VIEWER';
    return AppStrings.userRoleLabels[normalized] ?? normalized;
  }
}

class _SiteCard extends StatelessWidget {
  final SiteRecord site;
  final bool canManage;
  final String priceLabel;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _SiteCard({
    required this.site,
    required this.canManage,
    required this.priceLabel,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _typeColor(site.type).withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  _typeIcon(site.type),
                  color: _typeColor(site.type),
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(site.name, style: AppTextStyles.headlineSmall),
                    const SizedBox(height: 6),
                    AppStatusBadge(
                      label: _typeLabel(site.type),
                      status: _typeBadgeStatus(site.type),
                      small: true,
                    ),
                  ],
                ),
              ),
              if (canManage)
                PopupMenuButton<_SiteAction>(
                  icon: const Icon(
                    Icons.more_vert_rounded,
                    color: AppColors.textSecondary,
                  ),
                  onSelected: (action) {
                    switch (action) {
                      case _SiteAction.edit:
                        onEdit();
                        break;
                      case _SiteAction.delete:
                        onDelete();
                        break;
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: _SiteAction.edit,
                      child: Text('Modifier'),
                    ),
                    PopupMenuItem(
                      value: _SiteAction.delete,
                      child: Text('Supprimer'),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 16),
          _InfoRow(
            icon: Icons.payments_outlined,
            label: 'Prix actuel',
            value: priceLabel,
          ),
          if (site.location.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            _InfoRow(
              icon: Icons.place_outlined,
              label: 'Localisation',
              value: site.location,
            ),
          ],
          if (site.contact.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            _InfoRow(
              icon: Icons.phone_outlined,
              label: 'Contact',
              value: site.contact,
            ),
          ],
          if (site.notes.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            _InfoRow(
              icon: Icons.sticky_note_2_outlined,
              label: 'Notes',
              value: site.notes,
            ),
          ],
        ],
      ),
    );
  }

  IconData _typeIcon(String type) {
    switch (type.trim().toUpperCase()) {
      case 'CARRIERE':
        return Icons.landscape_rounded;
      case 'USINE':
        return Icons.factory_rounded;
      default:
        return Icons.location_city_rounded;
    }
  }

  Color _typeColor(String type) {
    switch (type.trim().toUpperCase()) {
      case 'CARRIERE':
        return AppColors.primary;
      case 'USINE':
        return AppColors.accent;
      default:
        return AppColors.info;
    }
  }

  BadgeStatus _typeBadgeStatus(String type) {
    switch (type.trim().toUpperCase()) {
      case 'CARRIERE':
        return BadgeStatus.success;
      case 'USINE':
        return BadgeStatus.warning;
      default:
        return BadgeStatus.info;
    }
  }

  String _typeLabel(String type) {
    switch (type.trim().toUpperCase()) {
      case 'CARRIERE':
        return 'Carrière';
      case 'USINE':
        return 'Usine';
      default:
        return 'Autre site';
    }
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.bodySmall),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SiteEditorSheet extends StatefulWidget {
  final SiteRecord? initialSite;

  const _SiteEditorSheet({
    this.initialSite,
  });

  @override
  State<_SiteEditorSheet> createState() => _SiteEditorSheetState();
}

class _SiteEditorSheetState extends State<_SiteEditorSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _locationCtrl;
  late final TextEditingController _contactCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _notesCtrl;
  late String _type;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialSite;
    _nameCtrl = TextEditingController(text: initial?.name ?? '');
    _locationCtrl = TextEditingController(text: initial?.location ?? '');
    _contactCtrl = TextEditingController(text: initial?.contact ?? '');
    _priceCtrl = TextEditingController(
      text: initial == null || initial.currentPrice == 0
          ? ''
          : initial.currentPrice.toString(),
    );
    _notesCtrl = TextEditingController(text: initial?.notes ?? '');
    _type = initial?.type.trim().toUpperCase() ?? 'CARRIERE';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _locationCtrl.dispose();
    _contactCtrl.dispose();
    _priceCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    Navigator.of(context).pop(
      SiteUpsertRequest(
        name: _nameCtrl.text,
        type: _type,
        location: _locationCtrl.text,
        contact: _contactCtrl.text,
        currentPrice: int.tryParse(_priceCtrl.text.trim()) ?? 0,
        notes: _notesCtrl.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets;
    final isEditing = widget.initialSite != null;

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
            child: ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
                  isEditing ? 'Modifier le site' : 'Ajouter un site',
                  style: AppTextStyles.headlineLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Renseignez les informations principales du site.',
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: 20),
                AppSectionCard(
                  title: 'Informations générales',
                  icon: Icons.factory_rounded,
                  iconColor: AppColors.primary,
                  children: [
                    AppTextField(
                      label: 'Nom du site',
                      hint: 'Ex: Carrière de Yopougon',
                      controller: _nameCtrl,
                      required: true,
                      validator: (value) {
                        if ((value ?? '').trim().isEmpty) {
                          return 'Entrez le nom du site';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    AppDropdown<String>(
                      label: 'Type',
                      value: _type,
                      required: true,
                      items: const [
                        DropdownMenuItem(
                          value: 'CARRIERE',
                          child: Text('Carrière'),
                        ),
                        DropdownMenuItem(
                          value: 'USINE',
                          child: Text('Usine'),
                        ),
                        DropdownMenuItem(
                          value: 'AUTRE',
                          child: Text('Autre site'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }
                        setState(() => _type = value);
                      },
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      label: 'Localisation',
                      hint: 'Quartier, ville...',
                      controller: _locationCtrl,
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      label: 'Contact',
                      hint: 'Téléphone du site',
                      controller: _contactCtrl,
                      keyboardType: TextInputType.phone,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                AppSectionCard(
                  title: 'Tarification',
                  icon: Icons.payments_rounded,
                  iconColor: AppColors.success,
                  children: [
                    AppMoneyField(
                      label: 'Prix actuel',
                      controller: _priceCtrl,
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
                        label: AppStrings.cancel,
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
                            : Icons.add_business_rounded,
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
    );
  }
}

enum _SiteAction {
  edit,
  delete,
}
