class LoginResponse {
  String? accessToken;
  String? key;
  String? s3FolderName;
  num? status;
  String? statusMessage;
  dynamic setting;
  String? username;
  String? companyname;
  num? userID;

  LoginResponse(
      {this.accessToken, this.key, this.s3FolderName, this.status, this.statusMessage, this.setting, this.username, this.companyname, this.userID});

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map["access_token"] = accessToken;
    map["key"] = key;
    map["S3FolderName"] = s3FolderName;
    map["Status"] = status;
    map["StatusMessage"] = statusMessage;
    map["setting"] = setting;
    map["username"] = username;
    map["companyname"] = companyname;
    map["User_ID"] = userID;
    return map;
  }

  LoginResponse.fromJson(dynamic json){
    accessToken = json["access_token"];
    key = json["key"];
    s3FolderName = json["S3FolderName"];
    status = json["Status"];
    statusMessage = json["StatusMessage"];
    setting = json["setting"];
    username = json["username"];
    companyname = json["companyname"];
    userID = json["User_ID"];
  }
}