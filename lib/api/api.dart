import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart'; // For SHA256 and HMAC
import 'package:intl/intl.dart'; // For date formatting
import 'package:get/get.dart';
import 'package:invoice/features/invoice/invoice_screen.dart';

import '../main.dart';

class Api extends GetConnect {
  // --- AWS Credentials & S3 Info (STORE SECURELY ON SERVER-SIDE) ---
  String awsAccessKeyId = 'AKIARVO6ZMZNSLP5T6D5';
  String awsSecretAccessKey = 'o1jtruGqOd/jWb2+wZoavB2aX/vFBNwemKQdU1I+';
  String s3BucketName = 'zerosnap-storage-invoiceapp';
  String awsRegion = 'ca-central-1'; // e.g., 'us-east-1'
  String s3Service = 's3';

  Api() {
    httpClient.timeout = Duration(minutes: 5);
  }

  Future<String?> getPresignedUrl(File file, String fileName, String contentType, String action) async {
    try {
      final response = await post('https://exvbngvsie.execute-api.ca-central-1.amazonaws.com/dev/presign',{
        'fileName': fileName,
        'action': 'upload',
        'contentType': contentType,
      });

      if (response.statusCode == 200) {
        print('Presigned URL response: ${response.body['url']}');
        return response.body['url'];
      } else {
        print("❌ Upload failed: ${response.statusCode}");
      }
    }catch(exception) {
      print('Upload Exception: ${exception.toString()}');
    }
    return null;
  }

  Future<bool> uploadFile({required File file}) async {
    try {
      List<int> fileBytes = await file.readAsBytes();
      String base64String = base64Encode(fileBytes);
      var response = await post(
        'https://rug0dnlfpl.execute-api.ca-central-1.amazonaws.com/dev/upload',
        {
          'fileName': 'invoice.pdf',
          'contentType': 'pdf',
          'fileContent': base64String,
        },
      );
      if (response.statusCode == 200) {
        print('File uploaded successfully');
        return true;
      } else {
        print('Error uploading file: ${response.statusText}');
        return false;
      }
    } catch (exception) {
      print('Error uploading file: ${exception.toString()}');
      return false;
    }
  }

