import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:invoice/features/history/history_controller.dart';
import 'package:invoice/main.dart';

import '../../utils/routes.dart';

class HistoryScreen extends StatelessWidget {
  HistoryScreen({super.key});

  final historyController = Get.find<HistoryController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Obx(
            () => Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Center(
                      child: Text(
                        'Invoices',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: IconButton(
                        onPressed: historyController.onBackClicked,
                        icon: Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: historyController.invoices.length,
                    itemBuilder:
                        (context, index) => Container(
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    historyController
                                            .invoices[index]
                                            .invoiceId ??
                                        '',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  historyController.invoices[index].status ==
                                          'progress'
                                      ? CircularProgressIndicator(
                                        value:
                                            historyController
                                                .invoices[index]
                                                .progress
                                                ?.toDouble() ??
                                            0,
                                        backgroundColor: Colors.grey,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.orange,
                                            ),
                                        strokeWidth: 4.0,
                                      )
                                      : historyController
                                              .invoices[index]
                                              .status ==
                                          'failed'
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    historyController.invoices[index].status ??
                                        '',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: getStatusColor(
                                        historyController
                                            .invoices[index]
                                            .status,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  // Obx(
                                  //   () => InkWell(
                                  //     radius: 30,
                                  //     onTap: () {
                                  //       historyController
                                  //           .invoices[index]
                                  //           .isExpanded = !historyController
                                  //               .invoices[index]
                                  //               .isExpanded!;
                                  //     },
                                  //     child: Icon(
                                  //       (historyController
                                  //                   .invoices[index]
                                  //                   .isExpanded ??
                                  //               false)
                                  //           ? Icons.keyboard_arrow_up_outlined
                                  //           : Icons
                                  //               .keyboard_arrow_down_outlined,
                                  //       size: 20,
                                  //     ),
                                  //   ),
                                  // ),
                                ],
                              ),
                            ],
                          ),
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color getStatusColor(String? status) {
    if (status == 'progress') {
      return Colors.orange;
    } else if (status == 'failed') {
      return Colors.red;
    } else if (status == 'success') {
      return Colors.green;
    }
    return Colors.grey;
  }
}
