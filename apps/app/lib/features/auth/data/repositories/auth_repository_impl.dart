import '../../domain/entities/auth_app_context.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_supabase_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._dataSource);

  final AuthSupabaseDataSource _dataSource;

  @override
  Stream<AuthSession?> authStateChanges() {
    return _dataSource.onAuthStateChange();
  }

  @override
  AuthSession? currentSession() {
    return _dataSource.currentSession();
  }

  @override
  Future<AuthAppContext?> getMyAppContext() {
    return _dataSource.getMyAppContext();
  }

  @override
  Future<void> signInWithPhonePassword({
    required String phone,
    required String password,
  }) {
    return _dataSource.signInWithPhonePassword(
      phone: phone,
      password: password,
    );
  }

  @override
  Future<void> requestPhoneOtp(String phone) {
    return _dataSource.requestPhoneOtp(phone);
  }

  @override
  Future<void> requestPasswordResetOtp(String phone) {
    return _dataSource.requestPasswordResetOtp(phone);
  }

  @override
  Future<void> signOut() {
    return _dataSource.signOut();
  }

  @override
  Future<void> verifyPhoneOtp({required String phone, required String otp}) {
    return _dataSource.verifyPhoneOtp(phone: phone, otp: otp);
  }

  @override
  Future<void> resetPasswordWithOtp({
    required String phone,
    required String otp,
    required String newPassword,
  }) {
    return _dataSource.resetPasswordWithOtp(
      phone: phone,
      otp: otp,
      newPassword: newPassword,
    );
  }

  @override
  Future<void> updateProfile({
    required String name,
    required String password,
    required String role,
  }) {
    return _dataSource.updateProfile(
      name: name,
      password: password,
      role: role,
    );
  }
}
