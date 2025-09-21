import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:invoice/features/history/history_controller.dart';
import 'package:invoice/main.dart';

import '../../utils/colors.dart';
import '../../utils/routes.dart';

class HistoryScreen extends StatelessWidget {
  HistoryScreen({super.key});

  final historyController = Get.find<HistoryController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(
        () => Column(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [gradient1, gradient2],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              padding: const EdgeInsets.only(left: 10, top: 50, bottom: 10),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Center(
                    child: Text(
                      'Scanned Invoices',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      onPressed: historyController.onBackClicked,
                      icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: ListView.builder(
                  itemCount: historyController.invoices.length,
                  physics: AlwaysScrollableScrollPhysics(),
                  itemBuilder:
                      (context, index) => InkWell(
                        onTap:  () => historyController.toggleListItem(index),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Color.fromRGBO(245, 248, 250, 1),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          margin: const EdgeInsets.only(bottom: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    historyController.invoices[index].invoiceId ??
                                        '',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  historyController.invoices[index].status ==
                                          'Uploading'
                                      ? CircularProgressIndicator(
                                        value:
                                            historyController
                                                .invoices[index]
                                                .progress
                                                ?.toDouble() ??
                                            0,
                                        backgroundColor: Colors.grey,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.orange,
                                        ),
                                        strokeWidth: 2.0,
                                      )
                                      : historyController
                                              .invoices[index]
                                              .status ==
                                          'Failed'
                                      ? IconButton(
                                        onPressed:
                                            () => historyController.reUpload(
                                              historyController.invoices[index],
                                            ),
                                        icon: Icon(Icons.upload, size: 20),
                                      )
                                      : SvgPicture.asset(
                                        'assets/icons/ic_complete.svg',
                                        width: 20,
                                        height: 20,
                                      ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    historyController.invoices[index].status ??
                                        '',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: getStatusColor(
                                        historyController.invoices[index].status,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Obx(
                                    () => InkWell(
                                      radius: 50,
                                      onTap: () {
                                        historyController.toggleListItem(index);
                                      },
                                      child: Icon(
                                        (historyController
                                                    .invoices[index]
                                                    .isExpanded ??
                                                false)
                                            ? Icons.keyboard_arrow_up_outlined
                                            : Icons.keyboard_arrow_down_outlined,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Obx(
                                () => Visibility(
                                  visible:
                                      historyController
                                          .invoices[index]
                                          .isExpanded ??
                                      false,
                                  child: Container(
                                    color: Colors.white,
                                    padding: const EdgeInsets.only(
                                      bottom: 20,
                                    ),
                                    height: 450,
                                    margin: const EdgeInsets.symmetric(vertical: 20),
                                    child: PDFView(
                                      filePath:
                                      historyController
                                          .invoices[index]
                                          .filePath,
                                      enableSwipe: true,
                                      swipeHorizontal: true,
                                      autoSpacing: false,
                                      pageFling: true,
                                      onRender: (_pages) {},
                                      onError: (error) {
                                        print(error.toString());
                                      },
                                      onPageError: (page, error) {
                                        print('$page: ${error.toString()}');
                                      },
                                      onViewCreated:
                                          (
                                          PDFViewController
                                          pdfViewController,
                                          ) {},
                                      onPageChanged: (page, total) {},
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color getStatusColor(String? status) {
    if (status == 'Uploading') {
      return Colors.orange;
    } else if (status == 'Failed') {
      return Colors.red;
    } else if (status == 'Uploaded') {
      return Colors.green;
    }
    return Colors.grey;
  }
}
