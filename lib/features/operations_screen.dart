import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../core/constants/app_constants.dart';
import '../core/widgets/app_widgets.dart';
import 'loadings/presentation/loading_screen.dart';
import 'factory_payments/presentation/factory_payment_screen.dart';
import 'client_payments/presentation/client_payment_screen.dart';
import 'charges/presentation/charges_screen.dart';
import 'revenues/presentation/revenue_screen.dart';

class OperationsScreen extends StatelessWidget {
  const OperationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ops = [
      _OpCard(
        title: AppStrings.factoryPayment,
        description: 'Enregistrer un versement à la carrière ou à l\'usine',
        icon: Icons.factory_rounded,
        color: AppColors.primary,
        badge: null,
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FactoryPaymentScreen())),
      ),
      _OpCard(
        title: AppStrings.clientLoading,
        description: 'Nouveau chargement Sable, Gravier ou Transport',
        icon: Icons.inventory_2_rounded,
        color: AppColors.info,
        badge: 'Important',
        badgeColor: AppColors.info,
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ClientLoadingScreen())),
      ),
      _OpCard(
        title: AppStrings.clientPayment,
        description: 'Enregistrer un règlement de client',
        icon: Icons.payments_rounded,
        color: AppColors.success,
        badge: null,
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ClientPaymentScreen())),
      ),
      _OpCard(
        title: AppStrings.expenses,
        description: 'Dépenses simples ou entretiens / garage',
        icon: Icons.build_rounded,
        color: AppColors.warning,
        badge: null,
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChargesScreen())),
      ),
      _OpCard(
        title: AppStrings.revenue,
        description: 'Recettes par voyage ou par semaine',
        icon: Icons.add_card_rounded,
        color: AppColors.success,
        badge: null,
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RevenueScreen())),
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(AppStrings.operations),
        backgroundColor: AppColors.surface,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.divider),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Choisissez une opération',
            style: AppTextStyles.bodyMedium),
          const SizedBox(height: 16),
          ...ops.map((op) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildOpCard(op, context),
          )),
        ],
      ),
    );
  }

  Widget _buildOpCard(_OpCard op, BuildContext context) {
    return GestureDetector(
      onTap: op.onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                color: op.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(op.icon, color: op.color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(op.title, style: AppTextStyles.titleLarge),
                      if (op.badge != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: (op.badgeColor ?? op.color).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(op.badge!,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: op.badgeColor ?? op.color, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(op.description, style: AppTextStyles.bodyMedium),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}

class _OpCard {
  final String title, description;
  final IconData icon;
  final Color color;
  final String? badge;
  final Color? badgeColor;
  final VoidCallback onTap;
  _OpCard({required this.title, required this.description, required this.icon,
    required this.color, required this.onTap, this.badge, this.badgeColor});
}
