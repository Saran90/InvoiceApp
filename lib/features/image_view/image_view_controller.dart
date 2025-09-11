import 'dart:io';

import 'package:get/get.dart';

class ImageViewController extends GetxController {
  Rx<File?> selectedImage = Rx<File?>(null);

  @override
  void onInit() {
    selectedImage.value = Get.arguments as File?;
    super.onInit();
  }

  void onBackClicked() {
    Get.back();
  }
}
