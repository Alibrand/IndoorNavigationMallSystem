import 'package:google_maps_flutter/google_maps_flutter.dart';
import "package:maps_toolkit/maps_toolkit.dart" as mkit;
import 'package:rachidmallsystem/routing/models/Graph.dart';

class MapRouter {
  Graph graph;
  LatLng source;
  LatLng destination;
  int sourceFloor;
  int destinationFloor;
  Set<Marker> currentmarkers = <Marker>{};
  bool routeMode = false;
  String message = "";
  Marker starpointid = Marker(markerId: MarkerId("ghf"));

  MapRouter(this.graph, this.source, this.destination, this.sourceFloor,
      this.destinationFloor);

  converToMktLngLat(LatLng point) {
    return mkit.LatLng(point.latitude, point.longitude);
  }

  Polyline? getLocalRoute(int currentFloor) {
    if (currentFloor > destinationFloor && currentFloor > sourceFloor ||
        currentFloor < destinationFloor && currentFloor < sourceFloor) {
      message = "No route to your destination on this floor ";
      return null;
    }

    if (destinationFloor == sourceFloor) {
      message = "Follow the path on the map to your destination";
      return graph.getPath(source, destination);
    } else if (sourceFloor == currentFloor) {
      List<Marker> stairpoints = currentmarkers
          .where((marker) => marker.markerId.value.startsWith("stairpoint"))
          .toList();
      //order stailr points by distance from source
      stairpoints.sort((s1, s2) {
        var dist1 = mkit.SphericalUtil.computeDistanceBetween(
            converToMktLngLat(source), converToMktLngLat(s1.position));
        var dist2 = mkit.SphericalUtil.computeDistanceBetween(
            converToMktLngLat(source), converToMktLngLat(s2.position));
        return dist1.compareTo(dist2);
      });
      //take the nearest stairpoint as a destination
      LatLng nearestPoint = stairpoints.first.position;
      starpointid = stairpoints.first;
      if (sourceFloor < destinationFloor)
        message =
            "Follow the path on the map to the nearest stair and walk up stair to floor " +
                (currentFloor + 1).toString();
      else
        message =
            "Follow the path on the map to the nearest stair and walk down stair to floor " +
                (currentFloor - 1).toString();

      return graph.getPath(source, nearestPoint);
    } else if (destinationFloor == currentFloor) {
      Marker stairpoint;
      if (currentmarkers.length > 0)
        stairpoint = currentmarkers
            .firstWhere((marker) => marker.markerId == starpointid.markerId);
      else
        stairpoint = starpointid;
      //take the nearest stairpoint as a destination
      LatLng startPoint = stairpoint.position;

      message = "Follow the path on the map to your destination";
      return graph.getPath(startPoint, destination);
    } else {
      if (sourceFloor < destinationFloor)
        message =
            "Take the stairs up to floor " + (currentFloor + 1).toString();
      else
        message =
            "Take the stairs down to floor " + (currentFloor - 1).toString();

      return null;
    }
  }
}
