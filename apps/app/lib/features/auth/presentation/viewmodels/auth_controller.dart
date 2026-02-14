import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/di/providers.dart';
import '../../../../core/error/app_exception.dart';
import '../../domain/entities/auth_app_context.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/entities/sign_up_role.dart';
import '../../domain/repositories/auth_repository.dart';

final pendingPhoneProvider = StateProvider<String?>((ref) => null);
final pendingResetPhoneProvider = StateProvider<String?>((ref) => null);
final authBusyProvider = StateProvider<bool>((ref) => false);
final profileSetupPendingProvider = StateProvider<bool>((ref) => false);
final selectedSignUpRoleProvider = StateProvider<SignUpRole?>((ref) => null);
final passwordResetPendingProvider = StateProvider<bool>((ref) => false);
final authAppContextProvider = StateProvider<AuthAppContext?>((ref) => null);
final authAppContextErrorProvider = StateProvider<String?>((ref) => null);
final onboardingPersistenceErrorProvider = StateProvider<String?>((ref) => null);

enum AuthAppContextBootstrapStatus { idle, loading, ready, error }

final authAppContextBootstrapStatusProvider =
    StateProvider<AuthAppContextBootstrapStatus>(
      (ref) => AuthAppContextBootstrapStatus.idle,
    );

class AuthController extends AsyncNotifier<AuthSession?> {
  StreamSubscription<AuthSession?>? _authSubscription;

  @override
  Future<AuthSession?> build() async {
    final repository = ref.watch(authRepositoryProvider);
    final currentSession = repository.currentSession();
    Future<void>.microtask(() async {
      await _refreshAppContext(repository, session: currentSession);
    });

    _authSubscription = repository.authStateChanges().listen((session) {
      state = AsyncValue.data(session);
      unawaited(_refreshAppContext(repository, session: session));
    });

    ref.onDispose(() async {
      await _authSubscription?.cancel();
    });

    return currentSession;
  }

  Future<void> bootstrap() async {
    await future;
    await retryAppContextBootstrap();
  }

  Future<void> retryAppContextBootstrap() async {
    final repository = ref.read(authRepositoryProvider);
    final session = repository.currentSession();
    await _refreshAppContext(repository, session: session);
  }

  Future<void> requestPhoneOtp(String phone) async {
    final repository = ref.read(authRepositoryProvider);
    await repository.requestPhoneOtp(phone);

    ref.read(pendingPhoneProvider.notifier).state = phone;
    ref.read(passwordResetPendingProvider.notifier).state = false;
    ref.read(pendingResetPhoneProvider.notifier).state = null;
  }

