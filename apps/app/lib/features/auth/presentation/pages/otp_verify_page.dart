import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../router/route_paths.dart';
import '../../domain/value_objects/phone_number.dart';
import '../spec/auth_mobile_spec.dart';
import '../viewmodels/auth_controller.dart';

class OtpVerifyPage extends ConsumerStatefulWidget {
  const OtpVerifyPage({required this.phone, super.key});

  final String phone;

  @override
  ConsumerState<OtpVerifyPage> createState() => _OtpVerifyPageState();
}

class _OtpVerifyPageState extends ConsumerState<OtpVerifyPage> {
  static const int _otpLength = 6;
  static const int _resendTimeout = 60;

  late final List<TextEditingController> _otpControllers;
  late final List<FocusNode> _focusNodes;
  Timer? _timer;

  int _remainingSeconds = _resendTimeout;
  bool _verifying = false;
  bool _resending = false;

  String get _normalizedPhone =>
      PhoneNumber.normalize(widget.phone) ?? widget.phone.trim();

  String get _otpCode =>
      _otpControllers.map((controller) => controller.text).join();

  bool get _isOtpComplete =>
      _otpControllers.every((controller) => controller.text.trim().isNotEmpty);

  @override
  void initState() {
    super.initState();
    _otpControllers = List<TextEditingController>.generate(
      _otpLength,
      (_) => TextEditingController(),
    );
    _focusNodes = List<FocusNode>.generate(_otpLength, (_) => FocusNode());
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final controller in _otpControllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() {
      _remainingSeconds = _resendTimeout;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_remainingSeconds <= 1) {
        timer.cancel();
        setState(() {
          _remainingSeconds = 0;
        });
      } else {
        setState(() {
          _remainingSeconds--;
        });
      }
    });
  }

  String _formatError(Object error) {
    if (error is AuthException) {
      final code = (error.code ?? '').toLowerCase();
      if (code.contains('otp_expired')) {
        return 'انتهت صلاحية الرمز. اطلب رمزًا جديدًا.';
      }
      if (code.contains('invalid')) {
        return 'رمز التحقق غير صحيح.';
      }
      if (code.contains('over_sms_send_rate_limit')) {
        return 'تم تجاوز عدد المحاولات. انتظر ثم أعد المحاولة.';
      }
      return error.message;
    }
    return error.toString();
  }

  void _onOtpChanged(int index, String value) {
    if (value.length == 1 && index < _otpLength - 1) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  Future<void> _verifyOtp() async {
    if (_normalizedPhone.isEmpty || !_isOtpComplete || _verifying) {
      return;
    }

    final messenger = ScaffoldMessenger.of(context);

    setState(() {
      _verifying = true;
    });

    try {
      ref.read(profileSetupPendingProvider.notifier).state = true;
      await ref
          .read(authControllerProvider.notifier)
          .verifyPhoneOtp(phone: _normalizedPhone, otp: _otpCode);
      if (!mounted) {
        return;
      }
      context.go(RoutePaths.authBootstrap);
    } catch (error) {
      if (!mounted) {
        return;
      }
      messenger.showSnackBar(SnackBar(content: Text(_formatError(error))));
    } finally {
      if (mounted) {
        setState(() {
          _verifying = false;
        });
      }
    }
  }

  Future<void> _resendOtp() async {
    if (_remainingSeconds > 0 || _normalizedPhone.isEmpty || _resending) {
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    setState(() {
      _resending = true;
    });

    try {
      await ref
          .read(authControllerProvider.notifier)
          .requestPhoneOtp(_normalizedPhone);
      _startCountdown();
      if (mounted) {
        messenger.showSnackBar(
          const SnackBar(content: Text('تم إرسال رمز تحقق جديد.')),
        );
      }
    } catch (error) {
      if (!mounted) {
        return;
      }
      messenger.showSnackBar(SnackBar(content: Text(_formatError(error))));
    } finally {
      if (mounted) {
        setState(() {
          _resending = false;
        });
      }
    }
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
                  child: _normalizedPhone.isEmpty
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            const Text(
                              'رقم الهاتف غير متوفر. ارجع لصفحة الدخول ثم أعد المحاولة.',
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            FilledButton(
                              onPressed: () => context.go(RoutePaths.login),
                              child: const Text('العودة لتسجيل الدخول'),
                            ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Text(
                              'تحقق من رقم هاتفك',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'أدخل رمز التحقق المرسل إلى:',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _normalizedPhone,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List<Widget>.generate(_otpLength, (
                                index,
                              ) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: SizedBox(
                                    width: 44,
                                    child: TextField(
                                      key: ValueKey<String>('otp_digit_$index'),
                                      controller: _otpControllers[index],
                                      focusNode: _focusNodes[index],
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      textInputAction: index == _otpLength - 1
                                          ? TextInputAction.done
                                          : TextInputAction.next,
                                      inputFormatters: <TextInputFormatter>[
                                        FilteringTextInputFormatter.digitsOnly,
                                        LengthLimitingTextInputFormatter(1),
                                      ],
                                      decoration: InputDecoration(
                                        counterText: '',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                      ),
                                      onChanged: (value) =>
                                          _onOtpChanged(index, value),
                                    ),
                                  ),
                                );
                              }),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _remainingSeconds > 0
                                  ? 'إعادة الإرسال خلال $_remainingSeconds ثانية'
                                  : 'يمكنك إعادة إرسال الرمز الآن',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              key: const ValueKey<String>('otp_resend_button'),
                              onPressed:
                                  (_remainingSeconds == 0 && !_resending && !_verifying)
                                  ? _resendOtp
                                  : null,
                              child: Text(_resending ? 'جارٍ الإرسال...' : 'إعادة إرسال الرمز'),
                            ),
                            const SizedBox(height: 8),
                            FilledButton(
                              key: const ValueKey<String>('otp_verify_button'),
                              onPressed: _verifying ? null : _verifyOtp,
                              style: FilledButton.styleFrom(
                                minimumSize: const Size.fromHeight(AuthMobileSpec.buttonHeight),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AuthMobileSpec.fieldRadius),
                                ),
                              ),
                              child: Text(_verifying ? 'جارٍ التحقق...' : 'تأكيد الرمز'),
                            ),
                          ],
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
