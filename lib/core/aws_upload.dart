import 'dart:io';
import 'package:aws_s3_upload_lite/aws_s3_upload_lite.dart';
import 'package:aws_s3_upload_lite/enum/acl.dart';
import 'package:flutter/foundation.dart';

class AwsUpload {
  final String SECRET_KEY = 'o1jtruGqOd/jWb2+wZoavB2aX/vFBNwemKQdU1I+';
  final String ACCESS_KEY = 'AKIARVO6ZMZNSLP5T6D5';

  Future<String> uploadFile({required File file}) async {
    return await AwsS3.uploadFile(
        accessKey: ACCESS_KEY,
        secretKey: SECRET_KEY,
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