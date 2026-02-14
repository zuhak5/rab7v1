import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../domain/entities/map_marker_model.dart';
import '../../domain/entities/route_polyline_model.dart';

class GoogleMapAdapter {
  Set<Marker> toMarkers(List<MapMarkerModel> markers) {
    return markers
        .map(
          (item) => Marker(
            markerId: MarkerId(item.id),
            position: LatLng(item.latitude, item.longitude),
            infoWindow: InfoWindow(title: item.title, snippet: item.subtitle),
          ),
        )
        .toSet();
  }

  Set<Polyline> toPolylines(List<RoutePolylineModel> polylines) {
    return polylines
        .map(
          (item) => Polyline(
            polylineId: PolylineId(item.id),
            points: item.points
                .map((point) => LatLng(point.latitude, point.longitude))
                .toList(growable: false),
            width: 5,
          ),
        )
        .toSet();
  }
}
