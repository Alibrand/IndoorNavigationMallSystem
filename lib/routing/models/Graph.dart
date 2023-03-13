import 'dart:convert';

import 'package:collection/collection.dart';
import "package:flutter/material.dart";
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import "package:maps_toolkit/maps_toolkit.dart" as mkit;
import "package:path_provider/path_provider.dart";
import 'package:rachidmallsystem/routing/models/Edge.dart';
import 'package:rachidmallsystem/routing/models/Vertex.dart';
import "package:stack/stack.dart" as stk;

class Graph {
  List<Vertex> vertex = <Vertex>[];
  final double bearing = 218.07952880859375;
  final double minDistance = 2.1;
  final int rows = 60;
  final int columns = 150;
  final LatLng startPosition =
      const LatLng(18.238449514332633, 42.58016601204872);

  void addNewVertex(String id) {
    Vertex v1 = Vertex(id);
    vertex.add(v1);
  }

  void addVertex(String id, double x, double y) {
    Vertex v1 = Vertex.all(id, x, y);
    vertex.add(v1);
  }

  void addEdge(Vertex source, Vertex destination, double weight) {
    source.edges.add(Edge(source, destination, weight));
    destination.edges.add(Edge(destination, source, weight));
  }

  void addEdgeGrid(Vertex source, Vertex destination) {
    double weight = getDistance(source, destination);
    source.edges.add(Edge(source, destination, weight));
  }

  Vertex? getV(double x, double y) {
    for (int i = 0; i < vertex.length; i++) {
      if ((vertex[i].x == x) && (vertex[i].y == y)) {
        return vertex[i];
      }
    }
    return null;
  }

  Vertex? getVById(String id) {
    for (int i = 0; i < vertex.length; i++) {
      if ((vertex[i].id == id)) {
        return vertex[i];
      }
    }
    return null;
  }

