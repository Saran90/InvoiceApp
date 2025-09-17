import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:invoice/api/api.dart';
import 'package:invoice/core/aws_upload.dart';
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Invoice',
                    style: TextStyle(fontSize: 27, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Obx(
                        () => Wrap(
                          direction: Axis.horizontal,
                          runSpacing: 10,
                          spacing: 10,
                          children: [
                            ..._controller.images.map(
                              (element) => InkWell(
                                onTap: () {
                                  _controller.selectedImage.value = element;
                                  Get.toNamed(
                                    imageViewRoute,
                                    arguments: _controller.selectedImage.value,
                                  );
                                },
                                child: SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.4,
                                  child: Image.file(element),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Container(
                      height: 150,
                      color: Colors.white,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () async {
                              _controller.isLoading.value = true;
                              var pdf = await _controller.saveToPdf();
                              if (pdf != null) {
                                if (await _checkPermission(context)) {
                                  await _controller.savePdf(context, pdf, true);
                                }
                              }
                              _controller.isLoading.value = false;
                            },
                            child: SizedBox(
                              height: 65,
                              width: 250,
                              child: Stack(
                                children: [
                                  SvgPicture.asset(
                                    'assets/images/ic_button.svg',
                                    height: 65,
                                    width: 250,
                                  ),
                                  Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Finish',
                                      style: TextStyle(
                                        fontSize: 27,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () async {
                              _controller.isLoading.value = true;
                              var pdf = await _controller.saveToPdf();
                              if (pdf != null) {
                                if (await _checkPermission(context)) {
                                  _controller.savePdf(context, pdf, false);
                                }
                              }
                            },
                            child: SizedBox(
                              height: 65,
                              width: 250,
                              child: Stack(
                                children: [
                                  SvgPicture.asset(
                                    'assets/images/ic_button.svg',
                                    height: 65,
                                    width: 250,
                                  ),
                                  Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Finish & New',
                                      style: TextStyle(
                                        fontSize: 27,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Obx(
                () =>
                    _controller.isLoading.value
                        ? Center(
                          child: CircularProgressIndicator(
                            value:
                                _controller
                                    .uploadProgress
                                    .value, // 70% progress
                            backgroundColor: Colors.orange,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.grey,
                            ),
                            color: Colors.red,
                            strokeWidth: 4.0,
                          ),
                        )
                        : const SizedBox(),
              ),
            ],
          ),
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

  void _showMessage(BuildContext context, String message) {
    context.showMessage(message);
  }
}

class IsolateParams {
  ReceivePort receivePort;
  String filePath;
  String presignedUrl;
  String contentType;

  IsolateParams({
    required this.receivePort,
    required this.filePath,
    required this.presignedUrl,
    required this.contentType,
  });
}
