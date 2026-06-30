import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/layout/app_breakpoints.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_widgets.dart';
import 'controllers/session_controller.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  final SessionController sessionController;

  const LoginScreen({
    super.key,
    required this.sessionController,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _slideAnim =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    await widget.sessionController.login(
      identifier: _phoneCtrl.text,
      password: _passwordCtrl.text,
    );
  }

  Future<void> _openRegisterScreen() async {
    widget.sessionController.clearError();

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => RegisterScreen(
          sessionController: widget.sessionController,
        ),
      ),
    );
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
            final height = constraints.maxHeight;
            final horizontalPadding = AppBreakpoints.pagePadding(width);
            final maxWidth = AppBreakpoints.formContentMaxWidth(width);
            final headerHeight = (height * 0.28).clamp(180.0, 250.0).toDouble();
            final cardPadding = AppBreakpoints.isCompact(width) ? 22.0 : 28.0;

            return Scaffold(
              backgroundColor: AppColors.backgroundLight,
              body: AppLoadingOverlay(
                isLoading: isLoading,
                message: AppStrings.connecting,
                child: SafeArea(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxWidth),
                      child: SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          16,
                          horizontalPadding,
                          16,
                        ),
                        child: Column(
                          children: [
                            SizedBox(
                              height: headerHeight,
                              child: FadeTransition(
                                opacity: _fadeAnim,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        color: AppColors.primarySurface,
                                        borderRadius: BorderRadius.circular(24),
                                        border: Border.all(
                                          color: AppColors.primary
                                              .withValues(alpha: 0.20),
                                          width: 2,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.local_shipping_rounded,
                                        size: 44,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      AppStrings.appName,
                                      textAlign: TextAlign.center,
                                      style: AppTextStyles.displayMedium
                                          .copyWith(color: AppColors.primary),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      AppStrings.appTagline,
                                      textAlign: TextAlign.center,
                                      style: AppTextStyles.bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SlideTransition(
                              position: _slideAnim,
                              child: FadeTransition(
                                opacity: _fadeAnim,
                                child: Container(
                                  padding: EdgeInsets.all(cardPadding),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius: BorderRadius.circular(28),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: AppColors.shadowMedium,
                                        blurRadius: 16,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Form(
                                    key: _formKey,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          AppStrings.login,
                                          style: AppTextStyles.headlineLarge,
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          'Bienvenue ! Connectez-vous pour continuer.',
                                          style: AppTextStyles.bodyMedium,
                                        ),
                                        const SizedBox(height: 28),
                                        if (errorMessage != null) ...[
                                          Container(
                                            padding: const EdgeInsets.all(14),
                                            decoration: BoxDecoration(
                                              color: AppColors.errorSurface,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color: AppColors.error
                                                    .withValues(alpha: 0.30),
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
                                                    style: AppTextStyles
                                                        .bodyMedium
                                                        .copyWith(
                                                      color: AppColors.error,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 20),
                                        ],
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
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              _obscurePassword
                                                  ? Icons
                                                      .visibility_off_outlined
                                                  : Icons.visibility_outlined,
                                              color: AppColors.textSecondary,
                                              size: 20,
                                            ),
                                            onPressed: () => setState(
                                              () => _obscurePassword =
                                                  !_obscurePassword,
                                            ),
                                          ),
                                          validator: (value) {
                                            if ((value ?? '').trim().isEmpty) {
                                              return 'Entrez votre mot de passe';
                                            }
                                            return null;
                                          },
                                        ),
                                        const SizedBox(height: 28),
                                        AppButton(
                                          label: AppStrings.login,
                                          isLoading: isLoading,
                                          icon: Icons.login_rounded,
                                          onPressed: _login,
                                        ),
                                        const SizedBox(height: 18),
                                        Center(
                                          child: Wrap(
                                            crossAxisAlignment:
                                                WrapCrossAlignment.center,
                                            spacing: 4,
                                            children: [
                                              Text(
                                                'Pas encore de compte ?',
                                                style: AppTextStyles.bodyMedium,
                                              ),
                                              TextButton(
                                                onPressed: _openRegisterScreen,
                                                child: const Text(
                                                  AppStrings.register,
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
                            const SizedBox(height: 32),
                            Text(
                              '© 2026 TranspoGest — v1.0.0',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textTertiary,
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
