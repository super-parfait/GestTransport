import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_widgets.dart';
import '../data/models/create_factory_payment_request.dart';
import '../data/models/factory_payment_record.dart';
import '../data/models/factory_site_option.dart';
import 'controllers/factory_payment_controller.dart';

class FactoryPaymentDetailScreen extends StatefulWidget {
  final FactoryPaymentController controller;
  final String paymentId;

  const FactoryPaymentDetailScreen({
    super.key,
    required this.controller,
    required this.paymentId,
  });

  @override
  State<FactoryPaymentDetailScreen> createState() =>
      _FactoryPaymentDetailScreenState();
}

class _FactoryPaymentDetailScreenState
    extends State<FactoryPaymentDetailScreen> {
  final _moneyFormat = NumberFormat.decimalPattern('fr_FR');
  final _dateFormat = DateFormat(AppConstants.dateFormat);
  final _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');

  FactoryPaymentController get _controller => widget.controller;

  @override
  void initState() {
    super.initState();
    if (_controller.sites.isEmpty) {
      _controller.loadSites();
    }
    if (_controller.paymentById(widget.paymentId) == null) {
      _controller.loadPayments();
    }
  }

  FactoryPaymentRecord? get _payment =>
      _controller.paymentById(widget.paymentId);

  List<FactorySiteOption> get _availableSites {
    final payment = _payment;
    if (payment == null) {
      return _controller.sites;
    }

    final hasSite = _controller.sites.any((site) => site.id == payment.siteId);
    if (hasSite) {
      return _controller.sites;
    }

    return [
      FactorySiteOption(
        id: payment.siteId,
        name: payment.siteName,
        type: payment.siteType,
        currentPrice: payment.currentPrice,
        location: '',
        contact: '',
      ),
      ..._controller.sites,
    ];
  }

  Future<void> _openEditor() async {
    final payment = _payment;
    if (payment == null) {
      return;
    }

    final draft = await showModalBottomSheet<_FactoryPaymentEditDraft>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FactoryPaymentEditSheet(
        payment: payment,
        sites: _availableSites,
      ),
    );

    if (!mounted || draft == null) {
      return;
    }

    final updated = await _controller.updatePayment(
      paymentId: payment.id,
      request: draft.request,
      proofPath: draft.proofPath,
      existingProofUrl: payment.proofUrl,
    );

    if (!mounted) {
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    if (updated != null) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Versement mis à jour.'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final message = _controller.submitErrorMessage ??
        'Mise à jour du versement impossible.';
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _confirmDelete() async {
    final payment = _payment;
    if (payment == null) {
      return;
    }

    await AppConfirmDialog.show(
      context,
      title: 'Supprimer le versement',
      content: Text(
        'Le versement ${payment.voucherNumber} sera supprimé définitivement.',
        style: AppTextStyles.bodyMedium,
      ),
      confirmLabel: 'Supprimer',
      confirmColor: AppColors.error,
      onConfirm: () {
        _deletePayment(payment);
      },
    );
  }

  Future<void> _deletePayment(FactoryPaymentRecord payment) async {
    final deleted = await _controller.deletePayment(payment.id);
    if (!mounted) {
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    if (deleted) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Versement supprimé.'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop();
      return;
    }

    final message = _controller.submitErrorMessage ??
        'Suppression du versement impossible.';
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _formatMoney(int value) {
    return '${_moneyFormat.format(value)} ${AppConstants.currencySymbol}';
  }

  String _formatDateTime(DateTime value) {
    return _dateTimeFormat.format(value.toLocal());
  }

  String _formatTonnage(double tonnage, double quantity) {
    final value = tonnage > 0 ? tonnage : quantity;
    if (value <= 0) {
      return '—';
    }

    final decimals = value % 1 == 0 ? 0 : 1;
    return '${value.toStringAsFixed(decimals)} T';
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

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final payment = _payment;

        return AppLoadingOverlay(
          isLoading: _controller.isSubmitting,
          message: 'Traitement...',
          child: Scaffold(
            backgroundColor: AppColors.backgroundLight,
            appBar: AppBar(
              title: const Text('Détail du versement'),
              backgroundColor: AppColors.surface,
            ),
            body: payment == null
                ? _buildMissingState()
                : RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: _controller.loadPayments,
                    child: SafeArea(
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                        children: [
                          if (_controller.submitErrorMessage != null) ...[
                            _DetailErrorBanner(
                              message: _controller.submitErrorMessage!,
                            ),
                            const SizedBox(height: 14),
                          ],
                          _FactoryPaymentHero(
                            payment: payment,
                            amountLabel: _formatMoney(payment.amount),
                            dateLabel: _dateFormat.format(payment.date),
                            tonnageLabel: _formatTonnage(
                              payment.tonnage,
                              payment.quantity,
                            ),
                            priceLabel: payment.currentPrice > 0
                                ? '${_moneyFormat.format(payment.currentPrice)} ${AppConstants.currencySymbol}/T'
                                : '—',
                            statusLabel: _statusLabel(payment.status),
                            statusBadge: _statusBadge(payment.status),
                            siteTypeLabel: _siteTypeLabel(payment.siteType),
                            siteTypeBadge: _siteTypeStatus(payment.siteType),
                            hasProof: payment.proofUrl.trim().isNotEmpty,
                          ),
                          const SizedBox(height: 16),
                          AppSectionCard(
                            title: 'Informations générales',
                            icon: Icons.factory_rounded,
                            iconColor: AppColors.primary,
                            children: [
                              _DetailRow(
                                label: 'Site',
                                value: payment.siteName.trim().isEmpty
                                    ? '—'
                                    : payment.siteName,
                              ),
                              _DetailRow(
                                label: 'Type',
                                value: _siteTypeLabel(payment.siteType),
                              ),
                              _DetailRow(
                                label: 'Date',
                                value: _dateFormat.format(payment.date),
                              ),
                              _DetailRow(
                                label: 'Verseur',
                                value: payment.payerName.trim().isEmpty
                                    ? '—'
                                    : payment.payerName,
                              ),
                              _DetailRow(
                                label: 'Numéro de bon',
                                value: payment.voucherNumber.trim().isEmpty
                                    ? '—'
                                    : payment.voucherNumber,
                              ),
                              _DetailRow(
                                label: 'Numéro de reçu',
                                value: payment.receiptNumber.trim().isEmpty
                                    ? '—'
                                    : payment.receiptNumber,
                                isLast: true,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          AppSectionCard(
                            title: 'Informations financières',
                            icon: Icons.payments_rounded,
                            iconColor: AppColors.success,
                            children: [
                              _DetailRow(
                                label: 'Montant versé',
                                value: _formatMoney(payment.amount),
                              ),
                              _DetailRow(
                                label: 'Prix actuel',
                                value: payment.currentPrice > 0
                                    ? '${_moneyFormat.format(payment.currentPrice)} ${AppConstants.currencySymbol}/T'
                                    : '—',
                              ),
                              _DetailRow(
                                label: 'Ristourne',
                                value: _formatMoney(payment.rebate),
                              ),
                              _DetailRow(
                                label: 'Tonnage / Quantité',
                                value: _formatTonnage(
                                  payment.tonnage,
                                  payment.quantity,
                                ),
                                isLast: true,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          AppSectionCard(
                            title: 'Traçabilité',
                            icon: Icons.history_toggle_off_rounded,
                            iconColor: AppColors.info,
                            children: [
                              _DetailRow(
                                label: 'Créé par',
                                value: payment.createdByName.trim().isEmpty
                                    ? '—'
                                    : payment.createdByName,
                              ),
                              _DetailRow(
                                label: 'Créé le',
                                value: _formatDateTime(payment.createdAt),
                              ),
                              _DetailRow(
                                label: 'Mis à jour le',
                                value: _formatDateTime(payment.updatedAt),
                              ),
                              _DetailRow(
                                label: 'Justificatif',
                                value: payment.proofUrl.trim().isEmpty
                                    ? 'Non joint'
                                    : 'Joint',
                                isLast: true,
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: AppButton(
                                  label: 'Modifier',
                                  icon: Icons.edit_rounded,
                                  variant: AppButtonVariant.outlined,
                                  onPressed: _controller.isSubmitting
                                      ? null
                                      : _openEditor,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: AppButton(
                                  label: 'Supprimer',
                                  icon: Icons.delete_outline_rounded,
                                  variant: AppButtonVariant.danger,
                                  onPressed: _controller.isSubmitting
                                      ? null
                                      : _confirmDelete,
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
      },
    );
  }

  Widget _buildMissingState() {
    if (_controller.isLoadingPayments) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    return AppEmptyState(
      icon: Icons.receipt_long_rounded,
      title: 'Versement introuvable',
      subtitle: _controller.paymentsErrorMessage ??
          'Ce versement n’est plus disponible.',
      actionLabel: 'Retour',
      onAction: () => Navigator.of(context).pop(),
    );
  }
}

class _FactoryPaymentHero extends StatelessWidget {
  final FactoryPaymentRecord payment;
  final String amountLabel;
  final String dateLabel;
  final String tonnageLabel;
  final String priceLabel;
  final String statusLabel;
  final BadgeStatus statusBadge;
  final String siteTypeLabel;
  final BadgeStatus siteTypeBadge;
  final bool hasProof;

  const _FactoryPaymentHero({
    required this.payment,
    required this.amountLabel,
    required this.dateLabel,
    required this.tonnageLabel,
    required this.priceLabel,
    required this.statusLabel,
    required this.statusBadge,
    required this.siteTypeLabel,
    required this.siteTypeBadge,
    required this.hasProof,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowMedium,
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              AppStatusBadge(label: siteTypeLabel, status: siteTypeBadge),
              AppStatusBadge(label: statusLabel, status: statusBadge),
              if (hasProof)
                const AppStatusBadge(
                  label: 'Justificatif',
                  status: BadgeStatus.info,
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            payment.siteName.trim().isEmpty
                ? 'Versement usine'
                : payment.siteName,
            style: AppTextStyles.headlineLarge.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 6),
          Text(
            '${payment.voucherNumber} • $dateLabel',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white.withValues(alpha: 0.86),
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _HeroMetric(label: 'Montant', value: amountLabel),
              _HeroMetric(label: 'Prix/T', value: priceLabel),
              _HeroMetric(label: 'Tonnage', value: tonnageLabel),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  final String label;
  final String value;

  const _HeroMetric({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 96),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: Colors.white.withValues(alpha: 0.78),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.titleLarge.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;

  const _DetailRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.bodySmall),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.titleMedium,
          ),
          if (!isLast) ...[
            const SizedBox(height: 12),
            const Divider(height: 1, color: AppColors.divider),
          ],
        ],
      ),
    );
  }
}

class _DetailErrorBanner extends StatelessWidget {
  final String message;

  const _DetailErrorBanner({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.errorSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
        ],
      ),
    );
  }
}

class _FactoryPaymentEditSheet extends StatefulWidget {
  final FactoryPaymentRecord payment;
  final List<FactorySiteOption> sites;

  const _FactoryPaymentEditSheet({
    required this.payment,
    required this.sites,
  });

  @override
  State<_FactoryPaymentEditSheet> createState() =>
      _FactoryPaymentEditSheetState();
}

class _FactoryPaymentEditSheetState extends State<_FactoryPaymentEditSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _paidByCtrl;
  late final TextEditingController _voucherCtrl;
  late final TextEditingController _amountCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _rebateCtrl;
  late final TextEditingController _tonnageCtrl;

  late DateTime _date;
  late String _selectedSiteId;
  late String _status;
  String? _proofPath;

  @override
  void initState() {
    super.initState();
    final payment = widget.payment;
    _paidByCtrl = TextEditingController(text: payment.payerName);
    _voucherCtrl = TextEditingController(text: payment.voucherNumber);
    _amountCtrl = TextEditingController(text: payment.amount.toString());
    _priceCtrl = TextEditingController(text: payment.currentPrice.toString());
    _rebateCtrl = TextEditingController(text: payment.rebate.toString());
    _tonnageCtrl = TextEditingController(
      text: payment.tonnage > 0
          ? payment.tonnage.toString()
          : payment.quantity.toString(),
    );
    _date = payment.date;
    _selectedSiteId = payment.siteId;
    _status = payment.status.trim().toUpperCase();
  }

  @override
  void dispose() {
    _paidByCtrl.dispose();
    _voucherCtrl.dispose();
    _amountCtrl.dispose();
    _priceCtrl.dispose();
    _rebateCtrl.dispose();
    _tonnageCtrl.dispose();
    super.dispose();
  }

  FactorySiteOption? get _selectedSite {
    for (final site in widget.sites) {
      if (site.id == _selectedSiteId) {
        return site;
      }
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

  List<DropdownMenuItem<String>> _statusItems() {
    final items = <DropdownMenuItem<String>>[];
    if (_status != 'VALIDE' && _status != 'BROUILLON') {
      items.add(
        DropdownMenuItem<String>(
          value: _status,
          child: Text(_statusLabel(_status)),
        ),
      );
    }

    items.addAll(const [
      DropdownMenuItem<String>(
        value: 'VALIDE',
        child: Text('Validé'),
      ),
      DropdownMenuItem<String>(
        value: 'BROUILLON',
        child: Text('Brouillon'),
      ),
    ]);

    return items;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final draft = _FactoryPaymentEditDraft(
      request: CreateFactoryPaymentRequest(
        siteId: _selectedSiteId,
        date: _date,
        payerName: _paidByCtrl.text.trim(),
        voucherNumber: _voucherCtrl.text.trim(),
        amount: _parseInt(_amountCtrl.text),
        currentPrice: _parseInt(_priceCtrl.text),
        rebate: _parseInt(_rebateCtrl.text, defaultValue: 0),
        tonnage: _parseDouble(_tonnageCtrl.text),
        status: _status,
      ),
      proofPath: _proofPath,
    );

    Navigator.of(context).pop(draft);
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets;
    final selectedSite = _selectedSite;

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
                  'Modifier le versement',
                  style: AppTextStyles.headlineLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Ajustez les informations du versement avant validation.',
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: 20),
                AppSectionCard(
                  title: 'Informations générales',
                  icon: Icons.factory_rounded,
                  iconColor: AppColors.primary,
                  children: [
                    AppDropdown<String>(
                      label: 'Carrière / Usine',
                      value: _selectedSiteId,
                      required: true,
                      items: widget.sites
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
                      onChanged: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return;
                        }
                        setState(() {
                          _selectedSiteId = value;
                        });
                        final site = _selectedSite;
                        if (site != null && site.currentPrice > 0) {
                          _priceCtrl.text = site.currentPrice.toString();
                        }
                      },
                      validator: (value) {
                        if ((value ?? '').trim().isEmpty) {
                          return 'Choisissez une carrière ou une usine';
                        }
                        return null;
                      },
                    ),
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
                      controller: _voucherCtrl,
                      required: true,
                      validator: (value) => _validateRequiredText(
                        value,
                        'Entrez le numéro de bon',
                      ),
                    ),
                    const SizedBox(height: 14),
                    AppDropdown<String>(
                      label: 'Statut',
                      value: _status,
                      required: true,
                      items: _statusItems(),
                      onChanged: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return;
                        }
                        setState(() => _status = value);
                      },
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
                      controller: _rebateCtrl,
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
                    if (widget.payment.proofUrl.trim().isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.infoSurface,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.check_circle_rounded,
                              color: AppColors.info,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Un justificatif est déjà enregistré pour ce versement.',
                                style: AppTextStyles.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],
                    AppFilePicker(
                      label: 'Remplacer le justificatif',
                      onFileSelected: (path) {
                        setState(() => _proofPath = path);
                      },
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
                        label: 'Mettre à jour',
                        icon: Icons.save_rounded,
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

class _FactoryPaymentEditDraft {
  final CreateFactoryPaymentRequest request;
  final String? proofPath;

  const _FactoryPaymentEditDraft({
    required this.request,
    required this.proofPath,
  });
}
