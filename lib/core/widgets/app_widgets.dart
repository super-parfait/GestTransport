import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../constants/app_constants.dart';

// ─── AppButton ──────────────────────────────────────────────────────────────

enum AppButtonVariant { primary, secondary, outlined, danger, ghost }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final bool expanded;
  final double? height;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.expanded = true,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _getColors();
    final child = isLoading
        ? SizedBox(
            width: 20, height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5, color: colors['text'],
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20, color: colors['text']),
                const SizedBox(width: 8),
              ],
              Text(label, style: AppTextStyles.titleLarge.copyWith(color: colors['text'])),
            ],
          );

    final button = Material(
      color: colors['bg'],
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: isLoading ? null : onPressed,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: height ?? 52,
          constraints: expanded ? const BoxConstraints(minWidth: double.infinity) : null,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: colors['border'] != null
                ? Border.all(color: colors['border']!, width: 1.5)
                : null,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Center(child: child),
        ),
      ),
    );

    return expanded ? SizedBox(width: double.infinity, child: button) : button;
  }

  Map<String, Color?> _getColors() {
    switch (variant) {
      case AppButtonVariant.primary:
        return {'bg': AppColors.primary, 'text': Colors.white, 'border': null};
      case AppButtonVariant.secondary:
        return {'bg': AppColors.primarySurface, 'text': AppColors.primary, 'border': null};
      case AppButtonVariant.outlined:
        return {'bg': Colors.transparent, 'text': AppColors.primary, 'border': AppColors.primary};
      case AppButtonVariant.danger:
        return {'bg': AppColors.error, 'text': Colors.white, 'border': null};
      case AppButtonVariant.ghost:
        return {'bg': Colors.transparent, 'text': AppColors.textSecondary, 'border': AppColors.divider};
    }
  }
}

// ─── AppTextField ────────────────────────────────────────────────────────────

class AppTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscureText;
  final bool readOnly;
  final bool enabled;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final void Function(String)? onChanged;
  final void Function()? onTap;
  final int? maxLines;
  final String? initialValue;
  final bool required;

  const AppTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.validator,
    this.keyboardType,
    this.inputFormatters,
    this.obscureText = false,
    this.readOnly = false,
    this.enabled = true,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.onTap,
    this.maxLines = 1,
    this.initialValue,
    this.required = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: AppTextStyles.labelLarge),
            if (required) ...[
              const SizedBox(width: 4),
              Text('*', style: AppTextStyles.labelLarge.copyWith(color: AppColors.error)),
            ],
          ],
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          initialValue: initialValue,
          validator: validator,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          obscureText: obscureText,
          readOnly: readOnly,
          enabled: enabled,
          onChanged: onChanged,
          onTap: onTap,
          maxLines: maxLines,
          style: AppTextStyles.bodyLarge.copyWith(
            color: enabled ? AppColors.textPrimary : AppColors.disabled,
          ),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: enabled ? AppColors.surfaceVariant : AppColors.disabledSurface,
          ),
        ),
      ],
    );
  }
}

// ─── AppMoneyField ───────────────────────────────────────────────────────────

class AppMoneyField extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool enabled;
  final bool required;

  const AppMoneyField({
    super.key,
    required this.label,
    this.controller,
    this.validator,
    this.onChanged,
    this.enabled = true,
    this.required = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: label,
      hint: '0',
      controller: controller,
      validator: validator,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,0}'))],
      onChanged: onChanged,
      enabled: enabled,
      required: required,
      suffixIcon: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primarySurface,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(AppConstants.currency,
          style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary)),
      ),
    );
  }
}

// ─── AppDropdown ─────────────────────────────────────────────────────────────