  Future<void> signInWithPassword({
    required String phone,
    required String password,
  }) async {
    ref.read(authBusyProvider.notifier).state = true;
    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.signInWithPhonePassword(
        phone: phone,
        password: password,
      );
      ref.read(passwordResetPendingProvider.notifier).state = false;
      ref.read(pendingResetPhoneProvider.notifier).state = null;
      final session = repository.currentSession();
      await _refreshAppContext(repository, session: session);
      state = AsyncValue.data(session);
    } finally {
      ref.read(authBusyProvider.notifier).state = false;
    }
  }

  Future<void> verifyPhoneOtp({
    required String phone,
    required String otp,
  }) async {
    state = const AsyncValue.loading();

    final repository = ref.read(authRepositoryProvider);
    await repository.verifyPhoneOtp(phone: phone, otp: otp);
    final session = repository.currentSession();
    await _refreshAppContext(repository, session: session);
    state = AsyncValue.data(session);
  }

  Future<void> startPasswordReset(String phone) async {
    final repository = ref.read(authRepositoryProvider);
    await repository.requestPasswordResetOtp(phone);
    ref.read(passwordResetPendingProvider.notifier).state = true;
    ref.read(pendingResetPhoneProvider.notifier).state = phone;
    ref.read(profileSetupPendingProvider.notifier).state = false;
    ref.read(selectedSignUpRoleProvider.notifier).state = null;
    ref.read(pendingPhoneProvider.notifier).state = null;
  }

  Future<void> completePasswordReset({
    required String phone,
    required String otp,
    required String newPassword,
  }) async {
    ref.read(authBusyProvider.notifier).state = true;
    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.resetPasswordWithOtp(
        phone: phone,
        otp: otp,
        newPassword: newPassword,
      );
      ref.read(passwordResetPendingProvider.notifier).state = false;
      ref.read(pendingResetPhoneProvider.notifier).state = null;
      ref.read(profileSetupPendingProvider.notifier).state = false;
      ref.read(selectedSignUpRoleProvider.notifier).state = null;
      ref.read(authAppContextProvider.notifier).state = null;
      ref.read(authAppContextErrorProvider.notifier).state = null;
      ref.read(authAppContextBootstrapStatusProvider.notifier).state =
          AuthAppContextBootstrapStatus.ready;
      state = const AsyncValue.data(null);
    } finally {
      ref.read(authBusyProvider.notifier).state = false;
    }
  }

  Future<void> completeProfile({
    required String name,
    required String password,
    required SignUpRole role,
  }) async {
    ref.read(authBusyProvider.notifier).state = true;
    ref.read(onboardingPersistenceErrorProvider.notifier).state = null;
    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.updateProfile(
        name: name,
        password: password,
        role: role.backendRole,
      );
      ref.read(passwordResetPendingProvider.notifier).state = false;
      ref.read(pendingResetPhoneProvider.notifier).state = null;
      final session = repository.currentSession();
      await _refreshAppContextUntilResolved(repository, session: session);
      state = AsyncValue.data(session);
      ref.read(authAppContextErrorProvider.notifier).state = null;
      ref.read(authAppContextBootstrapStatusProvider.notifier).state =
          AuthAppContextBootstrapStatus.ready;
    } on AppException catch (error) {
      ref.read(onboardingPersistenceErrorProvider.notifier).state = error.message;
      ref.read(authAppContextErrorProvider.notifier).state = error.message;
      ref.read(authAppContextBootstrapStatusProvider.notifier).state =
          AuthAppContextBootstrapStatus.error;
      rethrow;
    } catch (error) {
      final message = error.toString();
      ref.read(onboardingPersistenceErrorProvider.notifier).state = message;
      ref.read(authAppContextErrorProvider.notifier).state = message;
      ref.read(authAppContextBootstrapStatusProvider.notifier).state =
          AuthAppContextBootstrapStatus.error;
      rethrow;
    } finally {
      ref.read(authBusyProvider.notifier).state = false;
    }
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    final repository = ref.read(authRepositoryProvider);
    await repository.signOut();
    ref.read(profileSetupPendingProvider.notifier).state = false;
    ref.read(selectedSignUpRoleProvider.notifier).state = null;
    ref.read(passwordResetPendingProvider.notifier).state = false;
    ref.read(pendingResetPhoneProvider.notifier).state = null;
    ref.read(authAppContextProvider.notifier).state = null;
    ref.read(authAppContextErrorProvider.notifier).state = null;
    ref.read(onboardingPersistenceErrorProvider.notifier).state = null;
    ref.read(authAppContextBootstrapStatusProvider.notifier).state =
        AuthAppContextBootstrapStatus.ready;
    state = const AsyncValue.data(null);
  }

  Future<void> _refreshAppContext(
    AuthRepository repository, {
    required AuthSession? session,
  }) async {
    if (session == null) {
      ref.read(authAppContextProvider.notifier).state = null;
      ref.read(authAppContextErrorProvider.notifier).state = null;
      ref.read(onboardingPersistenceErrorProvider.notifier).state = null;
      ref.read(authAppContextBootstrapStatusProvider.notifier).state =
          AuthAppContextBootstrapStatus.ready;
      ref.read(profileSetupPendingProvider.notifier).state = false;
      ref.read(selectedSignUpRoleProvider.notifier).state = null;
      return;
    }

    ref.read(authAppContextBootstrapStatusProvider.notifier).state =
        AuthAppContextBootstrapStatus.loading;

    try {
      final appContext = await repository.getMyAppContext();
      if (appContext == null) {
        ref.read(authAppContextProvider.notifier).state = null;
        ref.read(authAppContextErrorProvider.notifier).state =
            'تعذر تحميل سياق الحساب.';
        ref.read(authAppContextBootstrapStatusProvider.notifier).state =
            AuthAppContextBootstrapStatus.error;
        return;
      }
      ref.read(authAppContextProvider.notifier).state = appContext;
      ref.read(authAppContextErrorProvider.notifier).state = null;
      ref.read(onboardingPersistenceErrorProvider.notifier).state = null;
      ref.read(authAppContextBootstrapStatusProvider.notifier).state =
          AuthAppContextBootstrapStatus.ready;
      _syncOnboardingState(appContext);
    } catch (error) {
      ref.read(authAppContextProvider.notifier).state = null;
      ref.read(authAppContextErrorProvider.notifier).state = error.toString();
      ref.read(authAppContextBootstrapStatusProvider.notifier).state =
          AuthAppContextBootstrapStatus.error;
    }
  }

  Future<void> _refreshAppContextUntilResolved(
    AuthRepository repository, {
    required AuthSession? session,
    int maxAttempts = 6,
  }) async {
    await _refreshAppContext(repository, session: session);
    if (session == null) {
      return;
    }

    if (_isOnboardingResolved()) {
      return;
    }

    for (var attempt = 1; attempt < maxAttempts; attempt++) {
      await Future<void>.delayed(Duration(milliseconds: 250 * attempt));
      await _refreshAppContext(repository, session: session);
      if (_isOnboardingResolved()) {
        return;
      }
    }

    throw const AppException(
      'تم حفظ بيانات الملف الشخصي لكن حالة الإعداد لم تُحسم بعد. حاول مرة أخرى.',
      code: 'onboarding_sync_timeout',
    );
  }

  bool _isOnboardingResolved() {
    final appContext = ref.read(authAppContextProvider);
    final status = ref.read(authAppContextBootstrapStatusProvider);
    if (status != AuthAppContextBootstrapStatus.ready) {
      return false;
    }
    return appContext != null && appContext.roleOnboardingCompleted;
  }

  void _syncOnboardingState(AuthAppContext? appContext) {
    if (appContext == null) {
      return;
    }

    final needsOnboarding = !appContext.roleOnboardingCompleted;
    ref.read(profileSetupPendingProvider.notifier).state = needsOnboarding;

    if (!needsOnboarding) {
      ref.read(selectedSignUpRoleProvider.notifier).state = null;
      return;
    }

    final currentSelectedRole = ref.read(selectedSignUpRoleProvider);
    if (currentSelectedRole != null) {
      // Preserve the role the user picked locally until onboarding is completed.
      return;
    }

    final backendRole = signUpRoleFromBackend(appContext.activeRole);
    if (backendRole != null && backendRole != SignUpRole.customer) {
      ref.read(selectedSignUpRoleProvider.notifier).state = backendRole;
    }
  }
}

final authControllerProvider =
    AsyncNotifierProvider<AuthController, AuthSession?>(AuthController.new);
