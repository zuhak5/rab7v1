import 'package:equatable/equatable.dart';

class DriverLocationEntity extends Equatable {
  const DriverLocationEntity({
    required this.driverId,
    required this.latitude,
    required this.longitude,
    required this.updatedAt,
    this.heading,
    this.speedMps,
    this.accuracyM,
  });

  final String driverId;
  final double latitude;
  final double longitude;
  final DateTime updatedAt;
  final double? heading;
  final double? speedMps;
  final double? accuracyM;

  @override
  List<Object?> get props => [
    driverId,
    latitude,
    longitude,
    updatedAt,
    heading,
    speedMps,
    accuracyM,
  ];
}
