import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../core/network/api_service.dart';

class ClientPaymentScreen extends StatefulWidget {
  final String? prefilledClient;
  const ClientPaymentScreen({super.key, this.prefilledClient});

  @override
  State<ClientPaymentScreen> createState() => _ClientPaymentScreenState();
}

class _ClientPaymentScreenState extends State<ClientPaymentScreen> {
  late String? _selectedClient;
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  String _mode = 'Espèces';
  bool _saved = false;

  static const _modes = [
    'Espèces',
    'Virement',
    'Chèque',
    'Orange Money',
    'Wave'
  ];

  @override
  void initState() {
    super.initState();
    _selectedClient = widget.prefilledClient;
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Map<String, dynamic>? get _clientData => _selectedClient == null
      ? null
      : AppData.clients
          .cast<Map<String, dynamic>?>()
          .firstWhere((c) => c!['name'] == _selectedClient, orElse: () => null);

  double get _amount =>
      double.tryParse(_amountCtrl.text.replaceAll(' ', '')) ?? 0;

  @override
  Widget build(BuildContext context) {
    final client = _clientData;
    final balance = (client?['balance'] as double?) ?? 0;
    final remaining = balance - _amount;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
          title: const Text('Règlement client'),
          backgroundColor: AppColors.surface),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        // Sélecteur client
        AppSectionCard(title: 'Client', icon: Icons.person_rounded, children: [
          DropdownButtonFormField<String>(
            value: _selectedClient,
            hint: const Text('Sélectionner un client'),
            decoration: const InputDecoration(
                border: InputBorder.none, contentPadding: EdgeInsets.zero),
            items: AppData.clients
                .map((c) => DropdownMenuItem<String>(
                      value: c['name'] as String,
                      child: Text(c['name'] as String),
                    ))
                .toList(),
            onChanged: (v) => setState(() {
              _selectedClient = v;
              _amountCtrl.clear();
            }),
          ),
        ]),
        const SizedBox(height: 14),

        // Solde actuel
        if (client != null) ...[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: balance > 0
                  ? AppColors.errorSurface
                  : AppColors.successSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: (balance > 0 ? AppColors.error : AppColors.success)
                      .withOpacity(0.3)),
            ),
            child: Row(children: [
              Icon(
                  balance > 0
                      ? Icons.account_balance_wallet_rounded
                      : Icons.check_circle_rounded,
                  color: balance > 0 ? AppColors.error : AppColors.success,
                  size: 22),
              const SizedBox(width: 10),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Solde actuel', style: AppTextStyles.bodySmall),
                Text(AppData.fmtMoneyFull(balance),
                    style: AppTextStyles.headlineSmall.copyWith(
                        color:
                            balance > 0 ? AppColors.error : AppColors.success)),
              ]),
            ]),
          ),
          const SizedBox(height: 14),
        ],

        // Montant & mode
        AppSectionCard(
            title: 'Paiement',
            icon: Icons.payments_rounded,
            children: [
              AppMoneyField(
                  label: 'Montant réglé',
                  controller: _amountCtrl,
                  onChanged: (_) => setState(() {})),
              const SizedBox(height: 14),
              Text('Mode de paiement',
                  style: AppTextStyles.bodyMedium
                      .copyWith(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _modes
                      .map((m) => GestureDetector(
                            onTap: () => setState(() => _mode = m),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: _mode == m
                                    ? AppColors.primary
                                    : AppColors.surfaceVariant,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(m,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: _mode == m
                                        ? Colors.white
                                        : AppColors.textSecondary,
                                    fontWeight: _mode == m
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  )),
                            ),
                          ))
                      .toList()),
              const SizedBox(height: 12),
              AppTextField(
                  label: 'Note (optionnel)',
                  controller: _noteCtrl,
                  hint: 'Ex: Acompte semaine 25'),
            ]),
        const SizedBox(height: 14),

        // Résumé
        if (_amount > 0 && client != null) ...[
          AppSummaryCard(
            title: '📋 Résumé du règlement',
            color: AppColors.success,
            rows: [
              AppSummaryRow(label: 'Client', value: _selectedClient ?? ''),
              AppSummaryRow(
                  label: 'Solde avant',
                  value: AppData.fmtMoneyFull(balance),
                  valueColor: AppColors.error),
              AppSummaryRow(
                  label: 'Montant réglé',
                  value: AppData.fmtMoneyFull(_amount),
                  valueColor: AppColors.success),
              const AppSummaryRow(label: '────────────', value: ''),
              AppSummaryRow(
                label: remaining < 0 ? '⚠️ Sur-paiement' : 'Reste à payer',
                value: AppData.fmtMoneyFull(remaining.abs()),
                valueColor: remaining < 0
                    ? AppColors.warning
                    : remaining == 0
                        ? AppColors.success
                        : AppColors.error,
                isBold: true,
              ),
            ],
          ),
          if (remaining < 0) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warningSurface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.warning.withOpacity(0.3)),
              ),
              child: Row(children: [
                const Icon(Icons.warning_rounded,
                    color: AppColors.warning, size: 18),
                const SizedBox(width: 8),
                Expanded(
                    child: Text(
                  'Le montant saisi dépasse le solde du client de ${AppData.fmtMoneyFull(remaining.abs())}.',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.warning),
                )),
              ]),
            ),
          ],
          const SizedBox(height: 14),
        ],

        if (_saved)
          Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.successSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.success.withOpacity(0.3)),
            ),
            child: Row(children: [
              const Icon(Icons.check_circle_rounded, color: AppColors.success),
              const SizedBox(width: 10),
              Text('Règlement enregistré avec succès !',
                  style: AppTextStyles.titleMedium
                      .copyWith(color: AppColors.success)),
            ]),
          ),

        AppButton(
          label: 'Valider le règlement',
          icon: Icons.check_rounded,
          onPressed: _selectedClient != null && _amount > 0
              ? () {
                  setState(() => _saved = true);
                  Future.delayed(const Duration(seconds: 3), () {
                    if (mounted) setState(() => _saved = false);
                  });
                }
              : null,
        ),
        const SizedBox(height: 20),
      ]),
    );
  }
}
