import 'package:equatable/equatable.dart';

class AuthAppContext extends Equatable {
  const AuthAppContext({
    required this.userId,
    required this.activeRole,
    required this.roleOnboardingCompleted,
    required this.locale,
  });

  final String userId;
  final String activeRole;
  final bool roleOnboardingCompleted;
  final String locale;

  @override
  List<Object?> get props => <Object?>[
    userId,
    activeRole,
    roleOnboardingCompleted,
    locale,
  ];
}
