import 'dart:io';

import 'package:get/get.dart';
import 'package:invoice/features/invoice/models/invoice.dart';
import 'package:stream_isolate/stream_isolate.dart';

import '../invoice/invoice_controller.dart';

class HistoryController extends GetxController {
  RxList<Invoice> invoices = <Invoice>[].obs;

  @override
  void onInit() {
    print('History init');
    invoices.value = [];
    super.onInit();
  }

  void addInvoice(Invoice invoice) {
    invoices.add(invoice);
  }

  void updateInvoice(Invoice invoice, String id) {
    int index = invoices.indexWhere((element) => element.invoiceId == id);
    invoices[index] = invoice;
  }

  Invoice? getInvoice(String id) {
    return invoices.firstWhereOrNull((element) => element.invoiceId == id);
  }

  reUpload(Invoice selectedInvoice) async {
    selectedInvoice.status = 'progress';
    selectedInvoice.progress = 0;
    updateInvoice(selectedInvoice, selectedInvoice.invoiceId!);
    final streamIsolate = await StreamIsolate.spawnWithArgument(
      uploadPdfBackground,
      argument: [selectedInvoice],
    );
    streamIsolate.stream.listen((event) {
      Invoice? invoice = invoices.firstWhereOrNull(
        (element) => element.invoiceId == selectedInvoice.invoiceId,
      );
      if (invoice != null) {
        updateInvoice(event, event.invoiceId!);
      }
    });
  }

  @override
  void dispose() {
    print('History dispose');
    super.dispose();
  }

  void onBackClicked() {
    Get.back();
  }
}
