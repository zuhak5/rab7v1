import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../router/route_paths.dart';
import '../../domain/value_objects/phone_number.dart';
import '../spec/auth_mobile_spec.dart';
import '../viewmodels/auth_controller.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  static const List<({String code, String country})> _countryCodes =
      <({String code, String country})>[
        (code: '+964', country: 'العراق'),
        (code: '+966', country: 'السعودية'),
        (code: '+971', country: 'الإمارات'),
        (code: '+20', country: 'مصر'),
      ];

  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();

  String _selectedCode = '+964';
  bool _submitting = false;

  @override
  void dispose() {
    _phoneController.dispose();
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
    if (_containsCode(error, 'user_not_found')) {
      return 'لا يوجد حساب مرتبط بهذا الرقم.';
    }
    if (_containsCode(error, 'phone_provider_disabled')) {
      return 'إرسال OTP غير مفعل في إعدادات Supabase.';
    }
    if (_containsCode(error, 'over_sms_send_rate_limit')) {
      return 'تم تجاوز عدد المحاولات. انتظر قليلًا ثم أعد المحاولة.';
    }
    if (_containsCode(error, 'hook_timeout') ||
        _errorMessage(error).contains('failed to reach hook')) {
      return 'هناك تأخير من مزود الرسائل. إذا وصلك الرمز أكمل الخطوات.';
    }
    return error.toString();
  }

  Future<void> _sendResetOtp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final phone = _buildNormalizedPhone()!;
    final messenger = ScaffoldMessenger.of(context);

    setState(() {
      _submitting = true;
    });

    var shouldNavigate = false;
    try {
      await ref.read(authControllerProvider.notifier).startPasswordReset(phone);
      shouldNavigate = true;
    } catch (error) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text(_formatResetError(error))),
        );
      }
      if (_containsCode(error, 'hook_timeout') ||
          _errorMessage(error).contains('failed to reach hook')) {
        ref.read(passwordResetPendingProvider.notifier).state = true;
        ref.read(pendingResetPhoneProvider.notifier).state = phone;
        shouldNavigate = true;
      }
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }

    if (!mounted || !shouldNavigate) {
      return;
    }
    context.go(
      '${RoutePaths.resetPassword}?phone=${Uri.encodeComponent(phone)}',
    );
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
                          'استعادة كلمة المرور',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'أدخل رقم الهاتف لإرسال رمز إعادة التعيين.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          key: const ValueKey<String>('forgot_phone_field'),
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
                        const SizedBox(height: 18),
                        FilledButton(
                          key: const ValueKey<String>('forgot_send_button'),
                          onPressed: _submitting ? null : _sendResetOtp,
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(AuthMobileSpec.buttonHeight),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AuthMobileSpec.fieldRadius),
                            ),
                          ),
                          child: Text(_submitting ? 'جارٍ الإرسال...' : 'إرسال رمز الاستعادة'),
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton(
                          onPressed: _submitting
                              ? null
                              : () => context.go(RoutePaths.login),
                          child: const Text('العودة لتسجيل الدخول'),
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
