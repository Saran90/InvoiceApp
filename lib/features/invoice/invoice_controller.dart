import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:get_storage/get_storage.dart';
import 'package:invoice/features/invoice/models/invoice.dart';
import 'package:invoice/main.dart';
import 'package:invoice/utils/extensions.dart';
import 'package:path_provider/path_provider.dart';
import 'package:stream_isolate/stream_isolate.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:get/get.dart';

import '../../api/api.dart';
import '../../api/error_response.dart';
import '../../core/aws_upload.dart';
import '../../data/app_storage.dart';
import '../../data/error/failures.dart';
import '../../utils/messages.dart';
import '../../utils/routes.dart';
import '../camera/models/media_model.dart';
import '../history/history_controller.dart';
import '../splash/storage_controller.dart';
import 'invoice_screen.dart';

class InvoiceController extends GetxController {
  RxList<File> images = <File>[].obs;
  Rx<File?> selectedImage = Rx<File?>(null);
  final Completer<PDFViewController> pdfController =
      Completer<PDFViewController>();
  RxInt pages = 0.obs;
  RxInt currentPage = 0.obs;
  RxBool isReady = false.obs;
  RxBool isLoading = false.obs;
  RxDouble uploadProgress = 0.0.obs;
  final _historyController = Get.find<HistoryController>();
  final Api api = Api(baseUrl: appStorage.getBaseUrl() ?? '');

  @override
  void onInit() {
    List<MediaModel>? files = Get.arguments as List<MediaModel>?;
    if (files != null) {
      images.value = files.map((e) => File(e.file.path)).toList();
      selectedImage.value = images.first;
    }
    super.onInit();
  }

  Future<File?> saveToPdf() async {
    if (images.isEmpty) {
      debugPrint("No images provided to convert.");
      return null;
    }

    //Create a new PDF document
    PdfDocument document = PdfDocument();

    for (var imageFile in images) {
      try {
        final List<int> imageBytes = await imageFile.readAsBytes();
        //Load the image using PdfBitmap object
        final PdfImage image = PdfBitmap(imageBytes);
        //Add a new page and draw the image
        // document.pages.add().graphics.drawImage(
        //   image,
        //   Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
        // );
        // You might want to scale the image to fit the page:
        final PdfPage page = document.pages.add();
        final Size pageSize = page.getClientSize();
        page.graphics.drawImage(
          image,
          Rect.fromLTWH(
            0,
            0,
            pageSize.width,
            pageSize.height,
          ), // Example: fit to page
        );
      } catch (e) {
        debugPrint(
          "Error processing image ${imageFile.path} with Syncfusion: $e",
        );
      }
    }

    try {
      //Save the document
      final List<int> bytes = await document.save();
      //Dispose the document
      document.dispose();

      //Get the temporary directory.
      var outputFileName = 'invoice';
      final directory = await getTemporaryDirectory();
      final path = directory.path;
      final file = File('$path/$outputFileName.pdf');
      await file.writeAsBytes(bytes, flush: true);
      debugPrint("Syncfusion PDF saved to: ${file.path}");
      return file;
    } catch (e) {
      debugPrint("Error saving Syncfusion PDF: $e");
      return null;
    }
  }

  Future<void> savePdfBackground(File? pdf) async {
    try {
      if (pdf != null) {
        String id = DateTime.timestamp().millisecondsSinceEpoch.toString();
        Invoice invoice = Invoice(
          invoiceId: id,
          filePath: pdf.path,
          status: 'Uploading',
          progress: 0,
        );
        String s3Bucket = appStorage.getS3Folder()??'';
        int userId = appStorage.getUserId()??0;
        _historyController.addInvoice(invoice);
        final streamIsolate = await StreamIsolate.spawnWithArgument(
          uploadPdfBackground,
          argument: [invoice, s3Bucket, userId],
        );
        uploadComplete();
        streamIsolate.stream.listen((event) {
          Invoice? invoice = _historyController.invoices.firstWhereOrNull(
            (element) => element.invoiceId == event.invoiceId,
          );
          if (invoice == null) {
            _historyController.addInvoice(event);
          } else {
            _historyController.updateInvoice(event, event.invoiceId!);
          }
        });
        // await for (final i in streamIsolate.stream) {
        //   print(i);
        //   streamIsolate.send('received');
        // }
        // receivePort.listen((message) {
        //   print('Result from isolate: $message');
        //   var invoice = message as Invoice?;
        //   if(invoice != null) {
        //     // _historyController.addInvoice(invoice);
        //     print('Invoices final: ${_historyController.invoices.length}');
        //     receivePort.close();
        //     uploadComplete();
        //   }
        // });
      } else {
        _showMessage(Get.context!, 'PDF not generated');
      }
      isLoading.value = false;
    } catch (exception) {
      debugPrint('Exception: ${exception.toString()}');
      isLoading.value = false;
    }
  }

