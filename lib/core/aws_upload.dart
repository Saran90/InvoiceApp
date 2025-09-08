import 'dart:io';
import 'package:aws_s3_upload_lite/aws_s3_upload_lite.dart';
import 'package:flutter/foundation.dart';
import 'package:invoice/main.dart';

class AwsUpload {

  Future<String> uploadFile({required File file}) async {
    return await AwsS3.uploadFile(
        accessKey: storage.read('AccessKey'),
        secretKey: storage.read('SecretKey'),
        file: file,
        bucket: "zerosnap-storage-invoiceapp",
        region: "ca-central-1",
        destDir: "", // The path to upload the file to (e.g. "uploads/public"). Defaults to the root "directory"
        filename: "invoice.pdf", //The filename to upload as
        onUploadProgress: setUploadProgress,
        useSSL: true
    );
  }

  void setUploadProgress(int sentBytes, int totalBytes) {
    debugPrint('Upload Progress: ${(sentBytes/totalBytes)*100}');
  }
}