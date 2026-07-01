import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../clients/domain/repositories/clients_repository.dart';
import '../../drivers/domain/repositories/drivers_repository.dart';
import '../../sites/data/models/site_record.dart';
import '../../sites/domain/repositories/sites_repository.dart';
import '../../trucks/data/models/truck_model.dart';
import '../../trucks/domain/repositories/trucks_repository.dart';
import '../data/models/create_loading_request.dart';
import '../data/models/loading_driver_option.dart';
import '../data/models/loading_record.dart';
import '../domain/repositories/loadings_repository.dart';
import 'controllers/client_loading_controller.dart';

class ClientLoadingScreen extends StatefulWidget {
  final LoadingsRepository loadingsRepository;
  final ClientsRepository clientsRepository;
  final DriversRepository driversRepository;
  final TrucksRepository trucksRepository;
  final SitesRepository sitesRepository;
  final String? prefilledClientId;
  final bool lockPrefilledClient;

  const ClientLoadingScreen({
    super.key,
    required this.loadingsRepository,
    required this.clientsRepository,
    required this.driversRepository,
    required this.trucksRepository,
    required this.sitesRepository,
    this.prefilledClientId,
    this.lockPrefilledClient = true,
  });

  @override
  State<ClientLoadingScreen> createState() => _ClientLoadingScreenState();
}

