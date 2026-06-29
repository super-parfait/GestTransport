import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_widgets.dart';

class OilChangeScreen extends StatefulWidget {
  final String truckPlate;
  final List oilChanges;
  const OilChangeScreen(
      {super.key, required this.truckPlate, this.oilChanges = const []});

  @override
  State<OilChangeScreen> createState() => _OilChangeScreenState();
}

class _OilChangeScreenState extends State<OilChangeScreen> {
  String _type = 'Par km';
  final _kmCtrl = TextEditingController();
  final _huileCtrl = TextEditingController();
  bool _filtre = false;
  bool _saved = false;

  @override
  void dispose() {
    _kmCtrl.dispose();
    _huileCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isStandalone = widget.oilChanges.isEmpty;

    return isStandalone
        ? Scaffold(
            backgroundColor: AppColors.backgroundLight,
            appBar: AppBar(
                title: Text('Vidange — ${widget.truckPlate}'),
                backgroundColor: AppColors.surface),
            body: _buildBody(),
          )
        : _buildBody();
  }

  Widget _buildBody() => ListView(padding: const EdgeInsets.all(16), children: [
        // Historique
        if (widget.oilChanges.isNotEmpty) ...[
          Text('Historique vidanges', style: AppTextStyles.headlineSmall),
          const SizedBox(height: 12),
          ...widget.oilChanges.map((o) => _histCard(o as Map<String, dynamic>)),
          const SizedBox(height: 20),
        ],

        // Formulaire nouvelle vidange
        Text('Nouvelle vidange', style: AppTextStyles.headlineSmall),
        const SizedBox(height: 12),

        AppSectionCard(
            title: 'Type de suivi',
            icon: Icons.tune_rounded,
            children: [
              Row(children: [
                Expanded(child: _typeBtn('Par km', Icons.speed_rounded)),
                const SizedBox(width: 10),
                Expanded(
                    child: _typeBtn('Par semaines', Icons.date_range_rounded)),
              ]),
            ]),
        const SizedBox(height: 14),

        AppSectionCard(
            title: 'Détails',
            icon: Icons.oil_barrel_rounded,
            children: [
              AppTextField(
                label: _type == 'Par km'
                    ? 'Kilométrage actuel'
                    : 'Date de la vidange',
                controller: _kmCtrl,
                keyboardType: _type == 'Par km'
                    ? TextInputType.number
                    : TextInputType.text,
                required: true,
              ),
              const SizedBox(height: 12),
              AppTextField(
                  label: "Type d'huile",
                  controller: _huileCtrl,
                  hint: 'Ex: 15W-40'),
              const SizedBox(height: 12),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Changement filtre', style: AppTextStyles.bodyMedium),
                Switch(
                  value: _filtre,
                  onChanged: (v) => setState(() => _filtre = v),
                  activeColor: AppColors.primary,
                ),
              ]),
            ]),
        const SizedBox(height: 20),

        if (_saved)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.successSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.success.withOpacity(0.3)),
            ),
            child: Row(children: [
              const Icon(Icons.check_circle_rounded, color: AppColors.success),
              const SizedBox(width: 10),
              Text('Vidange enregistrée !',
                  style: AppTextStyles.titleMedium
                      .copyWith(color: AppColors.success)),
            ]),
          ),

        AppButton(
          label: 'Enregistrer la vidange',
          icon: Icons.save_rounded,
          onPressed: () {
            setState(() {
              _saved = true;
              _kmCtrl.clear();
              _huileCtrl.clear();
              _filtre = false;
            });
            Future.delayed(const Duration(seconds: 3), () {
              if (mounted) setState(() => _saved = false);
            });
          },
        ),
      ]);

  Widget _typeBtn(String label, IconData icon) {
    final selected = _type == label;
    return GestureDetector(
      onTap: () => setState(() => _type = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(children: [
          Icon(icon,
              color: selected ? Colors.white : AppColors.textSecondary,
              size: 22),
          const SizedBox(height: 4),
          Text(label,
              style: AppTextStyles.bodySmall.copyWith(
                color: selected ? Colors.white : AppColors.textSecondary,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              )),
        ]),
      ),
    );
  }

  Widget _histCard(Map<String, dynamic> o) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primarySurface),
        boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 6)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.oil_barrel_rounded,
              color: AppColors.primary, size: 18),
          const SizedBox(width: 8),
          Text(o['date'], style: AppTextStyles.titleMedium),
          const Spacer(),
          AppStatusBadge(label: o['type'], status: BadgeStatus.info),
        ]),
        const SizedBox(height: 8),
        if (o['km'] != null)
          Text('KM: ${o['km']}', style: AppTextStyles.bodySmall),
        if (o['prochain_km'] != null)
          Text('Prochain: ${o['prochain_km']} km',
              style:
                  AppTextStyles.bodySmall.copyWith(color: AppColors.warning)),
        if (o['prochaine_date'] != null)
          Text('Prochain: ${o['prochaine_date']}',
              style:
                  AppTextStyles.bodySmall.copyWith(color: AppColors.warning)),
        Text('Huile: ${o['huile']}', style: AppTextStyles.bodySmall),
        Text('Filtre: ${(o['filtre'] as bool) ? 'Changé' : 'Non changé'}',
            style: AppTextStyles.bodySmall.copyWith(
                color: (o['filtre'] as bool)
                    ? AppColors.success
                    : AppColors.textTertiary)),
      ]),
    );
  }
}
