import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:invoice/api/api.dart';
import 'package:invoice/core/aws_upload.dart';
import 'package:invoice/features/camera/models/media_model.dart';
import 'package:invoice/features/history/history_controller.dart';
import 'package:invoice/utils/extensions.dart';
import 'package:invoice/utils/routes.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../main.dart';
import '../../utils/colors.dart';
import 'invoice_controller.dart';

class InvoiceScreen extends StatelessWidget {
  InvoiceScreen({super.key});

  final _controller = Get.find<InvoiceController>();
  final _historyController = Get.find<HistoryController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 70, right: 5),
        child: Stack(
          children: [
            InkWell(
              onTap: () => Get.toNamed(historyRoute),
              child: Align(
                alignment: Alignment.bottomRight,
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: gradient2,
                  child: Stack(
                    children: [
                      Obx(() {
                        int size =
                            _historyController.invoices
                                .where((p0) => p0.status == 'Uploading')
                                .length;
                        return size > 0
                            ? Center(
                              child: Transform.scale(
                                scale: 1.6,
                                child: CircularProgressIndicator(
                                  color: Color.fromRGBO(0, 123, 255, 1),
                                ),
                              ),
                            )
                            : SizedBox();
                      }),
                      Center(
                        child: Icon(
                          Icons.cloud_upload,
                          size: 30,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Obx(() {
                int size =
                    _historyController.invoices
                        .where((p0) => p0.status == 'Uploading')
                        .length;
                return size != 0
                    ? CircleAvatar(
                      radius: 10,
                      backgroundColor: Colors.red,
                      child: Center(
                        child: Text(
                          '$size',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                    : SizedBox();
              }),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.only(
                  top: 50,
                  left: 10,
                  bottom: 10,
                  right: 20,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [gradient1, gradient2],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Center(
                  child: Text(
                    'Invoice',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 24,
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      Expanded(
                        child: Obx(
                          () => CarouselSlider(
                            options: CarouselOptions(
                              height: double.infinity,
                              enableInfiniteScroll: false,
                            ),
                            items:
                                _controller.images.map((i) {
                                  return Builder(
                                    builder: (BuildContext context) {
                                      return Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        margin: EdgeInsets.symmetric(
                                          horizontal: 5.0,
                                        ),
                                        child: Image.file(i),
                                      );
                                    },
                                  );
                                }).toList(),
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
                              Obx(
                                () => Visibility(
                                  visible: _controller.images.isNotEmpty,
                                  child: InkWell(
                                    onTap: () async {
                                      if (_controller.images.isNotEmpty) {
                                        _controller.isLoading.value = true;
                                        var pdf = await _controller.saveToPdf();
                                        if (pdf != null) {
                                          if (await _checkPermission(context)) {
                                            await _controller.savePdf(pdf);
                                          }
                                        }
                                        _controller.isLoading.value = false;
                                      } else {
                                        _showMessage(
                                          context,
                                          'Please add images',
                                        );
                                      }
                                    },
                                    child: SizedBox(
                                      height: 55,
                                      width: 250,
                                      child: Stack(
                                        children: [
                                          SvgPicture.asset(
                                            'assets/images/ic_button.svg',
                                            height: 55,
                                            width: 250,
                                          ),
                                          Align(
                                            alignment: Alignment.center,
                                            child: Text(
                                              'Finish',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Obx(
                                () => Visibility(
                                  visible: _controller.images.isNotEmpty,
                                  child: InkWell(
                                    onTap: () async {
                                      if (_controller.images.isNotEmpty) {
                                        _controller.isLoading.value = true;
                                        var pdf = await _controller.saveToPdf();
                                        if (pdf != null) {
                                          if (await _checkPermission(context)) {
                                            _controller.savePdfBackground(pdf);
                                          }
                                        }
                                      } else {
                                        _showMessage(
                                          context,
                                          'Please add images',
                                        );
                                      }
                                    },
                                    child: SizedBox(
                                      height: 55,
                                      width: 250,
                                      child: Stack(
                                        children: [
                                          SvgPicture.asset(
                                            'assets/images/ic_button_blue.svg',
                                            height: 55,
                                            width: 250,
                                          ),
                                          Align(
                                            alignment: Alignment.center,
                                            child: Text(
                                              'Finish & New',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Obx(
                                () => Visibility(
                                  visible: _controller.images.isEmpty,
                                  child: InkWell(
                                    onTap: () async {
                                      _controller.uploadComplete();
                                    },
                                    child: Container(
                                      height: 55,
                                      width: 250,
                                      margin: const EdgeInsets.only(top: 20),
                                      child: Stack(
                                        children: [
                                          SvgPicture.asset(
                                            'assets/images/ic_button.svg',
                                            height: 55,
                                            width: 250,
                                          ),
                                          Align(
                                            alignment: Alignment.center,
                                            child: Text(
                                              'Add New',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
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
                        value: _controller.uploadProgress.value,
                        // 70% progress
                        backgroundColor: Colors.grey,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.orange,
                        ),
                        strokeWidth: 4.0,
                      ),
                    )
                    : const SizedBox(),
          ),
        ],
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
