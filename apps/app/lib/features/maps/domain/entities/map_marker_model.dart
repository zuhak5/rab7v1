import 'package:equatable/equatable.dart';

class MapMarkerModel extends Equatable {
  const MapMarkerModel({
    required this.id,
    required this.latitude,
    required this.longitude,
    this.title,
    this.subtitle,
  });

  final String id;
  final double latitude;
  final double longitude;
  final String? title;
  final String? subtitle;

  @override
  List<Object?> get props => [id, latitude, longitude, title, subtitle];
}
