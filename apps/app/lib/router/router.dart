import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app/di/providers.dart';
import '../features/auth/presentation/pages/auth_bootstrap_page.dart';
import '../features/auth/presentation/pages/forgot_password_page.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/otp_verify_page.dart';
import '../features/auth/presentation/pages/profile_setup_page.dart';
import '../features/auth/presentation/pages/reset_password_page.dart';
import '../features/auth/presentation/pages/role_selection_page.dart';
import '../features/auth/presentation/pages/splash_page.dart';
import '../features/auth/presentation/viewmodels/auth_controller.dart';
import '../features/rider_home/presentation/pages/account_page.dart';
import '../features/rider_home/presentation/pages/activity_page.dart';
import '../features/rider_home/presentation/pages/finding_driver_page.dart';
import '../features/rider_home/presentation/pages/rider_home_page.dart';
import '../features/rider_home/presentation/pages/trip_options_page.dart';
import 'route_paths.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final session = ref.watch(
    authControllerProvider.select((value) => value.valueOrNull),
  );
  final appContext = ref.watch(authAppContextProvider);
  final appContextBootstrapStatus = ref.watch(
    authAppContextBootstrapStatusProvider,
  );
  final profileSetupPending = ref.watch(profileSetupPendingProvider);
  final selectedSignUpRole = ref.watch(selectedSignUpRoleProvider);
  final passwordResetPending = ref.watch(passwordResetPendingProvider);

  final router = GoRouter(
    initialLocation: RoutePaths.splash,
    refreshListenable: GoRouterRefreshStream(authRepository.authStateChanges()),
    redirect: (context, state) {
      final path = state.uri.path;
      final isPublicAuthRoute =
          path == RoutePaths.login ||
          path == RoutePaths.authBootstrap ||
          path == RoutePaths.forgotPassword ||
          path == RoutePaths.resetPassword ||
          path == RoutePaths.otpVerify ||
          path == RoutePaths.authCallback;
      final isSplashRoute = path == RoutePaths.splash;
      final isAuthenticated = session != null;
      final isAppContextReady =
          appContextBootstrapStatus == AuthAppContextBootstrapStatus.ready;
      final hasResolvedAppContext = !isAuthenticated || appContext != null;
      final requiresOnboarding =
          isAuthenticated &&
          isAppContextReady &&
          ((appContext != null && !appContext.roleOnboardingCompleted) ||
              (appContext == null && profileSetupPending));

      if (passwordResetPending &&
          path != RoutePaths.resetPassword &&
          path != RoutePaths.forgotPassword) {
        return RoutePaths.resetPassword;
      }
      if (!isAuthenticated && path == RoutePaths.authBootstrap) {
        return RoutePaths.login;
      }
      if (!isAuthenticated && isSplashRoute) {
        return RoutePaths.login;
      }
      if (!isAuthenticated && !isPublicAuthRoute) {
        return RoutePaths.login;
      }
      if (isAuthenticated &&
          path != RoutePaths.authBootstrap &&
          !isAppContextReady) {
        return RoutePaths.authBootstrap;
      }
      if (isAuthenticated &&
          path == RoutePaths.authBootstrap &&
          !isAppContextReady) {
        return null;
      }
      if (isAuthenticated && isAppContextReady && !hasResolvedAppContext) {
        return RoutePaths.authBootstrap;
      }
      if (requiresOnboarding) {
        if (selectedSignUpRole == null && path != RoutePaths.roleSelection) {
          return RoutePaths.roleSelection;
        }
        if (selectedSignUpRole != null && path != RoutePaths.profileSetup) {
          return RoutePaths.profileSetup;
        }
      }
      if (isAuthenticated &&
          isAppContextReady &&
          (isSplashRoute || path == RoutePaths.authBootstrap)) {
        return RoutePaths.rides;
      }
      if (isAuthenticated &&
          isAppContextReady &&
          isPublicAuthRoute &&
          !requiresOnboarding) {
        return RoutePaths.rides;
      }
      if (isAuthenticated &&
          isAppContextReady &&
          !requiresOnboarding &&
          (path == RoutePaths.roleSelection ||
              path == RoutePaths.profileSetup)) {
        return RoutePaths.rides;
      }
      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: RoutePaths.splash,
        pageBuilder: (context, state) =>
            _buildSlideFadePage(state: state, child: const SplashPage()),
      ),
      GoRoute(
        path: RoutePaths.login,
        pageBuilder: (context, state) =>
            _buildSlideFadePage(state: state, child: const LoginPage()),
      ),
      GoRoute(
        path: RoutePaths.authBootstrap,
        pageBuilder: (context, state) => _buildSlideFadePage(
          state: state,
          child: const AuthBootstrapPage(),
        ),
      ),
      GoRoute(
        path: RoutePaths.forgotPassword,
        pageBuilder: (context, state) => _buildSlideFadePage(
          state: state,
          child: const ForgotPasswordPage(),
        ),
      ),
      GoRoute(
        path: RoutePaths.resetPassword,
        pageBuilder: (context, state) {
          final phone =
              state.uri.queryParameters['phone'] ??
              ref.read(pendingResetPhoneProvider) ??
              '';
          return _buildSlideFadePage(
            state: state,
            child: ResetPasswordPage(initialPhone: phone),
          );
        },
      ),
      GoRoute(
        path: RoutePaths.otpVerify,
        pageBuilder: (context, state) {
          final phone =
              state.uri.queryParameters['phone'] ??
              ref.read(pendingPhoneProvider) ??
              '';
          return _buildSlideFadePage(
            state: state,
            child: OtpVerifyPage(phone: phone),
          );
        },
      ),
      GoRoute(
        path: RoutePaths.profileSetup,
        pageBuilder: (context, state) =>
            _buildSlideFadePage(state: state, child: const ProfileSetupPage()),
      ),
      GoRoute(
        path: RoutePaths.roleSelection,
        pageBuilder: (context, state) =>
            _buildSlideFadePage(state: state, child: const RoleSelectionPage()),
      ),
      GoRoute(
        path: RoutePaths.authCallback,
        pageBuilder: (context, state) => _buildSlideFadePage(
          state: state,
          child: const _AuthCallbackPlaceholderPage(),
        ),
      ),
      GoRoute(
        path: RoutePaths.rides,
        builder: (context, state) => const RiderHomePage(),
      ),
      GoRoute(
        path: RoutePaths.tripOptions,
        builder: (context, state) => const TripOptionsPage(),
      ),
      GoRoute(
        path: RoutePaths.findingDriver,
        builder: (context, state) {
          final requestId = state.uri.queryParameters['requestId'] ?? '';
          return FindingDriverPage(requestId: requestId);
        },
      ),
      GoRoute(
        path: RoutePaths.activity,
        builder: (context, state) => const ActivityPage(),
      ),
      GoRoute(
        path: RoutePaths.account,
        builder: (context, state) => const AccountPage(),
      ),
    ],
  );

  ref.onDispose(router.dispose);
  return router;
});

CustomTransitionPage<void> _buildSlideFadePage({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, pageChild) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOut);
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.02, 0),
            end: Offset.zero,
          ).animate(curved),
          child: pageChild,
        ),
      );
    },
  );
}

class _AuthCallbackPlaceholderPage extends StatelessWidget {
  const _AuthCallbackPlaceholderPage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'صفحة رجوع المصادقة. اضبط مسارات الرجوع حسب مزود تسجيل الدخول.',
        ),
      ),
    );
  }
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen(
      (_) => notifyListeners(),
      onError: (_) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
