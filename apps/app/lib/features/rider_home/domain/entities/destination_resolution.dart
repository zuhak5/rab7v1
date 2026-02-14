import 'package:equatable/equatable.dart';

class DestinationResolutionEntity extends Equatable {
  const DestinationResolutionEntity({
    required this.label,
    required this.latitude,
    required this.longitude,
    this.secondary,
  });

  final String label;
  final double latitude;
  final double longitude;
  final String? secondary;

  @override
  List<Object?> get props => <Object?>[label, latitude, longitude, secondary];
}
