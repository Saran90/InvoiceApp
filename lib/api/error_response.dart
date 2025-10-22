class ErrorResponse {
  String? message;

  ErrorResponse({this.message});

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map["message"] = message;
    return map;
  }

  ErrorResponse.fromJson(dynamic json){
    message = json["message"];
  }
}