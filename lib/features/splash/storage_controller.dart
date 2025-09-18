import 'package:get/get.dart';
import 'package:invoice/features/invoice/models/invoice.dart';

class StorageController extends GetxController {
  RxList<Invoice> invoices = <Invoice>[].obs;

  void addInvoice(Invoice invoice) {
    invoices.add(invoice);
  }
}