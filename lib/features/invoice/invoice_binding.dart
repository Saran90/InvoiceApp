import 'package:get/get.dart';

import '../history/history_controller.dart';
import 'invoice_controller.dart';

class InvoiceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => InvoiceController());
    Get.lazyPut(() => HistoryController());
  }
}