import 'package:cloud_firestore/cloud_firestore.dart';

class FireUser {
  String id;
  String email;


  FireUser(
      {this.id = "",
        this.email = "",});

  FireUser.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        email = json['email'];

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['email'] = email;
    return data;
  }
}
