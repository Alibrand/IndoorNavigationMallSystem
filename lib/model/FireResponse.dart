//an object handles function response
class FireRespone {
  String status;
  String message;
  dynamic data;

  FireRespone({this.status = "Ok", this.message = "", this.data});

  FireRespone.fromJson(Map<String, dynamic> json)
      : status = json['status'],
        message = json['message'],
        data = json['data'];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    data['data'] = data;
    return data;
  }
}
