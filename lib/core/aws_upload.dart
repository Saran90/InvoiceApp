import 'dart:io';
import 'package:aws_s3_upload_lite/aws_s3_upload_lite.dart';
import 'package:aws_s3_upload_lite/enum/acl.dart';
import 'package:invoice/main.dart';

class AwsUpload {
  Future<String> uploadFile({
    required File file,
    required String s3Folder,
    required int userId,
    required Function(int sentBytes, int totalBytes) setUploadProgress,
  }) async {
    print('S3 folder: $s3Folder');
    print('S3 File: ${file.path}');
    return await AwsS3.uploadFile(
      accessKey: 'AKIARVO6ZMZNSLP5T6D5',
      secretKey: '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',
      file: file,
      contentType: 'application/pdf',
      bucket: s3Folder,
      region: "ca-central-1",
      destDir: "uploads",
      // The path to upload the file to (e.g. "uploads/public"). Defaults to the root "directory"
      filename:
          "Invoice-${DateTime.now().millisecondsSinceEpoch}_$userId.pdf",
      //The filename to upload as
      onUploadProgress: setUploadProgress,
      useSSL: true,
      headers: {'Content-Type': 'application/pdf'},
      // key: ''
      acl: ACL.bucket_owner_full_control,
    );
  }
}