  void linkedlist() {
    for (int i = 0; i < vertex.length; i++) {
      for (int j = 0; j < vertex[i].edges.length; j++) {
        debugPrint("=>" + vertex[i].edges[j].destination!.id.toString());
      }
    }
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
      if (isGround && !isInsidePolygon)
        return true;
      else if (isGround && isInsidePolygon || !isGround && !isInsidePolygon)
        continue;
      else
        return true;
    }
    return false;
  }



  Future<String> loadGridFile(int floor) async {
    return await rootBundle.loadString('assets/grids/floor$floor.json');
  }

  Future<void> generateGraphForFloor(polygones, floor) async {
    //Set<Marker> markers = <Marker>{};

    // for (int i = 0; i < rows; i++) {
    //   for (int j = 0; j < columns; j++) {
    //     mkit.LatLng curpostion =
    //         mkit.LatLng(startPosition.latitude, startPosition.longitude);
    //     curpostion = mkit.SphericalUtil.computeOffset(
    //         curpostion, i * minDistance, 132.57440185546875);
    //
    //     mkit.LatLng newposition = mkit.SphericalUtil.computeOffset(
    //         curpostion, j * minDistance, bearing);
    //     LatLng newpo = LatLng(newposition.latitude, newposition.longitude);
    //     if (isInside(newpo, polygones, floor)) continue;
    //     String id = "vi" + i.toString() + "j" + j.toString();
    //     // markers.add(Marker(
    //     //     markerId: MarkerId("mark" + i.toString() + j.toString()),
    //     //     consumeTapEvents: false,
    //     //     position: newpo));
    //     vertex.add(Vertex.all(id, newpo.latitude, newpo.longitude));
    //
    //   }
    // }
    String grid = await loadGridFile(floor);
    Iterable vertexlist = json.decode(grid);
     vertex = List<Vertex>.from(vertexlist.map((v) => Vertex.fromMap(v)));

    generateEdges();
    //return markers;
  }

  void generateEdges() {
    int x1, x2, x3, x4, x5, x6, x7, x8;
    int y1, y2, y3, y4, y5, y6, y7, y8;
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < columns; j++) {
        String id = "vi" + i.toString() + "j" + j.toString();
        var curVertex = getVById(id);
        if (curVertex == null) continue;
        y1 = j - 1;
        x1 = i - 1;
        y2 = j;
        x2 = i - 1;
        y3 = j + 1;
        x3 = i - 1;
        y4 = j - 1;
        x4 = i;
        y5 = j + 1;
        x5 = i;
        y6 = j - 1;
        x6 = i + 1;
        y7 = j;
        x7 = i + 1;
        y8 = j + 1;
        x8 = i + 1;
        String n1vid = "vi" + x1.toString() + "j" + y1.toString();
        String n2vid = "vi" + x2.toString() + "j" + y2.toString();
        String n3vid = "vi" + x3.toString() + "j" + y3.toString();
        String n4vid = "vi" + x4.toString() + "j" + y4.toString();
        String n5vid = "vi" + x5.toString() + "j" + y5.toString();
        String n6vid = "vi" + x6.toString() + "j" + y6.toString();
        String n7vid = "vi" + x7.toString() + "j" + y7.toString();
        String n8vid = "vi" + x8.toString() + "j" + y8.toString();
        var n1v = getVById(n1vid);
        if (n1v != null) {
          addEdgeGrid(curVertex, n1v);
        }
        var n2v = getVById(n2vid);
        if (n2v != null) {
          addEdgeGrid(curVertex, n2v);
        }
        var n3v = getVById(n3vid);
        if (n3v != null) {
          addEdgeGrid(curVertex, n3v);
        }
        var n4v = getVById(n4vid);
        if (n4v != null) {
          addEdgeGrid(curVertex, n4v);
        }
        var n5v = getVById(n5vid);
        if (n5v != null) {
          addEdgeGrid(curVertex, n5v);
        }
        var n6v = getVById(n6vid);
        if (n6v != null) {
          addEdgeGrid(curVertex, n6v);
        }
        var n7v = getVById(n7vid);
        if (n7v != null) {
          addEdgeGrid(curVertex, n7v);
        }
        var n8v = getVById(n8vid);
        if (n8v != null) {
          addEdgeGrid(curVertex, n8v);
        }
      }
    }
  }

  Vertex? getNearestVertex(LatLng position) {
    mkit.LatLng from = mkit.LatLng(position.latitude, position.longitude);
    vertex.sort((v1, v2) {
      mkit.LatLng v1p = mkit.LatLng(v1.x, v1.y);
      var v1distance = mkit.SphericalUtil.computeDistanceBetween(from, v1p);
      mkit.LatLng v2p = mkit.LatLng(v2.x, v2.y);
      var v2distance = mkit.SphericalUtil.computeDistanceBetween(from, v2p);
      return v1distance.compareTo(v2distance);
    });
    return vertex.first;
    // for (int i = 0; i < vertex.length; i++) {
    //   mkit.LatLng to = mkit.LatLng(vertex[i].x, vertex[i].y);
    //   var distance = mkit.SphericalUtil.computeDistanceBetween(from, to);
    //
    //   if ((distance <= 2.5)) {
    //     return vertex[i];
    //   }
    // }
    return null;
  }

  Polyline? getPath(LatLng start, LatLng dest) {

    List<mkit.LatLng> pathPoints = <mkit.LatLng>[];
    var startV = getNearestVertex(start);
    if (startV == null) {
      debugPrint("start not found");
      return null;
    }
    debugPrint("start is " + startV.id);
    var destV = getNearestVertex(dest);
    if (destV == null) {
      debugPrint("dest not found");
      return null;
    }
    debugPrint("end is " + destV.id);
    pathPoints = Astar(startV, destV);
    List<LatLng> polyList = <LatLng>[];
    pathPoints.forEach((element) {
      polyList.add(LatLng(element.latitude, element.longitude));
    });
    return Polyline(
      polylineId: PolylineId("path"),
      visible: true,
      points: polyList,
      color: Colors.red,
    );

  }

  resetAllVertex() {
    vertex.forEach((vertex) {
      vertex.reset();
    });
  }

  List<mkit.LatLng> Astar(Vertex start, Vertex destination) {
    resetAllVertex();
    final path = <LatLng>[];
    String text = "Alg: A*(A star) ";
    //  int startTime = System.nanoTime();
    List<Vertex> CLOSED = <Vertex>[];

    PriorityQueue<Vertex> OPEN =
        PriorityQueue<Vertex>((v1, v2) => v1.compareTo(v2));

    start.d_value = 0;
    start.f_value = 0;
    OPEN.add(start);
    while (OPEN.isNotEmpty) {
      //debugPrint("open size=" + OPEN.length.toString());
      Vertex extracted = OPEN.removeFirst();
      //debugPrint(extracted.toString());
      extracted.discovered = true;
      CLOSED.add(extracted);
      //debugPrint("closed size=" + OPEN.length.toString());
      if (extracted == destination) {
        // debugPrint("dest foubd");
        break;
      }

      for (int i = 0; i < extracted.edges.length; i++) {
        Edge edge = extracted.edges[i];

        Vertex neighbor = edge.destination!;
        // debugPrint("edge " + i.toString() + " is " + neighbor.toString());
        if (neighbor.discovered == false) {
          heuristic(neighbor, destination);
          // debugPrint("check function");
          if (neighbor.f_value > (extracted.f_value + edge.weight!)) {
            //  debugPrint("check function");
            neighbor.d_value = (extracted.d_value + edge.weight!);
            heuristic(neighbor, destination);
            neighbor.f_value = (neighbor.d_value + neighbor.h_value);
            neighbor.parent = extracted;
            OPEN.remove(neighbor);
            OPEN.add(neighbor);
            // debugPrint("open size n=" + OPEN.length.toString());
          }
        }
      }
    }

    //int stopTime = System.nanoTime();
    if (destination.parent == null) {
      text = "This path does not exist";
    } else {
      text += (" Vertex ne CLOSED: " + CLOSED.length.toString());

      stk.Stack<Vertex> stack = stk.Stack();
      Vertex? current = destination;
      text += "\n";
      while (current != null) {
        stack.push(current);
        path.add(LatLng(current.x, current.y));
        current = current.parent ?? null;
      }
    }
    final mtoolPoints = <mkit.LatLng>[];
    path.forEach((element) {
      mtoolPoints.add(mkit.LatLng(element.latitude, element.longitude));
    });
    return mkit.PolygonUtil.simplify(mtoolPoints, 1);
  }

  void heuristic(Vertex v, Vertex destination) {
    mkit.LatLng from = mkit.LatLng(v.x, v.y);
    mkit.LatLng to = mkit.LatLng(destination.x, destination.y);
    v.h_value = mkit.SphericalUtil.computeDistanceBetween(from, to).toDouble();
  }

  double getDistance(Vertex v1, Vertex v2) {
    mkit.LatLng from = mkit.LatLng(v1.x, v1.y);
    mkit.LatLng to = mkit.LatLng(v2.x, v2.y);
    return mkit.SphericalUtil.computeDistanceBetween(from, to).toDouble();
  }
}
