import '../entities/auth_app_context.dart';
import '../entities/auth_session.dart';

abstract class AuthRepository {
  Stream<AuthSession?> authStateChanges();

  AuthSession? currentSession();
  Future<AuthAppContext?> getMyAppContext();

  Future<void> signInWithPhonePassword({
    required String phone,
    required String password,
  });

  Future<void> requestPhoneOtp(String phone);
  Future<void> requestPasswordResetOtp(String phone);

  Future<void> verifyPhoneOtp({required String phone, required String otp});
  Future<void> resetPasswordWithOtp({
    required String phone,
    required String otp,
    required String newPassword,
  });

  Future<void> updateProfile({
    required String name,
    required String password,
    required String role,
  });

  Future<void> signOut();
}
