import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rideiq_app/app/app.dart';
import 'package:rideiq_app/app/config/app_config.dart';
import 'package:rideiq_app/app/di/providers.dart';
import 'package:rideiq_app/data/supabase/supabase_client_provider.dart';
import 'package:rideiq_app/features/auth/domain/entities/auth_app_context.dart';
import 'package:rideiq_app/features/auth/domain/entities/auth_session.dart';
import 'package:rideiq_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:rideiq_app/features/auth/presentation/pages/profile_setup_page.dart';
import 'package:rideiq_app/features/auth/presentation/pages/role_selection_page.dart';
import 'package:rideiq_app/features/rider_home/presentation/pages/rider_home_page.dart';
import 'package:rideiq_app/features/rider_rides/domain/entities/driver_location.dart';
import 'package:rideiq_app/features/rider_rides/domain/entities/ride.dart';
import 'package:rideiq_app/features/rider_rides/domain/entities/ride_request.dart';
import 'package:rideiq_app/features/rider_rides/domain/repositories/rides_repository.dart';

class _FakeOnboardingAuthRepository implements AuthRepository {
  _FakeOnboardingAuthRepository()
    : _session = AuthSession(
        userId: 'user-1',
        accessToken: 'token',
        expiresAt: DateTime.utc(2026, 1, 1),
        phone: '+9647000000000',
      ),
      _context = const AuthAppContext(
        userId: 'user-1',
        activeRole: 'rider',
        roleOnboardingCompleted: false,
        locale: 'ar',
      );

  AuthSession? _session;
  AuthAppContext _context;

  final _controller = StreamController<AuthSession?>.broadcast();

  @override
  Stream<AuthSession?> authStateChanges() => _controller.stream;

  @override
  AuthSession? currentSession() => _session;

  @override
  Future<AuthAppContext?> getMyAppContext() async => _context;

  @override
  Future<void> signInWithPhonePassword({
    required String phone,
    required String password,
  }) async {}

  @override
  Future<void> requestPhoneOtp(String phone) async {}

  @override
  Future<void> requestPasswordResetOtp(String phone) async {}

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

  @override
  Future<void> updateProfile({
    required String name,
    required String password,
    required String role,
  }) async {
    _context = AuthAppContext(
      userId: _context.userId,
      activeRole: role,
      roleOnboardingCompleted: true,
      locale: _context.locale,
    );
  }

  @override
  Future<void> signOut() async {
    _session = null;
    _controller.add(null);
  }

  Future<void> dispose() async {
    await _controller.close();
  }
}

class _FakeRidesRepository implements RidesRepository {
  @override
  Future<void> cancelRideRequest(String requestId) async {}

  @override
  Future<RideRequestEntity> createRideRequest(CreateRideRequestInput input) {
    throw UnimplementedError();
  }

  @override
  Future<List<RideRequestEntity>> listRideRequests() async => const [];

  @override
  Future<void> triggerMatchRide(String requestId) async {}

  @override
  Stream<DriverLocationEntity?> watchDriverLocation(String driverId) {
    return const Stream<DriverLocationEntity?>.empty();
  }

  @override
  Stream<RideEntity?> watchRideByRequest(String requestId) {
    return const Stream<RideEntity?>.empty();
  }

  @override
  Stream<RideRequestEntity?> watchRideRequest(String requestId) {
    return const Stream<RideRequestEntity?>.empty();
  }
}

void main() {
  testWidgets(
    'onboarding flow routes role selection -> profile setup -> rider home',
    (tester) async {
      const config = AppConfig(
        supabaseUrl: 'https://example.supabase.co',
        supabaseAnonKey: 'public-anon-key',
        appEnv: AppEnvironment.dev,
        logLevel: LogLevel.debug,
      );
      final authRepository = _FakeOnboardingAuthRepository();
      addTearDown(() async {
        await authRepository.dispose();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(config),
            authRepositoryProvider.overrideWithValue(authRepository),
            ridesRepositoryProvider.overrideWithValue(_FakeRidesRepository()),
          ],
          child: const RideIqApp(),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(RoleSelectionPage), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey<String>('role_option_customer')));
      await tester.tap(find.byKey(const ValueKey<String>('role_continue_button')));
      await tester.pumpAndSettle();
      expect(find.byType(ProfileSetupPage), findsOneWidget);

      await tester.enterText(
        find.byKey(const ValueKey<String>('profile_name_field')),
        'Test User',
      );
      await tester.enterText(
        find.byKey(const ValueKey<String>('profile_password_field')),
        'test-pass-123',
      );
      await tester.enterText(
        find.byKey(const ValueKey<String>('profile_confirm_password_field')),
        'test-pass-123',
      );
      await tester.tap(find.byKey(const ValueKey<String>('profile_create_button')));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.byType(RiderHomePage), findsOneWidget);
    },
  );
}
