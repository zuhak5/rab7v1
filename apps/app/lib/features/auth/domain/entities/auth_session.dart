import 'package:equatable/equatable.dart';

class AuthSession extends Equatable {
  const AuthSession({
    required this.userId,
    required this.accessToken,
    required this.expiresAt,
    required this.phone,
  });

  final String userId;
  final String accessToken;
  final DateTime? expiresAt;
  final String? phone;

  @override
  List<Object?> get props => [userId, accessToken, expiresAt, phone];
}
