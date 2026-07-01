import 'package:flutter/material.dart';

import '../../../core/layout/app_breakpoints.dart';
import '../../../core/layout/responsive_content.dart';
import '../../../core/network/api_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../core/widgets/primary_section_app_bar.dart';
import '../../drivers/data/models/driver_model.dart';
import '../../drivers/domain/repositories/drivers_repository.dart';
import '../data/models/truck_model.dart';
import '../data/models/truck_upsert_request.dart';
import 'controllers/trucks_controller.dart';
import 'truck_detail_screen.dart';

class TrucksScreen extends StatefulWidget {
  final TrucksController controller;
  final DriversRepository driversRepository;

  const TrucksScreen({
    super.key,
    required this.controller,
    required this.driversRepository,
  });

  @override
  State<TrucksScreen> createState() => _TrucksScreenState();
}

class _TrucksScreenState extends State<TrucksScreen> {
  Future<void> _openEditor({TruckModel? initialTruck}) async {
    final draft = await showModalBottomSheet<TruckUpsertRequest>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.92,
        child: _TruckEditorSheet(
          initialTruck: initialTruck,
          driversRepository: widget.driversRepository,
        ),
      ),
    );

    if (!mounted || draft == null) {
      return;
    }

    final ok = initialTruck == null
        ? await widget.controller.createTruck(draft)
        : await widget.controller.updateTruck(initialTruck.id, draft);

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

  Future<void> _confirmDelete(TruckModel truck) async {
    final confirmed = await AppConfirmDialog.show(
      context,
      title: 'Supprimer ce camion ?',
      confirmLabel: 'Supprimer',
      confirmColor: AppColors.error,
      content: Text(
        'Le camion "${truck.plate}" sera supprimé définitivement.',
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      onConfirm: () {},
    );

    if (confirmed != true || !mounted) {
      return;
    }

    final ok = await widget.controller.deleteTruck(truck.id);

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
      widget.controller.successMessage ?? 'Camion supprimé.',
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
        final trucks = widget.controller.trucks;
        final errorMessage = widget.controller.errorMessage;

        return AppLoadingOverlay(
          isLoading: widget.controller.isSaving,
          message: 'Sauvegarde en cours...',
          child: Scaffold(
            backgroundColor: AppColors.backgroundLight,
            appBar: PrimarySectionAppBar(
              sectionTitle: 'Camions',
              actions: [
                IconButton(
                  icon: const Icon(Icons.add_rounded, color: Colors.white),
                  onPressed: () => _openEditor(),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton.extended(
              heroTag: 'trucks_fab',
              onPressed: () => _openEditor(),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Ajouter'),
            ),
            body: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final pagePadding = AppBreakpoints.pagePadding(width);

                if (widget.controller.isLoading && trucks.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }

                if (errorMessage != null && trucks.isEmpty) {
                  return AppEmptyState(
                    icon: Icons.cloud_off_rounded,
                    title: 'Camions indisponibles',
                    subtitle: errorMessage,
                    actionLabel: 'Réessayer',
                    onAction: widget.controller.load,
                  );
                }

                if (trucks.isEmpty) {
                  return AppEmptyState(
                    icon: Icons.local_shipping_rounded,
                    title: 'Aucun camion disponible',
                    subtitle:
                        'Commencez par ajouter votre premier camion dans la flotte.',
                    actionLabel: 'Ajouter un camion',
                    onAction: () => _openEditor(),
                  );
                }

                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: widget.controller.load,
                  child: ResponsiveContent(
                    child: ListView(
                      padding: EdgeInsets.fromLTRB(
                        pagePadding,
                        pagePadding,
                        pagePadding,
                        96,
                      ),
                      children: [
                        LayoutBuilder(
                          builder: (context, statConstraints) {
                            final tileWidth = AppBreakpoints.statTileWidth(
                              statConstraints.maxWidth,
                              spacing: 10,
                            );

                            return Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: [
                                _stat(
                                  tileWidth,
                                  '${trucks.length}',
                                  'Total',
                                  AppColors.info,
                                  Icons.local_shipping_rounded,
                                ),
                                _stat(
                                  tileWidth,
                                  '${widget.controller.activeCount}',
                                  'En service',
                                  AppColors.success,
                                  Icons.check_circle_rounded,
                                ),
                                _stat(
                                  tileWidth,
                                  '${widget.controller.alertsCount}',
                                  'Alertes',
                                  AppColors.error,
                                  Icons.warning_rounded,
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        if (errorMessage != null) ...[
                          _TruckErrorBanner(
                            message: errorMessage,
                            actionLabel: 'Réessayer',
                            onAction: widget.controller.load,
                          ),
                          const SizedBox(height: 16),
                        ],
                        Text(
                          'Flotte de camions',
                          style: AppTextStyles.headlineSmall,
                        ),
                        const SizedBox(height: 12),
                        ...trucks.map(
                          (truck) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _TruckCard(
                              truck: truck,
                              onEdit: () => _openEditor(initialTruck: truck),
                              onDelete: () => _confirmDelete(truck),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _stat(
    double width,
    String value,
    String label,
    Color color,
    IconData icon,
  ) {
    return SizedBox(
      width: width,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: 6)],
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.headlineMedium.copyWith(color: color),
                  ),
                  Text(label, style: AppTextStyles.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TruckCard extends StatelessWidget {
  final TruckModel truck;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TruckCard({
    required this.truck,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final alerts = truck.alerts;
    final normalizedStatus = truck.status.trim().toUpperCase();
    final (color, badge) = _statusData(normalizedStatus);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TruckDetailScreen(truck: truck.toPresentationMap()),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
          border: alerts.isNotEmpty
              ? Border.all(
                  color: _alertColor(alerts).withValues(alpha: 0.30),
                  width: 1.5,
                )
              : null,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = AppBreakpoints.isCompact(constraints.maxWidth);

            return Column(
              children: [
                if (isCompact)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTruckIcon(color),
                          const SizedBox(width: 12),
                          Expanded(child: _buildIdentity()),
                          _buildMenu(),
                        ],
                      ),
                      const SizedBox(height: 10),
                      AppStatusBadge(
                        label: AppData.truckStatusLabels[normalizedStatus] ??
                            normalizedStatus,
                        status: badge,
                      ),
                    ],
                  )
                else
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTruckIcon(color),
                      const SizedBox(width: 12),
                      Expanded(child: _buildIdentity()),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _buildMenu(),
                          const SizedBox(height: 6),
                          AppStatusBadge(
                            label:
                                AppData.truckStatusLabels[normalizedStatus] ??
                                    normalizedStatus,
                            status: badge,
                          ),
                        ],
                      ),
                    ],
                  ),
                if (alerts.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  const Divider(color: AppColors.divider),
                  const SizedBox(height: 4),
                  ...alerts.map((alert) => _AlertRow(alert: alert)),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.speed_rounded,
                      size: 14,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(width: 4),
                    Text(_fmtKm(truck.km), style: AppTextStyles.bodySmall),
                    const Spacer(),
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: AppColors.textTertiary,
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

  Widget _buildTruckIcon(Color color) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(Icons.local_shipping_rounded, color: color, size: 26),
    );
  }

  Widget _buildIdentity() {
    final brandModel = [truck.brand.trim(), truck.model.trim()]
        .where((value) => value.isNotEmpty)
        .join(' · ');
    final driver = truck.driver.trim().isEmpty ? 'Non assigné' : truck.driver;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          truck.plate,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.headlineSmall.copyWith(letterSpacing: 1.5),
        ),
        if (brandModel.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            brandModel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
        const SizedBox(height: 4),
        Row(
          children: [
            const Icon(
              Icons.person_outline_rounded,
              size: 14,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                driver,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyMedium,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMenu() {
    return PopupMenuButton<_TruckAction>(
      icon: const Icon(
        Icons.more_vert_rounded,
        color: AppColors.textSecondary,
      ),
      onSelected: (action) {
        switch (action) {
          case _TruckAction.edit:
            onEdit();
            break;
          case _TruckAction.delete:
            onDelete();
            break;
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: _TruckAction.edit,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.edit_rounded),
            title: Text('Modifier'),
          ),
        ),
        PopupMenuItem(
          value: _TruckAction.delete,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.delete_outline_rounded),
            title: Text('Supprimer'),
          ),
        ),
      ],
    );
  }

  String _fmtKm(int value) {
    return '${value.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (match) => '${match[1]} ')} km';
  }

  (Color, BadgeStatus) _statusData(String status) => switch (status) {
        'ACTIF' || 'EN_VOYAGE' => (AppColors.success, BadgeStatus.success),
        'DISPONIBLE' => (AppColors.info, BadgeStatus.info),
        'EN_ENTRETIEN' => (AppColors.warning, BadgeStatus.warning),
        'EN_PANNE' || 'HORS_SERVICE' => (AppColors.error, BadgeStatus.error),
        'ACTIVE' || 'TRAVELING' => (AppColors.success, BadgeStatus.success),
        'AVAILABLE' => (AppColors.info, BadgeStatus.info),
        'MAINTENANCE' => (AppColors.warning, BadgeStatus.warning),
        'BREAKDOWN' => (AppColors.error, BadgeStatus.error),
        _ => (AppColors.textSecondary, BadgeStatus.neutral),
      };

  Color _alertColor(List<String> alerts) =>
      (alerts.contains('assurance_expired') ||
              alerts.contains('visite_expired') ||
              alerts.contains('breakdown'))
          ? AppColors.error
          : AppColors.warning;
}

class _AlertRow extends StatelessWidget {
  final String alert;

  const _AlertRow({required this.alert});

  static const _messages = {
    'assurance_expired': ('Assurance expirée', AppColors.error),
    'oil_change_soon': ('Vidange bientôt', AppColors.warning),
    'visite_expired': ('Visite technique expirée', AppColors.error),
    'breakdown': ('Camion en panne', AppColors.error),
  };

  @override
  Widget build(BuildContext context) {
    final data = _messages[alert];
    if (data == null) {
      return const SizedBox.shrink();
    }

    final (message, color) = data;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(Icons.warning_rounded, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            message,
            style: AppTextStyles.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _TruckErrorBanner extends StatelessWidget {
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _TruckErrorBanner({
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

class _TruckEditorSheet extends StatefulWidget {
  final TruckModel? initialTruck;
  final DriversRepository driversRepository;

  const _TruckEditorSheet({
    required this.driversRepository,
    this.initialTruck,
  });

  @override
  State<_TruckEditorSheet> createState() => _TruckEditorSheetState();
}

class _TruckEditorSheetState extends State<_TruckEditorSheet> {
  final _formKey = GlobalKey<FormState>();

  static const _statusValues = [
    'ACTIF',
    'DISPONIBLE',
    'EN_VOYAGE',
    'EN_ENTRETIEN',
    'EN_PANNE',
    'HORS_SERVICE',
  ];

  late final TextEditingController _registrationCtrl;
  late final TextEditingController _brandCtrl;
  late final TextEditingController _modelCtrl;
  late final TextEditingController _kmCtrl;
  late final TextEditingController _notesCtrl;

  late String _status;
  String? _selectedDriverId;
  bool _isLoadingDrivers = true;
  String? _driversErrorMessage;
  List<DriverModel> _drivers = const [];

  @override
  void initState() {
    super.initState();
    final initial = widget.initialTruck;
    _registrationCtrl = TextEditingController(text: initial?.plate ?? '');
    _brandCtrl = TextEditingController(text: initial?.brand ?? '');
    _modelCtrl = TextEditingController(text: initial?.model ?? '');
    _kmCtrl = TextEditingController(
      text: initial == null || initial.km == 0 ? '' : initial.km.toString(),
    );
    _notesCtrl = TextEditingController(text: initial?.notes ?? '');
    _status = _resolveInitialStatus(initial?.status);
    final initialDriverId = initial?.driverId.trim() ?? '';
    _selectedDriverId = initialDriverId.isEmpty ? null : initialDriverId;
    _loadDrivers();
  }

  @override
  void dispose() {
    _registrationCtrl.dispose();
    _brandCtrl.dispose();
    _modelCtrl.dispose();
    _kmCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  List<DriverModel> get _assignableDrivers => _drivers
      .where((driver) => driver.isActive && driver.hasUsableId)
      .toList(growable: false);

  bool get _hasExcludedDrivers => _drivers.any(
        (driver) => driver.isActive && !driver.hasUsableId,
      );

  Future<void> _loadDrivers() async {
    setState(() {
      _isLoadingDrivers = true;
      _driversErrorMessage = null;
    });

    try {
      final drivers = await widget.driversRepository.fetchDrivers();
      if (!mounted) {
        return;
      }

      drivers.sort(
        (left, right) =>
            left.name.toLowerCase().compareTo(right.name.toLowerCase()),
      );

      setState(() => _drivers = drivers);
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _driversErrorMessage = 'Chargement des chauffeurs impossible.';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoadingDrivers = false);
      }
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    Navigator.of(context).pop(
      TruckUpsertRequest(
        registration: _registrationCtrl.text,
        brand: _brandCtrl.text,
        model: _modelCtrl.text,
        status: _status,
        currentKm: int.tryParse(_kmCtrl.text.trim()) ?? 0,
        driverId: _selectedDriverId,
        notes: _notesCtrl.text,
      ),
    );
  }

  String _resolveInitialStatus(String? status) {
    final normalized = status?.trim().toUpperCase() ?? 'DISPONIBLE';
    if (_statusValues.contains(normalized)) {
      return normalized;
    }

    return switch (normalized) {
      'ACTIVE' => 'ACTIF',
      'TRAVELING' => 'EN_VOYAGE',
      'AVAILABLE' => 'DISPONIBLE',
      'MAINTENANCE' => 'EN_ENTRETIEN',
      'BREAKDOWN' => 'EN_PANNE',
      _ => 'DISPONIBLE',
    };
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets;
    final isEditing = widget.initialTruck != null;
    final assignableDrivers = _assignableDrivers;
    final driverDropdownValue = assignableDrivers.any(
      (driver) => driver.id == _selectedDriverId,
    )
        ? _selectedDriverId
        : '';
    final legacyAssignedDriver = widget.initialTruck != null &&
        widget.initialTruck!.driver.trim().isNotEmpty &&
        widget.initialTruck!.driverId.trim().isNotEmpty &&
        !assignableDrivers.any(
          (driver) => driver.id == widget.initialTruck!.driverId,
        );

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
                  isEditing ? 'Modifier le camion' : 'Ajouter un camion',
                  style: AppTextStyles.headlineLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Renseignez les informations du camion et affectez, si besoin, un chauffeur actif compatible avec l’API.',
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: 20),
                AppSectionCard(
                  title: 'Informations générales',
                  icon: Icons.local_shipping_rounded,
                  iconColor: AppColors.primary,
                  children: [
                    AppTextField(
                      label: 'Immatriculation',
                      hint: 'Ex: AA-856-AX',
                      controller: _registrationCtrl,
                      required: true,
                      validator: (value) {
                        if ((value ?? '').trim().isEmpty) {
                          return 'Entrez l’immatriculation du camion';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      label: 'Marque',
                      hint: 'Ex: Mercedes',
                      controller: _brandCtrl,
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      label: 'Modèle',
                      hint: 'Ex: Actros 2653',
                      controller: _modelCtrl,
                    ),
                    const SizedBox(height: 14),
                    AppDropdown<String>(
                      label: 'Statut',
                      value: _status,
                      required: true,
                      items: _statusValues
                          .map(
                            (status) => DropdownMenuItem<String>(
                              value: status,
                              child: Text(
                                AppData.truckStatusLabels[status] ?? status,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }
                        setState(() => _status = value);
                      },
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      label: 'Kilométrage actuel',
                      hint: '0',
                      controller: _kmCtrl,
                      keyboardType: TextInputType.number,
                      required: true,
                      validator: (value) {
                        final parsed = int.tryParse((value ?? '').trim());
                        if (parsed == null || parsed < 0) {
                          return 'Entrez un kilométrage valide';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    if (_driversErrorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.errorSurface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.error.withValues(alpha: 0.20),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.error_outline_rounded,
                              size: 18,
                              color: AppColors.error,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _driversErrorMessage!,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.error,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: _loadDrivers,
                              child: const Text('Réessayer'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],
                    if (_hasExcludedDrivers) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.warning.withValues(alpha: 0.20),
                          ),
                        ),
                        child: Text(
                          'Les anciens chauffeurs sans identifiant UUID sont exclus de cette affectation. Utilisez un chauffeur cree depuis l’ecran Chauffeurs.',
                          style: AppTextStyles.bodySmall,
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],
                    if (legacyAssignedDriver) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.warning.withValues(alpha: 0.20),
                          ),
                        ),
                        child: Text(
                          'Le chauffeur actuellement affecte (${widget.initialTruck!.driver}) n’est pas reutilisable ici car il est inactif ou non compatible avec l’API.',
                          style: AppTextStyles.bodySmall,
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],
                    AppDropdown<String>(
                      label: 'Chauffeur affecté',
                      value: driverDropdownValue,
                      hint: _isLoadingDrivers
                          ? 'Chargement des chauffeurs...'
                          : assignableDrivers.isNotEmpty
                              ? 'Sélectionner un chauffeur...'
                              : 'Aucun chauffeur disponible',
                      enabled: !_isLoadingDrivers,
                      items: [
                        const DropdownMenuItem<String>(
                          value: '',
                          child: Text('Aucun chauffeur'),
                        ),
                        ...assignableDrivers.map(
                          (driver) => DropdownMenuItem<String>(
                            value: driver.id,
                            child: Text(
                              driver.phone.trim().isEmpty
                                  ? driver.name
                                  : '${driver.name} · ${driver.phone}',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        final normalized = value?.trim() ?? '';
                        setState(
                          () => _selectedDriverId =
                              normalized.isEmpty ? null : normalized,
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                AppSectionCard(
                  title: 'Notes',
                  icon: Icons.sticky_note_2_outlined,
                  iconColor: AppColors.success,
                  children: [
                    AppTextField(
                      label: 'Observations',
                      hint: 'Informations utiles sur le camion',
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
                        icon:
                            isEditing ? Icons.edit_rounded : Icons.add_rounded,
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

enum _TruckAction {
  edit,
  delete,
}
