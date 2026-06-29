import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_widgets.dart';

class RevenueScreen extends StatefulWidget {
  const RevenueScreen({super.key});

  @override
  State<RevenueScreen> createState() => _RevenueScreenState();
}

class _RevenueScreenState extends State<RevenueScreen> {
  String? _type; // 'trip' or 'week'
  final _tripsCtrl = TextEditingController();
  final _tripValueCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _receivedByCtrl = TextEditingController();
  DateTime _dateFrom = DateTime.now();
  DateTime _dateTo = DateTime.now();

  double get _totalTrips =>
      (double.tryParse(_tripsCtrl.text) ?? 0) * (double.tryParse(_tripValueCtrl.text) ?? 0);

  // Mock expenses from expenses module
  double get _linkedExpenses => 185000;

  double get _balance {
    final total = _type == 'trip' ? _totalTrips : (double.tryParse(_amountCtrl.text) ?? 0);
    return total - _linkedExpenses;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(title: const Text('Recettes'), backgroundColor: AppColors.surface),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Type selector
          AppSectionCard(
            title: 'Type de recette',
            icon: Icons.add_card_rounded,
            iconColor: AppColors.success,
            children: [
              Row(
                children: [
                  _typeBtn('trip', 'Par voyage', Icons.local_shipping_rounded),
                  const SizedBox(width: 12),
                  _typeBtn('week', 'Par semaine', Icons.date_range_rounded),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (_type != null) ...[
            AppSectionCard(
              title: 'Informations générales',
              icon: Icons.info_outline_rounded,
              children: [
                if (_type == 'trip') ...[
                  AppDatePicker(label: 'Date', value: _dateFrom, required: true,
                    onChanged: (d) => setState(() => _dateFrom = d)),
                ] else ...[
                  AppDatePicker(label: 'Période du', value: _dateFrom, required: true,
                    onChanged: (d) => setState(() => _dateFrom = d)),
                  const SizedBox(height: 14),
                  AppDatePicker(label: 'Période au', value: _dateTo, required: true,
                    onChanged: (d) => setState(() => _dateTo = d)),
                ],
                const SizedBox(height: 14),
                AppDropdown<String>(
                  label: 'Camion', required: true,
                  items: ['CI-1234-AB', 'CI-5678-CD', 'CI-9012-EF']
                      .map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (_) {},
                ),
                const SizedBox(height: 14),
                AppDropdown<String>(
                  label: 'Chauffeur', required: true,
                  items: ['KONAN Yao', 'OUATTARA Issa', 'BAMBA Mamadou']
                      .map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (_) {},
                ),
              ],
            ),
            const SizedBox(height: 16),

            AppSectionCard(
              title: 'Montants',
              icon: Icons.attach_money_rounded,
              iconColor: AppColors.success,
              children: [
                if (_type == 'trip') ...[
                  AppTextField(label: 'Nombre de voyages', hint: '0',
                    controller: _tripsCtrl, keyboardType: TextInputType.number,
                    required: true, onChanged: (_) => setState(() {})),
                  const SizedBox(height: 14),
                  AppMoneyField(label: 'Valeur par voyage', controller: _tripValueCtrl,
                    required: true, onChanged: (_) => setState(() {})),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.successSurface,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total voyages', style: AppTextStyles.titleMedium),
                        Text('${_totalTrips.toStringAsFixed(0)} F',
                          style: AppTextStyles.moneySmall.copyWith(color: AppColors.success)),
                      ],
                    ),
                  ),
                ] else ...[
                  AppMoneyField(label: 'Montant reçu', controller: _amountCtrl,
                    required: true, onChanged: (_) => setState(() {})),
                ],
                const SizedBox(height: 14),
                AppTextField(label: 'Reçu par', hint: 'Nom de la personne', controller: _receivedByCtrl),
              ],
            ),
            const SizedBox(height: 16),

            // Linked expenses (read-only from expenses module)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.errorSurface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.error.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.link_rounded, color: AppColors.error, size: 18),
                      const SizedBox(width: 8),
                      Text('Dépenses liées (depuis le module Charges)',
                        style: AppTextStyles.titleMedium.copyWith(color: AppColors.error)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('Ces dépenses sont récupérées automatiquement. Elles ne créent pas de nouveau mouvement.',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.error)),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total dépenses ${_type == 'week' ? 'de la période' : 'du voyage'}',
                        style: AppTextStyles.bodyMedium),
                      Text('${_linkedExpenses.toStringAsFixed(0)} F',
                        style: AppTextStyles.titleLarge.copyWith(color: AppColors.error)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Balance summary
            AppSummaryCard(
              title: '💰 Solde ${_type == 'week' ? 'de la semaine' : 'du voyage'}',
              color: _balance >= 0 ? AppColors.success : AppColors.error,
              rows: [
                AppSummaryRow(
                  label: _type == 'trip' ? 'Total voyages' : 'Montant reçu',
                  value: '${(_type == 'trip' ? _totalTrips : (double.tryParse(_amountCtrl.text) ?? 0)).toStringAsFixed(0)} F',
                  valueColor: AppColors.success,
                ),
                AppSummaryRow(label: 'Dépenses liées', value: '${_linkedExpenses.toStringAsFixed(0)} F',
                  valueColor: AppColors.error),
                AppSummaryRow(label: 'Solde net', value: '${_balance.toStringAsFixed(0)} F',
                  valueColor: _balance >= 0 ? AppColors.success : AppColors.error,
                  isBold: true),
              ],
            ),
            const SizedBox(height: 20),

            AppButton(label: 'Enregistrer la recette', icon: Icons.check_circle_rounded, onPressed: () {}),
          ],
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _typeBtn(String type, String label, IconData icon) {
    final isSelected = _type == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _type = type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.success.withOpacity(0.1) : AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? AppColors.success : AppColors.divider,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? AppColors.success : AppColors.textTertiary, size: 26),
              const SizedBox(height: 6),
              Text(label,
                style: AppTextStyles.titleMedium.copyWith(
                  color: isSelected ? AppColors.success : AppColors.textSecondary),
                textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
