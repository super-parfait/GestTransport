import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/layout/app_breakpoints.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_widgets.dart';
import 'controllers/session_controller.dart';

class RegisterScreen extends StatefulWidget {
  final SessionController sessionController;

  const RegisterScreen({
    super.key,
    required this.sessionController,
  });

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    widget.sessionController.clearError();
  }

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final isRegistered = await widget.sessionController.register(
      fullName: _fullNameCtrl.text,
      phone: _phoneCtrl.text,
      email: _emailCtrl.text,
      password: _passwordCtrl.text,
    );

    if (!mounted || !isRegistered) {
      return;
    }

    Navigator.of(context).pop();
  }

  String? _validatePhone(String? value) {
    final trimmed = value?.trim() ?? '';
    final normalized = trimmed.replaceAll(RegExp(r'\s+'), '');

    if (normalized.isEmpty) {
      return 'Entrez votre numéro de téléphone';
    }

    if (normalized.length < 8) {
      return 'Numéro de téléphone invalide';
    }

    return null;
  }

  String? _validateEmail(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return null;
    }

    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(trimmed)) {
      return 'Email invalide';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    final trimmed = value?.trim() ?? '';

    if (trimmed.isEmpty) {
      return 'Entrez votre mot de passe';
    }

    if (trimmed.length < 6) {
      return 'Le mot de passe doit contenir au moins 6 caractères';
    }

    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if ((value ?? '').trim().isEmpty) {
      return 'Confirmez votre mot de passe';
    }

    if (value!.trim() != _passwordCtrl.text.trim()) {
      return 'Les mots de passe ne correspondent pas';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.sessionController,
      builder: (context, _) {
        final isLoading = widget.sessionController.isSubmitting;
        final errorMessage = widget.sessionController.errorMessage;

        return LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final horizontalPadding = AppBreakpoints.pagePadding(width);
            final maxWidth = AppBreakpoints.formContentMaxWidth(width);

            return Scaffold(
              backgroundColor: AppColors.backgroundLight,
              appBar: AppBar(
                title: const Text(AppStrings.register),
              ),
              body: AppLoadingOverlay(
                isLoading: isLoading,
                message: AppStrings.registering,
                child: SafeArea(
                  top: false,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxWidth),
                      child: SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          8,
                          horizontalPadding,
                          24,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 12),
                            Text(
                              'Créer un compte',
                              style: AppTextStyles.displayMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Utilise ce formulaire dédié pour créer ton accès mobile.',
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 28),
                            if (errorMessage != null) ...[
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: AppColors.errorSurface,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: AppColors.error.withValues(
                                      alpha: 0.30,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.error_outline_rounded,
                                      color: AppColors.error,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        errorMessage,
                                        style: AppTextStyles.bodyMedium
                                            .copyWith(color: AppColors.error),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                            Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AppTextField(
                                    label: AppStrings.fullName,
                                    hint: 'Ex: Konan Yao',
                                    controller: _fullNameCtrl,
                                    required: true,
                                    prefixIcon: const Icon(
                                      Icons.badge_outlined,
                                      color: AppColors.textSecondary,
                                      size: 20,
                                    ),
                                    validator: (value) {
                                      if ((value ?? '').trim().isEmpty) {
                                        return 'Entrez votre nom complet';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  AppTextField(
                                    label: AppStrings.phone,
                                    hint: 'Ex: 07 11 22 33 44',
                                    controller: _phoneCtrl,
                                    keyboardType: TextInputType.phone,
                                    required: true,
                                    prefixIcon: const Icon(
                                      Icons.phone_outlined,
                                      color: AppColors.textSecondary,
                                      size: 20,
                                    ),
                                    validator: _validatePhone,
                                  ),
                                  const SizedBox(height: 16),
                                  AppTextField(
                                    label: AppStrings.email,
                                    hint: 'Ex: contact@entreprise.com',
                                    controller: _emailCtrl,
                                    keyboardType: TextInputType.emailAddress,
                                    prefixIcon: const Icon(
                                      Icons.mail_outline_rounded,
                                      color: AppColors.textSecondary,
                                      size: 20,
                                    ),
                                    validator: _validateEmail,
                                  ),
                                  const SizedBox(height: 16),
                                  AppTextField(
                                    label: AppStrings.password,
                                    hint: '••••••••',
                                    controller: _passwordCtrl,
                                    obscureText: _obscurePassword,
                                    required: true,
                                    prefixIcon: const Icon(
                                      Icons.lock_outline_rounded,
                                      color: AppColors.textSecondary,
                                      size: 20,
                                    ),
                                    validator: _validatePassword,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        color: AppColors.textSecondary,
                                        size: 20,
                                      ),
                                      onPressed: () => setState(
                                        () => _obscurePassword =
                                            !_obscurePassword,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  AppTextField(
                                    label: AppStrings.confirmPassword,
                                    hint: '••••••••',
                                    controller: _confirmPasswordCtrl,
                                    obscureText: _obscureConfirmPassword,
                                    required: true,
                                    prefixIcon: const Icon(
                                      Icons.lock_reset_outlined,
                                      color: AppColors.textSecondary,
                                      size: 20,
                                    ),
                                    validator: _validateConfirmPassword,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscureConfirmPassword
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        color: AppColors.textSecondary,
                                        size: 20,
                                      ),
                                      onPressed: () => setState(
                                        () => _obscureConfirmPassword =
                                            !_obscureConfirmPassword,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 28),
                                  AppButton(
                                    label: AppStrings.register,
                                    icon: Icons.person_add_alt_1_rounded,
                                    isLoading: isLoading,
                                    onPressed: _submit,
                                  ),
                                  const SizedBox(height: 16),
                                  Center(
                                    child: TextButton(
                                      onPressed: isLoading
                                          ? null
                                          : () => Navigator.of(context).pop(),
                                      child: const Text(
                                        'J’ai déjà un compte',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
