class UrlValidResponse {
  num? status;
  num? id;
  String? statusMessage;

  UrlValidResponse({this.status, this.id, this.statusMessage});

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map["Status"] = status;
    map["Id"] = id;
    map["StatusMessage"] = statusMessage;
    return map;
  }

  UrlValidResponse.fromJson(dynamic json){
    status = json["Status"];
    id = json["Id"];
    statusMessage = json["StatusMessage"];
  }
}