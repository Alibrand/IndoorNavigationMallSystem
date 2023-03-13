import 'Edge.dart';

class Vertex implements Comparable<Vertex> {
  String id = "";
  Vertex? parent = null;
  double d_value = double.infinity;
  List<Edge> edges = <Edge>[];
  bool discovered = false;
  double x = 0.0;
  double y = 0.0;
  double h_value = 0.0;
  double f_value = double.infinity;

  Vertex(String id) {
    this.id = id;
  }

  Vertex.all(String id, double x, double y) {
    this.id = id;
    this.x = x;
    this.y = y;
  }

  Vertex.fromMap(Map<String, dynamic> map)
    :id = map["id"],
    x = map["x"],
    y = map["y"];


  reset() {
    parent = null;
    d_value = double.infinity;
    discovered = false;
    h_value = 0.0;
    f_value = double.infinity;
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    map["id"] = id;
    map["x"] = x;
    map["y"] = y;
    return map;
  }

  @override
  String toString() {
    // TODO: implement toString
    return "vertex is " +
        id +
        ' d=' +
        d_value.toString() +
        " h=" +
        h_value.toString() +
        " f=" +
        f_value.toString() +
        " discovered=" +
        discovered.toString() +
        " edges=" +
        edges.length.toString() +
        "\n parent is " +
        (parent == null ? "null" : parent.toString());
  }

  @override
  int compareTo(Vertex other) {
    return (this.f_value - other.f_value).toInt();
  }
}
