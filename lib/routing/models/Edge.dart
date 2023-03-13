import 'Vertex.dart';

class Edge {
  Vertex? source = null;
  Vertex? destination = null;
  double? weight = 0.0;
  int isPath = 0;

  Edge(Vertex source, Vertex destination, double weight) {
    this.source = source;
    this.destination = destination;
    this.weight = weight;
  }
}
