import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_widgets.dart';
import '../data/models/create_factory_payment_request.dart';
import '../data/models/factory_payment_record.dart';
import '../data/models/factory_site_option.dart';
import '../domain/repositories/factory_payments_repository.dart';
import 'controllers/factory_payment_controller.dart';
import 'factory_payment_detail_screen.dart';

class FactoryPaymentScreen extends StatefulWidget {
  final FactoryPaymentsRepository repository;

  const FactoryPaymentScreen({
    super.key,
    required this.repository,
  });

  @override
  State<FactoryPaymentScreen> createState() => _FactoryPaymentScreenState();
}

class _FactoryPaymentScreenState extends State<FactoryPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _paidByCtrl = TextEditingController();
  final _bonCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _discountCtrl = TextEditingController(text: '0');
  final _tonnageCtrl = TextEditingController();
  final _moneyFormat = NumberFormat.decimalPattern('fr_FR');
  final _dateFormat = DateFormat(AppConstants.dateFormat);

  late final FactoryPaymentController _controller;
  DateTime _date = DateTime.now();
  String? _selectedSiteId;
  String? _proofPath;
  int _filePickerVersion = 0;
  _FactoryPaymentView _activeView = _FactoryPaymentView.history;

  @override
  void initState() {
    super.initState();
    _controller = FactoryPaymentController(widget.repository)
      ..loadInitialData();
    for (final controller in [
      _paidByCtrl,
      _bonCtrl,
      _amountCtrl,
      _priceCtrl,
      _discountCtrl,
      _tonnageCtrl,
    ]) {
      controller.addListener(_refreshSummary);
    }
  }

  @override
  void dispose() {
    for (final controller in [
      _paidByCtrl,
      _bonCtrl,
      _amountCtrl,
      _priceCtrl,
      _discountCtrl,
      _tonnageCtrl,
    ]) {
      controller.removeListener(_refreshSummary);
      controller.dispose();
    }
    _controller.dispose();
    super.dispose();
  }

  void _refreshSummary() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _submit({required bool saveAsDraft}) async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final request = CreateFactoryPaymentRequest(
      siteId: _selectedSiteId!,
      date: _date,
      payerName: _paidByCtrl.text.trim(),
      voucherNumber: _bonCtrl.text.trim(),
      amount: _parseInt(_amountCtrl.text),
      currentPrice: _parseInt(_priceCtrl.text),
      rebate: _parseInt(_discountCtrl.text, defaultValue: 0),
      tonnage: _parseDouble(_tonnageCtrl.text),
      status: saveAsDraft ? 'BROUILLON' : 'VALIDE',
    );

    final payment = await _controller.submit(
      request: request,
      proofPath: _proofPath,
    );
    if (!mounted || payment == null) {
      return;
    }

    _resetForm();
    setState(() => _activeView = _FactoryPaymentView.history);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_controller.successMessage ?? 'Versement enregistré !'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _paidByCtrl.clear();
    _bonCtrl.clear();
    _amountCtrl.clear();
    _priceCtrl.clear();
    _discountCtrl.text = '0';
    _tonnageCtrl.clear();
    setState(() {
      _selectedSiteId = null;
      _proofPath = null;
      _date = DateTime.now();
      _filePickerVersion += 1;
    });
  }

  void _switchView(_FactoryPaymentView view) {
    FocusScope.of(context).unfocus();
    setState(() => _activeView = view);
  }

  Future<void> _openPaymentDetail(String paymentId) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FactoryPaymentDetailScreen(
          controller: _controller,
          paymentId: paymentId,
        ),
      ),
    );
  }

  void _onSiteChanged(String? siteId) {
    setState(() => _selectedSiteId = siteId);
    final selectedSite = _selectedSite;
    if (selectedSite != null && selectedSite.currentPrice > 0) {
      _priceCtrl.text = selectedSite.currentPrice.toString();
    }
  }

  FactorySiteOption? get _selectedSite {
    final selectedId = _selectedSiteId;
    if (selectedId == null || selectedId.isEmpty) {
      return null;
    }

    for (final site in _controller.sites) {
      if (site.id == selectedId) {
        return site;
      }
    }

    return null;
  }

  String? _validateSite(String? value) {
    if ((value ?? '').trim().isEmpty) {
      return 'Choisissez une carrière ou une usine';
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

  String _formatMoneyPreview(String value) {
    if (value.trim().isEmpty) {
      return '0 ${AppConstants.currencySymbol}';
    }

    final parsed = int.tryParse(value.trim());
    if (parsed == null) {
      return '${value.trim()} ${AppConstants.currencySymbol}';
    }

    return _formatMoney(parsed);
  }

  String _formatMetricAmount(FactoryPaymentRecord payment) {
    return _formatMoney(payment.amount);
  }

  String _formatTonnage(FactoryPaymentRecord payment) {
    if (payment.tonnage > 0) {
      return '${payment.tonnage.toStringAsFixed(payment.tonnage % 1 == 0 ? 0 : 1)} T';
    }

    if (payment.quantity > 0) {
      return payment.quantity
          .toStringAsFixed(payment.quantity % 1 == 0 ? 0 : 1);
    }

    return '—';
  }

  int get _validatedCount {
    return _controller.payments
        .where((payment) => payment.status.trim().toUpperCase() == 'VALIDE')
        .length;
  }

  int get _draftCount {
    return _controller.payments
        .where((payment) => payment.status.trim().toUpperCase() == 'BROUILLON')
        .length;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final hasAvailableSites = _controller.sites.isNotEmpty;
        final canSubmit = !_controller.isSubmitting &&
            !_controller.isLoadingSites &&
            hasAvailableSites;

        return AppLoadingOverlay(
          isLoading: _controller.isSubmitting,
          message: 'Enregistrement...',
          child: Scaffold(
            backgroundColor: AppColors.backgroundLight,
            appBar: AppBar(
              title: const Text('Versements usine'),
              backgroundColor: AppColors.surface,
            ),
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: _FactoryPaymentViewToggle(
                    activeView: _activeView,
                    onChanged: _switchView,
                  ),
                ),
                Expanded(
                  child: _activeView == _FactoryPaymentView.history
                      ? _buildHistoryView()
                      : _buildCreateView(canSubmit: canSubmit),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHistoryView() {
    final payments = _controller.payments;
    final errorMessage = _controller.paymentsErrorMessage;

    if (_controller.isLoadingPayments && payments.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (errorMessage != null && payments.isEmpty) {
      return AppEmptyState(
        icon: Icons.receipt_long_rounded,
        title: 'Historique indisponible',
        subtitle: errorMessage,
        actionLabel: 'Réessayer',
        onAction: _controller.loadPayments,
      );
    }

    if (payments.isEmpty) {
      return AppEmptyState(
        icon: Icons.receipt_long_rounded,
        title: 'Aucun versement enregistré',
        subtitle: 'Vos versements usine apparaîtront ici.',
        actionLabel: 'Nouveau versement',
        onAction: () => _switchView(_FactoryPaymentView.create),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _controller.loadPayments,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
        children: [
          if (_controller.isLoadingPayments) ...[
            const LinearProgressIndicator(
              color: AppColors.primary,
              minHeight: 3,
            ),
            const SizedBox(height: 14),
          ],
          if (errorMessage != null) ...[
            _ErrorBanner(
              message: errorMessage,
              actionLabel: 'Réessayer',
              onAction: _controller.loadPayments,
            ),
            const SizedBox(height: 14),
          ],
          AppSectionCard(
            title: 'Historique des versements',
            icon: Icons.history_rounded,
            iconColor: AppColors.primary,
            children: [
              Text(
                'Consultez les dernières opérations enregistrées sur vos usines et carrières.',
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _MetricPill(
                    value: '${payments.length}',
                    label: 'Total',
                    color: AppColors.primary,
                  ),
                  _MetricPill(
                    value: '$_validatedCount',
                    label: 'Validés',
                    color: AppColors.success,
                  ),
                  _MetricPill(
                    value: '$_draftCount',
                    label: 'Brouillons',
                    color: AppColors.warning,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...payments.map(
            (payment) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _FactoryPaymentHistoryCard(
                payment: payment,
                amountLabel: _formatMetricAmount(payment),
                dateLabel: _dateFormat.format(payment.date),
                tonnageLabel: _formatTonnage(payment),
                priceLabel: payment.currentPrice > 0
                    ? '${_moneyFormat.format(payment.currentPrice)} ${AppConstants.currencySymbol}/T'
                    : '—',
                onTap: () => _openPaymentDetail(payment.id),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateView({required bool canSubmit}) {
    final errorMessage = _controller.formErrorMessage;
    final selectedSite = _selectedSite;
    final hasAvailableSites = _controller.sites.isNotEmpty;

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
        children: [
          if (errorMessage != null) ...[
            _ErrorBanner(
              message: errorMessage,
              actionLabel:
                  !_controller.isLoadingSites && _controller.sites.isEmpty
                      ? 'Réessayer'
                      : null,
              onAction: !_controller.isLoadingSites && _controller.sites.isEmpty
                  ? _controller.loadSites
                  : null,
            ),
            const SizedBox(height: 16),
          ],
          AppSectionCard(
            title: 'Informations générales',
            icon: Icons.factory_rounded,
            iconColor: AppColors.primary,
            children: [
              if (_controller.isLoadingSites) ...[
                const LinearProgressIndicator(
                  color: AppColors.primary,
                  minHeight: 3,
                ),
                const SizedBox(height: 14),
              ],
              AppDropdown<String>(
                label: 'Carrière / Usine',
                required: true,
                hint: _controller.isLoadingSites
                    ? 'Chargement...'
                    : 'Sélectionner...',
                value: _selectedSiteId,
                enabled:
                    !_controller.isLoadingSites && _controller.sites.isNotEmpty,
                validator: _validateSite,
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
                onChanged: _onSiteChanged,
              ),
              if (!_controller.isLoadingSites &&
                  errorMessage == null &&
                  !hasAvailableSites) ...[
                const SizedBox(height: 12),
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
                    "Aucune carrière ou usine n'est affectée à ce compte. Il faut d'abord créer le site ou l'affecter à l'utilisateur côté API.",
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
              if (selectedSite != null &&
                  selectedSite.location.trim().isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  selectedSite.location,
                  style: AppTextStyles.bodySmall,
                ),
              ],
              const SizedBox(height: 14),
              AppDatePicker(
                label: 'Date',
                value: _date,
                required: true,
                onChanged: (date) => setState(() => _date = date),
              ),
              const SizedBox(height: 14),
              AppTextField(
                label: 'Nom du verseur',
                hint: 'Prénom et nom',
                controller: _paidByCtrl,
                required: true,
                validator: (value) => _validateRequiredText(
                  value,
                  'Entrez le nom du verseur',
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
            ],
          ),
          const SizedBox(height: 16),
          AppSectionCard(
            title: 'Informations financières',
            icon: Icons.payments_rounded,
            iconColor: AppColors.success,
            children: [
              AppMoneyField(
                label: 'Montant versé',
                controller: _amountCtrl,
                required: true,
                validator: (value) => _validatePositiveInt(
                  value,
                  'Entrez un montant valide',
                ),
              ),
              const SizedBox(height: 14),
              AppMoneyField(
                label: 'Prix actuel (par tonne)',
                controller: _priceCtrl,
                required: true,
                validator: (value) => _validatePositiveInt(
                  value,
                  'Entrez un prix valide',
                ),
              ),
              const SizedBox(height: 14),
              AppMoneyField(
                label: 'Ristourne',
                controller: _discountCtrl,
                validator: _validateNonNegativeInt,
              ),
              const SizedBox(height: 14),
              AppTextField(
                label: 'Tonnage',
                hint: '0 T',
                controller: _tonnageCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                required: true,
                validator: (value) => _validatePositiveDouble(
                  value,
                  'Entrez un tonnage valide',
                ),
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
                label: 'Photo ou scan du reçu',
                onFileSelected: (path) {
                  setState(() => _proofPath = path);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          AppSummaryCard(
            title: '📋 Résumé avant validation',
            color: AppColors.primary,
            rows: [
              AppSummaryRow(
                label: 'Carrière / Usine',
                value: selectedSite?.name ?? '—',
              ),
              AppSummaryRow(
                label: 'Montant',
                value: _formatMoneyPreview(_amountCtrl.text),
              ),
              AppSummaryRow(
                label: 'Tonnage',
                value: _tonnageCtrl.text.trim().isEmpty
                    ? '0 T'
                    : '${_tonnageCtrl.text.trim()} T',
              ),
              AppSummaryRow(
                label: 'Verseur',
                value: _paidByCtrl.text.trim().isEmpty
                    ? '—'
                    : _paidByCtrl.text.trim(),
              ),
              AppSummaryRow(
                label: 'Justificatif',
                value: _proofPath == null ? 'Non joint' : 'Joint',
              ),
            ],
          ),
          const SizedBox(height: 20),
          AppButton(
            label: 'Valider le versement',
            icon: Icons.check_circle_rounded,
            onPressed: canSubmit ? () => _submit(saveAsDraft: false) : null,
          ),
          const SizedBox(height: 10),
          AppButton(
            label: 'Enregistrer brouillon',
            variant: AppButtonVariant.outlined,
            icon: Icons.save_outlined,
            onPressed: canSubmit ? () => _submit(saveAsDraft: true) : null,
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

class _FactoryPaymentViewToggle extends StatelessWidget {
  final _FactoryPaymentView activeView;
  final ValueChanged<_FactoryPaymentView> onChanged;

  const _FactoryPaymentViewToggle({
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
            child: _FactoryPaymentViewButton(
              label: 'Historique',
              icon: Icons.history_rounded,
              isActive: activeView == _FactoryPaymentView.history,
              onTap: () => onChanged(_FactoryPaymentView.history),
            ),
          ),
          Expanded(
            child: _FactoryPaymentViewButton(
              label: 'Nouveau',
              icon: Icons.add_circle_outline_rounded,
              isActive: activeView == _FactoryPaymentView.create,
              onTap: () => onChanged(_FactoryPaymentView.create),
            ),
          ),
        ],
      ),
    );
  }
}

class _FactoryPaymentViewButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _FactoryPaymentViewButton({
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

class _MetricPill extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _MetricPill({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
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

class _FactoryPaymentHistoryCard extends StatelessWidget {
  final FactoryPaymentRecord payment;
  final String amountLabel;
  final String dateLabel;
  final String tonnageLabel;
  final String priceLabel;
  final VoidCallback onTap;

  const _FactoryPaymentHistoryCard({
    required this.payment,
    required this.amountLabel,
    required this.dateLabel,
    required this.tonnageLabel,
    required this.priceLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasProof = payment.proofUrl.trim().isNotEmpty;

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
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
                          payment.siteName.trim().isEmpty
                              ? 'Site'
                              : payment.siteName,
                          style: AppTextStyles.headlineSmall,
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            AppStatusBadge(
                              label: _siteTypeLabel(payment.siteType),
                              status: _siteTypeStatus(payment.siteType),
                              small: true,
                            ),
                            AppStatusBadge(
                              label: _statusLabel(payment.status),
                              status: _statusBadge(payment.status),
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
                      const SizedBox(height: 8),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.textSecondary,
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
                  _HistoryMeta(
                    icon: Icons.calendar_today_rounded,
                    label: dateLabel,
                  ),
                  _HistoryMeta(
                    icon: Icons.person_outline_rounded,
                    label: payment.payerName,
                  ),
                  _HistoryMeta(
                    icon: Icons.confirmation_number_outlined,
                    label: payment.voucherNumber,
                  ),
                  _HistoryMeta(
                    icon: Icons.scale_rounded,
                    label: tonnageLabel,
                  ),
                  _HistoryMeta(
                    icon: Icons.payments_outlined,
                    label: priceLabel,
                  ),
                  if (payment.rebate > 0)
                    _HistoryMeta(
                      icon: Icons.discount_outlined,
                      label: '${payment.rebate} ${AppConstants.currencySymbol}',
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
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

  BadgeStatus _siteTypeStatus(String type) {
    switch (type.trim().toUpperCase()) {
      case 'CARRIERE':
        return BadgeStatus.success;
      case 'USINE':
        return BadgeStatus.warning;
      default:
        return BadgeStatus.info;
    }
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

class _HistoryMeta extends StatelessWidget {
  final IconData icon;
  final String label;

  const _HistoryMeta({
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
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _ErrorBanner({
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
          if (actionLabel != null && onAction != null)
            TextButton(
              onPressed: onAction,
              child: Text(actionLabel!),
            ),
        ],
      ),
    );
  }
}

enum _FactoryPaymentView {
  history,
  create,
}
