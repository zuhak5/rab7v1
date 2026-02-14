import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../router/route_paths.dart';
import '../../domain/value_objects/phone_number.dart';
import '../spec/auth_mobile_spec.dart';
import '../viewmodels/auth_controller.dart';

enum _AuthFormMode { signIn, signUp }

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  static const List<({String code, String country})> _countryCodes =
      <({String code, String country})>[
        (code: '+964', country: 'العراق'),
        (code: '+966', country: 'السعودية'),
        (code: '+971', country: 'الإمارات'),
        (code: '+20', country: 'مصر'),
      ];

  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  _AuthFormMode _mode = _AuthFormMode.signIn;
  String _selectedCode = '+964';
  bool _busy = false;
  bool _obscurePassword = true;

  String _errorCode(Object error) {
    if (error is AuthException) {
      return (error.code ?? '').trim().toLowerCase();
    }
    return '';
  }

  String _errorMessage(Object error) {
    if (error is AuthException) {
      return error.message.trim().toLowerCase();
    }
    return error.toString().trim().toLowerCase();
  }

  bool _containsCode(Object error, String code) {
    final expected = code.toLowerCase();
    return _errorCode(error).contains(expected) ||
        _errorMessage(error).contains(expected);
  }

  String _formatAuthError(Object error) {
    if (_containsCode(error, 'invalid_credentials')) {
      return 'رقم الهاتف أو كلمة المرور غير صحيحة.';
    }
    if (_containsCode(error, 'phone_provider_disabled')) {
      return 'تسجيل الدخول عبر OTP غير مفعل في إعدادات Supabase.';
    }
    if (_containsCode(error, 'over_sms_send_rate_limit')) {
      return 'تم تجاوز عدد محاولات OTP. انتظر قليلًا ثم حاول مرة أخرى.';
    }
    if (_containsCode(error, 'hook_timeout') ||
        _errorMessage(error).contains('failed to reach hook')) {
      return 'هناك تأخير من مزود الرسائل. إذا وصلك الرمز، أكمل التحقق.';
    }
    return error.toString();
  }

  String? _buildNormalizedPhone() {
    final rawInput = _phoneController.text.trim();
    if (rawInput.isEmpty) {
      return null;
    }

    if (rawInput.startsWith('+') || rawInput.startsWith('00')) {
      return PhoneNumber.normalize(rawInput);
    }

    var digits = rawInput.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.startsWith('0')) {
      digits = digits.substring(1);
    }
    return PhoneNumber.normalize('$_selectedCode$digits');
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onSignInPressed() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    final phone = _buildNormalizedPhone()!;
    final password = _passwordController.text;

    setState(() {
      _busy = true;
    });

    try {
      await ref
          .read(authControllerProvider.notifier)
          .signInWithPassword(phone: phone, password: password);
      if (!mounted) {
        return;
      }
      context.go(RoutePaths.rides);
    } catch (error) {
      if (!mounted) {
        return;
      }
      messenger.showSnackBar(SnackBar(content: Text(_formatAuthError(error))));
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }

  Future<void> _onSendOtpPressed() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    final phone = _buildNormalizedPhone()!;
    ref.read(pendingPhoneProvider.notifier).state = phone;

    setState(() {
      _busy = true;
    });

    var shouldNavigate = false;
    try {
      await ref.read(authControllerProvider.notifier).requestPhoneOtp(phone);
      shouldNavigate = true;
    } catch (error) {
      final message = _formatAuthError(error);
      if (mounted) {
        messenger.showSnackBar(SnackBar(content: Text(message)));
      }
      if (_containsCode(error, 'hook_timeout') ||
          _errorMessage(error).contains('failed to reach hook')) {
        shouldNavigate = true;
      }
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }

    if (!mounted || !shouldNavigate) {
      return;
    }
    ref.read(profileSetupPendingProvider.notifier).state = true;
    ref.read(selectedSignUpRoleProvider.notifier).state = null;
    context.go('${RoutePaths.otpVerify}?phone=${Uri.encodeComponent(phone)}');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

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
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(AuthMobileSpec.surfaceRadius),
                    border: Border.all(color: colors.outline.withValues(alpha: 0.75)),
                    boxShadow: const <BoxShadow>[
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.12),
                        blurRadius: 20,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Text(
                          'مرحبًا بك في RideIQ',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _mode == _AuthFormMode.signIn
                              ? 'سجّل الدخول برقم هاتفك وكلمة المرور.'
                              : 'أنشئ حسابًا جديدًا عبر رمز OTP.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _AuthModeToggle(
                          mode: _mode,
                          onChanged: (mode) {
                            if (_busy) {
                              return;
                            }
                            setState(() {
                              _mode = mode;
                            });
                          },
                        ),
                        const SizedBox(height: 14),
                        _PhoneInput(
                          controller: _phoneController,
                          selectedCode: _selectedCode,
                          countryCodes: _countryCodes,
                          onCodeChanged: (value) {
                            setState(() {
                              _selectedCode = value;
                            });
                          },
                          validator: (_) {
                            if (_buildNormalizedPhone() == null) {
                              return 'أدخل رقم هاتف عراقي بصيغة صحيحة.';
                            }
                            return null;
                          },
                        ),
                        if (_mode == _AuthFormMode.signIn) ...<Widget>[
                          const SizedBox(height: 12),
                          TextFormField(
                            key: const ValueKey<String>('login_password_field'),
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.done,
                            decoration: InputDecoration(
                              labelText: 'كلمة المرور',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AuthMobileSpec.fieldRadius),
                              ),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_rounded
                                      : Icons.visibility_off_rounded,
                                ),
                              ),
                            ),
                            validator: (value) {
                              final v = value?.trim() ?? '';
                              if (v.isEmpty) {
                                return 'كلمة المرور مطلوبة.';
                              }
                              if (v.length < 8) {
                                return 'الحد الأدنى 8 أحرف.';
                              }
                              return null;
                            },
                          ),
                        ],
                        const SizedBox(height: 16),
                        FilledButton(
                          key: const ValueKey<String>('login_primary_button'),
                          onPressed: _busy
                              ? null
                              : () {
                                  if (_mode == _AuthFormMode.signIn) {
                                    _onSignInPressed();
                                  } else {
                                    _onSendOtpPressed();
                                  }
                                },
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(AuthMobileSpec.buttonHeight),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AuthMobileSpec.fieldRadius),
                            ),
                          ),
                          child: Text(
                            _busy
                                ? 'الرجاء الانتظار...'
                                : _mode == _AuthFormMode.signIn
                                ? 'تسجيل الدخول'
                                : 'إرسال رمز التحقق',
                          ),
                        ),
                        if (_mode == _AuthFormMode.signIn)
                          Align(
                            alignment: AlignmentDirectional.centerEnd,
                            child: TextButton(
                              key: const ValueKey<String>('login_forgot_button'),
                              onPressed: _busy
                                  ? null
                                  : () => context.go(RoutePaths.forgotPassword),
                              child: const Text('نسيت كلمة المرور؟'),
                            ),
                          ),
                        const SizedBox(height: 4),
                        TextButton(
                          key: const ValueKey<String>('login_toggle_button'),
                          onPressed: _busy
                              ? null
                              : () {
                                  setState(() {
                                    _mode = _mode == _AuthFormMode.signIn
                                        ? _AuthFormMode.signUp
                                        : _AuthFormMode.signIn;
                                  });
                                },
                          child: Text(
                            _mode == _AuthFormMode.signIn
                                ? 'ليس لديك حساب؟ إنشاء حساب'
                                : 'لديك حساب بالفعل؟ تسجيل الدخول',
                          ),
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

class _AuthModeToggle extends StatelessWidget {
  const _AuthModeToggle({required this.mode, required this.onChanged});

  final _AuthFormMode mode;
  final ValueChanged<_AuthFormMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _ToggleButton(
              key: const ValueKey<String>('login_mode_sign_in'),
              active: mode == _AuthFormMode.signIn,
              label: 'تسجيل الدخول',
              onTap: () => onChanged(_AuthFormMode.signIn),
            ),
          ),
          Expanded(
            child: _ToggleButton(
              key: const ValueKey<String>('login_mode_sign_up'),
              active: mode == _AuthFormMode.signUp,
              label: 'إنشاء حساب',
              onTap: () => onChanged(_AuthFormMode.signUp),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  const _ToggleButton({
    required this.active,
    required this.label,
    required this.onTap,
    super.key,
  });

  final bool active;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AuthMobileSpec.shortDuration,
        curve: AuthMobileSpec.standardCurve,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: active ? colors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: active ? colors.onPrimary : colors.onSurfaceVariant,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _PhoneInput extends StatelessWidget {
  const _PhoneInput({
    required this.controller,
    required this.selectedCode,
    required this.countryCodes,
    required this.onCodeChanged,
    required this.validator,
  });

  final TextEditingController controller;
  final String selectedCode;
  final List<({String code, String country})> countryCodes;
  final ValueChanged<String> onCodeChanged;
  final String? Function(String?) validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: const ValueKey<String>('login_phone_field'),
      controller: controller,
      keyboardType: TextInputType.phone,
      decoration: InputDecoration(
        labelText: 'رقم الهاتف',
        hintText: '7XXXXXXXXX',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AuthMobileSpec.fieldRadius),
        ),
        prefixIcon: Padding(
          padding: const EdgeInsetsDirectional.only(start: 8, end: 6),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedCode,
              borderRadius: BorderRadius.circular(12),
              items: countryCodes.map((entry) {
                return DropdownMenuItem<String>(
                  value: entry.code,
                  child: Text('${entry.code} ${entry.country}'),
                );
              }).toList(),
              onChanged: (value) {
                if (value == null) {
                  return;
                }
                onCodeChanged(value);
              },
            ),
          ),
        ),
      ),
      validator: validator,
    );
  }
}
