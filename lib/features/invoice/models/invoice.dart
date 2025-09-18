class Invoice {
  String? invoiceId;
  String? filePath;
  num? progress;
  String? status;

  Invoice({this.invoiceId, this.filePath, this.progress, this.status});

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map["invoiceId"] = invoiceId;
    map["filePath"] = filePath;
    map["progress"] = progress;
    map["status"] = status;
    return map;
  }

  Invoice.fromJson(dynamic json){
    invoiceId = json["invoiceId"];
    filePath = json["filePath"];
    progress = json["progress"];
    status = json["status"];
  }
}