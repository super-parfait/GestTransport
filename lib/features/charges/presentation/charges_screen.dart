import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_widgets.dart';

class ChargesScreen extends StatefulWidget {
  const ChargesScreen({super.key});

  @override
  State<ChargesScreen> createState() => _ChargesScreenState();
}

class _ChargesScreenState extends State<ChargesScreen> {
  String? _type; // 'maintenance' or 'simple'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(title: const Text('Charges / Dépenses'), backgroundColor: AppColors.surface),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Type selector
          AppSectionCard(
            title: 'Type de dépense',
            icon: Icons.build_rounded,
            iconColor: AppColors.warning,
            children: [
              Row(
                children: [
                  _typeCard('maintenance', 'Entretien / Garage',
                    Icons.car_repair_rounded, AppColors.warning),
                  const SizedBox(width: 12),
                  _typeCard('simple', 'Dépense simple',
                    Icons.receipt_rounded, AppColors.info),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (_type == 'maintenance') const _MaintenanceForm(),
          if (_type == 'simple') const _SimpleExpenseForm(),
        ],
      ),
    );
  }

  Widget _typeCard(String type, String label, IconData icon, Color color) {
    final isSelected = _type == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _type = type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.12) : AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? color : AppColors.divider,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? color : AppColors.textTertiary, size: 30),
              const SizedBox(height: 8),
              Text(label,
                style: AppTextStyles.titleMedium.copyWith(
                  color: isSelected ? color : AppColors.textSecondary),
                textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Maintenance Form ────────────────────────────────────────────────────────

class _MaintenanceForm extends StatefulWidget {
  const _MaintenanceForm();

  @override
  State<_MaintenanceForm> createState() => _MaintenanceFormState();
}

class _MaintenanceFormState extends State<_MaintenanceForm> {
  final _garageCtrl = TextEditingController();
  final _observationCtrl = TextEditingController();
  final _laborCtrl = TextEditingController();
  DateTime _date = DateTime.now();
  String? _truck;
  List<_MaintenanceLine> _lines = [_MaintenanceLine()];

  double get _subtotal => _lines.fold(0, (s, l) => s + l.total);
  double get _labor => double.tryParse(_laborCtrl.text) ?? 0;
  double get _grandTotal => _subtotal + _labor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppSectionCard(
          title: 'Informations générales',
          icon: Icons.info_outline_rounded,
          children: [
            AppDatePicker(label: 'Date', value: _date, required: true,
              onChanged: (d) => setState(() => _date = d)),
            const SizedBox(height: 14),
            AppDropdown<String>(
              label: 'Camion', required: true, hint: 'Sélectionner...',
              items: ['CI-1234-AB', 'CI-5678-CD', 'CI-9012-EF', 'CI-3456-GH']
                  .map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) => setState(() => _truck = v),
            ),
            const SizedBox(height: 14),
            AppTextField(label: 'Garage', hint: 'Nom du garage', controller: _garageCtrl, required: true,
              validator: (v) => v?.isEmpty == true ? 'Obligatoire' : null),
            const SizedBox(height: 14),
            AppTextField(label: 'Observation', hint: 'Motif de l\'entretien...', controller: _observationCtrl, maxLines: 2),
          ],
        ),
        const SizedBox(height: 16),

        // Lines
        AppSectionCard(
          title: 'Lignes d\'entretien',
          icon: Icons.list_alt_rounded,
          iconColor: AppColors.warning,
          children: [
            ..._lines.asMap().entries.map((e) => _buildLine(e.key, e.value)),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('+ Ajouter une ligne'),
              onPressed: () => setState(() => _lines.add(_MaintenanceLine())),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                minimumSize: const Size(double.infinity, 44),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Totals
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.warningSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.warning.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              _totalRow('Sous-total pièces', '${_subtotal.toStringAsFixed(0)} F', AppColors.textPrimary),
              const SizedBox(height: 10),
              AppMoneyField(label: 'Main-d\'œuvre (optionnel)', controller: _laborCtrl,
                onChanged: (_) => setState(() {})),
              const SizedBox(height: 10),
              const Divider(),
              _totalRow('TOTAL GÉNÉRAL', '${_grandTotal.toStringAsFixed(0)} F', AppColors.warning, bold: true),
            ],
          ),
        ),
        const SizedBox(height: 16),
        AppButton(label: 'Valider l\'entretien', icon: Icons.check_circle_rounded, onPressed: () {}),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildLine(int index, _MaintenanceLine line) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 24, height: 24,
                decoration: BoxDecoration(color: AppColors.warning, shape: BoxShape.circle),
                child: Center(
                  child: Text('${index + 1}',
                    style: AppTextStyles.bodySmall.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(width: 8),
              Text('Ligne ${index + 1}', style: AppTextStyles.titleMedium),
              const Spacer(),
              if (_lines.length > 1)
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 18),
                  onPressed: () => setState(() => _lines.removeAt(index)),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
          const SizedBox(height: 8),
          AppTextField(label: 'Désignation', hint: 'Ex: Filtre à huile',
            onChanged: (v) => setState(() => line.designation = v)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: AppTextField(label: 'Quantité', hint: '1',
                  keyboardType: TextInputType.number,
                  onChanged: (v) => setState(() { line.qty = double.tryParse(v) ?? 0; })),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AppMoneyField(label: 'Prix unitaire',
                  onChanged: (v) => setState(() { line.unitPrice = double.tryParse(v) ?? 0; })),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('Total : ', style: AppTextStyles.bodyMedium),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
                child: Text('${line.total.toStringAsFixed(0)} F',
                  style: AppTextStyles.titleLarge.copyWith(color: AppColors.warning)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _totalRow(String label, String value, Color color, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: bold ? AppTextStyles.titleLarge : AppTextStyles.bodyMedium),
        Text(value, style: (bold ? AppTextStyles.moneySmall : AppTextStyles.titleMedium).copyWith(color: color)),
      ],
    );
  }
}

