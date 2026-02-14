import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../router/route_paths.dart';
import '../../domain/value_objects/phone_number.dart';
import '../spec/auth_mobile_spec.dart';
import '../viewmodels/auth_controller.dart';

class ResetPasswordPage extends ConsumerStatefulWidget {
  const ResetPasswordPage({required this.initialPhone, super.key});

  final String initialPhone;

  @override
  ConsumerState<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends ConsumerState<ResetPasswordPage> {
  static const List<({String code, String country})> _countryCodes =
      <({String code, String country})>[
        (code: '+964', country: 'العراق'),
        (code: '+966', country: 'السعودية'),
        (code: '+971', country: 'الإمارات'),
        (code: '+20', country: 'مصر'),
      ];

  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String _selectedCode = '+964';
  bool _submitting = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    final pendingPhone = ref.read(pendingResetPhoneProvider);
    final sourcePhone = widget.initialPhone.isNotEmpty
        ? widget.initialPhone
        : (pendingPhone ?? '');
    if (sourcePhone.isNotEmpty) {
      _phoneController.text = sourcePhone;
      String? matchingCode;
      for (final entry in _countryCodes) {
        if (sourcePhone.startsWith(entry.code)) {
          matchingCode = entry.code;
          break;
        }
      }
      if (matchingCode != null) {
        _selectedCode = matchingCode;
      }
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
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

  String _formatResetError(Object error) {
    if (_containsCode(error, 'otp_expired')) {
      return 'انتهت صلاحية الرمز. اطلب رمزًا جديدًا.';
    }
    if (_containsCode(error, 'invalid_otp')) {
      return 'رمز التحقق غير صحيح.';
    }
    if (_containsCode(error, 'weak_password')) {
      return 'كلمة المرور ضعيفة. استخدم 8 أحرف على الأقل.';
    }
    if (_containsCode(error, 'hook_timeout') ||
        _errorMessage(error).contains('failed to reach hook')) {
      return 'تأخير من مزود الرسائل. إذا وصلك الرمز أعد المحاولة.';
    }
    return error.toString();
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final phone = _buildNormalizedPhone()!;
    final otp = _otpController.text.trim();
    final newPassword = _passwordController.text.trim();
    final messenger = ScaffoldMessenger.of(context);

    setState(() {
      _submitting = true;
    });

    try {
      await ref.read(authControllerProvider.notifier).completePasswordReset(
            phone: phone,
            otp: otp,
            newPassword: newPassword,
          );
      if (!mounted) {
        return;
      }
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            'تم تحديث كلمة المرور بنجاح. سجّل الدخول بكلمة المرور الجديدة.',
          ),
        ),
      );
      context.go(RoutePaths.login);
    } catch (error) {
      if (!mounted) {
        return;
      }
      messenger.showSnackBar(SnackBar(content: Text(_formatResetError(error))));
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
    final colors = Theme.of(context).colorScheme;

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
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Text(
                          'تعيين كلمة مرور جديدة',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'أدخل رقم الهاتف ورمز OTP وكلمة المرور الجديدة.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          key: const ValueKey<String>('reset_phone_field'),
                          controller: _phoneController,
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
                                  value: _selectedCode,
                                  borderRadius: BorderRadius.circular(12),
                                  items: _countryCodes.map((entry) {
                                    return DropdownMenuItem<String>(
                                      value: entry.code,
                                      child: Text('${entry.code} ${entry.country}'),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    if (value == null) {
                                      return;
                                    }
                                    setState(() {
                                      _selectedCode = value;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                          validator: (_) {
                            if (_buildNormalizedPhone() == null) {
                              return 'أدخل رقمًا عراقيًا صحيحًا.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          key: const ValueKey<String>('reset_otp_field'),
                          controller: _otpController,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            labelText: 'رمز التحقق',
                            hintText: '6 أرقام',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AuthMobileSpec.fieldRadius),
                            ),
                          ),
                          validator: (value) {
                            final otp = value?.trim() ?? '';
                            if (otp.length < 4 || otp.length > 6) {
                              return 'أدخل رمز تحقق صحيحًا.';
                            }
                            if (!RegExp(r'^[0-9]+$').hasMatch(otp)) {
                              return 'الرمز يجب أن يحتوي أرقامًا فقط.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          key: const ValueKey<String>('reset_new_password_field'),
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            labelText: 'كلمة المرور الجديدة',
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
                            final password = value?.trim() ?? '';
                            if (password.isEmpty) {
                              return 'كلمة المرور الجديدة مطلوبة.';
                            }
                            if (password.length < 8) {
                              return 'الحد الأدنى 8 أحرف.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          key: const ValueKey<String>('reset_confirm_password_field'),
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(
                            labelText: 'تأكيد كلمة المرور',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AuthMobileSpec.fieldRadius),
                            ),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword = !_obscureConfirmPassword;
                                });
                              },
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility_rounded
                                    : Icons.visibility_off_rounded,
                              ),
                            ),
                          ),
                          validator: (value) {
                            final confirm = value?.trim() ?? '';
                            if (confirm.isEmpty) {
                              return 'أعد تأكيد كلمة المرور.';
                            }
                            if (confirm != _passwordController.text.trim()) {
                              return 'كلمتا المرور غير متطابقتين.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),
                        FilledButton(
                          key: const ValueKey<String>('reset_submit_button'),
                          onPressed: _submitting ? null : _resetPassword,
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(AuthMobileSpec.buttonHeight),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AuthMobileSpec.fieldRadius),
                            ),
                          ),
                          child: Text(_submitting ? 'جارٍ التحديث...' : 'تحديث كلمة المرور'),
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton(
                          onPressed: _submitting
                              ? null
                              : () => context.go(RoutePaths.forgotPassword),
                          child: const Text('عودة'),
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