  Future<void> uploadWithPresignedUrl(
    File file,
    String presignedUrl,
    String contentType,
  ) async {
    try {
      List<int> fileBytes = await file.readAsBytes();
      final response = await put(
        presignedUrl,
        fileBytes,
        headers: {'Content-Type': contentType},
      );
      if (response.statusCode == 200) {
        print('File uploaded successfully using presigned URL!');
      } else {
        print(
          'Error uploading with presigned URL: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Exception during presigned URL upload: $e');
    }
  }

  Future<void> uploadFileToS3ViaRestApi(
    File fileToUpload,
    String s3ObjectKey,
  ) async {
    final fileBytes = await fileToUpload.readAsBytes();
    final host = '$s3BucketName.s3.$awsRegion.amazonaws.com';
    final canonicalUri =
        s3ObjectKey.isNotEmpty
            ? '/$s3ObjectKey'
            : ''; // Path to the object in the bucket
    final canonicalQueryString = ''; // No query parameters for basic PUT

    final requestDateTime = DateTime.now().toUtc();
    final amzDate = createAmzDate(requestDateTime);
    final dateStamp = createDateStamp(requestDateTime);

    // --- Calculate Payload Hash (SHA256 of the file content) ---
    final payloadHash = sha256.convert(fileBytes).toString();

    // --- Prepare Headers ---
    // Headers need to be sorted alphabetically by header name for canonical headers string
    final Map<String, String> headers = {
      'host': host,
      'x-amz-content-sha256': payloadHash,
      'x-amz-date': amzDate,
      // 'Content-Type': 'application/octet-stream', // Or be more specific, e.g., 'image/jpeg'
      // 'Content-Length': fileBytes.length.toString(), // http package handles this
      // Add other headers as needed, e.g., 'x-amz-acl': 'public-read'
    };

    // Determine Content-Type
    String contentType = 'application/octet-stream'; // Default
    // if (s3ObjectKey.toLowerCase().endsWith('.txt')) {
    //   contentType = 'text/plain';
    // } else if (s3ObjectKey.toLowerCase().endsWith('.jpg') || s3ObjectKey.toLowerCase().endsWith('.jpeg')) {
    //   contentType = 'image/jpeg';
    // } else if (s3ObjectKey.toLowerCase().endsWith('.png')) {
    //   contentType = 'image/png';
    // } else if (s3ObjectKey.toLowerCase().endsWith('.pdf')) {
    contentType = 'application/pdf';
    // }
    headers['Content-Type'] = contentType;

    // --- Create Canonical Headers and Signed Headers string ---
    // Important: Headers must be lowercase and sorted for canonical request.
    // The http package might automatically use lowercase header names.
    final sortedHeaderKeys = headers.keys.toList()..sort();
    String canonicalHeaders = '';
    List<String> signedHeadersList = [];
    for (String key in sortedHeaderKeys) {
      canonicalHeaders += '${key.toLowerCase()}:${headers[key]?.trim()}\n';
      signedHeadersList.add(key.toLowerCase());
    }
    String signedHeadersString = signedHeadersList.join(';');

    // --- Calculate Signature (THIS IS THE COMPLEX PART) ---
    // The `calculateDummySignature` is a placeholder.
    // You would need a full SigV4 implementation here.
    // The actual canonical request string would be:
    // METHOD\n
    // CanonicalURI\n
    // CanonicalQueryString\n
    // CanonicalHeaders\n
    // SignedHeaders\n
    // HexEncode(Hash(RequestPayload))
    String signature = calculateDummySignature(
      'PUT',
      host,
      canonicalUri,
      canonicalQueryString,
      headers,
      payloadHash,
      requestDateTime,
    );

    // --- Construct Authorization Header ---
    final authorizationHeader = buildAuthorizationHeader(
      signature,
      awsAccessKeyId,
      requestDateTime,
      awsRegion,
      s3Service,
      signedHeadersList,
    );
    headers['Authorization'] = authorizationHeader;
    // The http package will set Content-Length automatically.

    final url = Uri.https(host, canonicalUri);

    print('--- Uploading to S3 ---');
    print('URL: $url');
    print('Method: PUT');
    print('Headers:');
    headers.forEach((key, value) {
      print('  $key: $value');
    });
    // print('Body (first 100 bytes): ${fileBytes.sublist(0, fileBytes.length > 100 ? 100 : fileBytes.length)}...');

    try {
      final response = await put(url.toString(), fileBytes, headers: headers);

      print('Response Status Code: ${response.statusCode}');
      print(
        'Response Body: ${response.body}',
      ); // S3 PUT usually returns an empty body on success (200 OK)
      print('Response Headers: ${response.headers}');

      if (response.statusCode == 200) {
        print('File uploaded successfully to s3://$s3BucketName/$s3ObjectKey');
      } else {
        print('Error uploading file:');
        print('${response.body}');
        // Parse XML error response from S3 for more details if available
      }
    } catch (e) {
      print('Exception during HTTP PUT: $e');
    }
  }

  String buildAuthorizationHeader(
    String signature,
    String accessKeyId,
    DateTime requestDateTime,
    String region,
    String service,
    List<String> signedHeaders,
    // List of header names that were included in the canonical request
  ) {
    String credentialScope =
        '${createDateStamp(requestDateTime)}/$region/$service/aws4_request';
    return 'AWS4-HMAC-SHA256 Credential=$accessKeyId/$credentialScope, SignedHeaders=${signedHeaders.join(';')}, Signature=$signature';
  }

  String calculateDummySignature(
    String method,
    String host,
    String canonicalUri,
    String canonicalQueryString,
    Map<String, String> headers,
    String payloadHash,
    DateTime requestDateTime,
  ) {
    // This is NOT a real SigV4 signature calculation.
    // It's just a placeholder.
    String stringToSign = """
AWS4-HMAC-SHA256
${createAmzDate(requestDateTime)}
${createDateStamp(requestDateTime)}/$awsRegion/$s3Service/aws4_request
${sha256.convert(utf8.encode("DummyCanonicalRequest")).toString()}
"""; // The actual canonical request is much more complex

    // Deriving the signing key is also a multi-step process
    // List<int> kDate = Hmac(sha256, utf8.encode("AWS4$awsSecretAccessKey")).convert(utf8.encode(createDateStamp(requestDateTime))).bytes;
    // List<int> kRegion = Hmac(sha256, kDate).convert(utf8.encode(awsRegion)).bytes;
    // List<int> kService = Hmac(sha256, kRegion).convert(utf8.encode(s3Service)).bytes;
    // List<int> kSigning = Hmac(sha256, kService).convert(utf8.encode("aws4_request")).bytes;
    // String signature = Hmac(sha256, kSigning).convert(utf8.encode(stringToSign)).toString();
    // return signature;

    return "dummySignature"; // Replace with actual signature
  }

  String createAmzDate(DateTime dt) {
    // Format: YYYYMMDD'T'HHMMSS'Z'
    return DateFormat("yyyyMMdd'T'HHmmss'Z'").format(dt.toUtc());
  }

  String createDateStamp(DateTime dt) {
    // Format: YYYYMMDD
    return DateFormat('yyyyMMdd').format(dt.toUtc());
  }
}

Future<bool> uploadFileToS3(List<dynamic> args) async {
  try {
    final file = File(args[0]);

    var fileBytes = file.readAsBytesSync();

    final fileSize = file.lengthSync(); // File size in bytes
    print('File size: ${fileSize / (1024 * 1024)} MB'); // Convert to MB

    GetConnect getConnect = GetConnect(timeout: Duration(minutes: 10));
    final response = await getConnect.put(args[1], fileBytes,headers: {
      "Content-Type": args[2],
    },);

    if (response.statusCode == 200) {
      print("✅ Upload successful: ${response.body}");
      return true;
      // args[0].send(true);
    } else {
      print("❌ Upload failed: ${response.statusCode}");
      // args[0].send(false);
      return false;
    }
  }catch(exception) {
    print('Upload Exception: ${exception.toString()}');
    // args[0].send(false);
    return false;
  }
}
