import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../core/network/api_service.dart';
import 'client_detail_screen.dart';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});
  @override State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final clients = AppData.clients.where((c) =>
      (c['name'] as String).toLowerCase().contains(_search.toLowerCase()) ||
      (c['phone'] as String).contains(_search)
    ).toList();

    final totalDebt = clients.fold<double>(0, (s, c) => s + (c['balance'] as double));

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Clients'),
        backgroundColor: AppColors.surface,
        actions: [
          IconButton(icon: const Icon(Icons.person_add_rounded, color: AppColors.primary), onPressed: () {}),
        ],
      ),
      body: Column(children: [
        Container(
          color: AppColors.surface,
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            TextField(
              onChanged: (v) => setState(() => _search = v),
              decoration: InputDecoration(
                hintText: 'Rechercher un client...',
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary),
                filled: true, fillColor: AppColors.surfaceVariant,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 12),
            Row(children: [
              _pill('${clients.length}', 'Clients', AppColors.primary),
              const SizedBox(width: 8),
              _pill('${clients.where((c) => (c['balance'] as double) > 0).length}', 'Débiteurs', AppColors.error),
              const SizedBox(width: 8),
              _pill(AppData.fmtMoney(totalDebt), 'Encours', AppColors.warning),
            ]),
          ]),
        ),
        const Divider(height: 1),
        Expanded(
          child: clients.isEmpty
              ? AppEmptyState(icon: Icons.people_rounded, title: 'Aucun client trouvé',
                  subtitle: 'Modifiez votre recherche.', actionLabel: 'Ajouter', onAction: () {})
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: clients.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _ClientCard(client: clients[i]),
                ),
        ),
      ]),
    );
  }

  Widget _pill(String value, String label, Color color) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
      child: Column(children: [
        Text(value, style: AppTextStyles.headlineSmall.copyWith(color: color)),
        Text(label, style: AppTextStyles.bodySmall),
      ]),
    ),
  );
}

class _ClientCard extends StatelessWidget {
  final Map<String, dynamic> client;
  const _ClientCard({required this.client});

  Color get _color {
    final b = client['balance'] as double;
    if (b == 0) return AppColors.success;
    if (b > 3000000) return AppColors.error;
    return AppColors.warning;
  }

  @override
  Widget build(BuildContext context) {
    final balance = client['balance'] as double;
    return GestureDetector(
      onTap: () => Navigator.push(context,
        MaterialPageRoute(builder: (_) => ClientDetailScreen(client: client))),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface, borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 6)],
          border: balance > 0 ? Border.all(color: _color.withOpacity(0.25)) : null,
        ),
        child: Row(children: [
          Container(
            width: 46, height: 46,
            decoration: BoxDecoration(color: _color.withOpacity(0.12), shape: BoxShape.circle),
            child: Center(child: Text(
              (client['name'] as String)[0].toUpperCase(),
              style: AppTextStyles.headlineMedium.copyWith(color: _color),
            )),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(client['name'], style: AppTextStyles.titleLarge),
            const SizedBox(height: 2),
            Row(children: [
              const Icon(Icons.phone_rounded, size: 13, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(client['phone'], style: AppTextStyles.bodySmall),
            ]),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(AppData.fmtMoneyFull(balance), style: AppTextStyles.titleLarge.copyWith(color: _color)),
            const SizedBox(height: 4),
            AppStatusBadge(
              label: balance == 0 ? 'À jour' : 'Débiteur',
              status: balance == 0 ? BadgeStatus.success : balance > 3000000 ? BadgeStatus.error : BadgeStatus.warning,
              small: true,
            ),
          ]),
        ]),
      ),
    );
  }
}
