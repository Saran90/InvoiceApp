import 'package:get/get.dart';

import 'image_view_controller.dart';

class ImageViewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ImageViewController());
  }
}