class _ClientLoadingScreenState extends State<ClientLoadingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _moneyFormat = NumberFormat.decimalPattern('fr_FR');
  final _dateFormat = DateFormat(AppConstants.dateFormat);

  final _destinationCtrl = TextEditingController();
  final _bonCtrl = TextEditingController();
  final _quantityCtrl = TextEditingController();
  final _buyPriceCtrl = TextEditingController();
  final _sellPriceCtrl = TextEditingController();
  final _transportPriceCtrl = TextEditingController();
  final _fuelCtrl = TextEditingController(text: '0');
  final _roadCtrl = TextEditingController(text: '0');
  final _otherFeesCtrl = TextEditingController(text: '0');
  final _tripsCtrl = TextEditingController();

  late final ClientLoadingController _controller;

  DateTime _selectedDate = DateTime.now();
  String? _selectedType;
  String? _selectedClientId;
  String? _selectedSiteId;
  String? _selectedTruckId;
  String? _selectedDriverId;
  String? _proofPath;
  int _filePickerVersion = 0;
  _ClientLoadingView _activeView = _ClientLoadingView.history;

  @override
  void initState() {
    super.initState();
    _selectedClientId = widget.prefilledClientId;
    _controller = ClientLoadingController(
      loadingsRepository: widget.loadingsRepository,
      clientsRepository: widget.clientsRepository,
      driversRepository: widget.driversRepository,
      trucksRepository: widget.trucksRepository,
      sitesRepository: widget.sitesRepository,
    )..loadInitialData();

    for (final controller in [
      _quantityCtrl,
      _buyPriceCtrl,
      _sellPriceCtrl,
      _transportPriceCtrl,
      _fuelCtrl,
      _roadCtrl,
      _otherFeesCtrl,
      _tripsCtrl,
      _destinationCtrl,
      _bonCtrl,
    ]) {
      controller.addListener(_refreshComputedValues);
    }
  }

  @override
  void dispose() {
    for (final controller in [
      _destinationCtrl,
      _bonCtrl,
      _quantityCtrl,
      _buyPriceCtrl,
      _sellPriceCtrl,
      _transportPriceCtrl,
      _fuelCtrl,
      _roadCtrl,
      _otherFeesCtrl,
      _tripsCtrl,
    ]) {
      controller.removeListener(_refreshComputedValues);
      controller.dispose();
    }
    _controller.dispose();
    super.dispose();
  }

  bool get _isTransport => _selectedType == 'TRANSPORT';
  bool get _isMaterial =>
      _selectedType == 'SABLE' || _selectedType == 'GRAVIER';

  int get _validatedCount => _controller.loadings
      .where((item) => item.status.trim().toUpperCase() == 'VALIDE')
      .length;

  int get _draftCount => _controller.loadings
      .where((item) => item.status.trim().toUpperCase() == 'BROUILLON')
      .length;

  double get _quantity => _parseDouble(_quantityCtrl.text);
  int get _tripsCount => _parseInt(_tripsCtrl.text);
  int get _purchasePrice => _parseInt(_buyPriceCtrl.text);
  int get _salePrice => _parseInt(_sellPriceCtrl.text);
  int get _transportPrice => _parseInt(_transportPriceCtrl.text);
  int get _fuelExpense => _parseInt(_fuelCtrl.text);
  int get _roadFees => _parseInt(_roadCtrl.text);
  int get _otherFees => _parseInt(_otherFeesCtrl.text);

  int get _amountToPay {
    if (_isMaterial) {
      return (_quantity * _salePrice).round() + _transportPrice;
    }
    if (_isTransport) {
      return _tripsCount * _transportPrice;
    }
    return 0;
  }

  int get _totalExpenses {
    if (_isMaterial) {
      return (_quantity * _purchasePrice).round() +
          _fuelExpense +
          _roadFees +
          _otherFees;
    }

    if (_isTransport) {
      return _fuelExpense + _roadFees + _otherFees;
    }

    return 0;
  }

  int get _netMargin => _amountToPay - _totalExpenses;

  TruckModel? get _selectedTruck {
    final selectedId = _selectedTruckId;
    if (selectedId == null || selectedId.isEmpty) {
      return null;
    }
    return _controller.truckById(selectedId);
  }

  SiteRecord? get _selectedSite {
    final selectedId = _selectedSiteId;
    if (selectedId == null || selectedId.isEmpty) {
      return null;
    }
    return _controller.siteById(selectedId);
  }

  LoadingDriverOption? get _selectedDriver {
    final selectedId = _selectedDriverId;
    if (selectedId == null || selectedId.isEmpty) {
      return null;
    }
    return _controller.driverById(selectedId);
  }

  void _refreshComputedValues() {
    if (mounted) {
      setState(() {});
    }
  }

  void _switchView(_ClientLoadingView view) {
    FocusScope.of(context).unfocus();
    setState(() => _activeView = view);
  }

  void _onTypeChanged(String type) {
    FocusScope.of(context).unfocus();
    setState(() {
      _selectedType = type;
      if (type == 'TRANSPORT') {
        _selectedSiteId = null;
        _quantityCtrl.clear();
        _buyPriceCtrl.clear();
        _sellPriceCtrl.clear();
      } else {
        _tripsCtrl.clear();
      }
    });
  }

  void _onSiteChanged(String? siteId) {
    setState(() => _selectedSiteId = siteId);
    final site = _selectedSite;
    if (site != null && site.currentPrice > 0) {
      _buyPriceCtrl.text = site.currentPrice.toString();
    }
  }

  void _onTruckChanged(String? truckId) {
    if (truckId == null || truckId.trim().isEmpty) {
      setState(() {
        _selectedTruckId = truckId;
        _selectedDriverId = null;
      });
      return;
    }

    final assignedDriver = _controller.driverForTruck(truckId);
    setState(() {
      _selectedTruckId = truckId;
      _selectedDriverId = assignedDriver?.id;
    });
  }

  Future<void> _submit({required bool saveAsDraft}) async {
    FocusScope.of(context).unfocus();

    if (_selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Choisissez le type de chargement.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_controller.isSelectableClientId(_selectedClientId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Le client sélectionné n’est pas compatible avec l’API. Créez ou choisissez un client réel depuis l’écran Clients.',
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final driverId = _controller.isSelectableDriverId(_selectedDriverId)
        ? _selectedDriverId
        : null;

    final request = CreateLoadingRequest(
      date: _selectedDate,
      type: _selectedType!,
      clientId: _selectedClientId!,
      siteId: _isMaterial ? _selectedSiteId : null,
      truckId: _selectedTruckId,
      driverId: driverId,
      voucherNumber: _bonCtrl.text.trim(),
      destination: _destinationCtrl.text.trim(),
      quantity: _isMaterial ? _quantity : null,
      tripsCount: _isTransport ? _tripsCount : null,
      purchasePrice: _isMaterial ? _purchasePrice : null,
      salePrice: _isMaterial ? _salePrice : null,
      transportPrice: _transportPrice,
      fuelExpense: _fuelExpense,
      roadFees: _roadFees,
      otherFees: _otherFees,
      status: saveAsDraft ? 'BROUILLON' : 'VALIDE',
    );

    final created = await _controller.submit(
      request: request,
      proofPath: _proofPath,
    );
    if (!mounted || created == null) {
      return;
    }

    _resetForm();
    setState(() => _activeView = _ClientLoadingView.history);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_controller.successMessage ?? 'Chargement enregistré.'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _destinationCtrl.clear();
    _bonCtrl.clear();
    _quantityCtrl.clear();
    _buyPriceCtrl.clear();
    _sellPriceCtrl.clear();
    _transportPriceCtrl.clear();
    _fuelCtrl.text = '0';
    _roadCtrl.text = '0';
    _otherFeesCtrl.text = '0';
    _tripsCtrl.clear();

    setState(() {
      _selectedDate = DateTime.now();
      _selectedType = null;
      _selectedSiteId = null;
      _selectedTruckId = null;
      _selectedDriverId = null;
      _proofPath = null;
      _filePickerVersion += 1;
      _selectedClientId = widget.prefilledClientId;
    });
  }

  String? _validateTypeDependentQuantity(String? value) {
    if (!_isMaterial) {
      return null;
    }

    return _validatePositiveDouble(value, 'Entrez une quantité valide');
  }

  String? _validateTypeDependentTrips(String? value) {
    if (!_isTransport) {
      return null;
    }

    return _validatePositiveInt(value, 'Entrez un nombre de voyages valide');
  }

  String? _validateClient(String? value) {
    if ((value ?? '').trim().isEmpty) {
      return 'Choisissez un client';
    }
    return null;
  }

  String? _validateSite(String? value) {
    if (_isMaterial && (value ?? '').trim().isEmpty) {
      return 'Choisissez une carrière ou une usine';
    }
    return null;
  }

  String? _validateTruck(String? value) {
    if ((value ?? '').trim().isEmpty) {
      return 'Choisissez un camion';
    }
    return null;
  }

  String? _validateRequiredText(String? value, String message) {
    if ((value ?? '').trim().isEmpty) {
      return message;
    }
    return null;
  }

  String? _validatePositiveInt(String? value, String message) {
    final parsed = int.tryParse((value ?? '').trim());
    if (parsed == null || parsed <= 0) {
      return message;
    }
    return null;
  }

  String? _validateNonNegativeInt(String? value) {
    final trimmed = (value ?? '').trim();
    if (trimmed.isEmpty) {
      return null;
    }
    final parsed = int.tryParse(trimmed);
    if (parsed == null || parsed < 0) {
      return 'Montant invalide';
    }
    return null;
  }

  String? _validatePositiveDouble(String? value, String message) {
    final normalized = (value ?? '').trim().replaceAll(',', '.');
    final parsed = double.tryParse(normalized);
    if (parsed == null || parsed <= 0) {
      return message;
    }
    return null;
  }

  int _parseInt(String value, {int defaultValue = 0}) {
    return int.tryParse(value.trim()) ?? defaultValue;
  }

  double _parseDouble(String value, {double defaultValue = 0}) {
    return double.tryParse(value.trim().replaceAll(',', '.')) ?? defaultValue;
  }

  String _formatMoney(int value) {
    return '${_moneyFormat.format(value)} ${AppConstants.currencySymbol}';
  }

  String _formatQuantity(LoadingRecord loading) {
    if (loading.isMaterial) {
      final value = loading.quantity;
      final decimals = value % 1 == 0 ? 0 : 1;
      return '${value.toStringAsFixed(decimals)} T';
    }

    return '${loading.tripsCount} voyage(s)';
  }

  String _typeLabel(String type) {
    switch (type.trim().toUpperCase()) {
      case 'SABLE':
        return 'Sable';
      case 'GRAVIER':
        return 'Gravier';
      case 'TRANSPORT':
        return 'Transport';
      default:
        return type;
    }
  }

  IconData _typeIcon(String type) {
    switch (type.trim().toUpperCase()) {
      case 'SABLE':
        return Icons.grain_rounded;
      case 'GRAVIER':
        return Icons.layers_rounded;
      case 'TRANSPORT':
        return Icons.local_shipping_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  Color _typeColor(String type) {
    switch (type.trim().toUpperCase()) {
      case 'SABLE':
        return AppColors.info;
      case 'GRAVIER':
        return AppColors.primary;
      case 'TRANSPORT':
        return AppColors.warning;
      default:
        return AppColors.textSecondary;
    }
  }

  BadgeStatus _statusBadge(String status) {
    switch (status.trim().toUpperCase()) {
      case 'VALIDE':
        return BadgeStatus.success;
      case 'BROUILLON':
        return BadgeStatus.warning;
      case 'ANNULE':
      case 'REJETE':
        return BadgeStatus.error;
      default:
        return BadgeStatus.neutral;
    }
  }

  String _statusLabel(String status) {
    switch (status.trim().toUpperCase()) {
      case 'VALIDE':
        return 'Validé';
      case 'BROUILLON':
        return 'Brouillon';
      case 'ANNULE':
        return 'Annulé';
      case 'REJETE':
        return 'Rejeté';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final hasClients = _controller.selectableClients.isNotEmpty;
        final hasTrucks = _controller.availableTrucks.isNotEmpty;
        final hasSites = _controller.sites.isNotEmpty;
        final canSubmit = !_controller.isSubmitting &&
            !_controller.isLoadingReferences &&
            hasClients &&
            hasTrucks &&
            (!_isMaterial || hasSites);

        return AppLoadingOverlay(
          isLoading: _controller.isSubmitting,
          message: 'Enregistrement...',
          child: Scaffold(
            backgroundColor: AppColors.backgroundLight,
            appBar: AppBar(
              title: const Text('Chargements clients'),
              backgroundColor: AppColors.surface,
            ),
            body: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: _ClientLoadingViewToggle(
                      activeView: _activeView,
                      onChanged: _switchView,
                    ),
                  ),
                  Expanded(
                    child: _activeView == _ClientLoadingView.history
                        ? _buildHistoryView()
                        : _buildCreateView(canSubmit: canSubmit),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHistoryView() {
    final items = _controller.loadings;
    final errorMessage = _controller.loadingsErrorMessage;

    if (_controller.isLoadingLoadings && items.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (errorMessage != null && items.isEmpty) {
      return AppEmptyState(
        icon: Icons.inventory_2_rounded,
        title: 'Chargements indisponibles',
        subtitle: errorMessage,
        actionLabel: 'Réessayer',
        onAction: _controller.loadLoadings,
      );
    }

    if (items.isEmpty) {
      return AppEmptyState(
        icon: Icons.inventory_2_rounded,
        title: 'Aucun chargement enregistré',
        subtitle:
            'Les opérations de sable, gravier et transport apparaîtront ici.',
        actionLabel: 'Nouveau chargement',
        onAction: () => _switchView(_ClientLoadingView.create),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _controller.loadLoadings,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
        children: [
          if (_controller.isLoadingLoadings) ...[
            const LinearProgressIndicator(
              color: AppColors.primary,
              minHeight: 3,
            ),
            const SizedBox(height: 14),
          ],
          if (errorMessage != null) ...[
            _LoadingErrorBanner(
              message: errorMessage,
              actionLabel: 'Réessayer',
              onAction: _controller.loadLoadings,
            ),
            const SizedBox(height: 14),
          ],
          AppSectionCard(
            title: 'Historique des chargements',
            icon: Icons.history_rounded,
            iconColor: AppColors.primary,
            children: [
              Text(
                'Consultez les dernières opérations envoyées aux clients avec leur marge nette.',
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _LoadingMetricPill(
                    value: '${items.length}',
                    label: 'Total',
                    color: AppColors.primary,
                  ),
                  _LoadingMetricPill(
                    value: '$_validatedCount',
                    label: 'Validés',
                    color: AppColors.success,
                  ),
                  _LoadingMetricPill(
                    value: '$_draftCount',
                    label: 'Brouillons',
                    color: AppColors.warning,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...items.map(
            (loading) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _LoadingHistoryCard(
                loading: loading,
                typeLabel: _typeLabel(loading.type),
                typeIcon: _typeIcon(loading.type),
                typeColor: _typeColor(loading.type),
                statusLabel: _statusLabel(loading.status),
                statusBadge: _statusBadge(loading.status),
                amountLabel: _formatMoney(loading.amountToPay),
                marginLabel: _formatMoney(loading.netMargin.abs()),
                quantityLabel: _formatQuantity(loading),
                dateLabel: _dateFormat.format(loading.date),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateView({required bool canSubmit}) {
    final errorMessage = _controller.formErrorMessage;
    final referencesLoaded = !_controller.isLoadingReferences;
    final availableClients = _controller.selectableClients;
    final availableTrucks = _controller.availableTrucks;
    final availableDrivers = _controller.availableDrivers;
    final hasClients = availableClients.isNotEmpty;
    final hasTrucks = availableTrucks.isNotEmpty;
    final hasSites = _controller.sites.isNotEmpty;
    final hasLockedPrefilledClient = widget.lockPrefilledClient &&
        widget.prefilledClientId != null &&
        availableClients.any((client) => client.id == widget.prefilledClientId);

    final clientDropdownValue = availableClients.any(
      (client) => client.id == _selectedClientId,
    )
        ? _selectedClientId
        : null;
    final siteDropdownValue = _controller.sites.any(
      (site) => site.id == _selectedSiteId,
    )
        ? _selectedSiteId
        : null;
    final truckDropdownValue = availableTrucks.any(
      (truck) => truck.id == _selectedTruckId,
    )
        ? _selectedTruckId
        : null;
    final driverDropdownValue = availableDrivers.any(
      (driver) => driver.id == _selectedDriverId,
    )
        ? _selectedDriverId
        : null;

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
        children: [
          if (errorMessage != null) ...[
            _LoadingErrorBanner(
              message: errorMessage,
              actionLabel: referencesLoaded ? 'Réessayer' : null,
              onAction: referencesLoaded ? _controller.loadReferences : null,
            ),
            const SizedBox(height: 16),
          ],
          if (_controller.hasLegacyClients) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.warning.withValues(alpha: 0.20),
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
                      'Seuls les clients créés avec un identifiant UUID peuvent être utilisés pour ce formulaire. Les anciens clients restent visibles dans l’écran Clients mais sont exclus ici.',
                      style: AppTextStyles.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (_controller.hasLegacyDrivers) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.warning.withValues(alpha: 0.20),
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
                      'Seuls les chauffeurs actifs avec un identifiant UUID peuvent etre utilises pour ce formulaire. Les anciens chauffeurs restent gerables dans l’ecran Chauffeurs mais sont exclus ici.',
                      style: AppTextStyles.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (widget.prefilledClientId != null &&
              !hasLockedPrefilledClient &&
              !_controller.isLoadingReferences) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.warning.withValues(alpha: 0.20),
                ),
              ),
              child: Text(
                'Le client prérempli ne peut pas être réutilisé tel quel pour un chargement API. Choisissez un client réel créé depuis l’écran Clients.',
                style: AppTextStyles.bodyMedium,
              ),
            ),
            const SizedBox(height: 16),
          ],
          _buildTypeSelector(),
          const SizedBox(height: 16),
          if (_selectedType != null) ...[
            AppSectionCard(
              title: 'Informations générales',
              icon: Icons.info_outline_rounded,
              iconColor: AppColors.primary,
              children: [
                if (_controller.isLoadingReferences) ...[
                  const LinearProgressIndicator(
                    color: AppColors.primary,
                    minHeight: 3,
                  ),
                  const SizedBox(height: 14),
                ],
                AppDropdown<String>(
                  label: 'Client',
                  required: true,
                  value: clientDropdownValue,
                  hint: hasClients
                      ? 'Sélectionner un client...'
                      : 'Aucun client utilisable',
                  enabled: !_controller.isLoadingReferences &&
                      hasClients &&
                      !hasLockedPrefilledClient,
                  items: availableClients
                      .map(
                        (client) => DropdownMenuItem<String>(
                          value: client.id,
                          child: Text(
                            client.name,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  validator: _validateClient,
                  onChanged: (value) =>
                      setState(() => _selectedClientId = value),
                ),
                if (_isMaterial) ...[
                  const SizedBox(height: 14),
                  AppDropdown<String>(
                    label: 'Carrière / Usine',
                    required: true,
                    value: siteDropdownValue,
                    hint:
                        hasSites ? 'Sélectionner...' : 'Aucun site disponible',
                    enabled: !_controller.isLoadingReferences && hasSites,
                    items: _controller.sites
                        .map(
                          (site) => DropdownMenuItem<String>(
                            value: site.id,
                            child: Text(
                              '${site.name} (${_siteTypeLabel(site.type)})',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    validator: _validateSite,
                    onChanged: _onSiteChanged,
                  ),
                ],
                if (_selectedSite != null &&
                    _selectedSite!.location.trim().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    _selectedSite!.location,
                    style: AppTextStyles.bodySmall,
                  ),
                ],
                const SizedBox(height: 14),
                AppDropdown<String>(
                  label: 'Camion',
                  required: true,
                  value: truckDropdownValue,
                  hint: hasTrucks
                      ? 'Sélectionner un camion disponible...'
                      : 'Aucun camion disponible',
                  enabled: !_controller.isLoadingReferences && hasTrucks,
                  items: availableTrucks
                      .map(
                        (truck) => DropdownMenuItem<String>(
                          value: truck.id,
                          child: Text(
                            truck.plate.trim().isEmpty ? 'Camion' : truck.plate,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  validator: _validateTruck,
                  onChanged: _onTruckChanged,
                ),
                if (_selectedTruck != null &&
                    _selectedTruck!.driver.trim().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Chauffeur affecté : ${_selectedTruck!.driver}',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
                const SizedBox(height: 14),
                AppDropdown<String>(
                  label: 'Chauffeur',
                  value: driverDropdownValue,
                  hint: availableDrivers.isNotEmpty
                      ? 'Sélectionner un chauffeur...'
                      : 'Aucun chauffeur disponible',
                  enabled: !_controller.isLoadingReferences &&
                      availableDrivers.isNotEmpty,
                  items: availableDrivers
                      .map(
                        (driver) => DropdownMenuItem<String>(
                          value: driver.id,
                          child: Text(
                            driver.name,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) =>
                      setState(() => _selectedDriverId = value),
                ),
                if (_selectedDriver != null &&
                    _selectedDriver!.truckRegistration.trim().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Camion associé : ${_selectedDriver!.truckRegistration}',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
                const SizedBox(height: 14),
                AppDatePicker(
                  label: 'Date',
                  value: _selectedDate,
                  required: true,
                  onChanged: (date) => setState(() => _selectedDate = date),
                ),
                const SizedBox(height: 14),
                AppTextField(
                  label: 'Destination',
                  hint: 'Ex: Yopougon Marché',
                  controller: _destinationCtrl,
                  required: true,
                  validator: (value) => _validateRequiredText(
                    value,
                    'Entrez la destination',
                  ),
                ),
                const SizedBox(height: 14),
                AppTextField(
                  label: 'Numéro de bon',
                  hint: 'BON-2026-001',
                  controller: _bonCtrl,
                  required: true,
                  validator: (value) => _validateRequiredText(
                    value,
                    'Entrez le numéro de bon',
                  ),
                ),
                if (!_controller.isLoadingReferences &&
                    (!hasClients ||
                        !hasTrucks ||
                        (_isMaterial && !hasSites))) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.warning.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Text(
                      hasClients
                          ? 'Le formulaire demande au moins un client, un camion disponible et, pour sable/gravier, un site affecté à votre compte.'
                          : 'Créez d’abord un client réel dans l’écran Clients, puis revenez ici pour enregistrer le chargement.',
                      style: AppTextStyles.bodyMedium,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            AppSectionCard(
              title: 'Informations financières',
              icon: Icons.attach_money_rounded,
              iconColor: AppColors.success,
              children: [
                if (_isMaterial) ...[
                  AppTextField(
                    label: 'Quantité (en tonnes)',
                    hint: '0',
                    controller: _quantityCtrl,
                    required: true,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: _validateTypeDependentQuantity,
                  ),
                  const SizedBox(height: 14),
                  AppMoneyField(
                    label: 'Prix achat (par tonne)',
                    controller: _buyPriceCtrl,
                    required: true,
                    validator: (value) => _validatePositiveInt(
                      value,
                      'Entrez un prix achat valide',
                    ),
                  ),
                  const SizedBox(height: 14),
                  AppMoneyField(
                    label: 'Prix vente (par tonne)',
                    controller: _sellPriceCtrl,
                    required: true,
                    validator: (value) => _validatePositiveInt(
                      value,
                      'Entrez un prix vente valide',
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
                if (_isTransport) ...[
                  AppTextField(
                    label: 'Nombre de voyages',
                    hint: '0',
                    controller: _tripsCtrl,
                    required: true,
                    keyboardType: TextInputType.number,
                    validator: _validateTypeDependentTrips,
                  ),
                  const SizedBox(height: 14),
                ],
                AppMoneyField(
                  label:
                      'Prix transport (${_isTransport ? "par voyage" : "forfait"})',
                  controller: _transportPriceCtrl,
                  required: true,
                  validator: (value) => _validatePositiveInt(
                    value,
                    'Entrez un prix transport valide',
                  ),
                ),
                const SizedBox(height: 14),
                AppMoneyField(
                  label: 'Dépense carburant',
                  controller: _fuelCtrl,
                  validator: _validateNonNegativeInt,
                ),
                const SizedBox(height: 14),
                AppMoneyField(
                  label: 'Frais de route',
                  controller: _roadCtrl,
                  validator: _validateNonNegativeInt,
                ),
                const SizedBox(height: 14),
                AppMoneyField(
                  label: 'Autres frais',
                  controller: _otherFeesCtrl,
                  validator: _validateNonNegativeInt,
                ),
              ],
            ),
            const SizedBox(height: 16),
            AppSectionCard(
              title: 'Justificatif',
              icon: Icons.attachment_rounded,
              iconColor: AppColors.info,
              children: [
                AppFilePicker(
                  key: ValueKey(_filePickerVersion),
                  label: 'Photo ou scan du bon de chargement',
                  onFileSelected: (path) => setState(() => _proofPath = path),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildCalculationCard(),
            const SizedBox(height: 16),
            AppSummaryCard(
              title: '📋 Résumé avant validation',
              color: AppColors.primary,
              rows: [
                AppSummaryRow(
                  label: 'Type',
                  value:
                      _selectedType == null ? '—' : _typeLabel(_selectedType!),
                ),
                AppSummaryRow(
                  label: 'Client',
                  value: _selectedClientId == null
                      ? '—'
                      : (_controller.clientById(_selectedClientId!)?.name ??
                          '—'),
                ),
                AppSummaryRow(
                  label: 'Camion',
                  value: _selectedTruck?.plate.trim().isNotEmpty == true
                      ? _selectedTruck!.plate
                      : '—',
                ),
                AppSummaryRow(
                  label: 'Chauffeur',
                  value: _selectedDriver?.name.trim().isNotEmpty == true
                      ? _selectedDriver!.name
                      : '—',
                ),
                AppSummaryRow(
                  label: 'Montant à facturer',
                  value: _formatMoney(_amountToPay),
                  valueColor: AppColors.info,
                  isBold: true,
                ),
                AppSummaryRow(
                  label: 'Marge nette',
                  value: _formatMoney(_netMargin.abs()),
                  valueColor:
                      _netMargin >= 0 ? AppColors.success : AppColors.error,
                  isBold: true,
                ),
              ],
            ),
            const SizedBox(height: 20),
            AppButton(
              label: 'Valider le chargement',
              icon: Icons.check_circle_rounded,
              onPressed: canSubmit ? () => _submit(saveAsDraft: false) : null,
            ),
            const SizedBox(height: 10),
            AppButton(
              label: AppStrings.draft,
              variant: AppButtonVariant.outlined,
              icon: Icons.save_outlined,
              onPressed: canSubmit ? () => _submit(saveAsDraft: true) : null,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypeSelector() {
    return AppSectionCard(
      title: 'Type de chargement',
      icon: Icons.category_rounded,
      iconColor: AppColors.primary,
      children: [
        Text(
          'Sélectionnez le type d\'opération avant de remplir le formulaire.',
          style: AppTextStyles.bodyMedium,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _LoadingTypeTile(
                label: 'Sable',
                icon: Icons.grain_rounded,
                color: AppColors.info,
                isSelected: _selectedType == 'SABLE',
                onTap: () => _onTypeChanged('SABLE'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _LoadingTypeTile(
                label: 'Gravier',
                icon: Icons.layers_rounded,
                color: AppColors.primary,
                isSelected: _selectedType == 'GRAVIER',
                onTap: () => _onTypeChanged('GRAVIER'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _LoadingTypeTile(
                label: 'Transport',
                icon: Icons.local_shipping_rounded,
                color: AppColors.warning,
                isSelected: _selectedType == 'TRANSPORT',
                onTap: () => _onTypeChanged('TRANSPORT'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCalculationCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.08),
            AppColors.info.withValues(alpha: 0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.25),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.calculate_rounded,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Calcul automatique',
                style: AppTextStyles.headlineSmall.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.divider),
          _calcRow(
            'Montant à facturer',
            _formatMoney(_amountToPay),
            AppColors.info,
          ),
          _calcRow(
            'Total dépenses',
            _formatMoney(_totalExpenses),
            AppColors.error,
          ),
          const Divider(color: AppColors.divider),
          _calcRow(
            'Marge nette',
            _formatMoney(_netMargin.abs()),
            _netMargin >= 0 ? AppColors.success : AppColors.error,
            bold: true,
            prefix: _netMargin < 0 ? '- ' : '',
          ),
        ],
      ),
    );
  }

  Widget _calcRow(
    String label,
    String value,
    Color color, {
    bool bold = false,
    String prefix = '',
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: bold ? AppTextStyles.titleLarge : AppTextStyles.bodyMedium,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$prefix$value',
              style:
                  (bold ? AppTextStyles.moneySmall : AppTextStyles.titleMedium)
                      .copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }

  String _siteTypeLabel(String type) {
    switch (type.trim().toUpperCase()) {
      case 'CARRIERE':
        return 'Carrière';
      case 'USINE':
        return 'Usine';
      default:
        return 'Site';
    }
  }
}

enum _ClientLoadingView {
  history,
  create,
}

class _ClientLoadingViewToggle extends StatelessWidget {
  final _ClientLoadingView activeView;
  final ValueChanged<_ClientLoadingView> onChanged;

  const _ClientLoadingViewToggle({
    required this.activeView,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
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
      ),
      child: Row(
        children: [
          Expanded(
            child: _ClientLoadingViewButton(
              label: 'Historique',
              icon: Icons.history_rounded,
              isActive: activeView == _ClientLoadingView.history,
              onTap: () => onChanged(_ClientLoadingView.history),
            ),
          ),
          Expanded(
            child: _ClientLoadingViewButton(
              label: 'Nouveau',
              icon: Icons.add_circle_outline_rounded,
              isActive: activeView == _ClientLoadingView.create,
              onTap: () => onChanged(_ClientLoadingView.create),
            ),
          ),
        ],
      ),
    );
  }
}

class _ClientLoadingViewButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _ClientLoadingViewButton({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primarySurface : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isActive ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTextStyles.titleMedium.copyWith(
                color: isActive ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingTypeTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _LoadingTypeTile({
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.12)
              : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? color : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? color : AppColors.textTertiary,
              size: 24,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTextStyles.titleMedium.copyWith(
                color: isSelected ? color : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingMetricPill extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _LoadingMetricPill({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: AppTextStyles.headlineSmall.copyWith(color: color),
          ),
          Text(label, style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }
}

class _LoadingHistoryCard extends StatelessWidget {
  final LoadingRecord loading;
  final String typeLabel;
  final IconData typeIcon;
  final Color typeColor;
  final String statusLabel;
  final BadgeStatus statusBadge;
  final String amountLabel;
  final String marginLabel;
  final String quantityLabel;
  final String dateLabel;

  const _LoadingHistoryCard({
    required this.loading,
    required this.typeLabel,
    required this.typeIcon,
    required this.typeColor,
    required this.statusLabel,
    required this.statusBadge,
    required this.amountLabel,
    required this.marginLabel,
    required this.quantityLabel,
    required this.dateLabel,
  });

  @override
  Widget build(BuildContext context) {
    final hasProof = loading.proofUrl.trim().isNotEmpty;
    final marginColor =
        loading.netMargin >= 0 ? AppColors.success : AppColors.error;

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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loading.clientName.trim().isEmpty
                          ? 'Client'
                          : loading.clientName,
                      style: AppTextStyles.headlineSmall,
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        AppStatusBadge(
                          label: typeLabel,
                          status: _typeBadge(loading.type),
                          small: true,
                        ),
                        AppStatusBadge(
                          label: statusLabel,
                          status: statusBadge,
                          small: true,
                        ),
                        if (hasProof)
                          const AppStatusBadge(
                            label: 'Justificatif',
                            status: BadgeStatus.info,
                            small: true,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    amountLabel,
                    style: AppTextStyles.moneySmall.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    loading.netMargin < 0 ? '- $marginLabel' : marginLabel,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: marginColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 10,
            children: [
              _LoadingMeta(
                icon: Icons.calendar_today_rounded,
                label: dateLabel,
              ),
              _LoadingMeta(
                icon: typeIcon,
                label: quantityLabel,
              ),
              if (loading.siteName.trim().isNotEmpty)
                _LoadingMeta(
                  icon: Icons.factory_rounded,
                  label: loading.siteName,
                ),
              if (loading.truckRegistration.trim().isNotEmpty)
                _LoadingMeta(
                  icon: Icons.local_shipping_rounded,
                  label: loading.truckRegistration,
                ),
              if (loading.driverName.trim().isNotEmpty)
                _LoadingMeta(
                  icon: Icons.person_outline_rounded,
                  label: loading.driverName,
                ),
              if (loading.destination.trim().isNotEmpty)
                _LoadingMeta(
                  icon: Icons.place_outlined,
                  label: loading.destination,
                ),
              if (loading.voucherNumber.trim().isNotEmpty)
                _LoadingMeta(
                  icon: Icons.confirmation_number_outlined,
                  label: loading.voucherNumber,
                ),
            ],
          ),
        ],
      ),
    );
  }

  BadgeStatus _typeBadge(String type) {
    switch (type.trim().toUpperCase()) {
      case 'SABLE':
        return BadgeStatus.info;
      case 'GRAVIER':
        return BadgeStatus.success;
      case 'TRANSPORT':
        return BadgeStatus.warning;
      default:
        return BadgeStatus.neutral;
    }
  }
}

class _LoadingMeta extends StatelessWidget {
  final IconData icon;
  final String label;

  const _LoadingMeta({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _LoadingErrorBanner extends StatelessWidget {
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _LoadingErrorBanner({
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
          color: AppColors.error.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: AppColors.error,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
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
