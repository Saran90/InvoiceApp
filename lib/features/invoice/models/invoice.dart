class Invoice {
  String? invoiceId;
  String? filePath;
  num? progress;
  String? status;
  bool? isExpanded;

  Invoice({
    this.invoiceId,
    this.filePath,
    this.progress,
    this.status,
    this.isExpanded = false,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map["invoiceId"] = invoiceId;
    map["filePath"] = filePath;
    map["progress"] = progress;
    map["status"] = status;
    map["isExpanded"] = isExpanded;
    return map;
  }

  Invoice.fromJson(dynamic json) {
    invoiceId = json["invoiceId"];
    filePath = json["filePath"];
    progress = json["progress"];
    status = json["status"];
    isExpanded = json["isExpanded"];
  }
}
