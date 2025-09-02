import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:get/get.dart';
import 'package:invoice/features/camera/models/media_model.dart';
import 'package:invoice/utils/routes.dart';

import '../camera/widgets/multiple_image_camera.dart';
import 'invoice_controller.dart';

class InvoiceScreen extends StatelessWidget {
  InvoiceScreen({super.key});

  final _controller = Get.find<InvoiceController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Invoice')),
      body: SafeArea(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    List<MediaModel>? files =
                        await Get.toNamed(multiCameraRoute)
                            as List<MediaModel>?;
                    if (files != null) {
                      _controller.images.value =
                          files.map((e) => File(e.file.path)).toList();
                    }
                  },
                  child: Center(child: Text('Start Invoice')),
                ),
                Obx(() => Visibility(
                  visible: _controller.images.isNotEmpty,
                  child: ElevatedButton(
                    onPressed: () async {
                      var pdf = await _controller.saveToPdf();
                      _showPdf(context, pdf);
                    },
                    child: Center(child: Text('Finish')),
                  ),
                ),),
              ],
            ),
            Expanded(
              child: Obx(
                () =>
                    _controller.selectedImage.value != null
                        ? SizedBox(
                          height: double.infinity,
                          width: double.infinity,
                          child: Image.file(_controller.selectedImage.value!),
                        )
                        : SizedBox(),
              ),
            ),
            const SizedBox(height: 20),
            Obx(
              () => SizedBox(
                height: 300,
                child: ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemCount: _controller.images.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        _controller.selectedImage.value =
                            _controller.images[index];
                      },
                      child: SizedBox(
                        height: 300,
                        width: 200,
                        child: Image.file(_controller.images[index]),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPdf(BuildContext context, File? pdf) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (context) => PDFView(
            filePath: pdf?.path,
            enableSwipe: true,
            swipeHorizontal: true,
            autoSpacing: false,
            pageFling: true,
            pageSnap: true,
            defaultPage: _controller.currentPage.value,
            fitPolicy: FitPolicy.BOTH,
            preventLinkNavigation:
            false, // if set to true the link is handled in flutter
            onRender: (_pages) {
              _controller.pages.value = _pages??0;
              _controller.isReady.value = true;
            },
            onError: (error) {
              print(error.toString());
            },
            onPageError: (page, error) {
              print('$page: ${error.toString()}');
            },
            onViewCreated: (PDFViewController pdfViewController) {
              _controller.pdfController.complete(pdfViewController);
            },
            onLinkHandler: (String? uri) {
              print('goto uri: $uri');
            },
            onPageChanged: (int? page, int? total) {
              print('page change: ${page ?? 0 + 1}/$total');
              _controller.currentPage.value = page ?? 0;
            },
          ),
    );
  }
}
