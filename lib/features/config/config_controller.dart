import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:invoice/main.dart';
import 'package:invoice/utils/routes.dart';

class ConfigController extends GetxController {
  final baseUrlController = TextEditingController();

  void onSaveClicked() {
    appStorage.setBaseUrl(url: baseUrlController.text);
    Get.offAndToNamed(loginRoute);
  }
}
