import '../entities/map_marker_model.dart';
import '../entities/route_polyline_model.dart';

abstract class MapRepository {
  Future<void> ensureInitialized();

  Stream<List<MapMarkerModel>> markers();

  Stream<List<RoutePolylineModel>> polylines();

  Future<void> setMarkers(List<MapMarkerModel> markers);

  Future<void> setPolylines(List<RoutePolylineModel> polylines);
}
