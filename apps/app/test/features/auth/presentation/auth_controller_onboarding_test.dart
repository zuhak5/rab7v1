import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rideiq_app/app/di/providers.dart';
import 'package:rideiq_app/features/auth/domain/entities/auth_app_context.dart';
import 'package:rideiq_app/features/auth/domain/entities/auth_session.dart';
import 'package:rideiq_app/features/auth/domain/entities/sign_up_role.dart';
import 'package:rideiq_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:rideiq_app/features/auth/presentation/viewmodels/auth_controller.dart';

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({
    this.session,
    this.appContext,
    this.onGetMyAppContext,
    this.onUpdateProfile,
  });

  AuthSession? session;
  AuthAppContext? appContext;
  Future<AuthAppContext?> Function()? onGetMyAppContext;
  Future<void> Function({
    required String name,
    required String password,
    required String role,
  })?
  onUpdateProfile;

  final _streamController = StreamController<AuthSession?>.broadcast();

  @override
  Stream<AuthSession?> authStateChanges() => _streamController.stream;

  @override
  AuthSession? currentSession() => session;

  @override
  Future<AuthAppContext?> getMyAppContext() async {
    if (onGetMyAppContext != null) {
      return onGetMyAppContext!.call();
    }
    return appContext;
  }

  @override
  Future<void> requestPasswordResetOtp(String phone) async {}

  @override
  Future<void> requestPhoneOtp(String phone) async {}

  @override
  Future<void> resetPasswordWithOtp({
    required String phone,
    required String otp,
    required String newPassword,
  }) async {}

  @override
  Future<void> signInWithPhonePassword({
    required String phone,
    required String password,
  }) async {}

  @override
  Future<void> signOut() async {
    session = null;
    _streamController.add(null);
  }

  @override
  Future<void> updateProfile({
    required String name,
    required String password,
    required String role,
  }) async {
    if (onUpdateProfile != null) {
      await onUpdateProfile!(name: name, password: password, role: role);
    }
  }

  @override
  Future<void> verifyPhoneOtp({
    required String phone,
    required String otp,
  }) async {}

  Future<void> dispose() async {
    await _streamController.close();
  }
}

void main() {
  group('AuthController onboarding sync', () {
    test(
      'keeps locally selected customer role while onboarding is still pending',
      () async {
        final fakeRepository = _FakeAuthRepository(
          session: AuthSession(
            userId: 'user-1',
            accessToken: 'token',
            expiresAt: DateTime.utc(2026, 1, 1),
            phone: '+9647000000000',
          ),
          appContext: const AuthAppContext(
            userId: 'user-1',
            activeRole: 'rider',
            roleOnboardingCompleted: false,
            locale: 'ar',
          ),
        );

        final container = ProviderContainer(
          overrides: [authRepositoryProvider.overrideWithValue(fakeRepository)],
        );
        addTearDown(() async {
          await fakeRepository.dispose();
          container.dispose();
        });

        container.read(selectedSignUpRoleProvider.notifier).state =
            SignUpRole.customer;

        await container.read(authControllerProvider.future);
        await container
            .read(authControllerProvider.notifier)
            .retryAppContextBootstrap();

        expect(container.read(profileSetupPendingProvider), isTrue);
        expect(container.read(selectedSignUpRoleProvider), SignUpRole.customer);
      },
    );

    test('clears selected role when auth session is missing', () async {
      final fakeRepository = _FakeAuthRepository(
        session: null,
        appContext: null,
      );
      final container = ProviderContainer(
        overrides: [authRepositoryProvider.overrideWithValue(fakeRepository)],
      );
      addTearDown(() async {
        await fakeRepository.dispose();
        container.dispose();
      });

      container.read(selectedSignUpRoleProvider.notifier).state =
          SignUpRole.driver;

      await container.read(authControllerProvider.future);
      await container
          .read(authControllerProvider.notifier)
          .retryAppContextBootstrap();

      expect(container.read(profileSetupPendingProvider), isFalse);
      expect(container.read(selectedSignUpRoleProvider), isNull);
    });

    test(
      'completeProfile retries app-context refresh until onboarding is resolved',
      () async {
        var profileUpdated = false;
        var postUpdateReads = 0;

        final fakeRepository = _FakeAuthRepository(
          session: AuthSession(
            userId: 'user-1',
            accessToken: 'token',
            expiresAt: DateTime.utc(2026, 1, 1),
            phone: '+9647000000000',
          ),
          onGetMyAppContext: () async {
            if (!profileUpdated) {
              return const AuthAppContext(
                userId: 'user-1',
                activeRole: 'rider',
                roleOnboardingCompleted: false,
                locale: 'ar',
              );
            }

            postUpdateReads += 1;
            final resolved = postUpdateReads >= 3;
            return AuthAppContext(
              userId: 'user-1',
              activeRole: 'rider',
              roleOnboardingCompleted: resolved,
              locale: 'ar',
            );
          },
          onUpdateProfile:
              ({required name, required password, required role}) async {
                profileUpdated = true;
              },
        );

        final container = ProviderContainer(
          overrides: [authRepositoryProvider.overrideWithValue(fakeRepository)],
        );
        addTearDown(() async {
          await fakeRepository.dispose();
          container.dispose();
        });

        container.read(selectedSignUpRoleProvider.notifier).state =
            SignUpRole.customer;

        await container.read(authControllerProvider.future);
        await container
            .read(authControllerProvider.notifier)
            .completeProfile(
              name: 'Test User',
              password: 'test-pass-123',
              role: SignUpRole.customer,
            );

        final appContext = container.read(authAppContextProvider);
        expect(appContext, isNotNull);
        expect(appContext!.roleOnboardingCompleted, isTrue);
        expect(container.read(profileSetupPendingProvider), isFalse);
      },
    );
  });
}
