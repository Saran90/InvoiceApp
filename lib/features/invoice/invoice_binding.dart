import 'package:get/get.dart';

import 'invoice_controller.dart';

class InvoiceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => InvoiceController());
  }
}