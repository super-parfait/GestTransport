import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_widgets.dart';

class ClientLoadingScreen extends StatefulWidget {
  const ClientLoadingScreen({super.key});

  @override
  State<ClientLoadingScreen> createState() => _ClientLoadingScreenState();
}

class _ClientLoadingScreenState extends State<ClientLoadingScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedType;
  bool _isSubmitting = false;
  DateTime _selectedDate = DateTime.now();

  // Form controllers
  final _clientCtrl = TextEditingController();
  final _quarryCtrl = TextEditingController();
  final _truckCtrl = TextEditingController();
  final _driverCtrl = TextEditingController();
  final _destinationCtrl = TextEditingController();
  final _bonCtrl = TextEditingController();
  final _quantityCtrl = TextEditingController();
  final _buyPriceCtrl = TextEditingController();
  final _sellPriceCtrl = TextEditingController();
  final _transportPriceCtrl = TextEditingController();
  final _fuelCtrl = TextEditingController();
  final _roadCtrl = TextEditingController();
  final _otherFeesCtrl = TextEditingController();
  final _tripsCtrl = TextEditingController();

  // Computed values
  double _amountToPay = 0;
  double _totalExpenses = 0;
  double _netMargin = 0;

  bool get isTransport => _selectedType == 'Transport';
  bool get isMaterial => _selectedType == 'Sable' || _selectedType == 'Gravier';

  void _compute() {
    final qty = double.tryParse(_quantityCtrl.text) ?? 0;
    final trips = double.tryParse(_tripsCtrl.text) ?? 0;
    final buyPrice = double.tryParse(_buyPriceCtrl.text) ?? 0;
    final sellPrice = double.tryParse(_sellPriceCtrl.text) ?? 0;
    final transport = double.tryParse(_transportPriceCtrl.text) ?? 0;
    final fuel = double.tryParse(_fuelCtrl.text) ?? 0;
    final road = double.tryParse(_roadCtrl.text) ?? 0;
    final other = double.tryParse(_otherFeesCtrl.text) ?? 0;

    setState(() {
      if (isMaterial) {
        _amountToPay = (sellPrice + transport) * qty;
        _totalExpenses = (buyPrice * qty) + fuel + road + other;
        _netMargin = _amountToPay - _totalExpenses;
      } else {
        _amountToPay = transport * trips;
        _totalExpenses = fuel + road + other;
        _netMargin = _amountToPay - _totalExpenses;
      }
    });
  }

  void _showConfirmDialog() {
    if (!_formKey.currentState!.validate()) return;
    AppConfirmDialog.show(
      context,
      title: 'Confirmer le chargement',
      content: AppSummaryCard(
        title: 'Résumé de l\'opération',
        color: AppColors.info,
        rows: [
          AppSummaryRow(label: 'Type', value: _selectedType ?? ''),
          AppSummaryRow(label: 'Client', value: _clientCtrl.text),
          if (isMaterial)
            AppSummaryRow(label: 'Carrière', value: _quarryCtrl.text),
          AppSummaryRow(label: 'Camion', value: _truckCtrl.text),
          AppSummaryRow(label: 'Chauffeur', value: _driverCtrl.text),
          AppSummaryRow(label: 'Destination', value: _destinationCtrl.text),
          if (isMaterial)
            AppSummaryRow(label: 'Quantité', value: '${_quantityCtrl.text} T'),
          if (isTransport)
            AppSummaryRow(label: 'Voyages', value: _tripsCtrl.text),
          AppSummaryRow(
              label: 'Montant à payer',
              value: '${_fmt(_amountToPay)} F',
              valueColor: AppColors.success,
              isBold: true),
          AppSummaryRow(
              label: 'Total dépenses',
              value: '${_fmt(_totalExpenses)} F',
              valueColor: AppColors.error),
          AppSummaryRow(
              label: 'Marge nette',
              value: '${_fmt(_netMargin)} F',
              valueColor: _netMargin >= 0 ? AppColors.success : AppColors.error,
              isBold: true),
        ],
      ),
      confirmLabel: 'Valider le chargement',
      onConfirm: _submit,
    );
  }

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Chargement enregistré avec succès !',
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.white)),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    }
  }

  String _fmt(double v) => NumberFormat('#,###').format(v).replaceAll(',', ' ');

  @override
  Widget build(BuildContext context) {
    return AppLoadingOverlay(
      isLoading: _isSubmitting,
      message: 'Enregistrement...',
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(
          title: const Text('Chargement client'),
          backgroundColor: AppColors.surface,
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ── Type selector ──
              _buildTypeSelector(),
              const SizedBox(height: 16),

              // ── Form sections (conditionally shown) ──
              if (_selectedType != null) ...[
                _buildSection1(),
                const SizedBox(height: 16),
                _buildSection2(),
                const SizedBox(height: 16),
                _buildSection3(),
                const SizedBox(height: 16),
                _buildJustificatif(),
                const SizedBox(height: 16),

                // ── Auto-calculation card ──
                _buildCalculationCard(),
                const SizedBox(height: 20),

                AppButton(
                  label: 'Valider le chargement',
                  icon: Icons.check_circle_rounded,
                  onPressed: _showConfirmDialog,
                ),
                const SizedBox(height: 10),
                AppButton(
                  label: AppStrings.draft,
                  variant: AppButtonVariant.outlined,
                  icon: Icons.save_outlined,
                  onPressed: () {},
                ),
              ],
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return AppSectionCard(
      title: 'Type de chargement',
      icon: Icons.category_rounded,
      children: [
        Text('Sélectionnez le type de chargement',
            style: AppTextStyles.bodyMedium),
        const SizedBox(height: 12),
        Row(
          children: AppConstants.materialTypes.map((type) {
            final isSelected = _selectedType == type;
            final color = type == 'Transport'
                ? AppColors.warning
                : type == 'Sable'
                    ? AppColors.info
                    : AppColors.primary;
            final icon = type == 'Transport'
                ? Icons.local_shipping_rounded
                : type == 'Sable'
                    ? Icons.grain_rounded
                    : Icons.layers_rounded;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                    left: type == AppConstants.materialTypes.first ? 0 : 8),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedType = type),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding:
                        const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? color.withOpacity(0.12)
                          : AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? color : AppColors.divider,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(icon,
                            color: isSelected ? color : AppColors.textTertiary,
                            size: 26),
                        const SizedBox(height: 6),
                        Text(
                          type,
                          style: AppTextStyles.titleMedium.copyWith(
                            color: isSelected ? color : AppColors.textSecondary,
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSection1() {
    return AppSectionCard(
      title: 'Informations générales',
      icon: Icons.info_outline_rounded,
      children: [
        AppDatePicker(
            label: 'Date',
            value: _selectedDate,
            required: true,
            onChanged: (d) => setState(() => _selectedDate = d)),
        const SizedBox(height: 14),
        AppDropdown<String>(
          label: 'Client',
          required: true,
          hint: 'Sélectionner un client...',
          items: [
            'KOUAME Eric',
            'BTP SERVICES',
            'TOURE Construction',
            'DIALLO Travaux'
          ].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
          onChanged: (v) {
            _clientCtrl.text = v ?? '';
          },
        ),
        if (isMaterial) ...[
          const SizedBox(height: 14),
          AppDropdown<String>(
            label: 'Carrière / Usine',
            required: true,
            hint: 'Sélectionner...',
            items: ['Carrière KOSSOU', 'Usine ABATTA', 'Carrière DAOUKRO']
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (v) {
              _quarryCtrl.text = v ?? '';
            },
          ),
        ],
        const SizedBox(height: 14),
        AppDropdown<String>(
          label: 'Camion',
          required: true,
          hint: 'Sélectionner un camion...',
          items: ['CI-1234-AB', 'CI-5678-CD', 'CI-9012-EF', 'CI-3456-GH']
              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
              .toList(),
          onChanged: (v) {
            _truckCtrl.text = v ?? '';
          },
        ),
        const SizedBox(height: 14),
        AppDropdown<String>(
          label: 'Chauffeur',
          required: true,
          hint: 'Sélectionner un chauffeur...',
          items: [
            'KONAN Yao',
            'OUATTARA Issa',
            'BAMBA Mamadou',
            'COULIBALY Drissa'
          ].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
          onChanged: (v) {
            _driverCtrl.text = v ?? '';
          },
        ),
        const SizedBox(height: 14),
        AppTextField(
            label: 'Destination',
            hint: 'Ex: Yopougon Marché',
            controller: _destinationCtrl,
            required: true,
            validator: (v) =>
                v == null || v.isEmpty ? AppStrings.required : null),
        const SizedBox(height: 14),
        AppTextField(
            label: 'Numéro de bon',
            hint: 'BON-2026-001',
            controller: _bonCtrl,
            required: true,
            validator: (v) =>
                v == null || v.isEmpty ? AppStrings.required : null),
      ],
    );
  }

  Widget _buildSection2() {
    return AppSectionCard(
      title: 'Informations financières',
      icon: Icons.attach_money_rounded,
      iconColor: AppColors.success,
      children: [
        if (isMaterial) ...[
          AppTextField(
            label: 'Quantité (en tonnes)',
            hint: '0',
            controller: _quantityCtrl,
            required: true,
            keyboardType: TextInputType.number,
            onChanged: (_) => _compute(),
            validator: (v) =>
                v == null || v.isEmpty ? AppStrings.required : null,
          ),
          const SizedBox(height: 14),
          AppMoneyField(
              label: 'Prix achat (par tonne)',
              controller: _buyPriceCtrl,
              required: true,
              onChanged: (_) => _compute()),
          const SizedBox(height: 14),
          AppMoneyField(
              label: 'Prix vente (par tonne)',
              controller: _sellPriceCtrl,
              required: true,
              onChanged: (_) => _compute()),
        ],
        if (isTransport) ...[
          AppTextField(
            label: 'Nombre de voyages',
            hint: '0',
            controller: _tripsCtrl,
            required: true,
            keyboardType: TextInputType.number,
            onChanged: (_) => _compute(),
            validator: (v) =>
                v == null || v.isEmpty ? AppStrings.required : null,
          ),
        ],
        const SizedBox(height: 14),
        AppMoneyField(
            label:
                'Prix transport (${isTransport ? "par voyage" : "par tonne"})',
            controller: _transportPriceCtrl,
            required: true,
            onChanged: (_) => _compute()),
        const SizedBox(height: 14),
        AppMoneyField(
            label: 'Dépense carburant',
            controller: _fuelCtrl,
            onChanged: (_) => _compute()),
        const SizedBox(height: 14),
        AppMoneyField(
            label: 'Frais de route',
            controller: _roadCtrl,
            onChanged: (_) => _compute()),
        const SizedBox(height: 14),
        AppMoneyField(
            label: 'Autres frais',
            controller: _otherFeesCtrl,
            onChanged: (_) => _compute()),
      ],
    );
  }

  Widget _buildSection3() {
    return AppSectionCard(
      title: 'Détails supplémentaires',
      icon: Icons.notes_rounded,
      iconColor: AppColors.textSecondary,
      children: [
        AppTextField(
          label: 'Observation',
          hint: 'Notes éventuelles...',
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildJustificatif() {
    return AppSectionCard(
      title: 'Justificatif',
      icon: Icons.attachment_rounded,
      iconColor: AppColors.info,
      children: [
        const AppFilePicker(label: 'Photo ou scan du bon de chargement'),
      ],
    );
  }

  Widget _buildCalculationCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.08),
            AppColors.info.withOpacity(0.08)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: AppColors.primary.withOpacity(0.25), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calculate_rounded,
                  color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text('Calcul automatique',
                  style: AppTextStyles.headlineSmall
                      .copyWith(color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.divider),
          _calcRow(
              'Montant à payer', '${_fmt(_amountToPay)} F', AppColors.info),
          _calcRow(
              'Total dépenses', '${_fmt(_totalExpenses)} F', AppColors.error),
          const Divider(color: AppColors.divider),
          _calcRow('Marge nette', '${_fmt(_netMargin)} F',
              _netMargin >= 0 ? AppColors.success : AppColors.error,
              bold: true),
        ],
      ),
    );
  }

  Widget _calcRow(String label, String value, Color color,
      {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style:
                  bold ? AppTextStyles.titleLarge : AppTextStyles.bodyMedium),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(value,
                style: (bold
                        ? AppTextStyles.moneySmall
                        : AppTextStyles.titleMedium)
                    .copyWith(color: color)),
          ),
        ],
      ),
    );
  }
}
