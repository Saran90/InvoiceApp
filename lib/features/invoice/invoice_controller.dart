import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:invoice/utils/extensions.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:get/get.dart';

import '../../api/api.dart';
import '../../core/aws_upload.dart';
import '../../utils/routes.dart';
import '../camera/models/media_model.dart';
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

  Future<void> savePdf(
    BuildContext context,
    File? pdf,
    bool shouldClose,
  ) async {
    try {
      if (pdf != null) {
        var result = await AwsUpload().uploadFile(
          file: pdf,
          setUploadProgress: _onUploadProgress,
        );
        if (result == '204') {
          if (shouldClose) {
            uploadCompleteAndClose(context);
          } else {
            uploadComplete();
          }
        } else {
          _showMessage(context, 'Upload failed');
        }
      } else {
        _showMessage(context, 'PDF not generated');
      }
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
    images.clear();
    selectedImage.value = null;
    List<MediaModel>? files =
        await Get.toNamed(multiCameraRoute, arguments: {'from': 'invoice'})
            as List<MediaModel>?;
    if (files != null) {
      images.value = files.map((e) => File(e.file.path)).toList();
      selectedImage.value = images.first;
    }
  }

  void uploadCompleteAndClose(BuildContext context) {
    _showMessage(context, 'Uploaded');
    images.clear();
    selectedImage.value = null;
    Get.offAndToNamed(homeRoute);
  }

  void _onUploadProgress(int sentBytes, int totalBytes) {
    uploadProgress.value = (sentBytes / totalBytes);
    print('Progress: ${uploadProgress.value * 100}%');
  }
}
