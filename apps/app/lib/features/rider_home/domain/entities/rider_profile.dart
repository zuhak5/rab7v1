import 'package:equatable/equatable.dart';

class RiderProfileEntity extends Equatable {
  const RiderProfileEntity({
    required this.id,
    this.displayName,
    this.phoneE164,
    this.avatarObjectKey,
    this.avatarUrl,
  });

  final String id;
  final String? displayName;
  final String? phoneE164;
  final String? avatarObjectKey;
  final String? avatarUrl;

  RiderProfileEntity copyWith({
    String? id,
    String? displayName,
    String? phoneE164,
    String? avatarObjectKey,
    String? avatarUrl,
  }) {
    return RiderProfileEntity(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      phoneE164: phoneE164 ?? this.phoneE164,
      avatarObjectKey: avatarObjectKey ?? this.avatarObjectKey,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    id,
    displayName,
    phoneE164,
    avatarObjectKey,
    avatarUrl,
  ];
}
