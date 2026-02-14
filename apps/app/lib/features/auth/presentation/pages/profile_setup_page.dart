import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../router/route_paths.dart';
import '../../domain/entities/sign_up_role.dart';
import '../../domain/exceptions/auth_onboarding_exception.dart';
import '../spec/auth_mobile_spec.dart';
import '../viewmodels/auth_controller.dart';

class ProfileSetupPage extends ConsumerStatefulWidget {
  const ProfileSetupPage({super.key});

  @override
  ConsumerState<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends ConsumerState<ProfileSetupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _submitting = false;
  bool _hidePassword = true;
  bool _hideConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String _formatError(Object error) {
    if (error is RoleSetupRequiredException) {
      if (error.role == 'driver') {
        return 'إعداد حساب السائق غير مكتمل في الخلفية. أكمل التهيئة ثم أعد المحاولة.';
      }
      if (error.role == 'merchant') {
        return 'إعداد حساب التاجر غير مكتمل في الخلفية. أكمل التهيئة ثم أعد المحاولة.';
      }
      return 'تهيئة الدور غير مكتملة في الخلفية.';
    }
    if (error is OnboardingPersistenceException) {
      return error.message;
    }
    if (error is AppException) {
      return error.message;
    }
    if (error is AuthException) {
      return error.message;
    }
    if (error is PostgrestException) {
      final message = error.message.toLowerCase();
      if (message.contains('driver not setup')) {
        return 'حساب السائق غير مهيأ بعد في الخلفية.';
      }
      if (message.contains('merchant not setup')) {
        return 'حساب التاجر غير مهيأ بعد في الخلفية.';
      }
      if ((error.code ?? '').trim() == '42501' ||
          message.contains('permission denied')) {
        return 'لا توجد صلاحية لتحديث بيانات الإعداد في الخلفية.';
      }
      return error.message;
    }
    return error.toString();
  }

  Future<void> _createAccount() async {
    final role = ref.read(selectedSignUpRoleProvider);
    if (role == null) {
      if (mounted) {
        context.go(RoutePaths.roleSelection);
      }
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    ref.read(onboardingPersistenceErrorProvider.notifier).state = null;

    setState(() {
      _submitting = true;
    });

    try {
      await ref.read(authControllerProvider.notifier).completeProfile(
            name: _nameController.text.trim(),
            password: _passwordController.text,
            role: role,
          );
      if (!mounted) {
        return;
      }
      final bootstrapStatus = ref.read(authAppContextBootstrapStatusProvider);
      final setupPending = ref.read(profileSetupPendingProvider);

      if (bootstrapStatus == AuthAppContextBootstrapStatus.error || setupPending) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('تم حفظ البيانات، لكن حالة الإعداد لم تُحسم بعد. أعد التحقق.'),
          ),
        );
        context.go(RoutePaths.authBootstrap);
        return;
      }

      context.go(RoutePaths.authBootstrap);
    } catch (error) {
      if (!mounted) {
        return;
      }
      final message = _formatError(error);
      ref.read(onboardingPersistenceErrorProvider.notifier).state = message;
      messenger.showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final selectedRole = ref.watch(selectedSignUpRoleProvider);
    final onboardingError = ref.watch(onboardingPersistenceErrorProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AuthMobileSpec.pageGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AuthMobileSpec.pageHorizontalPadding,
                vertical: 16,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: AuthMobileSpec.maxContentWidth),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(AuthMobileSpec.surfaceRadius),
                    border: Border.all(color: colors.outline.withValues(alpha: 0.75)),
                    boxShadow: const <BoxShadow>[
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.12),
                        blurRadius: 18,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: selectedRole == null
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            const Text(
                              'اختر نوع الحساب قبل إكمال بيانات الملف الشخصي.',
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            FilledButton(
                              onPressed: () => context.go(RoutePaths.roleSelection),
                              child: const Text('اختيار الدور'),
                            ),
                          ],
                        )
                      : Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Text(
                                'إكمال الملف الشخصي',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Center(
                                child: Chip(label: Text('الدور: ${selectedRole.title}')),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'أدخل الاسم وكلمة المرور لإكمال إعداد الحساب.',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                              if (onboardingError != null &&
                                  onboardingError.trim().isNotEmpty) ...<Widget>[
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: colors.errorContainer.withValues(alpha: 0.65),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: colors.error.withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        onboardingError,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: colors.onErrorContainer,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: <Widget>[
                                          OutlinedButton(
                                            onPressed: _submitting
                                                ? null
                                                : () => context.go(RoutePaths.authBootstrap),
                                            child: const Text('التحقق من السياق'),
                                          ),
                                          OutlinedButton(
                                            onPressed: _submitting
                                                ? null
                                                : () {
                                                    ref
                                                        .read(onboardingPersistenceErrorProvider.notifier)
                                                        .state = null;
                                                  },
                                            child: const Text('إخفاء الرسالة'),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              const SizedBox(height: 16),
                              TextFormField(
                                key: const ValueKey<String>('profile_name_field'),
                                controller: _nameController,
                                textInputAction: TextInputAction.next,
                                decoration: InputDecoration(
                                  labelText: 'الاسم الكامل',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(AuthMobileSpec.fieldRadius),
                                  ),
                                ),
                                validator: (value) {
                                  final v = value?.trim() ?? '';
                                  if (v.isEmpty) {
                                    return 'الاسم مطلوب.';
                                  }
                                  if (v.length < 2) {
                                    return 'أدخل اسمًا مكونًا من حرفين على الأقل.';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                key: const ValueKey<String>('profile_password_field'),
                                controller: _passwordController,
                                obscureText: _hidePassword,
                                textInputAction: TextInputAction.next,
                                decoration: InputDecoration(
                                  labelText: 'كلمة المرور',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(AuthMobileSpec.fieldRadius),
                                  ),
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _hidePassword = !_hidePassword;
                                      });
                                    },
                                    icon: Icon(
                                      _hidePassword
                                          ? Icons.visibility_rounded
                                          : Icons.visibility_off_rounded,
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  final v = value ?? '';
                                  if (v.isEmpty) {
                                    return 'كلمة المرور مطلوبة.';
                                  }
                                  if (v.length < 8) {
                                    return 'الحد الأدنى 8 أحرف.';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                key: const ValueKey<String>('profile_confirm_password_field'),
                                controller: _confirmPasswordController,
                                obscureText: _hideConfirmPassword,
                                textInputAction: TextInputAction.done,
                                decoration: InputDecoration(
                                  labelText: 'تأكيد كلمة المرور',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(AuthMobileSpec.fieldRadius),
                                  ),
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _hideConfirmPassword = !_hideConfirmPassword;
                                      });
                                    },
                                    icon: Icon(
                                      _hideConfirmPassword
                                          ? Icons.visibility_rounded
                                          : Icons.visibility_off_rounded,
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  final v = value ?? '';
                                  if (v.isEmpty) {
                                    return 'أعد إدخال كلمة المرور.';
                                  }
                                  if (v != _passwordController.text) {
                                    return 'كلمتا المرور غير متطابقتين.';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 18),
                              FilledButton(
                                key: const ValueKey<String>('profile_create_button'),
                                onPressed: _submitting ? null : _createAccount,
                                style: FilledButton.styleFrom(
                                  minimumSize: const Size.fromHeight(AuthMobileSpec.buttonHeight),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(AuthMobileSpec.fieldRadius),
                                  ),
                                ),
                                child: Text(_submitting ? 'جارٍ الحفظ...' : 'إنشاء الحساب'),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