  Future<void> savePdf(File? pdf) async {
    try {
      if (pdf != null) {
        var result = await uploadPdf(pdf);
        if (result == '204') {
          uploadCompleteAndClose(Get.context!);
        } else {
          _showMessage(Get.context!, 'Upload failed');
        }
      } else {
        _showMessage(Get.context!, 'PDF not generated');
      }
      isLoading.value = false;
    } catch (exception) {
      debugPrint('Exception: ${exception.toString()}');
      isLoading.value = false;
    }
  }

  Future<File> moveFile(File sourceFile, String newPath) async {
    try {
      // prefer using rename as it is probably faster
      return await sourceFile.rename(newPath);
    } on FileSystemException catch (e) {
      // if rename fails, copy the source file and then delete it
      final newFile = await sourceFile.copy(newPath);
      await sourceFile.delete();
      return newFile;
    }
  }

  void _showMessage(BuildContext context, String message) {
    context.showMessage(message);
  }

  Future<void> uploadComplete() async {
    images.value = [];
    selectedImage.value = null;
    checkSubscription();
  }

  void uploadCompleteAndClose(BuildContext context) {
    _showMessage(context, 'Uploaded');
    images.value = [];
    selectedImage.value = null;
    Get.offAndToNamed(homeRoute);
  }

  Future<String> uploadPdf(File pdf) async {
    int userId = appStorage.getUserId()??0;
    var result = await AwsUpload().uploadFile(
      file: pdf,
      userId: userId,
      s3Folder: appStorage.getS3Folder()??'',
      setUploadProgress: (sentBytes, totalBytes) {
        uploadProgress.value = (sentBytes / totalBytes);
        print('Progress: ${uploadProgress.value * 100}%');
      },
    );
    return result;
  }

  Future<void> checkSubscription() async {
    isLoading.value = true;
    var result = await api.checkSubscription();
    result.fold(
          (l) {
        if (l is APIFailure) {
          ErrorResponse? errorResponse = l.error;
          Get.context!.showMessage(errorResponse?.message ?? apiFailureMessage);
        } else if (l is ServerFailure) {
          Get.context!.showMessage(l.message ?? serverFailureMessage);
        } else if (l is NetworkFailure) {
          Get.context!.showMessage(networkFailureMessage);
        } else {
          Get.context!.showMessage(unknownFailureMessage);
        }
        isLoading.value = false;
      },
          (r) async {
        if (r?.status == 1) {
          isLoading.value = false;
          List<MediaModel>? files =
          await Get.toNamed(multiCameraRoute, arguments: {'from': 'invoice'})
          as List<MediaModel>?;
          print('Invoices: ${_historyController.invoices.length}');
          if (files != null) {
            images.value = files.map((e) => File(e.file.path)).toList();
            selectedImage.value = images.first;
          }
        } else {
          isLoading.value = false;
          Get.context!.showMessage(r?.statusMessage ?? 'Please subscribe');
        }
      },
    );
  }
}

Stream<Invoice> uploadPdfBackground(List<dynamic> values) async* {
  Invoice? invoice = values[0];
  String s3Bucket = values[1];
  int userId = values[2];
  if(invoice != null) {
    var result = await AwsUpload().uploadFile(
      file: File(invoice.filePath ?? ''),
      s3Folder: s3Bucket,
      userId: userId,
      setUploadProgress: (sentBytes, totalBytes) async* {
        double uploadProgress = (sentBytes / totalBytes);
        invoice.progress = uploadProgress * 100;
        yield invoice;
        print('Progress: ${uploadProgress * 100}%');
      },
    );
    if (result == '204') {
      print('Invoice uploaded');
      invoice.status = 'Uploaded';
    } else {
      print('Invoice upload failed: $result');
      invoice.status = 'Failed';
    }
    yield invoice;
  }
}
