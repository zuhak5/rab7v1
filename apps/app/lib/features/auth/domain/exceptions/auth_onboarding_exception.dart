import '../../../../core/error/app_exception.dart';

class RoleSetupRequiredException extends AppException {
  const RoleSetupRequiredException({
    required this.role,
    this.backendMessage,
  }) : super(
         'تهيئة الدور "$role" غير مكتملة في الخلفية. أكمل التهيئة ثم أعد المحاولة.',
         code: 'role_setup_required',
       );

  final String role;
  final String? backendMessage;
}

class OnboardingPersistenceException extends AppException {
  const OnboardingPersistenceException({
    required this.reason,
    required String message,
    String code = 'onboarding_persistence_failed',
  }) : super(message, code: code);

  final String reason;
}
