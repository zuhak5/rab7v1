import 'package:equatable/equatable.dart';

class RideRequestEntity extends Equatable {
  const RideRequestEntity({
    required this.id,
    required this.status,
    required this.pickupLat,
    required this.pickupLng,
    required this.dropoffLat,
    required this.dropoffLng,
    required this.createdAt,
    required this.updatedAt,
    this.pickupAddress,
    this.dropoffAddress,
    this.assignedDriverId,
    this.productCode,
    this.fareQuoteId,
  });

  final String id;
  final String status;
  final double pickupLat;
  final double pickupLng;
  final double dropoffLat;
  final double dropoffLng;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? pickupAddress;
  final String? dropoffAddress;
  final String? assignedDriverId;
  final String? productCode;
  final String? fareQuoteId;

  bool get isActive =>
      status == 'requested' || status == 'matched' || status == 'accepted';

  @override
  List<Object?> get props => [
    id,
    status,
    pickupLat,
    pickupLng,
    dropoffLat,
    dropoffLng,
    createdAt,
    updatedAt,
    pickupAddress,
    dropoffAddress,
    assignedDriverId,
    productCode,
    fareQuoteId,
  ];
}
