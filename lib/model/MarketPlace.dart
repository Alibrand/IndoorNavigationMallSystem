import 'package:cloud_firestore/cloud_firestore.dart';

class MarketPlace {
  String id;
  String name;
  String category;
  String notes;
  String doc_id;
  int floor;
  GeoPoint location;

  MarketPlace(
      {this.id = "",
      this.name = "",
      this.category = "",
      this.notes = "",
      this.doc_id = "",
      this.floor = 0,
      this.location = const GeoPoint(0, 0)});

  MarketPlace.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        category = json['category'],
        notes = json['notes'],
        location = json['location'],
        doc_id = json['doc_id'],
        floor = json['floor'];

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['category'] = category;
    data['notes'] = notes;
    data['location'] = location;
    data['floor'] = floor;
    data['keywords'] = nameToSearchWords();
    return data;
  }

  List<String> nameToSearchWords() {
    List<String> keyWords = [];
    for (int i = 0; i < name.length; i++) {
      for (int j = i + 1; j <= name.length; j++) {
        if (name.substring(i, j).trim().isEmpty) continue;
        if (keyWords.contains(name.substring(i, j))) continue;
        keyWords.add(name.substring(i, j).trim());
        if (keyWords.contains(name.substring(i, j).toLowerCase())) continue;
        keyWords.add(name.substring(i, j).trim().toLowerCase());
      }
    }
    return keyWords;
  }
}
