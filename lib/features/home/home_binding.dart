import 'package:get/get.dart';
import 'package:invoice/features/history/history_controller.dart';
import 'package:invoice/features/home/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => HomeController());
  }
}