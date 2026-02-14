import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/map_marker_model.dart';
import '../../domain/entities/route_polyline_model.dart';
import '../../domain/repositories/map_repository.dart';

final mapRepositoryProvider = Provider<MapRepository>((ref) {
  return MapRepositoryImpl();
});

class MapRepositoryImpl implements MapRepository {
  final _markersController = StreamController<List<MapMarkerModel>>.broadcast();
  final _polylinesController =
      StreamController<List<RoutePolylineModel>>.broadcast();

  List<MapMarkerModel> _markers = const [];
  List<RoutePolylineModel> _polylines = const [];

  @override
  Future<void> ensureInitialized() async {
    _markersController.add(_markers);
    _polylinesController.add(_polylines);
  }

  @override
  Stream<List<MapMarkerModel>> markers() => _markersController.stream;

  @override
  Stream<List<RoutePolylineModel>> polylines() => _polylinesController.stream;

  @override
  Future<void> setMarkers(List<MapMarkerModel> markers) async {
    _markers = List<MapMarkerModel>.unmodifiable(markers);
    _markersController.add(_markers);
  }

  @override
  Future<void> setPolylines(List<RoutePolylineModel> polylines) async {
    _polylines = List<RoutePolylineModel>.unmodifiable(polylines);
    _polylinesController.add(_polylines);
  }
}
