import 'dart:io';
import 'package:aws_s3_upload_lite/aws_s3_upload_lite.dart';
import 'package:aws_s3_upload_lite/enum/acl.dart';
import 'package:flutter/foundation.dart';
import 'package:invoice/main.dart';

class AwsUpload {
  Future<String> uploadFile({required File file, required Function(int sentBytes, int totalBytes) setUploadProgress}) async {
    return await AwsS3.uploadFile(
      accessKey: 'AKIARVO6ZMZNSLP5T6D5',
      secretKey: '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',
      file: file,
      contentType: 'application/pdf',
      bucket: "zerosnap-storage-invoiceapp",
      region: "ca-central-1",
      destDir: "uploads",
      // The path to upload the file to (e.g. "uploads/public"). Defaults to the root "directory"
      filename: "Invoice-${DateTime.now().millisecondsSinceEpoch}.pdf",
      //The filename to upload as
      onUploadProgress: setUploadProgress,
      useSSL: true,
      headers: {'Content-Type': 'application/pdf'},
      // key: ''
      acl: ACL.bucket_owner_full_control
    );
  }
}
