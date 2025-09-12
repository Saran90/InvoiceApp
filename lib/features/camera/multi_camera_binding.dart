import 'package:get/get.dart';

import 'multi_camera_controller.dart';

class MultiCameraBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MultiCameraController());
  }


}