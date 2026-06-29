import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_widgets.dart';

class FactoryPaymentScreen extends StatefulWidget {
  const FactoryPaymentScreen({super.key});

  @override
  State<FactoryPaymentScreen> createState() => _FactoryPaymentScreenState();
}

class _FactoryPaymentScreenState extends State<FactoryPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quarryCtrl = TextEditingController();
  final _paidByCtrl = TextEditingController();
  final _bonCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _discountCtrl = TextEditingController();
  final _quantityCtrl = TextEditingController();
  DateTime _date = DateTime.now();
  String? _quarry;
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return AppLoadingOverlay(
      isLoading: _isSubmitting,
      message: 'Enregistrement...',
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(title: const Text('Versement usine'), backgroundColor: AppColors.surface),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Section 1
              AppSectionCard(
                title: 'Informations générales',
                icon: Icons.factory_rounded,
                iconColor: AppColors.primary,
                children: [
                  AppDropdown<String>(
                    label: 'Carrière / Usine', required: true, hint: 'Sélectionner...',
                    items: ['Carrière KOSSOU', 'Usine ABATTA', 'Carrière DAOUKRO']
                        .map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (v) => setState(() => _quarry = v),
                  ),
                  const SizedBox(height: 14),
                  AppDatePicker(label: 'Date', value: _date, required: true,
                    onChanged: (d) => setState(() => _date = d)),
                  const SizedBox(height: 14),
                  AppTextField(label: 'Nom du verseur', hint: 'Prénom et nom',
                    controller: _paidByCtrl, required: true,
                    validator: (v) => v?.isEmpty == true ? 'Obligatoire' : null),
                  const SizedBox(height: 14),
                  AppTextField(label: 'Numéro de bon', hint: 'BON-2024-001',
                    controller: _bonCtrl, required: true,
                    validator: (v) => v?.isEmpty == true ? 'Obligatoire' : null),
                ],
              ),
              const SizedBox(height: 16),

              // Section 2
              AppSectionCard(
                title: 'Informations financières',
                icon: Icons.payments_rounded,
                iconColor: AppColors.success,
                children: [
                  AppMoneyField(label: 'Montant versé', controller: _amountCtrl, required: true),
                  const SizedBox(height: 14),
                  AppMoneyField(label: 'Prix actuel (par tonne)', controller: _priceCtrl, required: true),
                  const SizedBox(height: 14),
                  AppMoneyField(label: 'Ristourne', controller: _discountCtrl),
                  const SizedBox(height: 14),
                  AppTextField(
                    label: 'Tonnage / Quantité',
                    hint: '0 T',
                    controller: _quantityCtrl,
                    keyboardType: TextInputType.number,
                    required: true,
                    validator: (v) => v?.isEmpty == true ? 'Obligatoire' : null,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Section 3 - Justificatif
              AppSectionCard(
                title: 'Justificatif',
                icon: Icons.attachment_rounded,
                iconColor: AppColors.info,
                children: [const AppFilePicker(label: 'Photo ou scan du reçu')],
              ),
              const SizedBox(height: 16),

              // Section 4 - Summary
              AppSummaryCard(
                title: '📋 Résumé avant validation',
                color: AppColors.primary,
                rows: [
                  AppSummaryRow(label: 'Carrière', value: _quarry ?? '—'),
                  AppSummaryRow(label: 'Montant', value: '${_amountCtrl.text.isEmpty ? "0" : _amountCtrl.text} F'),
                  AppSummaryRow(label: 'Quantité', value: '${_quantityCtrl.text.isEmpty ? "0" : _quantityCtrl.text} T'),
                  AppSummaryRow(label: 'Verseur', value: _paidByCtrl.text.isEmpty ? '—' : _paidByCtrl.text),
                ],
              ),
              const SizedBox(height: 20),

              AppButton(label: 'Valider le versement', icon: Icons.check_circle_rounded,
                onPressed: _submit),
              const SizedBox(height: 10),
              AppButton(label: 'Enregistrer brouillon', variant: AppButtonVariant.outlined,
                icon: Icons.save_outlined, onPressed: () {}),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Versement enregistré !'),
          backgroundColor: AppColors.success, behavior: SnackBarBehavior.floating),
      );
      Navigator.pop(context);
    }
  }
}