class AppDropdown<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?) onChanged;
  final String? Function(T?)? validator;
  final bool enabled;
  final bool required;
  final String? hint;

  const AppDropdown({
    super.key,
    required this.label,
    required this.items,
    required this.onChanged,
    this.value,
    this.validator,
    this.enabled = true,
    this.required = false,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: AppTextStyles.labelLarge),
            if (required) ...[
              const SizedBox(width: 4),
              Text('*', style: AppTextStyles.labelLarge.copyWith(color: AppColors.error)),
            ],
          ],
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<T>(
          value: value,
          items: items,
          onChanged: enabled ? onChanged : null,
          validator: validator,
          style: AppTextStyles.bodyLarge,
          decoration: InputDecoration(
            hintText: hint ?? 'Sélectionner...',
            filled: true,
            fillColor: enabled ? AppColors.surfaceVariant : AppColors.disabledSurface,
          ),
          dropdownColor: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

// ─── AppDatePicker ───────────────────────────────────────────────────────────

class AppDatePicker extends StatefulWidget {
  final String label;
  final DateTime? value;
  final void Function(DateTime) onChanged;
  final bool enabled;
  final bool required;
  final DateTime? firstDate;
  final DateTime? lastDate;

  const AppDatePicker({
    super.key,
    required this.label,
    required this.onChanged,
    this.value,
    this.enabled = true,
    this.required = false,
    this.firstDate,
    this.lastDate,
  });

  @override
  State<AppDatePicker> createState() => _AppDatePickerState();
}

class _AppDatePickerState extends State<AppDatePicker> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.value != null
          ? DateFormat(AppConstants.dateFormat).format(widget.value!)
          : '',
    );
  }

  @override
  void didUpdateWidget(AppDatePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value && widget.value != null) {
      _controller.text = DateFormat(AppConstants.dateFormat).format(widget.value!);
    }
  }

  Future<void> _pickDate() async {
    if (!widget.enabled) return;
    final picked = await showDatePicker(
      context: context,
      initialDate: widget.value ?? DateTime.now(),
      firstDate: widget.firstDate ?? DateTime(2020),
      lastDate: widget.lastDate ?? DateTime(2030),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      _controller.text = DateFormat(AppConstants.dateFormat).format(picked);
      widget.onChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: widget.label,
      hint: 'jj/mm/aaaa',
      controller: _controller,
      readOnly: true,
      enabled: widget.enabled,
      required: widget.required,
      onTap: _pickDate,
      suffixIcon: const Icon(Icons.calendar_today_rounded, size: 18, color: AppColors.textSecondary),
    );
  }
}

// ─── AppSectionCard ──────────────────────────────────────────────────────────

class AppSectionCard extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Color? iconColor;
  final List<Widget> children;
  final EdgeInsets? padding;

  const AppSectionCard({
    super.key,
    required this.title,
    required this.children,
    this.icon,
    this.iconColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.divider)),
            ),
            child: Row(
              children: [
                if (icon != null) ...[
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: (iconColor ?? AppColors.primary).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, size: 18, color: iconColor ?? AppColors.primary),
                  ),
                  const SizedBox(width: 10),
                ],
                Text(title, style: AppTextStyles.headlineSmall),
              ],
            ),
          ),
          Padding(
            padding: padding ?? const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── AppSummaryCard ──────────────────────────────────────────────────────────

class AppSummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isBold;

  const AppSummaryRow({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodyMedium),
          Text(value,
            style: isBold
                ? AppTextStyles.titleLarge.copyWith(color: valueColor ?? AppColors.textPrimary)
                : AppTextStyles.titleMedium.copyWith(color: valueColor ?? AppColors.textPrimary)),
        ],
      ),
    );
  }
}

class AppSummaryCard extends StatelessWidget {
  final String title;
  final List<AppSummaryRow> rows;
  final Color? color;
  final Color? backgroundColor;

  const AppSummaryCard({
    super.key,
    required this.title,
    required this.rows,
    this.color,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? (color ?? AppColors.primary).withOpacity(0.08);
    final borderColor = (color ?? AppColors.primary).withOpacity(0.3);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
            style: AppTextStyles.headlineSmall.copyWith(color: color ?? AppColors.primary)),
          const SizedBox(height: 10),
          const Divider(color: AppColors.divider),
          ...rows,
        ],
      ),
    );
  }
}

// ─── AppStatusBadge ──────────────────────────────────────────────────────────

enum BadgeStatus { success, warning, error, info, neutral }

class AppStatusBadge extends StatelessWidget {
  final String label;
  final BadgeStatus status;
  final bool small;

