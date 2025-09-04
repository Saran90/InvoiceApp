import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:get/get.dart';

class InvoiceController extends GetxController {
  RxList<File> images = <File>[].obs;
  Rx<File?> selectedImage = Rx<File?>(null);
  final Completer<PDFViewController> pdfController =
      Completer<PDFViewController>();
  RxInt pages = 0.obs;
  RxInt currentPage = 0.obs;
  RxBool isReady = false.obs;

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
          Rect.fromLTWH(0, 0, pageSize.width, pageSize.height), // Example: fit to page
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
      var outputFileName = 'Invoice';
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
}
