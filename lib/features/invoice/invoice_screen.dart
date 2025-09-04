import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:get/get.dart';
import 'package:invoice/features/camera/models/media_model.dart';
import 'package:invoice/utils/extensions.dart';
import 'package:invoice/utils/routes.dart';
import 'package:permission_handler/permission_handler.dart';

import 'invoice_controller.dart';

class InvoiceScreen extends StatelessWidget {
  InvoiceScreen({super.key});

  final _controller = Get.find<InvoiceController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Invoice')),
      floatingActionButton: _controller.images.isEmpty?FloatingActionButton(onPressed: () async {
        List<MediaModel>? files =
            await Get.toNamed(multiCameraRoute) as List<MediaModel>?;
        if (files != null) {
          _controller.images.value =
              files.map((e) => File(e.file.path)).toList();
          _controller.selectedImage.value = _controller.images.first;
        }
      },child: Icon(Icons.add),):null,
      body: SafeArea(
        child: Column(
          children: [
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
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Obx(
                      () => Visibility(
                        visible: _controller.images.isNotEmpty,
                        child: ElevatedButton(
                          onPressed: () async {
                            var pdf = await _controller.saveToPdf();
                            if (pdf != null) {
                              if (await _checkPermission(context)) {
                                await savePdf(pdf);
                                _showMessage(context, 'Pdf saved');
                                _controller.images.clear();
                                _controller.selectedImage.value = null;
                              }
                            }
                            // _showPdf(context, pdf);
                          },
                          child: Center(child: Text('Finish')),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Obx(
                      () => Visibility(
                        visible: _controller.images.isNotEmpty,
                        child: ElevatedButton(
                          onPressed: () async {
                            var pdf = await _controller.saveToPdf();
                            if (pdf != null) {
                              if (await _checkPermission(context)) {
                                await savePdf(pdf);
                                _showMessage(context, 'Pdf saved');
                                _controller.images.clear();
                                _controller.selectedImage.value = null;
                                List<MediaModel>? files =
                                await Get.toNamed(multiCameraRoute) as List<MediaModel>?;
                                if (files != null) {
                                  _controller.images.value =
                                      files.map((e) => File(e.file.path)).toList();
                                  _controller.selectedImage.value = _controller.images.first;
                                }
                              }
                            }
                            // _showPdf(context, pdf);
                          },
                          child: Center(child: Text('Finish and Next')),
                        ),
                      ),
                    ),
                  ),
                ],
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
            preventLinkNavigation: false,
            // if set to true the link is handled in flutter
            onRender: (_pages) {
              _controller.pages.value = _pages ?? 0;
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

  Future<bool> _checkPermission(BuildContext context) async {
    if (Platform.isAndroid) {
      final plugin = DeviceInfoPlugin();
      final android = await plugin.androidInfo;
      if (android.version.sdkInt < 33) {
        if (await Permission.storage.request().isGranted) {
          if (await Permission.manageExternalStorage.request().isGranted) {
            return true;
          } else {
            _showMessage(context, 'Manage storage permission denied');
          }
        } else {
          _showMessage(context, 'Storage permission denied');
        }
      } else {
        if (await Permission.photos.request().isGranted) {
          if (await Permission.manageExternalStorage.request().isGranted) {
            return true;
          } else {
            _showMessage(context, 'Manage storage permission denied');
          }
        } else {
          _showMessage(context, 'Photos permission denied');
        }
      }
    } else if (Platform.isIOS) {
      // Check current status first
      PermissionStatus status = await Permission.photos.status;
      print('Initial photos permission status: $status');

      if (status.isGranted) {
        return true;
      }

      // If not granted, request permission
      if (status.isDenied) {
        status = await Permission.photos.request();
        print('After request photos permission status: $status');

        if (status.isGranted) {
          return true;
        } else if (status.isPermanentlyDenied) {
          _showMessage(
            context,
            'Photos permission permanently denied. Please go to Settings > Privacy & Security > Photos to enable access.',
          );
          // Optionally open app settings
          await openAppSettings();
        } else {
          _showMessage(context, 'Photos permission denied');
        }
      } else if (status.isPermanentlyDenied) {
        _showMessage(
          context,
          'Photos permission permanently denied. Please go to Settings > Privacy & Security > Photos to enable access.',
        );
        await openAppSettings();
      } else if (status.isRestricted) {
        _showMessage(
          context,
          'Photos permission is restricted by device policy',
        );
      }
    }
    return false;
  }

  Future<void> savePdf(File? pdf) async {
    Directory directory = Directory('/storage/emulated/0');
    Directory appDirectory = Directory('${directory.path}/Invoice');
    if (!appDirectory.existsSync()) {
      appDirectory.create(recursive: true);
    }
    String fileName = '${DateTime.now().millisecondsSinceEpoch.toString()}.pdf';
    moveFile(pdf!, '${appDirectory.path}/$fileName');
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
}