  const AppStatusBadge({
    super.key,
    required this.label,
    this.status = BadgeStatus.neutral,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _getColors();
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 8 : 12,
        vertical: small ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: colors['bg'],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6, height: 6,
            decoration: BoxDecoration(color: colors['dot'], shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(label,
            style: (small ? AppTextStyles.bodySmall : AppTextStyles.labelLarge)
                .copyWith(color: colors['text'], fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Map<String, Color> _getColors() {
    switch (status) {
      case BadgeStatus.success:
        return {'bg': AppColors.successSurface, 'text': AppColors.success, 'dot': AppColors.success};
      case BadgeStatus.warning:
        return {'bg': AppColors.warningSurface, 'text': AppColors.warning, 'dot': AppColors.warning};
      case BadgeStatus.error:
        return {'bg': AppColors.errorSurface, 'text': AppColors.error, 'dot': AppColors.error};
      case BadgeStatus.info:
        return {'bg': AppColors.infoSurface, 'text': AppColors.info, 'dot': AppColors.info};
      case BadgeStatus.neutral:
        return {'bg': AppColors.surfaceVariant, 'text': AppColors.textSecondary, 'dot': AppColors.disabled};
    }
  }
}

// ─── AppFilePicker ───────────────────────────────────────────────────────────

class AppFilePicker extends StatefulWidget {
  final String label;
  final void Function(String? path)? onFileSelected;

  const AppFilePicker({super.key, this.label = 'Justificatif', this.onFileSelected});

  @override
  State<AppFilePicker> createState() => _AppFilePickerState();
}

class _AppFilePickerState extends State<AppFilePicker> {
  String? _fileName;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: AppTextStyles.labelLarge),
        const SizedBox(height: 6),
        InkWell(
          onTap: () {
            // Simulate file selection
            setState(() => _fileName = 'recu_scan.jpg');
            widget.onFileSelected?.call('/path/to/file');
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _fileName != null ? AppColors.primary : AppColors.divider,
                width: 1.5,
                style: BorderStyle.solid,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _fileName != null ? AppColors.primarySurface : AppColors.divider,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _fileName != null ? Icons.check_circle_rounded : Icons.upload_file_rounded,
                    color: _fileName != null ? AppColors.primary : AppColors.textSecondary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _fileName ?? AppStrings.addPhoto,
                        style: AppTextStyles.titleMedium.copyWith(
                          color: _fileName != null ? AppColors.primary : AppColors.textSecondary,
                        ),
                      ),
                      Text('Photo, image ou scan du reçu', style: AppTextStyles.bodySmall),
                    ],
                  ),
                ),
                if (_fileName != null)
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.textSecondary),
                    onPressed: () => setState(() { _fileName = null; widget.onFileSelected?.call(null); }),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── AppLoadingOverlay ───────────────────────────────────────────────────────

class AppLoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;

  const AppLoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.35),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: AppColors.shadowMedium, blurRadius: 20)],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: AppColors.primary),
                    if (message != null) ...[
                      const SizedBox(height: 16),
                      Text(message!, style: AppTextStyles.bodyMedium),
                    ],
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ─── AppEmptyState ───────────────────────────────────────────────────────────

class AppEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: AppColors.textTertiary),
            ),
            const SizedBox(height: 20),
            Text(title, style: AppTextStyles.headlineSmall.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(subtitle!, style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              AppButton(label: actionLabel!, onPressed: onAction, expanded: false),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── AppConfirmDialog ────────────────────────────────────────────────────────

class AppConfirmDialog extends StatelessWidget {
  final String title;
  final Widget content;
  final String confirmLabel;
  final String cancelLabel;
  final VoidCallback onConfirm;
  final Color? confirmColor;

  const AppConfirmDialog({
    super.key,
    required this.title,
    required this.content,
    required this.onConfirm,
    this.confirmLabel = 'Confirmer',
    this.cancelLabel = 'Annuler',
    this.confirmColor,
  });

  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required Widget content,
    required VoidCallback onConfirm,
    String confirmLabel = 'Confirmer',
    String cancelLabel = 'Annuler',
    Color? confirmColor,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AppConfirmDialog(
        title: title, content: content, onConfirm: onConfirm,
        confirmLabel: confirmLabel, cancelLabel: cancelLabel,
        confirmColor: confirmColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTextStyles.headlineMedium),
            const SizedBox(height: 16),
            content,
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: cancelLabel,
                    variant: AppButtonVariant.ghost,
                    onPressed: () => Navigator.pop(context, false),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton(
                    label: confirmLabel,
                    variant: confirmColor == AppColors.error
                        ? AppButtonVariant.danger
                        : AppButtonVariant.primary,
                    onPressed: () { Navigator.pop(context, true); onConfirm(); },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── DashboardMetricCard ─────────────────────────────────────────────────────

class DashboardMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? subtitle;
  final bool isAlert;
  final VoidCallback? onTap;

  const DashboardMetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
    this.isAlert = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: const Offset(0, 2))],
          border: isAlert ? Border.all(color: color.withOpacity(0.3), width: 1.5) : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 20, color: color),
                ),
                if (isAlert)
                  Container(
                    width: 10, height: 10,
                    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(value,
              style: AppTextStyles.moneyMedium.copyWith(color: AppColors.textPrimary),
              maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text(title, style: AppTextStyles.bodySmall),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(subtitle!, style: AppTextStyles.bodySmall.copyWith(color: color)),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── QuickActionButton ───────────────────────────────────────────────────────

class QuickActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const QuickActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60, height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.25), width: 1.5),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 6),
          Text(label, style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w500),
            textAlign: TextAlign.center, maxLines: 2),
        ],
      ),
    );
  }
}
