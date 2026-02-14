import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:rideiq_app/app/di/providers.dart';
import 'package:rideiq_app/features/auth/domain/entities/auth_app_context.dart';
import 'package:rideiq_app/features/auth/domain/entities/auth_session.dart';
import 'package:rideiq_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:rideiq_app/features/auth/presentation/pages/login_page.dart';
import 'package:rideiq_app/features/auth/presentation/viewmodels/auth_controller.dart';
import 'package:rideiq_app/router/route_paths.dart';

class _FakeAuthRepository implements AuthRepository {
  final _controller = StreamController<AuthSession?>.broadcast();

  @override
  Stream<AuthSession?> authStateChanges() => _controller.stream;

  @override
  AuthSession? currentSession() => null;

  @override
  Future<AuthAppContext?> getMyAppContext() async => null;

  @override
  Future<void> requestPhoneOtp(String phone) async {}

  @override
  Future<void> requestPasswordResetOtp(String phone) async {}

  @override
  Future<void> signInWithPhonePassword({
    required String phone,
    required String password,
  }) async {}

  @override
  Future<void> signOut() async {}

  @override
  Future<void> updateProfile({
    required String name,
    required String password,
    required String role,
  }) async {}

  @override
  Future<void> verifyPhoneOtp({
    required String phone,
    required String otp,
  }) async {}

  @override
  Future<void> resetPasswordWithOtp({
    required String phone,
    required String otp,
    required String newPassword,
  }) async {}
}

void main() {
  testWidgets('sign up send OTP routes to OTP page with normalized phone', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: <Override>[
        authRepositoryProvider.overrideWithValue(_FakeAuthRepository()),
      ],
    );
    addTearDown(container.dispose);

    final router = GoRouter(
      initialLocation: RoutePaths.login,
      routes: <RouteBase>[
        GoRoute(path: RoutePaths.login, builder: (_, _) => const LoginPage()),
        GoRoute(
          path: RoutePaths.otpVerify,
          builder: (_, state) {
            final phone = state.uri.queryParameters['phone'] ?? '';
            return Scaffold(body: Center(child: Text('otp:$phone')));
          },
        ),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey<String>('login_mode_sign_up')));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey<String>('login_phone_field')),
      '07912345678',
    );
    await tester.tap(find.byKey(const ValueKey<String>('login_primary_button')));
    await tester.pumpAndSettle();

    const phone = '+9647912345678';
    expect(find.text('otp:$phone'), findsOneWidget);
    expect(container.read(pendingPhoneProvider), phone);
  });

  testWidgets('forgot password link navigates to forgot password route', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: <Override>[
        authRepositoryProvider.overrideWithValue(_FakeAuthRepository()),
      ],
    );
    addTearDown(container.dispose);

    final router = GoRouter(
      initialLocation: RoutePaths.login,
      routes: <RouteBase>[
        GoRoute(path: RoutePaths.login, builder: (_, _) => const LoginPage()),
        GoRoute(
          path: RoutePaths.forgotPassword,
          builder: (_, _) =>
              const Scaffold(body: Center(child: Text('forgot-password'))),
        ),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey<String>('login_forgot_button')));
    await tester.pumpAndSettle();

    expect(find.text('forgot-password'), findsOneWidget);
  });
}
