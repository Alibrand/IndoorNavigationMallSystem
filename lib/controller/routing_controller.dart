import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as mkit;
import 'package:rachidmallsystem/controller/base_controller.dart';
import 'package:rachidmallsystem/routing/MapRouter.dart';
import 'package:rachidmallsystem/routing/models/Graph.dart';

class RoutingController extends BaseController {
  late MapRouter router;
  Graph graph = Graph();
  var routeMessage = "Please Wait..".obs;
  var routeMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    router = MapRouter(graph, LatLng(0, 0), LatLng(0, 0), 0, 0);
  }

  Future<Polyline?> drawPathForFloor(source, destination, sourceFloor,
      destinationFloor, markers, polygones, floor) async {
    routeMessage.value = "Please Wait..";
    routeMode.value = true;
    await Future.delayed(const Duration(seconds: 1));
    if (!isInside(source, polygones, floor)) {
      routeMessage.value = "Error: Your not in the mall area";
      return null;
    }
    this.isLoading.value = true;
    await initGraph(polygones, floor);
    initRouter(source, destination, sourceFloor, destinationFloor, markers);
    this.isLoading.value = false;
    return drawPathForCurrentFloor(floor);
  }

  startLoading() {
    this.routeMode.value = true;
  }

  resetRouteMode() {
    this.routeMode.value = false;
  }

  initGraph(polygones, floor) async {
    await graph.generateGraphForFloor(polygones, floor);
  }

  initRouter(source, destination, sourceFloor, destinationFloor, markers) {
    if (!routeMode.value) return;

    router.graph = graph;
    router.source = source;
    router.destination = destination;
    router.sourceFloor = sourceFloor;
    router.destinationFloor = destinationFloor;
    router.currentmarkers = markers;
  }

  Polyline? drawPathForCurrentFloor(selectedFloor) {
    Polyline? path = router.getLocalRoute(selectedFloor);

    routeMessage.value = router.message;
    return path;
  }

  bool isInside(LatLng point, polygones, floor) {
    mkit.LatLng kitPoint = mkit.LatLng(point.latitude, point.longitude);
    List<mkit.LatLng> polyPoints = <mkit.LatLng>[];

    for (Polygon polygon in polygones) {
      polyPoints = <mkit.LatLng>[];
      polygon.points.forEach((element) {
        polyPoints.add(mkit.LatLng(element.latitude, element.longitude));
      });

      bool isGround =
          polygon.polygonId.value.startsWith("f" + floor.toString() + "area");

      bool isInsidePolygon =
          mkit.PolygonUtil.containsLocation(kitPoint, polyPoints, true) ||
              mkit.PolygonUtil.isLocationOnEdge(kitPoint, polyPoints, true);
      if (isGround && isInsidePolygon) return true;
    }
    return false;
  }
}