class _MaintenanceLine {
  String designation = '';
  double qty = 0;
  double unitPrice = 0;
  double get total => qty * unitPrice;
}

// ─── Simple Expense Form ─────────────────────────────────────────────────────

class _SimpleExpenseForm extends StatefulWidget {
  const _SimpleExpenseForm();

  @override
  State<_SimpleExpenseForm> createState() => _SimpleExpenseFormState();
}

class _SimpleExpenseFormState extends State<_SimpleExpenseForm> {
  DateTime _date = DateTime.now();
  final _typeCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _obsCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppSectionCard(
          title: 'Dépense simple',
          icon: Icons.receipt_rounded,
          iconColor: AppColors.info,
          children: [
            AppDatePicker(label: 'Date', value: _date, required: true,
              onChanged: (d) => setState(() => _date = d)),
            const SizedBox(height: 14),
            AppDropdown<String>(
              label: 'Camion (optionnel)', hint: 'Lié à un camion ?',
              items: ['CI-1234-AB', 'CI-5678-CD', 'CI-9012-EF', 'CI-3456-GH']
                  .map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) {},
            ),
            const SizedBox(height: 14),
            AppTextField(label: 'Type / Désignation', hint: 'Ex: Carburant, Péage...',
              controller: _typeCtrl, required: true,
              validator: (v) => v?.isEmpty == true ? 'Obligatoire' : null),
            const SizedBox(height: 14),
            AppMoneyField(label: 'Montant', controller: _amountCtrl, required: true),
            const SizedBox(height: 14),
            const AppFilePicker(label: 'Photo ou scan du reçu'),
            const SizedBox(height: 14),
            AppTextField(label: 'Observation', hint: 'Notes...', controller: _obsCtrl, maxLines: 2),
          ],
        ),
        const SizedBox(height: 20),
        AppButton(label: 'Valider la dépense', icon: Icons.check_circle_rounded, onPressed: () {}),
        const SizedBox(height: 32),
      ],
    );
  }
}
