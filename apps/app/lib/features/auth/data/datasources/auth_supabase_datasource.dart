import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../data/supabase/schema_contract.dart';
import '../../domain/entities/auth_app_context.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/exceptions/auth_onboarding_exception.dart';

class AuthSupabaseDataSource {
  AuthSupabaseDataSource(this._client);

  final SupabaseClient _client;

  Stream<AuthSession?> onAuthStateChange() {
    return _client.auth.onAuthStateChange.map((event) {
      final session = event.session;
      if (session == null || session.user.id.isEmpty) {
        return null;
      }

      return AuthSession(
        userId: session.user.id,
        accessToken: session.accessToken,
        expiresAt: session.expiresAt == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(
                session.expiresAt! * 1000,
                isUtc: true,
              ),
        phone: session.user.phone,
      );
    });
  }

  AuthSession? currentSession() {
    final session = _client.auth.currentSession;
    if (session == null || session.user.id.isEmpty) {
      return null;
    }

    return AuthSession(
      userId: session.user.id,
      accessToken: session.accessToken,
      expiresAt: session.expiresAt == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(
              session.expiresAt! * 1000,
              isUtc: true,
            ),
      phone: session.user.phone,
    );
  }

  Future<AuthAppContext?> getMyAppContext() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return null;
    }

    final response = await _client.rpc<dynamic>(Rpcs.getMyAppContext);
    final row = _extractContextRow(response);
    if (row == null) {
      return null;
    }

    return AuthAppContext(
      userId: _asString(row['user_id']) ?? user.id,
      activeRole: _asString(row['active_role']) ?? 'rider',
      roleOnboardingCompleted: _asBool(row['role_onboarding_completed']),
      locale: _asString(row['locale']) ?? 'ar',
    );
  }

  Future<void> requestPhoneOtp(String phone) {
    return _client.auth.signInWithOtp(phone: phone);
  }

  Future<void> requestPasswordResetOtp(String phone) {
    return _client.auth.signInWithOtp(phone: phone, shouldCreateUser: false);
  }

  Future<void> signInWithPhonePassword({
    required String phone,
    required String password,
  }) async {
    await _client.auth.signInWithPassword(phone: phone, password: password);
  }

  Future<void> verifyPhoneOtp({required String phone, required String otp}) {
    return _client.auth.verifyOTP(phone: phone, token: otp, type: OtpType.sms);
  }

  Future<void> resetPasswordWithOtp({
    required String phone,
    required String otp,
    required String newPassword,
  }) async {
    await _client.auth.verifyOTP(phone: phone, token: otp, type: OtpType.sms);
    await _client.auth.updateUser(UserAttributes(password: newPassword));
    await _client.auth.signOut();
  }

  Future<void> updateProfile({
    required String name,
    required String password,
    required String role,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw const AuthException('لا توجد جلسة نشطة لإكمال إعداد الملف الشخصي.');
    }

    await _client.auth.updateUser(
      UserAttributes(
        password: password,
        data: <String, dynamic>{'full_name': name, 'role': role},
      ),
    );

    try {
      await _client.rpc<dynamic>(
        Rpcs.setMyActiveRole,
        params: <String, dynamic>{'p_role': role},
      );
    } on PostgrestException catch (error) {
      if (role != 'rider' && _isRoleSetupPending(error)) {
        await _client.auth.updateUser(
          UserAttributes(
            data: <String, dynamic>{
              'requested_role': role,
              'role_activation_pending': true,
            },
          ),
        );
        throw RoleSetupRequiredException(
          role: role,
          backendMessage: error.message,
        );
      }
      rethrow;
    }

    final updated = await _updateProfileOnboarding(
      userId: user.id,
      displayName: name,
    );

    if (!_asBool(updated[ProfileColumns.roleOnboardingCompleted])) {
      throw const OnboardingPersistenceException(
        reason: 'onboarding_not_persisted',
        message:
            'تم حفظ الملف الشخصي لكن علم إكمال الإعداد في الخلفية ما زال غير مفعل.',
        code: 'onboarding_not_persisted',
      );
    }
  }

  Future<void> signOut() {
    return _client.auth.signOut();
  }

  Map<String, dynamic>? _extractContextRow(dynamic response) {
    if (response is List && response.isNotEmpty) {
      final first = response.first;
      if (first is Map<String, dynamic>) {
        return first;
      }
      if (first is Map) {
        return first.cast<String, dynamic>();
      }
    }
    if (response is Map<String, dynamic>) {
      return response;
    }
    if (response is Map) {
      return response.cast<String, dynamic>();
    }
    return null;
  }

  String? _asString(dynamic value) {
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isNotEmpty) {
        return trimmed;
      }
    }
    return null;
  }

  bool _asBool(dynamic value) {
    if (value is bool) {
      return value;
    }
    if (value is num) {
      return value != 0;
    }
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      return normalized == 'true' || normalized == 't' || normalized == '1';
    }
    return false;
  }

  bool _isRoleSetupPending(PostgrestException error) {
    final message = error.message.toLowerCase();
    return message.contains('driver not setup') ||
        message.contains('merchant not setup');
  }

  Future<Map<String, dynamic>> _updateProfileOnboarding({
    required String userId,
    required String displayName,
  }) async {
    try {
      return await _patchProfile(
        userId: userId,
        payload: <String, dynamic>{
          ProfileColumns.displayName: displayName,
          ProfileColumns.roleOnboardingCompleted: true,
        },
      );
    } on PostgrestException catch (error) {
      if (!_isPermissionDenied(error)) {
        rethrow;
      }

      // Some deployments allow onboarding flag updates but deny display_name updates.
      try {
        return await _patchProfile(
          userId: userId,
          payload: <String, dynamic>{
            ProfileColumns.roleOnboardingCompleted: true,
          },
        );
      } on PostgrestException catch (fallbackError) {
        if (!_isPermissionDenied(fallbackError)) {
          rethrow;
        }

        final context = await getMyAppContext();
        if (context?.roleOnboardingCompleted == true) {
          return <String, dynamic>{
            ProfileColumns.id: userId,
            ProfileColumns.roleOnboardingCompleted: true,
          };
        }

        throw const OnboardingPersistenceException(
          reason: 'permission_denied',
          message:
              'الخلفية رفضت تحديث حالة إكمال الإعداد. '
              'يجب السماح للمستخدم الموثق بتحديث profiles.role_onboarding_completed.',
          code: 'onboarding_permission_denied',
        );
      }
    }
  }

  Future<Map<String, dynamic>> _patchProfile({
    required String userId,
    required Map<String, dynamic> payload,
  }) async {
    final updatedRows = await _client
        .from(Tables.profiles)
        .update(payload)
        .eq(ProfileColumns.id, userId)
        .select(
          '${ProfileColumns.id},${ProfileColumns.roleOnboardingCompleted}',
        );

    final updatedRaw = updatedRows.isNotEmpty ? updatedRows.first : null;
    if (updatedRaw is! Map) {
      throw const AppException(
        'Profile setup could not be completed because profile record was not found.',
        code: 'profile_not_found',
      );
    }

    return Map<String, dynamic>.from(updatedRaw as Map<dynamic, dynamic>);
  }

  bool _isPermissionDenied(PostgrestException error) {
    final code = (error.code ?? '').trim();
    final message = error.message.toLowerCase();
    return code == '42501' || message.contains('permission denied');
  }
}
