import 'package:flutter/material.dart';

import '../../../core/layout/app_breakpoints.dart';
import '../../../core/layout/responsive_content.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../core/widgets/primary_section_app_bar.dart';
import '../data/models/driver_model.dart';
import '../data/models/driver_upsert_request.dart';
import 'controllers/drivers_controller.dart';

class DriversScreen extends StatefulWidget {
  final DriversController controller;

  const DriversScreen({
    super.key,
    required this.controller,
  });

  @override
  State<DriversScreen> createState() => _DriversScreenState();
}

class _DriversScreenState extends State<DriversScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.controller.drivers.isEmpty && !widget.controller.isLoading) {
      widget.controller.load();
    }
  }

  Future<void> _openEditor({DriverModel? initialDriver}) async {
    final draft = await showModalBottomSheet<DriverUpsertRequest>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.92,
        child: _DriverEditorSheet(initialDriver: initialDriver),
      ),
    );

    if (!mounted || draft == null) {
      return;
    }

    final ok = initialDriver == null
        ? await widget.controller.createDriver(draft)
        : await widget.controller.updateDriver(initialDriver.id, draft);

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

  Future<void> _confirmDelete(DriverModel driver) async {
    final confirmed = await AppConfirmDialog.show(
      context,
      title: 'Supprimer ce chauffeur ?',
      confirmLabel: 'Supprimer',
      confirmColor: AppColors.error,
      content: Text(
        'Le chauffeur "${driver.name}" sera supprimé définitivement.',
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      onConfirm: () {},
    );

    if (confirmed != true || !mounted) {
      return;
    }

    final ok = await widget.controller.deleteDriver(driver.id);

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
      widget.controller.successMessage ?? 'Chauffeur supprimé.',
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
        final drivers = widget.controller.filteredDrivers;
        final errorMessage = widget.controller.errorMessage;

        return AppLoadingOverlay(
          isLoading: widget.controller.isSaving,
          message: 'Sauvegarde en cours...',
          child: Scaffold(
            backgroundColor: AppColors.backgroundLight,
            appBar: PrimarySectionAppBar(
              sectionTitle: 'Chauffeurs',
              actions: [
                IconButton(
                  icon: const Icon(Icons.person_add_alt_1_rounded,
                      color: Colors.white),
                  onPressed: () => _openEditor(),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton.extended(
              heroTag: 'drivers_fab',
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
                                hintText: 'Rechercher un chauffeur...',
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
                                      '${drivers.length}',
                                      'Chauffeurs',
                                      AppColors.primary,
                                    ),
                                    _pill(
                                      tileWidth,
                                      '${widget.controller.activeCount}',
                                      'Actifs',
                                      AppColors.success,
                                    ),
                                    _pill(
                                      tileWidth,
                                      '${widget.controller.inactiveCount}',
                                      'Inactifs',
                                      AppColors.warning,
                                    ),
                                  ],
                                );
                              },
                            ),
                            if (widget.controller.errorMessage != null &&
                                widget.controller.drivers.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              _DriverErrorBanner(
                                message: errorMessage!,
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
                              widget.controller.drivers.isEmpty) {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                              ),
                            );
                          }

                          if (widget.controller.errorMessage != null &&
                              widget.controller.drivers.isEmpty) {
                            return AppEmptyState(
                              icon: Icons.cloud_off_rounded,
                              title: 'Chauffeurs indisponibles',
                              subtitle: errorMessage,
                              actionLabel: 'Réessayer',
                              onAction: widget.controller.load,
                            );
                          }

                          if (drivers.isEmpty) {
                            return AppEmptyState(
                              icon: Icons.badge_outlined,
                              title: 'Aucun chauffeur trouvé',
                              subtitle: widget.controller.searchQuery.isEmpty
                                  ? 'Les chauffeurs apparaîtront ici.'
                                  : 'Modifiez votre recherche.',
                              actionLabel: widget.controller.searchQuery.isEmpty
                                  ? 'Ajouter un chauffeur'
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
                                itemCount: drivers.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 10),
                                itemBuilder: (_, index) => _DriverCard(
                                  driver: drivers[index],
                                  onEdit: () => _openEditor(
                                    initialDriver: drivers[index],
                                  ),
                                  onDelete: () => _confirmDelete(
                                    drivers[index],
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

class _DriverCard extends StatelessWidget {
  final DriverModel driver;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _DriverCard({
    required this.driver,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final color = driver.isActive ? AppColors.success : AppColors.warning;
    final initial = driver.name.trim().isEmpty
        ? '?'
        : driver.name.trim().substring(0, 1).toUpperCase();
    final phone =
        driver.phone.trim().isEmpty ? 'Aucun téléphone' : driver.phone;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: AppColors.shadow, blurRadius: 6),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                initial,
                style: AppTextStyles.headlineMedium.copyWith(color: color),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  driver.name,
                  style: AppTextStyles.titleLarge,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
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
                        style: AppTextStyles.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                AppStatusBadge(
                  label: driver.isActive ? 'Actif' : 'Inactif',
                  status: driver.isActive
                      ? BadgeStatus.success
                      : BadgeStatus.warning,
                  small: true,
                ),
                if (driver.notes.trim().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    driver.notes,
                    style: AppTextStyles.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          PopupMenuButton<_DriverAction>(
            icon: const Icon(
              Icons.more_vert_rounded,
              color: AppColors.textSecondary,
            ),
            onSelected: (action) {
              switch (action) {
                case _DriverAction.edit:
                  onEdit();
                  break;
                case _DriverAction.delete:
                  onDelete();
                  break;
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: _DriverAction.edit,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.edit_rounded),
                  title: Text('Modifier'),
                ),
              ),
              PopupMenuItem(
                value: _DriverAction.delete,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.delete_outline_rounded),
                  title: Text('Supprimer'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DriverErrorBanner extends StatelessWidget {
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _DriverErrorBanner({
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

class _DriverEditorSheet extends StatefulWidget {
  final DriverModel? initialDriver;

  const _DriverEditorSheet({
    this.initialDriver,
  });

  @override
  State<_DriverEditorSheet> createState() => _DriverEditorSheetState();
}

class _DriverEditorSheetState extends State<_DriverEditorSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _notesCtrl;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialDriver;
    _nameCtrl = TextEditingController(text: initial?.name ?? '');
    _phoneCtrl = TextEditingController(text: initial?.phone ?? '');
    _notesCtrl = TextEditingController(text: initial?.notes ?? '');
    _isActive = initial?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    Navigator.of(context).pop(
      DriverUpsertRequest(
        name: _nameCtrl.text,
        phone: _phoneCtrl.text,
        isActive: _isActive,
        notes: _notesCtrl.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets;
    final isEditing = widget.initialDriver != null;

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
                  isEditing ? 'Modifier le chauffeur' : 'Ajouter un chauffeur',
                  style: AppTextStyles.headlineLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Créez et gérez les chauffeurs de votre activité directement depuis l’application.',
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: 20),
                AppSectionCard(
                  title: 'Informations générales',
                  icon: Icons.badge_rounded,
                  iconColor: AppColors.primary,
                  children: [
                    AppTextField(
                      label: 'Nom du chauffeur',
                      hint: 'Ex: KONAN Yao',
                      controller: _nameCtrl,
                      required: true,
                      validator: (value) {
                        if ((value ?? '').trim().isEmpty) {
                          return 'Entrez le nom du chauffeur';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      label: 'Téléphone',
                      hint: 'Ex: 0711223344',
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
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
                          'Chauffeur actif',
                          style: AppTextStyles.titleMedium,
                        ),
                        subtitle: Text(
                          _isActive
                              ? 'Ce chauffeur peut être utilisé dans les opérations.'
                              : 'Le chauffeur reste visible mais n’est plus considéré comme actif.',
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
    );
  }
}

enum _DriverAction {
  edit,
  delete,
}
