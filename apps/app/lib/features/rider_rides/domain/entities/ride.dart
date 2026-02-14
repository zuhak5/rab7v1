import 'package:equatable/equatable.dart';

class RideEntity extends Equatable {
  const RideEntity({
    required this.id,
    required this.requestId,
    required this.status,
    required this.version,
    required this.updatedAt,
    this.driverId,
    this.fareAmountIqd,
    this.currency,
  });

  final String id;
  final String requestId;
  final String status;
  final int version;
  final DateTime updatedAt;
  final String? driverId;
  final int? fareAmountIqd;
  final String? currency;

  @override
  List<Object?> get props => [
    id,
    requestId,
    status,
    version,
    updatedAt,
    driverId,
    fareAmountIqd,
    currency,
  ];
}
