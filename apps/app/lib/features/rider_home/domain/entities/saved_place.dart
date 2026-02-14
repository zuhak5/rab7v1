import 'package:equatable/equatable.dart';

class SavedPlaceEntity extends Equatable {
  const SavedPlaceEntity({
    required this.label,
    required this.city,
    required this.addressLine1,
    this.id,
    this.addressLine2,
    this.area,
    this.latitude,
    this.longitude,
    this.isDefault = false,
    this.updatedAt,
  });

  final String? id;
  final String label;
  final String city;
  final String addressLine1;
  final String? addressLine2;
  final String? area;
  final double? latitude;
  final double? longitude;
  final bool isDefault;
  final DateTime? updatedAt;

  SavedPlaceEntity copyWith({
    String? id,
    String? label,
    String? city,
    String? addressLine1,
    String? addressLine2,
    String? area,
    double? latitude,
    double? longitude,
    bool? isDefault,
    DateTime? updatedAt,
  }) {
    return SavedPlaceEntity(
      id: id ?? this.id,
      label: label ?? this.label,
      city: city ?? this.city,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      area: area ?? this.area,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isDefault: isDefault ?? this.isDefault,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    id,
    label,
    city,
    addressLine1,
    addressLine2,
    area,
    latitude,
    longitude,
    isDefault,
    updatedAt,
  ];
}
