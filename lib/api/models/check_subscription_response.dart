class CheckSubscriptionResponse {
  num? status;
  num? id;
  String? statusMessage;

  CheckSubscriptionResponse({this.status, this.id, this.statusMessage});

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map["Status"] = status;
    map["Id"] = id;
    map["StatusMessage"] = statusMessage;
    return map;
  }

  CheckSubscriptionResponse.fromJson(dynamic json){
    status = json["Status"];
    id = json["Id"];
    statusMessage = json["StatusMessage"];
  }
}