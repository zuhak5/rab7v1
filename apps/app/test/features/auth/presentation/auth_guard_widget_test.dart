import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rideiq_app/app/app.dart';
import 'package:rideiq_app/app/config/app_config.dart';
import 'package:rideiq_app/app/di/providers.dart';
import 'package:rideiq_app/data/supabase/supabase_client_provider.dart';
import 'package:rideiq_app/features/auth/domain/entities/auth_app_context.dart';
import 'package:rideiq_app/features/auth/domain/entities/auth_session.dart';
import 'package:rideiq_app/features/auth/domain/entities/sign_up_role.dart';
import 'package:rideiq_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:rideiq_app/features/auth/presentation/pages/auth_bootstrap_page.dart';
import 'package:rideiq_app/features/auth/presentation/pages/login_page.dart';
import 'package:rideiq_app/features/auth/presentation/pages/profile_setup_page.dart';
import 'package:rideiq_app/features/auth/presentation/pages/role_selection_page.dart';
import 'package:rideiq_app/features/auth/presentation/viewmodels/auth_controller.dart';
import 'package:rideiq_app/features/rider_home/presentation/pages/rider_home_page.dart';
import 'package:rideiq_app/features/rider_rides/domain/entities/driver_location.dart';
import 'package:rideiq_app/features/rider_rides/domain/entities/ride.dart';
import 'package:rideiq_app/features/rider_rides/domain/entities/ride_request.dart';
import 'package:rideiq_app/features/rider_rides/domain/repositories/rides_repository.dart';

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository(this._session, {AuthAppContext? appContext})
    : _appContext = appContext;

  AuthSession? _session;
  final AuthAppContext? _appContext;
  final _controller = StreamController<AuthSession?>.broadcast();

  @override
  Stream<AuthSession?> authStateChanges() => _controller.stream;

  @override
  AuthSession? currentSession() => _session;

  @override
  Future<AuthAppContext?> getMyAppContext() async => _appContext;

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
  Future<void> signOut() async {
    _session = null;
    _controller.add(null);
  }

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
  }) async {}
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
  const config = AppConfig(
    supabaseUrl: 'https://example.supabase.co',
    supabaseAnonKey: 'public-anon-key',
    appEnv: AppEnvironment.dev,
    logLevel: LogLevel.debug,
  );

  testWidgets('redirects signed-out users to login route', (tester) async {
    final authRepository = _FakeAuthRepository(null);

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

    expect(find.byType(LoginPage), findsOneWidget);
  });

  testWidgets(
    'blocks signed-in users while app context bootstrap is unresolved',
    (tester) async {
      final authRepository = _FakeAuthRepository(
        AuthSession(
          userId: 'user-1',
          accessToken: 'token',
          expiresAt: DateTime.utc(2026, 1, 1),
          phone: '+9647000000000',
        ),
      );

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

      expect(find.byType(AuthBootstrapPage), findsOneWidget);
    },
  );

  testWidgets(
    'allows signed-in users to access rides route when context is ready',
    (tester) async {
      final authRepository = _FakeAuthRepository(
        AuthSession(
          userId: 'user-1',
          accessToken: 'token',
          expiresAt: DateTime.utc(2026, 1, 1),
          phone: '+9647000000000',
        ),
        appContext: const AuthAppContext(
          userId: 'user-1',
          activeRole: 'rider',
          roleOnboardingCompleted: true,
          locale: 'ar',
        ),
      );

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

      expect(find.byType(RiderHomePage), findsOneWidget);
    },
  );

  testWidgets(
    'forces role selection when signup flow is pending without role',
    (tester) async {
      final authRepository = _FakeAuthRepository(
        AuthSession(
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

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(config),
            authRepositoryProvider.overrideWithValue(authRepository),
            ridesRepositoryProvider.overrideWithValue(_FakeRidesRepository()),
            profileSetupPendingProvider.overrideWith((ref) => true),
            selectedSignUpRoleProvider.overrideWith((ref) => null),
          ],
          child: const RideIqApp(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(RoleSelectionPage), findsOneWidget);
    },
  );

  testWidgets('forces profile setup when role already selected', (
    tester,
  ) async {
    final authRepository = _FakeAuthRepository(
      AuthSession(
        userId: 'user-1',
        accessToken: 'token',
        expiresAt: DateTime.utc(2026, 1, 1),
        phone: '+9647000000000',
      ),
      appContext: const AuthAppContext(
        userId: 'user-1',
        activeRole: 'driver',
        roleOnboardingCompleted: false,
        locale: 'ar',
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(config),
          authRepositoryProvider.overrideWithValue(authRepository),
          ridesRepositoryProvider.overrideWithValue(_FakeRidesRepository()),
          profileSetupPendingProvider.overrideWith((ref) => true),
          selectedSignUpRoleProvider.overrideWith((ref) => SignUpRole.driver),
        ],
        child: const RideIqApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(ProfileSetupPage), findsOneWidget);
  });

  testWidgets(
    'keeps users on profile setup when customer role was selected locally',
    (tester) async {
      final authRepository = _FakeAuthRepository(
        AuthSession(
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

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(config),
            authRepositoryProvider.overrideWithValue(authRepository),
            ridesRepositoryProvider.overrideWithValue(_FakeRidesRepository()),
            profileSetupPendingProvider.overrideWith((ref) => true),
            selectedSignUpRoleProvider.overrideWith(
              (ref) => SignUpRole.customer,
            ),
          ],
          child: const RideIqApp(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(ProfileSetupPage), findsOneWidget);
    },
  );
}
