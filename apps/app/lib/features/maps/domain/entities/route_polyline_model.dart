import 'package:equatable/equatable.dart';

class RoutePolylineModel extends Equatable {
  const RoutePolylineModel({required this.id, required this.points});

  final String id;
  final List<LatLngPoint> points;

  @override
  List<Object?> get props => [id, points];
}

class LatLngPoint extends Equatable {
  const LatLngPoint({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;

  @override
  List<Object?> get props => [latitude, longitude];
}
